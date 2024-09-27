// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../_core/interfaces/function_declaration.dart';
import '../../_core/interfaces/variable_declaration.dart';
import '../../_core/shared/parameter.dart';
import '../../_core/shared/referred_type.dart';

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
class GlobalFunctionDeclaration implements FunctionDeclaration {
  @override
  String id;

  @override
  String name;

  @override
  List<Parameter> params;

  @override
  List<GenericType> typeParams;

  @override
  ReferredType? returnType;

  @override
  List<String> statements;

  GlobalFunctionDeclaration({
    required this.id,
    required this.name,
    required this.params,
    required this.returnType,
    this.typeParams = const [],
    this.statements = const [],
  });
}

/// Describes a globally defined values (i.e variable/constant).
class GlobalVariableDeclaration implements VariableDeclaration {
  @override
  String id;

  @override
  String name;

  @override
  ReferredType type;

  @override
  bool isConstant;

  GlobalVariableDeclaration({
    required this.id,
    required this.name,
    required this.type,
    required this.isConstant,
  });
}
