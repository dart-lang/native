// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../../../config.dart';
import '../../../_core/interfaces/availability.dart';
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
  InputConfig? source;

  int? lineNumber;

  @override
  List<AvailabilityInfo> availability;

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

  bool hasExplicitGetter;

  PropertyStatements? getter;
  PropertyStatements? setter;

  bool unowned;

  bool weak;

  bool lazy;

  bool isStatic;

  PropertyDeclaration({
    required this.id,
    required this.name,
    required this.source,
    required this.availability,
    required this.type,
    this.lineNumber,
    this.hasSetter = false,
    this.isConstant = false,
    this.hasObjCAnnotation = false,
    this.getter,
    this.setter,
    this.hasExplicitGetter = false,
    this.isStatic = false,
    this.throws = false,
    this.async = false,
    this.unowned = false,
    this.weak = false,
    this.lazy = false,
    this.mutating = false,
  }) : assert(!(isConstant && hasSetter)),
       assert(!(hasSetter && throws));

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
  @override
  final List<String> statements;

  PropertyStatements(this.statements);
}
