// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';

import 'binding_string.dart';
import 'writer.dart';

/// Built in functions used by the Objective C bindings.
class ObjCBuiltInFunctions {
  late final registerName = ObjCImport('registerName');
  late final getClass = ObjCImport('getClass');
  late final objectRetain = ObjCImport('objectRetain');
  late final objectRelease = ObjCImport('objectRelease');
  late final newBlock = ObjCImport('newBlock');
  late final blockCopy = ObjCImport('blockCopy');
  late final blockRelease = ObjCImport('blockRelease');
  late final useMsgSendVariants = ObjCImport('useMsgSendVariants');
  late final objectBase = ObjCImport('ObjCObjectBase');
  late final blockBase = ObjCImport('ObjCBlockBase');

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

  final _interfaceRegistry = <String, ObjCInterface>{};
  void registerInterface(ObjCInterface interface) {
    _interfaceRegistry[interface.originalName] = interface;
  }

  ObjCInterface get nsData {
    return _interfaceRegistry["NSData"] ??
        (ObjCInterface(
          originalName: "NSData",
          builtInFunctions: this,
        ));
  }

  void generateNSStringUtils(Writer w, StringBuffer s) {
    // Generate a constructor that wraps stringWithCharacters, and a toString
    // method that wraps dataUsingEncoding.
    s.write('''
  factory NSString(${w.className} _lib, String str) {
    final cstr = str.toNativeUtf16();
    final nsstr = stringWithCharacters_length_(_lib, cstr.cast(), str.length);
    ${w.ffiPkgLibraryPrefix}.calloc.free(cstr);
    return nsstr;
  }

  @override
  String toString() {
    final data = dataUsingEncoding_(
        0x94000100 /* NSUTF16LittleEndianStringEncoding */);
    return data!.bytes.cast<${w.ffiPkgLibraryPrefix}.Utf16>().toDartString(
        length: length);
  }
''');
  }

  void generateStringUtils(Writer w, StringBuffer s) {
    // Generate an extension on String to convert to NSString
    s.write('''
extension StringToNSString on String {
  NSString toNSString(${w.className} lib) => NSString(lib, this);
}
''');
  }
}

/// A function, global variable, or helper type defined in package:objective_c.
class ObjCImport {
  String name;

  ObjCImport(this.name);

  String gen(Writer w) => '${w.objcPkgPrefix}.$name';
}

/// Globals only used internally by ObjC bindings, such as classes and SELs.
class ObjCInternalGlobal extends LookUpBinding {
  final String Function(Writer) makeValue;

  ObjCInternalGlobal(String name, this.makeValue)
      : super(originalName: name, name: name, isInternal: true);

  @override
  BindingString toBindingString(Writer w) {
    final s = StringBuffer();
    name = w.wrapperLevelUniqueNamer.makeUnique(name);
    s.write('late final $name = ${makeValue(w)};');
    return BindingString(type: BindingStringType.global, string: s.toString());
  }

  @override
  void addDependencies(Set<Binding> dependencies) {
    if (dependencies.contains(this)) return;
    dependencies.add(this);
  }
}

enum ObjCMsgSendVariant {
  normal('objc_msgSend'),
  stret('objc_msgSend_stret'),
  fpret('objc_msgSend_fpret');

  final String name;
  const ObjCMsgSendVariant(this.name);

  static ObjCMsgSendVariant fromReturnType(Type returnType) {
    if (returnType is Compound && returnType.isStruct) {
      return ObjCMsgSendVariant.stret;
    } else if (returnType == floatType || returnType == doubleType) {
      return ObjCMsgSendVariant.fpret;
    }
    return ObjCMsgSendVariant.normal;
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
  late final Func normalFunc;
  late final Func? variantFunc;

  ObjCMsgSendFunc(String name, Type returnType, List<ObjCMethodParam> params,
      this.useVariants)
      : variant = ObjCMsgSendVariant.fromReturnType(returnType) {
    normalFunc = Func(
      name: name,
      originalName: ObjCMsgSendVariant.normal.name,
      returnType: returnType,
      parameters: _params(params),
      isInternal: true,
    );
    switch (variant) {
      case ObjCMsgSendVariant.normal:
        variantFunc = null;
      case ObjCMsgSendVariant.fpret:
        variantFunc = Func(
          name: '${name}_fpret',
          originalName: variant.name,
          returnType: returnType,
          parameters: _params(params),
          isInternal: true,
        );
      case ObjCMsgSendVariant.stret:
        variantFunc = Func(
          name: '${name}_stret',
          originalName: variant.name,
          returnType: voidType,
          parameters: _params(params, structRetPtr: PointerType(returnType)),
          isInternal: true,
        );
    }
  }

  static List<Parameter> _params(List<ObjCMethodParam> params,
      {Type? structRetPtr}) {
    return [
      if (structRetPtr != null) Parameter(name: 'stret', type: structRetPtr),
      Parameter(name: 'obj', type: PointerType(objCObjectType)),
      Parameter(name: 'sel', type: PointerType(objCSelType)),
      for (final p in params) Parameter(name: p.name, type: p.type),
    ];
  }

  bool get isStret => variant == ObjCMsgSendVariant.stret;

  void addDependencies(Set<Binding> dependencies) {
    normalFunc.addDependencies(dependencies);
    variantFunc?.addDependencies(dependencies);
  }

  String invoke(
      Writer w, String lib, String target, String sel, Iterable<String> params,
      {String? structRetPtr}) {
    final normalCall = _invoke(normalFunc.name, lib, target, sel, params);
    switch (variant) {
      case ObjCMsgSendVariant.normal:
        return normalCall;
      case ObjCMsgSendVariant.fpret:
        final fpretCall = _invoke(variantFunc!.name, lib, target, sel, params);
        return '${useVariants.gen(w)} ? $fpretCall : $normalCall';
      case ObjCMsgSendVariant.stret:
        final stretCall = _invoke(variantFunc!.name, lib, target, sel, params,
            structRetPtr: structRetPtr);
        return '${useVariants.gen(w)} ? $stretCall : '
            '$structRetPtr.ref = $normalCall';
    }
  }

  static String _invoke(
    String name,
    String lib,
    String target,
    String sel,
    Iterable<String> params, {
    String? structRetPtr,
  }) {
    return '''$lib.$name(${[
      if (structRetPtr != null) structRetPtr,
      target,
      sel,
      ...params,
    ].join(', ')})''';
  }
}
