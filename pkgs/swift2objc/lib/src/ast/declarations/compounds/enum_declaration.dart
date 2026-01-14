// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../../config.dart';
import '../../_core/interfaces/availability.dart';
import '../../_core/interfaces/compound_declaration.dart';
import '../../_core/interfaces/declaration.dart';
import '../../_core/interfaces/nestable_declaration.dart';
import '../../_core/interfaces/parameterizable.dart';
import '../../_core/shared/parameter.dart';
import '../../_core/shared/referred_type.dart';
import '../../ast_node.dart';
import 'members/initializer_declaration.dart';
import 'members/method_declaration.dart';
import 'members/property_declaration.dart';
import 'protocol_declaration.dart';

/// Describes the declaration of a Swift enum.
class EnumDeclaration extends AstNode implements CompoundDeclaration {
  @override
  String id;

  @override
  String name;

  @override
  InputConfig? source;

  @override
  List<AvailabilityInfo> availability;

  List<EnumCaseDeclaration> cases;

  @override
  List<PropertyDeclaration> properties;

  @override
  List<MethodDeclaration> methods;

  @override
  List<InitializerDeclaration> initializers;

  @override
  List<GenericType> typeParams;

  @override
  List<DeclaredType<ProtocolDeclaration>> conformedProtocols;

  @override
  OuterNestableDeclaration? nestingParent;

  @override
  List<InnerNestableDeclaration> nestedDeclarations;

  EnumDeclaration({
    required this.id,
    required this.name,
    required this.source,
    required this.availability,
    required this.cases,
    required this.properties,
    required this.methods,
    required this.initializers,
    this.conformedProtocols = const [],
    this.typeParams = const [],
    this.nestingParent,
    this.nestedDeclarations = const [],
  });

  @override
  void visit(Visitation visitation) => visitation.visitEnumDeclaration(this);

  @override
  void visitChildren(Visitor visitor) {
    super.visitChildren(visitor);
    visitor.visitAll(cases);
    visitor.visitAll(properties);
    visitor.visitAll(methods);
    visitor.visitAll(initializers);
    visitor.visitAll(typeParams);
    visitor.visitAll(conformedProtocols);
    visitor.visit(nestingParent);
    visitor.visitAll(nestedDeclarations);
  }
}

/// Describes the declaration of a Swift enum case.
class EnumCaseDeclaration extends AstNode
    implements Declaration, Parameterizable {
  @override
  String id;

  @override
  String name;

  @override
  InputConfig? source;

  @override
  List<AvailabilityInfo> availability;

  @override
  List<EnumCaseParam> params;

  EnumCaseDeclaration({
    required this.id,
    required this.name,
    required this.source,
    required this.availability,
    required this.params,
  });

  @override
  void visitChildren(Visitor visitor) {
    super.visitChildren(visitor);
    visitor.visitAll(params);
  }

  @override
  String toString() => '$name(${params.map((p) => '$p').join(', ')})';
}

/// Describes an associated value of a Swift enum case.
class EnumCaseParam extends AstNode implements Parameter {
  @override
  String name;

  @override
  ReferredType type;

  @override
  covariant Null internalName;

  EnumCaseParam({required this.name, required this.type});

  @override
  void visitChildren(Visitor visitor) {
    super.visitChildren(visitor);
    visitor.visit(type);
  }

  @override
  String toString() => '${name == '' ? '' : '$name: '}$type';
}
