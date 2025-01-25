// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../code_generator.dart';
import '../config_provider/config_types.dart';
import '../visitor/ast.dart';

import 'binding_string.dart';
import 'utils.dart';
import 'writer.dart';

/// A binding for C function.
///
/// For example, take the following C function.
///
/// ```c
/// int sum(int a, int b);
/// ```
///
/// The generated Dart code for this function (without `FfiNative`) is as
/// follows.
///
/// ```dart
/// int sum(int a, int b) {
///   return _sum(a, b);
/// }
///
/// final _dart_sum _sum = _dylib.lookupFunction<_c_sum, _dart_sum>('sum');
///
/// typedef _c_sum = ffi.Int32 Function(ffi.Int32 a, ffi.Int32 b);
///
/// typedef _dart_sum = int Function(int a, int b);
/// ```
///
/// When using `Native`, the code is as follows.
///
/// ```dart
/// @ffi.Native<ffi.Int32 Function(ffi.Int32 a, ffi.Int32 b)>('sum')
/// external int sum(int a, int b);
/// ```
class Func extends LookUpBinding {
  final FunctionType functionType;
  final bool exposeSymbolAddress;
  final bool exposeFunctionTypedefs;
  final bool isLeaf;
  final bool objCReturnsRetained;
  final bool useNameForLookup;
  final FfiNativeConfig ffiNativeConfig;
  late final String funcPointerName;

  /// Contains typealias for function type if [exposeFunctionTypedefs] is true.
  Typealias? _exposedFunctionTypealias;

  /// [originalName] is looked up in dynamic library, if not
  /// provided, takes the value of [name].
  Func({
    super.usr,
    required String name,
    super.originalName,
    super.dartDoc,
    required Type returnType,
    List<Parameter>? parameters,
    List<Parameter>? varArgParameters,
    this.exposeSymbolAddress = false,
    this.exposeFunctionTypedefs = false,
    this.isLeaf = false,
    this.objCReturnsRetained = false,
    this.useNameForLookup = false,
    super.isInternal,
    this.ffiNativeConfig = const FfiNativeConfig(enabled: false),
  })  : functionType = FunctionType(
          returnType: returnType,
          parameters: parameters ?? const [],
          varArgParameters: varArgParameters ?? const [],
        ),
        super(
          name: name,
        ) {
    for (var i = 0; i < functionType.parameters.length; i++) {
      if (functionType.parameters[i].name.trim() == '') {
        functionType.parameters[i].name = 'arg$i';
      }
    }

    // Get function name with first letter in upper case.
    final upperCaseName = name[0].toUpperCase() + name.substring(1);
    if (exposeFunctionTypedefs) {
      _exposedFunctionTypealias = Typealias(
        name: upperCaseName,
        type: functionType,
        genFfiDartType: true,
        isInternal: true,
      );
    }
  }

  String get _lookupName => useNameForLookup ? name : originalName;

  @override
  BindingString toBindingString(Writer w) {
    final s = StringBuffer();
    final enclosingFuncName = name;

    if (dartDoc != null) {
      s.write(makeDartDoc(dartDoc!));
    }
    // Resolve name conflicts in function parameter names.
    final paramNamer = UniqueNamer({});
    for (final p in functionType.dartTypeParameters) {
      p.name = paramNamer.makeUnique(p.name);
    }

    final cType = _exposedFunctionTypealias?.getCType(w) ??
        functionType.getCType(w, writeArgumentNames: false);
    final dartType = _exposedFunctionTypealias?.getFfiDartType(w) ??
        functionType.getFfiDartType(w, writeArgumentNames: false);
    final needsWrapper = !functionType.sameDartAndFfiDartType && !isInternal;

    final funcVarName = w.wrapperLevelUniqueNamer.makeUnique('_$name');
    final ffiReturnType = functionType.returnType.getFfiDartType(w);
    final ffiArgDeclString = functionType.dartTypeParameters
        .map((p) => '${p.type.getFfiDartType(w)} ${p.name},\n')
        .join('');

    late final String dartReturnType;
    late final String dartArgDeclString;
    late final String funcImplCall;
    if (needsWrapper) {
      dartReturnType = functionType.returnType.getDartType(w);
      dartArgDeclString = functionType.dartTypeParameters
          .map((p) => '${p.type.getDartType(w)} ${p.name},\n')
          .join('');

      final argString = functionType.dartTypeParameters.map((p) {
        final type = p.type.convertDartTypeToFfiDartType(
          w,
          p.name,
          objCRetain: p.objCConsumed,
          objCAutorelease: false,
        );
        return '$type,\n';
      }).join('');
      funcImplCall = functionType.returnType.convertFfiDartTypeToDartType(
        w,
        '$funcVarName($argString)',
        objCRetain: !objCReturnsRetained,
      );
    } else {
      dartReturnType = ffiReturnType;
      dartArgDeclString = ffiArgDeclString;
      final argString =
          functionType.dartTypeParameters.map((p) => '${p.name},\n').join('');
      funcImplCall = '$funcVarName($argString)';
    }

    if (ffiNativeConfig.enabled) {
      final nativeFuncName = needsWrapper ? funcVarName : enclosingFuncName;
      s.write('''
${makeNativeAnnotation(
        w,
        nativeType: cType,
        dartName: nativeFuncName,
        nativeSymbolName: _lookupName,
        isLeaf: isLeaf,
      )}
external $ffiReturnType $nativeFuncName($ffiArgDeclString);

''');
      if (needsWrapper) {
        s.write('''
$dartReturnType $enclosingFuncName($dartArgDeclString) => $funcImplCall;

''');
      }

      if (exposeSymbolAddress) {
        // Add to SymbolAddress in writer.
        w.symbolAddressWriter.addNativeSymbol(
          type: '${w.ffiLibraryPrefix}.Pointer<'
              '${w.ffiLibraryPrefix}.NativeFunction<$cType>>',
          name: name,
        );
      }
    } else {
      funcPointerName = w.wrapperLevelUniqueNamer.makeUnique('_${name}Ptr');
      final isLeafString = isLeaf ? 'isLeaf:true' : '';

      // Write enclosing function.
      s.write('''
$dartReturnType $enclosingFuncName($dartArgDeclString) {
  return $funcImplCall;
}

''');

      if (exposeSymbolAddress) {
        // Add to SymbolAddress in writer.
        w.symbolAddressWriter.addSymbol(
          type: '${w.ffiLibraryPrefix}.Pointer<'
              '${w.ffiLibraryPrefix}.NativeFunction<$cType>>',
          name: name,
          ptrName: funcPointerName,
        );
      }

      // Write function pointer.
      s.write('''
late final $funcPointerName = ${w.lookupFuncIdentifier}<
    ${w.ffiLibraryPrefix}.NativeFunction<$cType>>('$_lookupName');
late final $funcVarName = $funcPointerName.asFunction<$dartType>($isLeafString);

''');
    }

    return BindingString(type: BindingStringType.func, string: s.toString());
  }

  @override
  void visitChildren(Visitor visitor) {
    super.visitChildren(visitor);
    visitor.visit(functionType);
    visitor.visit(_exposedFunctionTypealias);
  }

  @override
  void visit(Visitation visitation) => visitation.visitFunc(this);
}

/// Represents a Parameter, used in [Func], [Typealias], [ObjCMethod], and
/// [ObjCBlock].
class Parameter extends AstNode {
  final String? originalName;
  String name;
  Type type;
  final bool objCConsumed;
  bool isCovariant = false;

  Parameter({
    String? originalName,
    this.name = '',
    required Type type,
    required this.objCConsumed,
  })  : originalName = originalName ?? name,
        // A [NativeFunc] is wrapped with a pointer because this is a shorthand
        // used in C for Pointer to function.
        type = type.typealiasType is NativeFunc ? PointerType(type) : type;

  String getNativeType({String varName = ''}) =>
      '${type.getNativeType(varName: varName)}'
      '${objCConsumed ? ' __attribute__((ns_consumed))' : ''}';

  @override
  String toString() => '$type $name';

  @override
  void visitChildren(Visitor visitor) {
    super.visitChildren(visitor);
    visitor.visit(type);
  }
}
