// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../_core/interfaces/function_declaration.dart';
import '../../_core/interfaces/variable_declaration.dart';
import '../../_core/shared/parameter.dart';
import '../../_core/shared/referred_type.dart';
import '../../ast_node.dart';

/// A container for globally defined values (i.e variables & constants)
/// and functions.
class Globals {
  List<GlobalFunctionDeclaration> functions;
  List<GlobalVariableDeclaration> variables;

  Globals({
    required this.functions,
    required this.variables,
  });
}

/// Describes a globally defined function.
class GlobalFunctionDeclaration extends AstNode implements FunctionDeclaration {
  @override
  String id;

  @override
  String name;

  @override
  List<Parameter> params;

  @override
  List<GenericType> typeParams;

  @override
  bool throws;

  @override
  bool async;

  @override
  ReferredType returnType;

  @override
  List<String> statements;

  @override
  bool isCallingProperty;

  GlobalFunctionDeclaration({
    required this.id,
    required this.name,
    required this.params,
    required this.returnType,
    this.typeParams = const [],
    this.statements = const [],
    this.throws = false,
    this.async = false,
    this.isCallingProperty = false,
  });

  @override
  void visitChildren(Visitor visitor) {
    super.visitChildren(visitor);
    visitor.visitAll(params);
    visitor.visitAll(typeParams);
    visitor.visit(returnType);
  }
}

/// Describes a globally defined values (i.e variable/constant).
class GlobalVariableDeclaration extends AstNode implements VariableDeclaration {
  @override
  String id;

  @override
  String name;

  @override
  ReferredType type;

  @override
  bool isConstant;

  @override
  bool throws;

  @override
  bool async;

  GlobalVariableDeclaration({
    required this.id,
    required this.name,
    required this.type,
    required this.isConstant,
    required this.throws,
    required this.async,
  }) : assert(!(throws && !isConstant));

  @override
  void visitChildren(Visitor visitor) {
    super.visitChildren(visitor);
    visitor.visit(type);
  }
}
