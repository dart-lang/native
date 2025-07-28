// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';

import '../context.dart';
import '../header_parser/sub_parsers/api_availability.dart';
import '../visitor/ast.dart';
import 'func.dart';
import 'imports.dart';
import 'native_type.dart';
import 'objc_block.dart';
import 'objc_built_in_functions.dart';
import 'objc_interface.dart';
import 'objc_nullable.dart';
import 'pointer.dart';
import 'type.dart';
import 'typealias.dart';
import 'unique_namer.dart';
import 'utils.dart';
import 'writer.dart';

mixin ObjCMethods {
  Map<String, ObjCMethod> _methods = <String, ObjCMethod>{};
  List<String> _order = <String>[];

  Iterable<ObjCMethod> get methods =>
      _order.map((key) => _methods[key]).nonNulls;
  ObjCMethod? getSimilarMethod(ObjCMethod method) => _methods[method.key];

  String get originalName;
  String get name;
  Context get context;

  void addMethod(ObjCMethod? method) {
    if (method == null) return;
    final oldMethod = getSimilarMethod(method);
    if (oldMethod != null) {
      _methods[method.key] = _maybeReplaceMethod(oldMethod, method);
    } else {
      _methods[method.key] = method;
      _order.add(method.key);
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
      context.logger.severe(
        'Duplicate methods with different signatures: '
        '$originalName.${newMethod.originalName}',
      );
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

  UniqueNamer createMethodRenamer(Writer w) =>
      UniqueNamer(parent: w.topLevelUniqueNamer)..markAllUsed([
        name,
        'pointer',
        'toString',
        'hashCode',
        'runtimeType',
        'noSuchMethod',
      ]);

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

  String generateMethodBindings(Writer w, ObjCInterface target) =>
      _generateMethods(w, target, null);

  String generateStaticMethodBindings(Writer w, ObjCInterface target) =>
      _generateMethods(w, target, true);

  String generateInstanceMethodBindings(Writer w, ObjCInterface target) =>
      _generateMethods(w, target, false);

  String _generateMethods(Writer w, ObjCInterface target, bool? staticMethods) {
    final methodNamer = createMethodRenamer(w);
    return [
      for (final m in methods)
        if (staticMethods == null || staticMethods == m.isClassMethod)
          m.generateBindings(w, target, methodNamer),
    ].join('\n');
  }
}

enum ObjCMethodKind { method, propertyGetter, propertySetter }

enum ObjCMethodOwnership { retained, notRetained, autoreleased }

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

  const ObjCMethodFamily(
    this.name, {
    required this.returnsRetained,
    required this.consumesSelf,
  });

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
  final Context context;
  final String? dartDoc;
  final String originalName;
  String name;
  String? dartMethodName;
  late final String protocolMethodName;
  final ObjCProperty? property;
  Type returnType;
  final List<Parameter> params;
  ObjCMethodKind kind;
  final bool isClassMethod;
  final bool isOptional;
  ObjCMethodOwnership? ownershipAttribute;
  final ObjCMethodFamily? family;
  final ApiAvailability apiAvailability;
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
    required this.context,
    required this.originalName,
    required this.name,
    this.property,
    this.dartDoc,
    required this.kind,
    required this.isClassMethod,
    required this.isOptional,
    required this.returnType,
    required this.family,
    required this.apiAvailability,
    List<Parameter>? params_,
  }) : params = params_ ?? [],
       selObject = context.objCBuiltInFunctions.getSelObject(originalName);

  // Must be called after all params are added to the method.
  void finalizeParams() {
    protocolMethodName = name.replaceAll(':', '_');

    // Split the name at the ':'. The first chunk is the name of the method, and
    // the rest of the chunks are named parameters. Eg NSString's
    //   - compare:options:range:
    // method becomes
    //   NSComparisonResult compare(NSString string,
    //       {required NSStringCompareOptions options, required NSRange range})
    final chunks = name.split(':');

    // Details:
    //  - The first chunk is always the new Dart method name.
    //  - The rest of the chunks correspond to the params, so there's always
    //    one more chunk than the number of params.
    //  - The correspondence between the chunks and the params is non-trivial:
    //    - The ObjC name always ends with a ':' unless there are no ':' at all.
    //    - The first param is an ordinary param, not a named param.
    final correctNumParams = chunks.length == params.length + 1;
    final lastChunkIsEmpty = chunks.length == 1 || chunks.last.isEmpty;
    if (correctNumParams && lastChunkIsEmpty) {
      // Take the first chunk as the name, ignore the last chunk, and map the
      // rest to each of the params after the first.
      name = chunks[0];
      for (var i = 1; i < params.length; ++i) {
        params[i].name = chunks[i];
      }
    } else {
      // There are a few methods that don't obey these rules, eg due to variadic
      // parameters. Most of these are omitted from the bindings as they're not
      // supported yet. But as a fallback, just replace all the ':' in the name
      // with '_', like we do for protocol methods.
      name = protocolMethodName;
    }
  }

  bool get isProperty =>
      kind == ObjCMethodKind.propertyGetter ||
      kind == ObjCMethodKind.propertySetter;
  bool get isRequired => !isOptional;
  bool get isInstanceMethod => !isClassMethod;

  void fillMsgSend() {
    msgSend ??= context.objCBuiltInFunctions.getMsgSendFunc(returnType, params);
  }

  void fillProtocolBlock() {
    protocolBlock ??= ObjCBlock(
      context,
      returnType: returnType,
      params: [
        // First arg of the protocol block is a void pointer that we ignore.
        Parameter(name: '_', type: PointerType(voidType), objCConsumed: false),
        ...params,
      ],
      returnsRetained: returnsRetained,
    )..fillProtocolTrampoline();
  }

  String getDartProtocolMethodName(UniqueNamer uniqueNamer) =>
      uniqueNamer.makeUnique(protocolMethodName);

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

    return uniqueNamer.makeUnique(name);
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
  String toString() =>
      '${isOptional ? '@optional ' : ''}$returnType '
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

  static String _paramToStr(Writer w, Parameter p) =>
      '${p.type.getDartType(w)} ${p.name}';

  static String _paramToNamed(Writer w, Parameter p) =>
      '${p.isNullable ? '' : 'required '}${_paramToStr(w, p)}';

  static String _joinParamStr(Writer w, List<Parameter> params) {
    if (params.isEmpty) return '';
    if (params.length == 1) return _paramToStr(w, params.first);
    final named = params.sublist(1).map((p) => _paramToNamed(w, p)).join(',');
    return '${_paramToStr(w, params.first)}, {$named}';
  }

  String generateBindings(
    Writer w,
    ObjCInterface target,
    UniqueNamer methodNamer,
  ) {
    if (dartMethodName == null) {
      dartMethodName = getDartMethodName(methodNamer);
      final paramNamer = UniqueNamer(parent: methodNamer);
      for (final p in params) {
        p.name = paramNamer.makeUnique(p.name);
      }
    }
    final methodName = dartMethodName!;
    final upperName = methodName[0].toUpperCase() + methodName.substring(1);
    final s = StringBuffer();

    final targetType = target.getDartType(w);
    final returnTypeStr = _getConvertedReturnType(w, targetType);
    final paramStr = _joinParamStr(w, params);

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
    final versionCheck = apiAvailability.runtimeCheck(
      ObjCBuiltInFunctions.checkOsVersion.gen(w),
      '${target.originalName}.$originalName',
    );
    if (versionCheck != null) {
      s.write('  $versionCheck\n');
    }

    final sel = selObject.name;
    if (isOptional) {
      s.write('''
    if (!${ObjCBuiltInFunctions.respondsToSelector.gen(w)}($targetStr, $sel)) {
      throw ${ObjCBuiltInFunctions.unimplementedOptionalMethodException.gen(w)}(
          '${target.originalName}', '$originalName');
    }
''');
    }
    final convertReturn =
        kind != ObjCMethodKind.propertySetter &&
        !returnType.sameDartAndFfiDartType;

    final msgSendParams = params.map(
      (p) => p.type.convertDartTypeToFfiDartType(
        w,
        p.name,
        objCRetain: p.objCConsumed,
        objCAutorelease: false,
      ),
    );
    if (msgSend!.isStret) {
      assert(!convertReturn);
      final calloc = '${w.ffiPkgLibraryPrefix}.calloc';
      final sizeOf = '${w.ffiLibraryPrefix}.sizeOf';
      final uint8Type = NativeType(SupportedNativeType.uint8).getCType(w);
      final invoke = msgSend!.invoke(
        w,
        targetStr,
        sel,
        msgSendParams,
        structRetPtr: '_ptr',
      );
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
