// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../config.dart';
import '../_core/interfaces/availability.dart';
import '../_core/interfaces/nestable_declaration.dart';
import '../_core/shared/referred_type.dart';
import '../ast_node.dart';

/// Describes the declaration of a Swift class.
class TypealiasDeclaration extends AstNode implements InnerNestableDeclaration {
  @override
  final String id;

  @override
  final String name;

  @override
  InputConfig? source;

  @override
  List<AvailabilityInfo> availability;

  final ReferredType target;

  @override
  OuterNestableDeclaration? nestingParent;

  TypealiasDeclaration({
    required this.id,
    required this.name,
    required this.source,
    required this.target,
    required this.availability,
  });

  @override
  void visit(Visitation visitation) =>
      visitation.visitTypealiasDeclaration(this);

  @override
  void visitChildren(Visitor visitor) {
    super.visitChildren(visitor);
    visitor.visit(target);
  }
}
