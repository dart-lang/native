// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../../_core/interfaces/executable.dart';
import '../../../_core/interfaces/objc_annotatable.dart';
import '../../../_core/interfaces/variable_declaration.dart';
import '../../../_core/shared/referred_type.dart';
import '../../../ast_node.dart';

/// Describes a property declaration for a Swift compound entity
/// (e.g, class, structs)
class PropertyDeclaration extends AstNode
    implements VariableDeclaration, ObjCAnnotatable {
  @override
  String id;

  @override
  String name;

  @override
  bool hasObjCAnnotation;

  @override
  ReferredType type;

  @override
  bool isConstant;

  @override
  bool throws;

  @override
  bool async;

  bool mutating;

  bool hasSetter;

  PropertyStatements? getter;
  PropertyStatements? setter;

  bool isStatic;

  PropertyDeclaration({
    required this.id,
    required this.name,
    required this.type,
    this.hasSetter = false,
    this.isConstant = false,
    this.hasObjCAnnotation = false,
    this.getter,
    this.setter,
    this.isStatic = false,
    this.throws = false,
    this.async = false,
    this.mutating = false
  })  : assert(!(isConstant && hasSetter)),
        assert(!(hasSetter && throws)),
        assert(async && (getter?.async == null || getter!.async));

  @override
  void visit(Visitation visitation) =>
      visitation.visitPropertyDeclaration(this);

  @override
  void visitChildren(Visitor visitor) {
    super.visitChildren(visitor);
    visitor.visit(type);
  }
}

class PropertyStatements implements Executable {
  final bool async;

  final bool throws;

  final bool mutating;

  @override
  final List<String> statements;

  PropertyStatements(this.statements, {
    this.async = false,
    this.mutating = false,
    this.throws = false
  });
}
