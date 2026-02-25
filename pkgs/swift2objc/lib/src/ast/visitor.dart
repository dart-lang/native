// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../context.dart';
import '_core/interfaces/compound_declaration.dart';
import '_core/interfaces/declaration.dart';
import '_core/interfaces/function_declaration.dart';
import '_core/interfaces/variable_declaration.dart';
import '_core/shared/referred_type.dart';
import 'ast_node.dart';
import 'declarations/built_in/built_in_declaration.dart';
import 'declarations/compounds/class_declaration.dart';
import 'declarations/compounds/enum_declaration.dart';
import 'declarations/compounds/members/initializer_declaration.dart';
import 'declarations/compounds/members/method_declaration.dart';
import 'declarations/compounds/members/property_declaration.dart';
import 'declarations/compounds/protocol_declaration.dart';
import 'declarations/compounds/struct_declaration.dart';
import 'declarations/globals/globals.dart';
import 'declarations/typealias_declaration.dart';

/// Wrapper around [Visitation] to be used by callers.
///
/// The [Visitor] determines the traversal order of the AST, and has helper
/// methods that the [Visitation] calls to visit nodes. The [Visitation] is
/// responsible for what happens at each visited node. The [Visitor] is generic
/// and the [Visitation] contains the specific logic of the traversal.
final class Visitor {
  Visitor(this._context, this._visitation, {bool debug = false})
    : _debug = debug {
    _visitation.visitor = this;
  }

  final Context _context;
  final Visitation _visitation;
  final _seen = <AstNode>{};
  final bool _debug;
  int _indentLevel = 0;

  /// Visits a node.
  void visit(AstNode? node) {
    if (node == null) return;
    if (_debug) _context.logger.info('${'  ' * _indentLevel++}$node');
    if (!_seen.contains(node)) {
      _seen.add(node);
      node.visit(_visitation);
    }
    if (_debug) --_indentLevel;
  }

  /// Helper method for visiting an iterable of nodes.
  void visitAll(Iterable<AstNode> nodes) {
    for (final node in nodes) {
      visit(node);
    }
  }
}

/// Base class for all AST visitations.
///
/// Callers should wrap their [Visitation] in a [Visitor] and invoke its
/// methods, instead of interacting directly with the [Visitation]. This
/// distinction is why [Visitor] and [Visitation] are seperate classes.
///
/// The `visitFoo` methods in this class should reflect the inheritance
/// hierarchy of all AstNodes. Eg `visitChild` should default to calling
/// `visitBase` which should default to calling `visitAstNode`.
///
/// Implementers should implement the specific visit methods for each node type
/// they care about. Any visit methods not implemented will default to calling
/// `node.visitChildren`, which visits the node's children but otherwise doesn't
/// alter the node itself.
abstract class Visitation {
  late final Visitor visitor;

  void visitReferredType(ReferredType node) => visitAstNode(node);
  void visitDeclaredType(DeclaredType node) => visitReferredType(node);
  void visitGenericType(GenericType node) => visitReferredType(node);
  void visitOptionalType(OptionalType node) => visitReferredType(node);
  void visitInoutType(InoutType node) => visitReferredType(node);
  void visitDeclaration(Declaration node) => visitAstNode(node);
  void visitBuiltInDeclaration(BuiltInDeclaration node) =>
      visitDeclaration(node);
  void visitInitializerDeclaration(InitializerDeclaration node) =>
      visitDeclaration(node);
  void visitFunctionDeclaration(FunctionDeclaration node) =>
      visitDeclaration(node);
  void visitMethodDeclaration(MethodDeclaration node) =>
      visitFunctionDeclaration(node);
  void visitGlobalFunctionDeclaration(GlobalFunctionDeclaration node) =>
      visitFunctionDeclaration(node);
  void visitVariableDeclaration(VariableDeclaration node) =>
      visitDeclaration(node);
  void visitPropertyDeclaration(PropertyDeclaration node) =>
      visitVariableDeclaration(node);
  void visitGlobalVariableDeclaration(GlobalVariableDeclaration node) =>
      visitVariableDeclaration(node);
  void visitCompoundDeclaration(CompoundDeclaration node) =>
      visitDeclaration(node);
  void visitClassDeclaration(ClassDeclaration node) =>
      visitCompoundDeclaration(node);
  void visitProtocolDeclaration(ProtocolDeclaration node) =>
      visitCompoundDeclaration(node);
  void visitStructDeclaration(StructDeclaration node) =>
      visitCompoundDeclaration(node);
  void visitEnumDeclaration(EnumDeclaration node) =>
      visitCompoundDeclaration(node);
  void visitTypealiasDeclaration(TypealiasDeclaration node) =>
      visitDeclaration(node);

  /// Default behavior for all visit methods.
  void visitAstNode(AstNode node) => node.visitChildren(visitor);
}

T visit<T extends Visitation>(
  Context context,
  T visitation,
  Iterable<AstNode> roots, {
  bool debug = false,
}) {
  Visitor(context, visitation, debug: debug).visitAll(roots);
  return visitation;
}
