// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../_core/interfaces/declaration.dart';
import '../_core/interfaces/nestable_declaration.dart';
import '../_core/shared/referred_type.dart';
import '../ast_node.dart';

/// Describes the declaration of a Swift class.
class TypealiasDeclaration extends AstNode implements InnerNestableDeclaration {
  @override
  final String id;

  @override
  final String name;

  final ReferredType target;

  @override
  OuterNestableDeclaration? nestingParent;

  TypealiasDeclaration(
      {required this.id, required this.name, required this.target});

  @override
  void visit(Visitation visitation) =>
      visitation.visitTypealiasDeclaration(this);

  @override
  void visitChildren(Visitor visitor) {
    super.visitChildren(visitor);
    visitor.visit(target);
  }
}

// TODO:
//  - Fix bug where nested typealias is appearing both nested and global
//  - Fix analysis
//  - Add a test for aliases of non-trivial types
//      eg a nullable or specialized generic
