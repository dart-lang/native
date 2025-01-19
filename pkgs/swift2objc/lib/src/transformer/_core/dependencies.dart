// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../ast/_core/interfaces/compound_declaration.dart';
import '../../ast/_core/interfaces/declaration.dart';
import '../../ast/declarations/globals/globals.dart';
import '../../ast/visitor.dart';

class DependencyVisitation extends Visitation {
  Set<Declaration> topLevelDeclarations = {};

  @override
  void visitGlobalFunctionDeclaration(GlobalFunctionDeclaration node) {
    node.visitChildren(visitor);
    topLevelDeclarations.add(node);
  }

  @override
  void visitGlobalVariableDeclaration(GlobalVariableDeclaration node) {
    node.visitChildren(visitor);
    topLevelDeclarations.add(node);
  }

  @override
  void visitCompoundDeclaration(CompoundDeclaration node) {
    node.visitChildren(visitor);

    // Don't add nested classes etc to the top level declarations.
    if (node.nestingParent == null) topLevelDeclarations.add(node);
  }
}
