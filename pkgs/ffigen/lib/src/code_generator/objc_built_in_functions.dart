// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';

import 'binding_string.dart';
import 'writer.dart';

/// Built in functions used by the Objective C bindings.
class ObjCBuiltInFunctions {
  ObjCBuiltInFunctions(this.generateForPackageObjectiveC);

  final bool generateForPackageObjectiveC;

  static const registerName = ObjCImport('registerName');
  static const getClass = ObjCImport('getClass');
  static const msgSendPointer = ObjCImport('msgSendPointer');
  static const msgSendFpretPointer = ObjCImport('msgSendFpretPointer');
  static const msgSendStretPointer = ObjCImport('msgSendStretPointer');
  static const useMsgSendVariants = ObjCImport('useMsgSendVariants');
  static const newPointerBlock = ObjCImport('newPointerBlock');
  static const newClosureBlock = ObjCImport('newClosureBlock');
  static const getBlockClosure = ObjCImport('getBlockClosure');
  static const objectBase = ObjCImport('ObjCObjectBase');
  static const blockBase = ObjCImport('ObjCBlockBase');

  // Keep in sync with pkgs/objective_c/ffigen_objc.yaml.
  static const builtInInterfaces = {
    'NSArray',
    'NSCharacterSet',
    'NSCoder',
    'NSData',
    'NSDate',
    'NSDictionary',
    'NSEnumerator',
    'NSError',
    'NSIndexSet',
    'NSInvocation',
    'NSItemProvider',
    'NSLocale',
    'NSMethodSignature',
    'NSMutableArray',
    'NSMutableData',
    'NSMutableDictionary',
    'NSMutableSet',
    'NSMutableString',
    'NSNotification',
    'NSNumber',
    'NSObject',
    'NSProgress',
    'NSSet',
    'NSString',
    'NSURL',
    'NSURLHandle',
    'NSValue',
    'Protocol',
  };

  bool isBuiltInInterface(String name) =>
      !generateForPackageObjectiveC && builtInInterfaces.contains(name);

  // We need to load a separate instance of objc_msgSend for each signature. If
  // the return type is a struct, we need to use objc_msgSend_stret instead, and
  // for float return types we need objc_msgSend_fpret.
  final _msgSendFuncs = <String, ObjCMsgSendFunc>{};
  ObjCMsgSendFunc getMsgSendFunc(
      Type returnType, List<ObjCMethodParam> params) {
    var key = returnType.cacheKey();
    for (final p in params) {
      key += ' ${p.type.cacheKey()}';
    }
    return _msgSendFuncs[key] ??= ObjCMsgSendFunc(
        '_objc_msgSend_${_msgSendFuncs.length}',
        returnType,
        params,
        useMsgSendVariants);
  }

  final _selObjects = <String, ObjCInternalGlobal>{};
  ObjCInternalGlobal getSelObject(String methodName) {
    return _selObjects[methodName] ??= ObjCInternalGlobal(
      '_sel_${methodName.replaceAll(":", "_")}',
      (Writer w) => '${registerName.gen(w)}("$methodName")',
    );
  }

  void addDependencies(Set<Binding> dependencies) {
    for (final msgSendFunc in _msgSendFuncs.values) {
      msgSendFunc.addDependencies(dependencies);
    }
    for (final sel in _selObjects.values) {
      sel.addDependencies(dependencies);
    }
  }
}

/// A function, global variable, or helper type defined in package:objective_c.
class ObjCImport {
  final String name;

  const ObjCImport(this.name);

  String gen(Writer w) => '${w.objcPkgPrefix}.$name';
}

/// Globals only used internally by ObjC bindings, such as classes and SELs.
class ObjCInternalGlobal extends NoLookUpBinding {
  final String Function(Writer) makeValue;

  ObjCInternalGlobal(String name, this.makeValue)
      : super(originalName: name, name: name, isInternal: true);

  @override
  BindingString toBindingString(Writer w) {
    final s = StringBuffer();
    name = w.wrapperLevelUniqueNamer.makeUnique(name);
    s.write('late final $name = ${makeValue(w)};\n');
    return BindingString(type: BindingStringType.global, string: s.toString());
  }

  @override
  void addDependencies(Set<Binding> dependencies) {
    if (dependencies.contains(this)) return;
    dependencies.add(this);
  }
}

enum ObjCMsgSendVariant {
  normal(ObjCBuiltInFunctions.msgSendPointer),
  stret(ObjCBuiltInFunctions.msgSendStretPointer),
  fpret(ObjCBuiltInFunctions.msgSendFpretPointer);

  final ObjCImport pointer;
  const ObjCMsgSendVariant(this.pointer);

  static ObjCMsgSendVariant fromReturnType(Type returnType) {
    if (returnType is Compound && returnType.isStruct) {
      return ObjCMsgSendVariant.stret;
    } else if (returnType == floatType || returnType == doubleType) {
      return ObjCMsgSendVariant.fpret;
    }
    return ObjCMsgSendVariant.normal;
  }
}

class ObjCMsgSendVariantFunc extends NoLookUpBinding {
  ObjCMsgSendVariant variant;
  FunctionType type;

  ObjCMsgSendVariantFunc(
      {required super.name,
      required this.variant,
      required Type returnType,
      required List<Parameter> parameters})
      : type = FunctionType(returnType: returnType, parameters: parameters),
        super(isInternal: true);

  @override
  BindingString toBindingString(Writer w) {
    final cType = NativeFunc(type).getCType(w);
    final dartType = type.getFfiDartType(w, writeArgumentNames: false);
    final pointer = variant.pointer.gen(w);

    final bindingString = '''
final $name = $pointer.cast<$cType>().asFunction<$dartType>();
''';

    return BindingString(type: BindingStringType.func, string: bindingString);
  }

  @override
  void addDependencies(Set<Binding> dependencies) {
    if (dependencies.contains(this)) return;
    dependencies.add(this);
    type.addDependencies(dependencies);
  }
}

/// A wrapper around the objc_msgSend function, or the stret or fpret variants.
///
/// The [variant] is based purely on the return type of the method.
///
/// For the stret and fpret variants, we may need to fall back to the normal
/// objc_msgSend function at runtime, depending on the ABI. So we emit both the
/// variant function and the normal function, and decide which to use at runtime
/// based on the ABI. The result of the ABI check is stored in [useVariants].
///
/// This runtime check is complicated by the fact that objc_msgSend_stret has
/// a different signature than objc_msgSend has for the same method. This is
/// because objc_msgSend_stret takes a pointer to the return type as its first
/// arg.
class ObjCMsgSendFunc {
  final ObjCMsgSendVariant variant;
  final ObjCImport useVariants;

  // [normalFunc] is always a reference to the normal objc_msgSend function. If
  // the [variant] is fpret or stret, then [variantFunc] is a reference to the
  // corresponding variant of the objc_msgSend function, otherwise it's null.
  late final ObjCMsgSendVariantFunc normalFunc;
  late final ObjCMsgSendVariantFunc? variantFunc;

  ObjCMsgSendFunc(String name, Type returnType, List<ObjCMethodParam> params,
      this.useVariants)
      : variant = ObjCMsgSendVariant.fromReturnType(returnType) {
    normalFunc = ObjCMsgSendVariantFunc(
      name: name,
      variant: ObjCMsgSendVariant.normal,
      returnType: returnType,
      parameters: _params(params),
    );
    switch (variant) {
      case ObjCMsgSendVariant.normal:
        variantFunc = null;
      case ObjCMsgSendVariant.fpret:
        variantFunc = ObjCMsgSendVariantFunc(
          name: '${name}Fpret',
          variant: variant,
          returnType: returnType,
          parameters: _params(params),
        );
      case ObjCMsgSendVariant.stret:
        variantFunc = ObjCMsgSendVariantFunc(
          name: '${name}Stret',
          variant: variant,
          returnType: voidType,
          parameters: _params(params, structRetPtr: PointerType(returnType)),
        );
    }
  }

  static List<Parameter> _params(List<ObjCMethodParam> params,
      {Type? structRetPtr}) {
    return [
      if (structRetPtr != null) Parameter(type: structRetPtr),
      Parameter(type: PointerType(objCObjectType)),
      Parameter(type: PointerType(objCSelType)),
      for (final p in params) Parameter(type: p.type),
    ];
  }

  bool get isStret => variant == ObjCMsgSendVariant.stret;

  void addDependencies(Set<Binding> dependencies) {
    normalFunc.addDependencies(dependencies);
    variantFunc?.addDependencies(dependencies);
  }

  String invoke(Writer w, String target, String sel, Iterable<String> params,
      {String? structRetPtr}) {
    final normalCall = _invoke(normalFunc.name, target, sel, params);
    switch (variant) {
      case ObjCMsgSendVariant.normal:
        return normalCall;
      case ObjCMsgSendVariant.fpret:
        final fpretCall = _invoke(variantFunc!.name, target, sel, params);
        return '${useVariants.gen(w)} ? $fpretCall : $normalCall';
      case ObjCMsgSendVariant.stret:
        final stretCall = _invoke(variantFunc!.name, target, sel, params,
            structRetPtr: structRetPtr);
        return '${useVariants.gen(w)} ? $stretCall : '
            '$structRetPtr.ref = $normalCall';
    }
  }

  static String _invoke(
    String name,
    String target,
    String sel,
    Iterable<String> params, {
    String? structRetPtr,
  }) {
    return '''$name(${[
      if (structRetPtr != null) structRetPtr,
      target,
      sel,
      ...params,
    ].join(', ')})''';
  }
}
