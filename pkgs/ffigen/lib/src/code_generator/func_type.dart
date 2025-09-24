// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../code_generator.dart';
import '../context.dart';
import '../visitor/ast.dart';
import 'namespace.dart';

/// Represents a function type.
class FunctionType extends Type with HasLocalNamespace {
  final Type returnType;
  final List<Parameter> parameters;
  final List<Parameter> varArgParameters;

  /// Get all the parameters for generating the dart type. This includes both
  /// [parameters] and [varArgParameters].
  List<Parameter> get dartTypeParameters => parameters + varArgParameters;
  int get numDartTypeParameters => parameters.length + varArgParameters.length;

  FunctionType({
    required this.returnType,
    required this.parameters,
    this.varArgParameters = const [],
  });

  String _getTypeImpl(
    bool writeArgumentNames,
    String Function(Type) typeToString, {
    String? varArgWrapper,
  }) {
    final params = varArgWrapper != null ? parameters : dartTypeParameters;
    String paramToString(Parameter p) =>
        '${typeToString(p.type)} ${writeArgumentNames ? p.originalName : ""}';
    String? varArgPack;
    if (varArgWrapper != null && varArgParameters.isNotEmpty) {
      final varArgPackBuf = StringBuffer();
      varArgPackBuf.write('$varArgWrapper<(');
      varArgPackBuf.write(
        varArgParameters.map<String>(paramToString).join(', '),
      );
      varArgPackBuf.write(',)>');
      varArgPack = varArgPackBuf.toString();
    }

    // Write return Type.
    final sb = StringBuffer();
    sb.write(typeToString(returnType));

    // Write Function.
    sb.write(' Function(');
    sb.write(
      [
        ...params.map<String>(paramToString),
        if (varArgPack != null) varArgPack,
      ].join(', '),
    );
    sb.write(')');

    return sb.toString();
  }

  @override
  String getCType(Context context, {bool writeArgumentNames = true}) =>
      _getTypeImpl(
        writeArgumentNames,
        (Type t) => t.getCType(context),
        varArgWrapper: '${context.libs.prefix(ffiImport)}.VarArgs',
      );

  @override
  String getFfiDartType(Context context, {bool writeArgumentNames = true}) =>
      _getTypeImpl(writeArgumentNames, (Type t) => t.getFfiDartType(context));

  @override
  String getDartType(Context context, {bool writeArgumentNames = true}) =>
      _getTypeImpl(writeArgumentNames, (Type t) => t.getDartType(context));

  @override
  String getNativeType({String varName = ''}) {
    final arg = dartTypeParameters.map<String>((p) => p.type.getNativeType());
    return '${returnType.getNativeType()} (*$varName)(${arg.join(', ')})';
  }

  @override
  bool get sameFfiDartAndCType =>
      returnType.sameFfiDartAndCType &&
      dartTypeParameters.every((p) => p.type.sameFfiDartAndCType);

  @override
  bool get sameDartAndCType =>
      returnType.sameDartAndCType &&
      dartTypeParameters.every((p) => p.type.sameDartAndCType);

  @override
  bool get sameDartAndFfiDartType =>
      returnType.sameDartAndFfiDartType &&
      dartTypeParameters.every((p) => p.type.sameDartAndFfiDartType);

  @override
  String toString() => _getTypeImpl(false, (Type t) => t.toString());

  @override
  String cacheKey() => _getTypeImpl(false, (Type t) => t.cacheKey());

  void addParameterNames(List<String> names) {
    if (names.length != parameters.length) {
      return;
    }
    for (var i = 0; i < parameters.length; i++) {
      parameters[i] = Parameter(
        type: parameters[i].type,
        name: names[i],
        objCConsumed: false,
      );
    }
  }

  @override
  void visitChildren(Visitor visitor) {
    super.visitChildren(visitor);
    visitor.visit(returnType);
    visitor.visitAll(parameters);
    visitor.visitAll(varArgParameters);
    visitor.visit(ffiImport);
  }

  @override
  void visit(Visitation visitation) => visitation.visitFunctionType(this);

  @override
  bool isSupertypeOf(Type other) {
    other = other.typealiasType;
    if (other is FunctionType) {
      return Type.isSupertypeOfVariance(
        covariantLeft: [returnType],
        covariantRight: [other.returnType],
        contravariantLeft: dartTypeParameters.map((p) => p.type).toList(),
        contravariantRight: other.dartTypeParameters
            .map((p) => p.type)
            .toList(),
      );
    }
    return false;
  }
}

/// Represents a `NativeFunction<Function>`.
class NativeFunc extends Type {
  // Either a FunctionType or a Typealias of a FunctionType.
  final Type _type;

  NativeFunc(this._type) : assert(_type is FunctionType || _type is Typealias);

  FunctionType get type {
    if (_type is Typealias) {
      return _type.typealiasType as FunctionType;
    }
    return _type as FunctionType;
  }

  @override
  String getCType(Context context, {bool writeArgumentNames = true}) {
    final funcType = _type is FunctionType
        ? _type.getCType(context, writeArgumentNames: writeArgumentNames)
        : _type.getCType(context);
    return '${context.libs.prefix(ffiImport)}.NativeFunction<$funcType>';
  }

  @override
  String getFfiDartType(Context context, {bool writeArgumentNames = true}) =>
      getCType(context, writeArgumentNames: writeArgumentNames);

  @override
  String getNativeType({String varName = ''}) =>
      _type.getNativeType(varName: varName);

  @override
  bool get sameFfiDartAndCType => true;

  @override
  String toString() => 'NativeFunction<${_type.toString()}>';

  @override
  String cacheKey() => 'NatFn(${_type.cacheKey()})';

  @override
  void visitChildren(Visitor visitor) {
    super.visitChildren(visitor);
    visitor.visit(_type);
  }

  @override
  bool isSupertypeOf(Type other) {
    other = other.typealiasType;
    if (other is NativeFunc) return type.isSupertypeOf(other.type);
    return false;
  }
}
