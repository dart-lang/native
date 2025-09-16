// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../code_generator.dart';
import '../context.dart';
import '../visitor/ast.dart';

import 'binding_string.dart';
import 'namespace.dart';
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
  late final FunctionType functionType;
  final bool exposeSymbolAddress;
  final bool exposeFunctionTypedefs;
  final bool isLeaf;
  final bool objCReturnsRetained;
  final bool useNameForLookup;
  final bool loadFromNativeAsset;

  /// Contains typealias for function type if [exposeFunctionTypedefs] is true.
  Typealias? _exposedFunctionTypealias;

  final Namespace _localNamespace;

  /// [originalName] is looked up in dynamic library, if not
  /// provided, takes the value of [name].
  Func({
    required Context context,
    super.usr,
    required String name,
    super.originalName,
    super.dartDoc,
    required Type returnType,
    List<DetachedParameter> parameters = const [],
    List<DetachedParameter> varArgParameters = const [],
    this.exposeSymbolAddress = false,
    this.exposeFunctionTypedefs = false,
    this.isLeaf = false,
    this.objCReturnsRetained = false,
    this.useNameForLookup = false,
    super.isInternal,
    this.loadFromNativeAsset = false,
  }) : _localNamespace = context.rootNamespace.addNamespace(),
       super(namespace: context.rootNamespace, name: name) {
    functionType = FunctionType(
      returnType: returnType,
      parameters: _makeParams(parameters, 0),
      varArgParameters: _makeParams(varArgParameters, parameters.length),
    );
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

  List<Parameter> _makeParams(List<DetachedParameter> dps, int firstIndex) =>
      <Parameter>[for (var i = 0; i < dps.length; ++i) _makeParam(dps[i], i)];
  Parameter _makeParam(DetachedParameter p, int index) {
    if (p.name.isEmpty) p.name = 'arg$index';
    return p.attach(_localNamespace);
  }

  @override
  BindingString toBindingString(Writer w) {
    final s = StringBuffer();
    final enclosingFuncName = name;

    s.write(makeDartDoc(dartDoc));

    final context = w.context;
    final cType =
        _exposedFunctionTypealias?.getCType(context) ??
        functionType.getCType(context, writeArgumentNames: false);
    final dartType =
        _exposedFunctionTypealias?.getFfiDartType(context) ??
        functionType.getFfiDartType(context, writeArgumentNames: false);
    final needsWrapper = !functionType.sameDartAndFfiDartType && !isInternal;

    final funcVarName = _localNamespace.addPrivate('_$name');
    final ffiReturnType = functionType.returnType.getFfiDartType(context);
    final ffiArgDeclString = functionType.dartTypeParameters
        .map((p) => '${p.type.getFfiDartType(context)} ${p.name},\n')
        .join('');
    final lookupName = useNameForLookup ? name : originalName;

    final String dartReturnType;
    final String dartArgDeclString;
    final String funcImplCall;
    if (needsWrapper) {
      dartReturnType = functionType.returnType.getDartType(context);
      dartArgDeclString = functionType.dartTypeParameters
          .map((p) => '${p.type.getDartType(context)} ${p.name},\n')
          .join('');

      final argString = functionType.dartTypeParameters
          .map((p) {
            final type = p.type.convertDartTypeToFfiDartType(
              context,
              p.name,
              objCRetain: p.objCConsumed,
              objCAutorelease: false,
            );
            return '$type,\n';
          })
          .join('');
      funcImplCall = functionType.returnType.convertFfiDartTypeToDartType(
        context,
        '$funcVarName($argString)',
        objCRetain: !objCReturnsRetained,
      );
    } else {
      dartReturnType = ffiReturnType;
      dartArgDeclString = ffiArgDeclString;
      final argString = functionType.dartTypeParameters
          .map((p) => '${p.name},\n')
          .join('');
      funcImplCall = '$funcVarName($argString)';
    }

    if (loadFromNativeAsset) {
      final nativeFuncName = needsWrapper ? funcVarName : enclosingFuncName;
      final nativeAnnotation = makeNativeAnnotation(
        w,
        nativeType: cType,
        dartName: nativeFuncName,
        nativeSymbolName: lookupName,
        isLeaf: isLeaf,
      );
      s.write('''
$nativeAnnotation
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
          type:
              '${w.context.libs.prefix(ffiImport)}.Pointer<'
              '${w.context.libs.prefix(ffiImport)}.NativeFunction<$cType>>',
          name: name,
        );
      }
    } else {
      final funcPointerName = _localNamespace.addPrivate('_${name}Ptr');
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
          type:
              '${w.context.libs.prefix(ffiImport)}.Pointer<'
              '${w.context.libs.prefix(ffiImport)}.NativeFunction<$cType>>',
          name: name,
          ptrName: funcPointerName,
        );
      }

      // Write function pointer.
      final lookupStr = Namespace.stringLiteral(lookupName);
      s.write('''
late final $funcPointerName = ${w.lookupFuncIdentifier}<
    ${w.context.libs.prefix(ffiImport)}.NativeFunction<$cType>>('$lookupStr');
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
    visitor.visit(ffiImport);
    if (loadFromNativeAsset && exposeSymbolAddress) {
      visitor.visit(selfImport);
    }
  }

  @override
  void visit(Visitation visitation) => visitation.visitFunc(this);
}

/// Represents a Parameter, used in [Func], [Typealias], [ObjCMethod], and
/// [ObjCBlock].
class Parameter extends AstNode {
  final String? originalName;
  Type type;
  final bool objCConsumed;
  bool isCovariant = false;

  final Symbol symbol;
  String get name => symbol.name;

  factory Parameter({
    required Namespace namespace,
    String? originalName,
    required String name,
    required Type type,
    required bool objCConsumed,
  }) => Parameter.fromSymbol(
    originalName: originalName,
    type: type,
    symbol: namespace.add(name),
    objCConsumed: objCConsumed,
  );

  Parameter.fromSymbol({
    this.originalName,
    required this.symbol,
    required Type type,
    required this.objCConsumed,
  }) : // A [NativeFunc] is wrapped with a pointer because this is a shorthand
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

  bool get isNullable => type.typealiasType is ObjCNullable;

  DetachedParameter detach() => DetachedParameter(
    originalName: originalName,
    name: symbol.oldName,
    type: type,
    objCConsumed: objCConsumed,
  );
}

class DetachedParameter {
  String? originalName;
  String name;
  Type type;
  bool objCConsumed;

  DetachedParameter({
    this.originalName,
    required this.name,
    required this.type,
    required this.objCConsumed,
  });

  Parameter attach(Namespace namespace) => Parameter(
    namespace: namespace,
    originalName: originalName,
    name: name,
    type: type,
    objCConsumed: objCConsumed,
  );
}
