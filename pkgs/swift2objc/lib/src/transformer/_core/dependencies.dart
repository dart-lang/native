// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../ast/_core/interfaces/compound_declaration.dart';
import '../../ast/_core/interfaces/declaration.dart';
import '../../ast/declarations/compounds/class_declaration.dart';
import '../../ast/declarations/compounds/protocol_declaration.dart';
import '../../ast/declarations/compounds/struct_declaration.dart';
import '../../ast/declarations/globals/globals.dart';
import '../../ast/visitor.dart';

class ListDeclsVisitation extends Visitation {
  final Set<Declaration> includes;
  final Set<Declaration> directTransitives;
  final topLevelDecls = <Declaration>{};
  final stubDecls = <Declaration>{};

  ListDeclsVisitation(this.includes, this.directTransitives);

  @override
  void visitGlobalFunctionDeclaration(GlobalFunctionDeclaration node) {
    node.visitChildren(visitor);
    topLevelDecls.add(node);
  }

  @override
  void visitGlobalVariableDeclaration(GlobalVariableDeclaration node) {
    node.visitChildren(visitor);
    topLevelDecls.add(node);
  }

  @override
  void visitCompoundDeclaration(CompoundDeclaration node) {
    node.visitChildren(visitor);

    // Don't add nested classes etc to the top level declarations.
    if (node.nestingParent == null) topLevelDecls.add(node);

    if (!includes.contains(node) && directTransitives.contains(node)) {
      stubDecls.add(node);
    }
  }
}

class FindDirectTransitiveDepsVisitation extends Visitation {
  final Set<Declaration> includes;
  final directTransitives = <Declaration>{};

  FindDirectTransitiveDepsVisitation(this.includes);

  void _visitImpl(Declaration node, bool forceVisitChildren) {
    directTransitives.add(node);
    if (forceVisitChildren || includes.contains(node)) {
      node.visitChildren(visitor);
    }
  }

  @override
  void visitDeclaration(Declaration node) => _visitImpl(node, true);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    _visitImpl(node, false);

    // Always visit the super type, protocols, and nesting parent, regardless of
    // whether the node is directly included. This ensures that super types etc
    // of stubs are also stubs, rather than being omitted like the rest of the
    // stub's children.
    visitor.visit(node.superClass);
    visitor.visitAll(node.conformedProtocols);
    visitor.visit(node.nestingParent);
  }

  @override
  void visitProtocolDeclaration(ProtocolDeclaration node) {
    _visitImpl(node, false);

    // See visitClassDeclaration.
    visitor.visitAll(node.conformedProtocols);
    visitor.visit(node.nestingParent);
  }

  @override
  void visitStructDeclaration(StructDeclaration node) {
    _visitImpl(node, false);

    // See visitClassDeclaration.
    visitor.visitAll(node.conformedProtocols);
    visitor.visit(node.nestingParent);
  }
}

// Include everything explicitly included
// Include direct transitive deps as stubs
//   func/method arg/return types
//   propertie types
//   entire super type chain, including protocols
