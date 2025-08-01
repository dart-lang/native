// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../_core/interfaces/compound_declaration.dart';
import '../../_core/interfaces/nestable_declaration.dart';
import '../../_core/shared/referred_type.dart';
import '../../ast_node.dart';
import 'members/initializer_declaration.dart';
import 'members/method_declaration.dart';
import 'members/property_declaration.dart';
import 'protocol_declaration.dart';

/// Describes the declaration of a Swift struct.
class StructDeclaration extends AstNode implements CompoundDeclaration {
  @override
  String id;

  @override
  String name;

  @override
  covariant List<PropertyDeclaration> properties;

  @override
  covariant List<MethodDeclaration> methods;

  @override
  List<DeclaredType<ProtocolDeclaration>> conformedProtocols;

  @override
  List<GenericType> typeParams;

  @override
  List<InitializerDeclaration> initializers;

  @override
  OuterNestableDeclaration? nestingParent;

  @override
  List<InnerNestableDeclaration> nestedDeclarations;

  StructDeclaration({
    required this.id,
    required this.name,
    this.properties = const [],
    this.methods = const [],
    this.initializers = const [],
    this.conformedProtocols = const [],
    this.typeParams = const [],
    this.nestingParent,
    this.nestedDeclarations = const [],
  });

  @override
  void visit(Visitation visitation) => visitation.visitStructDeclaration(this);

  @override
  void visitChildren(Visitor visitor) {
    super.visitChildren(visitor);
    visitor.visitAll(properties);
    visitor.visitAll(methods);
    visitor.visitAll(conformedProtocols);
    visitor.visitAll(typeParams);
    visitor.visitAll(initializers);
    visitor.visit(nestingParent);
    visitor.visitAll(nestedDeclarations);
  }
}
