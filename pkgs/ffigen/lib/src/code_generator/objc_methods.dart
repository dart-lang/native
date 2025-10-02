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
import 'scope.dart';
import 'type.dart';
import 'typealias.dart';
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
    if (oldMethod == null) {
      _methods[method.key] = method;
      _order.add(method.key);
    } else if (_shouldReplaceMethod(oldMethod, method)) {
      _methods[method.key] = method;
    }
  }

  void visitMethods(Visitor visitor) {
    visitor.visitAll(methods);
  }

  bool _shouldReplaceMethod(ObjCMethod oldMethod, ObjCMethod newMethod) {
    // Typically we ignore duplicate methods. However, property setters and
    // getters are duplicated in the AST. One copy is marked with
    // ObjCMethodKind.propertyGetter/Setter. The other copy is missing
    // important information, and is a plain old instanceMethod. So if the
    // existing method is an instanceMethod, and the new one is a property,
    // override it.
    if (newMethod.isProperty && !oldMethod.isProperty) {
      return true;
    } else if (!newMethod.isProperty && oldMethod.isProperty) {
      // Don't override, but also skip the same method check below.
      return false;
    }

    // If one of the methods is optional, and the other is required, keep the
    // required one.
    if (newMethod.isOptional && !oldMethod.isOptional) {
      return false;
    } else if (!newMethod.isOptional && oldMethod.isOptional) {
      return true;
    }

    // Check the duplicate is the same method.
    if (!newMethod.sameAs(oldMethod)) {
      context.logger.severe(
        'Duplicate methods with different signatures: '
        '$originalName.${newMethod.originalName}',
      );
      return true;
    }

    // There's a bug in some Apple APIs where an init method that should return
    // instancetype has a duplicate definition that instead returns id. In that
    // case, use the one that returns instancetype. Note that since instancetype
    // is an alias of id, the sameAs check above passes.
    if (ObjCBuiltInFunctions.isInstanceType(newMethod.returnType) &&
        !ObjCBuiltInFunctions.isInstanceType(oldMethod.returnType)) {
      return true;
    } else if (!ObjCBuiltInFunctions.isInstanceType(newMethod.returnType) &&
        ObjCBuiltInFunctions.isInstanceType(oldMethod.returnType)) {
      return false;
    }

    return true;
  }

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
    return [
      for (final m in methods)
        if (staticMethods == null || staticMethods == m.isClassMethod)
          m.generateBindings(w, target),
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

class ObjCMethod extends AstNode with HasLocalScope {
  final Context context;
  final String? dartDoc;
  final String originalName;
  Symbol symbol;
  final String originalProtocolMethodName;
  Type returnType;
  final List<Parameter> _params;
  ObjCMethodKind kind;
  final bool isClassMethod;
  final bool isOptional;
  final ObjCMethodOwnership? ownershipAttribute;
  final ObjCMethodFamily? family;
  final ApiAvailability apiAvailability;
  final bool consumesSelfAttribute;
  ObjCInternalGlobal selObject;
  ObjCMsgSendFunc? msgSend;
  ObjCBlock? protocolBlock;
  Symbol? protocolMethodName;

  @override
  void visitChildren(Visitor visitor) {
    super.visitChildren(visitor);
    visitor.visit(symbol);
    visitor.visit(protocolMethodName);
    visitor.visit(returnType);
    visitor.visitAll(_params);
    visitor.visit(selObject);
    visitor.visit(msgSend);
    visitor.visit(protocolBlock);
    visitor.visit(ffiImport);
    visitor.visit(ffiPkgImport);
    visitor.visit(objcPkgImport);
  }

  @override
  void visit(Visitation visitation) => visitation.visitObjCMethod(this);

  ObjCMethod.withSymbol({
    required this.context,
    required this.originalName,
    required this.symbol,
    required String protocolMethodName,
    this.dartDoc,
    required this.kind,
    required this.isClassMethod,
    required this.isOptional,
    required this.returnType,
    required this.family,
    required this.apiAvailability,
    required List<Parameter> params,
    required this.ownershipAttribute,
    required this.consumesSelfAttribute,
  }) : originalProtocolMethodName = protocolMethodName.replaceAll(':', '_'),
       _params = params,
       selObject = context.objCBuiltInFunctions.getSelObject(originalName);

  factory ObjCMethod({
    required Context context,
    required String originalName,
    required String name,
    String? dartDoc,
    required ObjCMethodKind kind,
    required bool isClassMethod,
    required bool isOptional,
    required Type returnType,
    required ObjCMethodFamily? family,
    required ApiAvailability apiAvailability,
    required List<Parameter> params,
    required ObjCMethodOwnership? ownershipAttribute,
    required bool consumesSelfAttribute,
  }) {
    final protocolMethodName = name;

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
        params[i].symbol = Symbol(chunks[i]);
      }
    } else {
      // There are a few methods that don't obey these rules, eg due to variadic
      // parameters. Most of these are omitted from the bindings as they're not
      // supported yet. But as a fallback, just replace all the ':' in the name
      // with '_', like we do for protocol methods.
      name = name.replaceAll(':', '_');
    }

    return ObjCMethod.withSymbol(
      context: context,
      originalName: originalName,
      symbol: Symbol(name),
      protocolMethodName: protocolMethodName,
      dartDoc: dartDoc,
      kind: kind,
      isClassMethod: isClassMethod,
      isOptional: isOptional,
      returnType: returnType,
      family: family,
      apiAvailability: apiAvailability,
      params: params,
      ownershipAttribute: ownershipAttribute,
      consumesSelfAttribute: consumesSelfAttribute,
    );
  }

  String get name => symbol.name;
  Iterable<Parameter> get params => _params;

  bool get isProperty =>
      kind == ObjCMethodKind.propertyGetter ||
      kind == ObjCMethodKind.propertySetter;
  bool get isRequired => !isOptional;
  bool get isInstanceMethod => !isClassMethod;

  void fillMsgSend() {
    msgSend ??= context.objCBuiltInFunctions.getMsgSendFunc(
      returnType,
      _params,
    );
  }

  void fillProtocolBlock() {
    protocolBlock ??= ObjCBlock(
      context,
      returnType: returnType,
      params: [
        // First arg of the protocol block is a void pointer that we ignore.
        Parameter(name: '_', type: PointerType(voidType), objCConsumed: false),
        ..._params,
      ],
      returnsRetained: returnsRetained,
    )..fillProtocolTrampoline();
    protocolMethodName ??= symbol.oldName == originalProtocolMethodName
        ? symbol
        : Symbol(originalProtocolMethodName);
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
    for (final p in _params) {
      yield p.type;
    }
  }

  // Key used to dedupe methods in [ObjCMethods]. ObjC is similar to Dart in
  // that it doesn't have method overloading, so the [originalName] is mostly
  // sufficient as the key. But unlike Dart, ObjC can have static methods and
  // instance methods with the same name, so we have to include staticness in
  // the key. We order instance methods before static methods alphabetically.
  String get key => '${isClassMethod ? 'S' : 'I'} $originalName';

  @override
  String toString() =>
      '${isOptional ? '@optional ' : ''}$returnType '
      '$originalName(${_params.join(', ')})';

  bool get returnsInstanceType {
    if (returnType is ObjCInstanceType) return true;
    final baseType = returnType.typealiasType;
    if (baseType is ObjCNullable && baseType.child is ObjCInstanceType) {
      return true;
    }
    return false;
  }

  bool get returnsNSErrorByOutParam {
    // In ObjC, the pattern for returning an error is to return it as an out
    // param. Specifically, the last param is named error, and is a NSError**.
    // The same pattern is used when translating Swift methods that throw into
    // ObjC methods. We don't need to handle subtypes of NSError, as there are
    // no known APIs that return subtypes of NSError (in fact the Swift bridging
    // relies on the type always being exactly NSError).
    final p = _params.lastOrNull;
    if (p == null || p.originalName != 'error') return false;
    final t = p.type;
    if (t is! PointerType) return false;
    final c = t.child;
    if (c is! ObjCInterface) return false;
    return ObjCBuiltInFunctions.isNSError(c.originalName);
  }

  String _getConvertedReturnType(Context context, String instanceType) {
    if (returnType is ObjCInstanceType) return instanceType;
    final baseType = returnType.typealiasType;
    if (baseType is ObjCNullable && baseType.child is ObjCInstanceType) {
      return '$instanceType?';
    }
    return returnType.getDartType(context);
  }

  static String _paramToStr(Context context, Parameter p) =>
      '${p.type.getDartType(context)} ${p.name}';

  static String _paramToNamed(Context context, Parameter p) =>
      '${p.isNullable ? '' : 'required '}${_paramToStr(context, p)}';

  static String _joinParamStr(Context context, List<Parameter> params) {
    if (params.isEmpty) return '';
    if (params.length == 1) return _paramToStr(context, params.first);
    final named = params
        .sublist(1)
        .map((p) => _paramToNamed(context, p))
        .join(',');
    return '${_paramToStr(context, params.first)}, {$named}';
  }

  String generateBindings(Writer w, ObjCInterface target) {
    final context = w.context;
    final methodName = symbol.name;
    final upperName = methodName[0].toUpperCase() + methodName.substring(1);
    final throwNSError = returnsNSErrorByOutParam;

    final params = throwNSError
        ? _params.sublist(0, _params.length - 1)
        : _params;
    final retVar = localScope.addPrivate('_ret');
    final ptrVar = localScope.addPrivate('_ptr');
    final finalizableVar = localScope.addPrivate('_finalizable');
    final errVar = localScope.addPrivate('_err');

    final s = StringBuffer();
    final targetType = target.getDartType(context);
    final returnTypeStr = _getConvertedReturnType(context, targetType);
    final paramStr = _joinParamStr(context, params);

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
        context,
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
      ObjCBuiltInFunctions.checkOsVersion.gen(context),
      '${target.originalName}.$originalName',
    );
    if (versionCheck != null) {
      s.write('  $versionCheck\n');
    }

    final sel = selObject.name;
    if (isOptional) {
      final responds = ObjCBuiltInFunctions.respondsToSelector.gen(context);
      final unimplementedException = ObjCBuiltInFunctions
          .unimplementedOptionalMethodException
          .gen(context);
      s.write('''
    if (!$responds($targetStr, $sel)) {
      throw $unimplementedException('${target.originalName}', '$originalName');
    }
''');
    }

    final calloc = '${context.libs.prefix(ffiPkgImport)}.calloc';
    if (throwNSError) {
      final rawObjType = PointerType(objCObjectType).getCType(context);
      s.write('''
    final $errVar = $calloc<$rawObjType>();
    try {
''');
    }

    final convertReturn =
        kind != ObjCMethodKind.propertySetter &&
        !returnType.sameDartAndFfiDartType;
    final msgSendParams = [
      for (final p in params)
        p.type.convertDartTypeToFfiDartType(
          context,
          p.name,
          objCRetain: p.objCConsumed,
          objCAutorelease: false,
        ),
      if (throwNSError) errVar,
    ];

    if (msgSend!.isStret) {
      assert(!convertReturn);
      assert(!throwNSError);
      final sizeOf = '${context.libs.prefix(ffiImport)}.sizeOf';
      final uint8Type = NativeType(SupportedNativeType.uint8).getCType(context);
      final invoke = msgSend!.invoke(
        context,
        targetStr,
        sel,
        msgSendParams,
        structRetPtr: ptrVar,
      );
      s.write('''
    final $ptrVar = $calloc<$returnTypeStr>();
    $invoke;
    final $finalizableVar = $ptrVar.cast<$uint8Type>().asTypedList(
        $sizeOf<$returnTypeStr>(), finalizer: $calloc.nativeFree);
    return ${context.libs.prefix(ffiImport)}.Struct.create<$returnTypeStr>(
        $finalizableVar);
''');
    } else {
      final useReturn = returnType != voidType;
      final useReturnVar = convertReturn || throwNSError;
      if (useReturn) {
        s.write('    ${useReturnVar ? 'final $retVar = ' : 'return '}');
      }
      s.write(msgSend!.invoke(context, targetStr, sel, msgSendParams));
      s.write(';\n');
      if (throwNSError) {
        final nsErrorException = ObjCBuiltInFunctions.nsErrorException.gen(
          context,
        );
        s.write('    $nsErrorException.checkErrorPointer($errVar.value);\n');
      }
      if (useReturnVar) {
        final result = convertReturn
            ? returnType.convertFfiDartTypeToDartType(
                context,
                retVar,
                objCRetain: !returnsRetained,
                objCEnclosingClass: targetType,
              )
            : retVar;
        s.write('    return $result;');
      }
    }
    if (throwNSError) {
      s.write('''
    } finally {
      $calloc.free($errVar);
    }
''');
    }

    s.write('\n  }\n');
    return s.toString();
  }
}
