// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../ast_node.dart';
import 'declaration.dart';

/// A Swift entity that can contain other declarations.
abstract interface class OuterNestableDeclaration implements Declaration, AstNode {
  abstract final List<InnerNestableDeclaration> nestedDeclarations;
}

/// A Swift entity that can be nested inside other declarations.
abstract interface class InnerNestableDeclaration implements Declaration, AstNode {
  abstract OuterNestableDeclaration? nestingParent;
}

extension FillNestingParents on List<InnerNestableDeclaration> {
  void fillNestingParents(OuterNestableDeclaration parent) {
    for (final nested in this) {
      assert(nested.nestingParent == null);
      nested.nestingParent = parent;
    }
  }
}
