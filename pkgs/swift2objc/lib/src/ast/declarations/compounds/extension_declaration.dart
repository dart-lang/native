// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../../config.dart';
import '../../_core/interfaces/availability.dart';
import '../../_core/interfaces/declaration.dart';
import '../../_core/shared/referred_type.dart';
import '../../ast_node.dart';
import 'members/initializer_declaration.dart';
import 'members/method_declaration.dart';
import 'members/property_declaration.dart';

class ExtensionDeclaration extends AstNode implements Declaration {
  @override
  String id;

  @override
  String name;

  @override
  InputConfig? source;

  @override
  List<AvailabilityInfo> availability;

  @override
  final int? lineNumber;

  DeclaredType<Declaration> extendedType;

  List<PropertyDeclaration> properties;
  List<MethodDeclaration> methods;
  List<InitializerDeclaration> initializers;

  ExtensionDeclaration({
    required this.id,
    required this.name,
    required this.source,
    required this.availability,
    required this.extendedType,
    this.lineNumber,
    this.properties = const [],
    this.methods = const [],
    this.initializers = const [],
  });

  @override
  void visit(Visitation visitation) =>
      visitation.visitExtensionDeclaration(this);

  @override
  void visitChildren(Visitor visitor) {
    super.visitChildren(visitor);
    visitor.visit(extendedType);
    visitor.visitAll(properties);
    visitor.visitAll(methods);
    visitor.visitAll(initializers);
  }
}
