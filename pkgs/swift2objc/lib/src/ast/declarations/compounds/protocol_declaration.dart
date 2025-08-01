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

/// Describes the declaration of a Swift protocol.
class ProtocolDeclaration extends AstNode implements CompoundDeclaration {
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

  ProtocolDeclaration({
    required this.id,
    required this.name,
    required this.properties,
    required this.methods,
    required this.initializers,
    required this.conformedProtocols,
    required this.typeParams,
    this.nestingParent,
    this.nestedDeclarations = const [],
  });

  @override
  void visit(Visitation visitation) =>
      visitation.visitProtocolDeclaration(this);

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
