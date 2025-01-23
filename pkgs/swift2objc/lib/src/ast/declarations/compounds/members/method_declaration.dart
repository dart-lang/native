// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../../_core/interfaces/function_declaration.dart';
import '../../../_core/interfaces/objc_annotatable.dart';
import '../../../_core/interfaces/overridable.dart';
import '../../../_core/shared/parameter.dart';
import '../../../_core/shared/referred_type.dart';
import '../../../ast_node.dart';

/// Describes a method declaration for a Swift compound entity
/// (e.g, class, structs)
class MethodDeclaration extends AstNode
    implements FunctionDeclaration, ObjCAnnotatable, Overridable {
  @override
  String id;

  @override
  String name;

  @override
  List<Parameter> params;

  @override
  List<GenericType> typeParams;

  @override
  bool hasObjCAnnotation;

  @override
  bool isOverriding;

  @override
  bool throws;

  @override
  bool async;

  @override
  List<String> statements;

  @override
  ReferredType returnType;

  @override
  bool isCallingProperty;

  bool isStatic;

  String get fullName => [
        name,
        for (final p in params) p.name,
      ].join(':');

  MethodDeclaration({
    required this.id,
    required this.name,
    required this.returnType,
    required this.params,
    this.typeParams = const [],
    this.hasObjCAnnotation = false,
    this.statements = const [],
    this.isStatic = false,
    this.isOverriding = false,
    this.throws = false,
    this.async = false,
    this.isCallingProperty = false,
  }) : assert(!isStatic || !isOverriding);

  @override
  void visit(Visitation visitation) => visitation.visitMethodDeclaration(this);

  @override
  void visitChildren(Visitor visitor) {
    super.visitChildren(visitor);
    visitor.visitAll(params);
    visitor.visitAll(typeParams);
    visitor.visit(returnType);
  }
}
