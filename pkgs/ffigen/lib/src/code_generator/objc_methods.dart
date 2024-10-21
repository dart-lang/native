// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';

import 'package:logging/logging.dart';

import '../code_generator.dart';
import '../visitor/ast.dart';

import 'utils.dart';
import 'writer.dart';

final _logger = Logger('ffigen.code_generator.objc_methods');

mixin ObjCMethods {
  final _methods = <String, ObjCMethod>{};
  final _order = <String>[];

  Iterable<ObjCMethod> get methods =>
      _order.map((name) => _methods[name]).nonNulls;
  ObjCMethod? getMethod(String name) => _methods[name];

  String get originalName;
  String get name;
  ObjCBuiltInFunctions get builtInFunctions;

  void addMethod(ObjCMethod method) {
    if (_shouldIncludeMethod(method)) {
      final oldMethod = getMethod(method.originalName);
      if (oldMethod != null) {
        _methods[method.originalName] = _maybeReplaceMethod(oldMethod, method);
      } else {
        _methods[method.originalName] = method;
        _order.add(method.originalName);
      }
    }
  }

  void visitMethods(Visitor visitor) {
    visitor.visitAll(_methods.values);
  }

  ObjCMethod _maybeReplaceMethod(ObjCMethod oldMethod, ObjCMethod newMethod) {
    // Typically we ignore duplicate methods. However, property setters and
    // getters are duplicated in the AST. One copy is marked with
    // ObjCMethodKind.propertyGetter/Setter. The other copy is missing
    // important information, and is a plain old instanceMethod. So if the
    // existing method is an instanceMethod, and the new one is a property,
    // override it.
    if (newMethod.isProperty && !oldMethod.isProperty) {
      return newMethod;
    } else if (!newMethod.isProperty && oldMethod.isProperty) {
      // Don't override, but also skip the same method check below.
      return oldMethod;
    }

    // Check the duplicate is the same method.
    if (!newMethod.sameAs(oldMethod)) {
      _logger.severe('Duplicate methods with different signatures: '
          '$originalName.${newMethod.originalName}');
      return newMethod;
    }

    // There's a bug in some Apple APIs where an init method that should return
    // instancetype has a duplicate definition that instead returns id. In that
    // case, use the one that returns instancetype. Note that since instancetype
    // is an alias of id, the sameAs check above passes.
    if (ObjCBuiltInFunctions.isInstanceType(newMethod.returnType) &&
        !ObjCBuiltInFunctions.isInstanceType(oldMethod.returnType)) {
      return newMethod;
    } else if (!ObjCBuiltInFunctions.isInstanceType(newMethod.returnType) &&
        ObjCBuiltInFunctions.isInstanceType(oldMethod.returnType)) {
      return oldMethod;
    }

    return newMethod;
  }

  bool _shouldIncludeMethod(ObjCMethod method) =>
      method.childTypes.every((Type t) {
        t = t.typealiasType.baseType;

        // Ignore methods with block args or rets when we're generating in
        // package:objective_c.
        // TODO(https://github.com/dart-lang/native/issues/1180): Remove this.
        if (builtInFunctions.generateForPackageObjectiveC && t is ObjCBlock) {
          return false;
        }

        return true;
      });

  UniqueNamer createMethodRenamer(Writer w) => UniqueNamer(
      {name, 'pointer', 'toString', 'hashCode', 'runtimeType', 'noSuchMethod'},
      parent: w.topLevelUniqueNamer);

  void sortMethods() => _order.sort();
}

enum ObjCMethodKind {
  method,
  propertyGetter,
  propertySetter,
}

enum ObjCMethodOwnership {
  retained,
  notRetained,
  autoreleased,
}

// In ObjC, the name of a method affects its ref counting semantics. See
// https://clang.llvm.org/docs/AutomaticReferenceCounting.html#method-families
enum ObjCMethodFamily {
  alloc('alloc', returnsRetained: true, consumesSelf: false),
  init('init', returnsRetained: true, consumesSelf: true),
  new_('new', returnsRetained: true, consumesSelf: false),
  copy('copy', returnsRetained: true, consumesSelf: false),
  mutableCopy('mutableCopy', returnsRetained: true, consumesSelf: false);

  final String name;
  final bool returnsRetained;
  final bool consumesSelf;

  const ObjCMethodFamily(this.name,
      {required this.returnsRetained, required this.consumesSelf});

  static ObjCMethodFamily? parse(String methodName) {
    final name = methodName.substring(_findFamilyStart(methodName));
    for (final family in ObjCMethodFamily.values) {
      if (_matchesFamily(name, family.name)) return family;
    }
    return null;
  }

  static int _findFamilyStart(String methodName) {
    for (var i = 0; i < methodName.length; ++i) {
      if (methodName[i] != '_') return i;
    }
    return methodName.length;
  }

  static final _lowerCase = RegExp('[a-z]');
  static bool _matchesFamily(String name, String familyName) {
    if (!name.startsWith(familyName)) return false;
    final tail = name.substring(familyName.length);
    return !tail.startsWith(_lowerCase);
  }
}

class ObjCProperty extends AstNode {
  final String originalName;
  final String name;
  String? dartName;

  ObjCProperty({required this.originalName, required this.name});
}

class ObjCMethod extends AstNode {
  final ObjCBuiltInFunctions builtInFunctions;
  final String? dartDoc;
  final String originalName;
  final String name;
  final ObjCProperty? property;
  Type returnType;
  final List<Parameter> params;
  final ObjCMethodKind kind;
  final bool isClassMethod;
  final bool isOptional;
  ObjCMethodOwnership? ownershipAttribute;
  final ObjCMethodFamily? family;
  bool consumesSelfAttribute = false;
  ObjCInternalGlobal selObject;
  ObjCMsgSendFunc? msgSend;
  ObjCBlock? protocolBlock;

  @override
  void visitChildren(Visitor visitor) {
    super.visitChildren(visitor);
    visitor.visit(property);
    visitor.visit(returnType);
    visitor.visitAll(params);
    visitor.visit(selObject);
    visitor.visit(msgSend);
    visitor.visit(protocolBlock);
  }

  ObjCMethod({
    required this.builtInFunctions,
    required this.originalName,
    required this.name,
    this.property,
    this.dartDoc,
    required this.kind,
    required this.isClassMethod,
    required this.isOptional,
    required this.returnType,
    required this.family,
    List<Parameter>? params_,
  })  : params = params_ ?? [],
        selObject = builtInFunctions.getSelObject(originalName);

  bool get isProperty =>
      kind == ObjCMethodKind.propertyGetter ||
      kind == ObjCMethodKind.propertySetter;
  bool get isRequired => !isOptional;
  bool get isInstanceMethod => !isClassMethod;

  void fillMsgSend() {
    msgSend ??= builtInFunctions.getMsgSendFunc(returnType, params);
  }

  void fillProtocolBlock() {
    protocolBlock ??= ObjCBlock(
      returnType: returnType,
      params: [
        // First arg of the protocol block is a void pointer that we ignore.
        Parameter(
          name: '_',
          type: PointerType(voidType),
          objCConsumed: false,
        ),
        ...params,
      ],
      returnsRetained: returnsRetained,
      builtInFunctions: builtInFunctions,
    );
  }

  String getDartMethodName(UniqueNamer uniqueNamer) {
    if (property != null) {
      // A getter and a setter are allowed to have the same name, so we can't
      // just run the name through uniqueNamer. Instead they need to share
      // the dartName, which is run through uniqueNamer.
      if (property!.dartName == null) {
        property!.dartName = uniqueNamer.makeUnique(property!.name);
      }
      return property!.dartName!;
    }
    // Objective C methods can look like:
    // foo
    // foo:
    // foo:someArgName:
    // So replace all ':' with '_'.
    return uniqueNamer.makeUnique(name.replaceAll(':', '_'));
  }

  bool sameAs(ObjCMethod other) {
    if (originalName != other.originalName) return false;
    if (kind != other.kind) return false;
    if (isClassMethod != other.isClassMethod) return false;
    if (isOptional != other.isOptional) return false;
    // msgSend is deduped by signature, so this check covers the signature.
    return msgSend == other.msgSend;
  }

  bool get returnsRetained {
    if (ownershipAttribute != null) {
      return ownershipAttribute == ObjCMethodOwnership.retained;
    }
    return family?.returnsRetained ?? false;
  }

  bool get consumesSelf =>
      consumesSelfAttribute || (family?.consumesSelf ?? false);

  Iterable<Type> get childTypes sync* {
    yield returnType;
    for (final p in params) {
      yield p.type;
    }
  }

  @override
  String toString() => '${isOptional ? '@optional ' : ''}$returnType '
      '$originalName(${params.join(', ')})';
}
