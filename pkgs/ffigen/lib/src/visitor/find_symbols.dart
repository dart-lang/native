// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../code_generator/binding.dart';
import '../code_generator/func_type.dart';
import '../code_generator/namespace.dart';
import '../code_generator/objc_built_in_functions.dart';
import '../code_generator/objc_category.dart';
import '../code_generator/objc_interface.dart';
import '../code_generator/objc_methods.dart';
import '../code_generator/objc_protocol.dart';
import '../code_generator/typealias.dart';
import '../context.dart';
import 'ast.dart';

// Visitation to create all the namespaces and all the symbols to the correct
// namespace.
//
// A Binding's name Symbol is always added to the root namespace. If the Binding
// has a local namespace, its other symbols (eg a struct's field names) are
// added to that local namespace. If the Binding doesn't have a local namespace
// all its symbols are added to the root namespace.
//
// Most local namespaces are parented to the root namespace (eg functions or
// structs), but some are parented to a non-root namespace (eg ObjC interfaces
// are parented to their supertype).
class FindSymbolsVisitation extends Visitation {
  final Context context;
  final Set<Binding> bindings;
  Namespace currentNamespace;

  FindSymbolsVisitation(this.context, this.bindings)
    : currentNamespace = context.rootNamespace;

  void visitInsideNamespace(AstNode node, Namespace localNamespace) {
    final oldNamespace = currentNamespace;
    currentNamespace = localNamespace;
    node.visitChildren(visitor);
    currentNamespace = oldNamespace;
  }

  void visitHasLocalNamespace(
    HasLocalNamespace node,
    Namespace parentNamespace,
    String debugName,
  ) {
    if (!node.localNamespaceFilled) {
      node.localNamespace = parentNamespace.addNamespace(debugName);
    }
    visitInsideNamespace(node, node.localNamespace);
  }

  // Note: node should be Binding & HasLocalNamespace, but Dart doesn't have
  // intersection types.
  void visitBindingHasLocalNamespace(Binding node, Namespace parentNamespace) {
    // Explicitly add the Binding's symbol to the root namespace before visiting
    // the children, because the name shouldn't be part of the local namespace.
    // Visiting the children will also add the symbol to the local namespace,
    // but that's ok because `Namespace.fillNames` is built to handle that.
    context.rootNamespace.add(node.symbol);
    visitHasLocalNamespace(
      node as HasLocalNamespace,
      parentNamespace,
      node.originalName,
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

  @override
  void visitTypealias(Typealias node) {
    // If the typealias is not in the bindings, that means we're not generating
    // bindings for it, so we shouldn't add its name to the namespace. But we
    // still need to visit its target type. Otherwise, if the target type is
    // only referred to via this alias, then we won't visit it at all.
    if (!bindings.contains(node)) {
      visitor.visit(node.type);
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
    if (!bindings.contains(node)) return;
    fillObjCInterfaceNamespaces(node.parent);
    visitBindingHasLocalNamespace(node, node.parent.localNamespace);
  }

  @override
  void visitObjCInterface(ObjCInterface node) {
    context.rootNamespace.add(node.symbol);
    fillObjCInterfaceNamespaces(node.superType);
    if (!node.generateAsStub) {
      visitBindingHasLocalNamespace(
        node,
        node.superType?.localNamespace ?? context.rootNamespace,
      );
    }
  }

  @override
  void visitObjCProtocol(ObjCProtocol node) {
    context.rootNamespace.add(node.symbol);
    node.localNamespace = context.rootNamespace.addNamespace(
      node.originalName,
      preUsedNames: objCObjectBaseMethods,
    );
    if (!node.generateAsStub) {
      visitBindingHasLocalNamespace(node, context.rootNamespace);
    }
  }

  @override
  void visitFunctionType(FunctionType node) =>
      visitHasLocalNamespace(node, context.rootNamespace, 'FunctionType');

  @override
  void visitObjCMsgSendFunc(ObjCMsgSendFunc node) =>
      visitHasLocalNamespace(node, context.rootNamespace, 'objc_msgSend');

  @override
  void visitObjCMethod(ObjCMethod node) {
    currentNamespace.add(node.symbol);
    currentNamespace.add(node.protocolMethodName);
    visitHasLocalNamespace(node, context.rootNamespace, node.originalName);
  }

  void fillObjCInterfaceNamespaces(ObjCInterface? node) {
    if (node == null || node.localNamespaceFilled) return;
    fillObjCInterfaceNamespaces(node.superType);
    node.localNamespace =
        (node.superType?.localNamespace ?? context.rootNamespace).addNamespace(
          node.originalName,
          preUsedNames: objCObjectBaseMethods,
        );
  }
}
