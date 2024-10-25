// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../code_generator.dart';

import 'ast.dart';

/// Wrapper around [Visitation] to be used by callers.
final class Visitor {
  Visitor(this._visitation) {
    _visitation.visitor = this;
  }

  final Visitation _visitation;
  final _seen = <AstNode>{};

  /// Visits a node.
  void visit(AstNode? node) {
    if (node == null || _seen.contains(node)) return;
    _seen.add(node);
    node.visit(_visitation);
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
/// heirarchy of all AstNodes. Eg `visitChild` should default to calling
/// `visitBase` which should default to calling `visitAstNode`.
///
/// Implementers should implement the specific visit methods for each node type
/// they care about. Any visit methods not implemented will default to calling
/// `node.visitChildren`, which visits the node's children but otherwise doesn't
/// alter the node itself.
///
/// Note: [BindingType] is a subtype of both [Type] and [NoLookUpBinding], so
/// [visitBindingType] has to make a decision about which to delegate to. It
/// delegates to [visitNoLookUpBinding] as that tends to be more useful, so if
/// you need it to delegate to [visitType] you'll need to override it.
abstract class Visitation {
  late final Visitor visitor;

  void visitType(Type node) => visitAstNode(node);
  void visitBindingType(BindingType node) => visitNoLookUpBinding(node);
  void visitBinding(Binding node) => visitAstNode(node);
  void visitLookUpBinding(LookUpBinding node) => visitBinding(node);
  void visitNoLookUpBinding(NoLookUpBinding node) => visitBinding(node);
  void visitLibraryImport(NoLookUpBinding node) => visitBinding(node);
  void visitObjCInterface(ObjCInterface node) => visitBindingType(node);
  void visitObjCProtocol(ObjCProtocol node) => visitNoLookUpBinding(node);
  void visitStruct(Struct node) => visitCompound(node);
  void visitUnion(Union node) => visitCompound(node);
  void visitCompound(Compound node) => visitBindingType(node);
  void visitEnumClass(EnumClass node) => visitBindingType(node);
  void visitFunc(Func node) => visitLookUpBinding(node);
  void visitMacroConstant(MacroConstant node) => visitConstant(node);
  void visitUnnamedEnumConstant(UnnamedEnumConstant node) =>
      visitConstant(node);
  void visitConstant(Constant node) => visitNoLookUpBinding(node);
  void visitGlobal(Global node) => visitLookUpBinding(node);
  void visitTypealias(Typealias node) => visitBindingType(node);
  void visitPointerType(PointerType node) => visitType(node);

  /// Default behavior for all visit methods.
  void visitAstNode(AstNode node) => node..visitChildren(visitor);
}

T visit<T extends Visitation>(T visitation, Iterable<AstNode> roots) {
  Visitor(visitation).visitAll(roots);
  return visitation;
}
