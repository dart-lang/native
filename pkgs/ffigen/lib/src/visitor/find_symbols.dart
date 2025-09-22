// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../code_generator/binding.dart';
import '../code_generator/namespace.dart';
import '../code_generator/objc_built_in_functions.dart';
import '../code_generator/objc_category.dart';
import '../code_generator/objc_interface.dart';
import '../code_generator/objc_methods.dart';
import '../code_generator/objc_protocol.dart';
import '../context.dart';
import 'ast.dart';

// Visitation to add all the symbols to the correct namespace.
//
// This visitation is based on the assumption that all Bindings' name symbols
// live in the root namespace. The other names inside a binding (eg function
// params) may be nested in several layers of namespaces.
class FindSymbolsVisitation extends Visitation {
  final Context context;
  Namespace currentNamespace;

  FindSymbolsVisitation(this.context)
    : currentNamespace = context.rootNamespace;

  void visitInsideNamespace(AstNode node, Namespace localNamespace) {
    final oldNamespace = currentNamespace;
    currentNamespace = localNamespace;
    node.visitChildren(visitor);
    currentNamespace = oldNamespace;
  }

  void visitHasLocalNamespace(
    HasLocalNamespace node,
    Namespace parentNamespace, {
    Set<String> extraKeywords = const {},
  }) {
    node.localNamespace = parentNamespace.addNamespace(
      extraKeywords: extraKeywords,
    );
    visitInsideNamespace(node, node.localNamespace);
  }

  // Node: node should be Binding & HasLocalNamespace, but Dart doesn't have
  // intersection types.
  void visitBindingHasLocalNamespace(
    Binding node,
    Namespace parentNamespace, {
    Set<String> extraKeywords = const {},
  }) {
    // Explicitly add the Binding's symbol to the root namespace before visiting
    // the children, because the name shouldn't be part of the local namespace.
    // Visiting the children will also add the symbol to the local namespace,
    // but that's ok because `Namespace.fillNames` is built to handle that.
    context.rootNamespace.add(node.symbol);
    visitHasLocalNamespace(
      node as HasLocalNamespace,
      parentNamespace,
      extraKeywords: extraKeywords,
    );
  }

  @override
  void visitSymbol(Symbol node) => currentNamespace.add(node);

  @override
  void visitBinding(Binding node) {
    if (node is HasLocalNamespace) {
      visitBindingHasLocalNamespace(node, context.rootNamespace);
    } else {
      visitInsideNamespace(node, context.rootNamespace);
    }
  }

  static const objCObjectBaseMethods = {
    'ref',
    'toString',
    'hashCode',
    'runtimeType',
    'noSuchMethod',
  };

  @override
  void visitObjCCategory(ObjCCategory node) {
    visitor.visit(node.parent);
    visitBindingHasLocalNamespace(
      node,
      node.parent.localNamespace,
      extraKeywords: objCObjectBaseMethods,
    );
  }

  @override
  void visitObjCInterface(ObjCInterface node) {
    visitor.visit(node.superType);
    visitBindingHasLocalNamespace(
      node,
      node.superType?.localNamespace ?? context.rootNamespace,
      extraKeywords: objCObjectBaseMethods,
    );
  }

  @override
  void visitObjCProtocol(ObjCProtocol node) => visitBindingHasLocalNamespace(
    node,
    context.rootNamespace,
    extraKeywords: objCObjectBaseMethods,
  );

  @override
  void visitObjCMsgSendFunc(ObjCMsgSendFunc node) =>
      visitHasLocalNamespace(node, context.rootNamespace);

  @override
  void visitObjCMethod(ObjCMethod node) {
    currentNamespace.add(node.symbol);
    currentNamespace.add(node.protocolMethodName);
    visitHasLocalNamespace(node, context.rootNamespace);
  }
}
