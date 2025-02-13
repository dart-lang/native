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
  Map<String, ObjCMethod> _methods = <String, ObjCMethod>{};
  List<String> _order = <String>[];

  Iterable<ObjCMethod> get methods =>
      _order.map((key) => _methods[key]).nonNulls;
  ObjCMethod? getSimilarMethod(ObjCMethod method) => _methods[method.key];

  String get originalName;
  String get name;
  ObjCBuiltInFunctions get builtInFunctions;

  void addMethod(ObjCMethod? method) {
    if (method == null) return;
    if (_shouldIncludeMethod(method)) {
      final oldMethod = getSimilarMethod(method);
      if (oldMethod != null) {
        _methods[method.key] = _maybeReplaceMethod(oldMethod, method);
      } else {
        _methods[method.key] = method;
        _order.add(method.key);
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

    // If one of the methods is optional, and the other is required, keep the
    // required one.
    if (newMethod.isOptional && !oldMethod.isOptional) {
      return oldMethod;
    } else if (!newMethod.isOptional && oldMethod.isOptional) {
      return newMethod;
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

  void filterMethods(bool Function(ObjCMethod method) predicate) {
    final newOrder = <String>[];
    final newMethods = <String, ObjCMethod>{};
    for (final key in _order) {
      final method = _methods[key];
      if (method != null && predicate(method)) {
        newMethods[key] = method;
        newOrder.add(key);
      }
    }
    _order = newOrder;
    _methods = newMethods;
  }

  String generateMethodBindings(Writer w, ObjCInterface target) {
    final methodNamer = createMethodRenamer(w);
    return [
      for (final m in methods) m.generateBindings(w, target, methodNamer),
    ].join('\n');
  }
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
  ObjCMethodKind kind;
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

  String getDartMethodName(UniqueNamer uniqueNamer,
      {bool usePropertyNaming = true}) {
    if (property != null && usePropertyNaming) {
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

  // Key used to dedupe methods in [ObjCMethods]. ObjC is similar to Dart in
  // that it doesn't have method overloading, so the [originalName] is mostly
  // sufficient as the key. But unlike Dart, ObjC can have static methods and
  // instance methods with the same name, so we have to include staticness in
  // the key.
  String get key => '${isClassMethod ? '+' : '-'}$originalName';

  @override
  String toString() => '${isOptional ? '@optional ' : ''}$returnType '
      '$originalName(${params.join(', ')})';

  bool get returnsInstanceType {
    if (returnType is ObjCInstanceType) return true;
    final baseType = returnType.typealiasType;
    if (baseType is ObjCNullable && baseType.child is ObjCInstanceType) {
      return true;
    }
    return false;
  }

  String _getConvertedReturnType(Writer w, String instanceType) {
    if (returnType is ObjCInstanceType) return instanceType;
    final baseType = returnType.typealiasType;
    if (baseType is ObjCNullable && baseType.child is ObjCInstanceType) {
      return '$instanceType?';
    }
    return returnType.getDartType(w);
  }

  String generateBindings(
      Writer w, ObjCInterface target, UniqueNamer methodNamer) {
    final methodName = getDartMethodName(methodNamer);
    final upperName = methodName[0].toUpperCase() + methodName.substring(1);
    final s = StringBuffer();

    final targetType = target.getDartType(w);
    final returnTypeStr = _getConvertedReturnType(w, targetType);
    final paramStr = <String>[
      for (final p in params)
        '${p.isCovariant ? 'covariant ' : ''}'
            '${p.type.getDartType(w)} ${p.name}',
    ].join(', ');

    // The method declaration.
    s.write('\n  ${makeDartDoc(dartDoc)}  ');
    late String targetStr;
    if (isClassMethod) {
      targetStr = target.classObject.name;
      switch (kind) {
        case ObjCMethodKind.method:
          s.write('static $returnTypeStr $methodName($paramStr)');
          break;
        case ObjCMethodKind.propertyGetter:
          s.write('static $returnTypeStr get$upperName($paramStr)');
          break;
        case ObjCMethodKind.propertySetter:
          s.write('static $returnTypeStr set$upperName($paramStr)');
          break;
      }
    } else {
      targetStr = target.convertDartTypeToFfiDartType(
        w,
        'this',
        objCRetain: consumesSelf,
        objCAutorelease: false,
      );
      switch (kind) {
        case ObjCMethodKind.method:
          s.write('$returnTypeStr $methodName($paramStr)');
          break;
        case ObjCMethodKind.propertyGetter:
          s.write('$returnTypeStr get $methodName');
          break;
        case ObjCMethodKind.propertySetter:
          s.write('set $methodName($paramStr)');
          break;
      }
    }
    s.write(' {\n');

    // Implementation.
    final sel = selObject.name;
    if (isOptional) {
      s.write('''
    if (!${ObjCBuiltInFunctions.respondsToSelector.gen(w)}($targetStr, $sel)) {
      throw ${ObjCBuiltInFunctions.unimplementedOptionalMethodException.gen(w)}(
          '${target.originalName}', '$originalName');
    }
''');
    }
    final convertReturn = kind != ObjCMethodKind.propertySetter &&
        !returnType.sameDartAndFfiDartType;

    final msgSendParams = params.map((p) => p.type.convertDartTypeToFfiDartType(
          w,
          p.name,
          objCRetain: p.objCConsumed,
          objCAutorelease: false,
        ));
    if (msgSend!.isStret) {
      assert(!convertReturn);
      final calloc = '${w.ffiPkgLibraryPrefix}.calloc';
      final sizeOf = '${w.ffiLibraryPrefix}.sizeOf';
      final uint8Type = NativeType(SupportedNativeType.uint8).getCType(w);
      final invoke = msgSend!
          .invoke(w, targetStr, sel, msgSendParams, structRetPtr: '_ptr');
      s.write('''
    final _ptr = $calloc<$returnTypeStr>();
    $invoke;
    final _finalizable = _ptr.cast<$uint8Type>().asTypedList(
        $sizeOf<$returnTypeStr>(), finalizer: $calloc.nativeFree);
    return ${w.ffiLibraryPrefix}.Struct.create<$returnTypeStr>(_finalizable);
''');
    } else {
      if (returnType != voidType) {
        s.write('    ${convertReturn ? 'final _ret = ' : 'return '}');
      }
      s.write(msgSend!.invoke(w, targetStr, sel, msgSendParams));
      s.write(';\n');
      if (convertReturn) {
        final result = returnType.convertFfiDartTypeToDartType(
          w,
          '_ret',
          objCRetain: !returnsRetained,
          objCEnclosingClass: targetType,
        );
        s.write('    return $result;');
      }
    }

    s.write('\n  }\n');
    return s.toString();
  }
}
