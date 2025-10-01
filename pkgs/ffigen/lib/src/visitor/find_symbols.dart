// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../code_generator/binding.dart';
import '../code_generator/func_type.dart';
import '../code_generator/objc_built_in_functions.dart';
import '../code_generator/objc_category.dart';
import '../code_generator/objc_interface.dart';
import '../code_generator/objc_methods.dart';
import '../code_generator/objc_protocol.dart';
import '../code_generator/scope.dart';
import '../code_generator/typealias.dart';
import '../context.dart';
import 'ast.dart';

// Visitation to create all the scopes and all the symbols to the correct scope.
//
// A Binding's name Symbol is always added to the root scope. If the Binding has
// a local scope, its other symbols (eg a struct's field names) are added to
// that local scope. If the Binding doesn't have a local scope all its symbols
// are added to the root scope.
//
// Most local scopes are parented to the root scope (eg functions or structs),
// but some are parented to a non-root scope (eg ObjC interfaces are parented to
// their supertype).
class FindSymbolsVisitation extends Visitation {
  final Context context;
  final Set<Binding> bindings;
  Scope currentScope;

  FindSymbolsVisitation(this.context, this.bindings)
    : currentScope = context.rootScope;

  void visitInsideScope(AstNode node, Scope localScope) {
    final oldScope = currentScope;
    currentScope = localScope;
    node.visitChildren(visitor);
    currentScope = oldScope;
  }

  void visitHasLocalScope(
    HasLocalScope node,
    Scope parentScope,
    String debugName,
  ) {
    if (!node.localScopeFilled) {
      node.localScope = parentScope.addChild(debugName);
    }
    visitInsideScope(node, node.localScope);
  }

  // Note: node should be Binding & HasLocalScope, but Dart doesn't have
  // intersection types.
  void visitBindingHasLocalScope(Binding node, Scope parentScope) {
    // Explicitly add the Binding's symbol to the root scope before visiting
    // the children, because the name shouldn't be part of the local scope.
    // Visiting the children will also add the symbol to the local scope,
    // but that's ok because `Scope.fillNames` is built to handle that.
    context.rootScope.add(node.symbol);
    visitHasLocalScope(node as HasLocalScope, parentScope, node.originalName);
  }

  @override
  void visitSymbol(Symbol node) => currentScope.add(node);

  @override
  void visitBinding(Binding node) {
    if (node is HasLocalScope) {
      visitBindingHasLocalScope(node, context.rootScope);
    } else {
      visitInsideScope(node, context.rootScope);
    }
  }

  @override
  void visitTypealias(Typealias node) {
    // If the typealias is not in the bindings, that means we're not generating
    // bindings for it, so we shouldn't add its name to the scope. But we
    // still need to visit its target type. Otherwise, if the target type is
    // only referred to via this alias, then we won't visit it at all.
    if (!bindings.contains(node)) {
      visitor.visit(node.type);
    } else {
      visitInsideScope(node, context.rootScope);
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
    fillObjCInterfaceScopes(node.parent);
    visitBindingHasLocalScope(node, node.parent.localScope);
  }

  @override
  void visitObjCInterface(ObjCInterface node) {
    context.rootScope.add(node.symbol);
    fillObjCInterfaceScopes(node.superType);
    if (!node.generateAsStub) {
      visitBindingHasLocalScope(
        node,
        node.superType?.localScope ?? context.rootScope,
      );
    }
  }

  @override
  void visitObjCProtocol(ObjCProtocol node) {
    context.rootScope.add(node.symbol);
    node.localScope = context.rootScope.addChild(
      node.originalName,
      preUsedNames: objCObjectBaseMethods,
    );
    if (!node.generateAsStub) {
      visitBindingHasLocalScope(node, context.rootScope);
    }
  }

  @override
  void visitFunctionType(FunctionType node) =>
      visitHasLocalScope(node, context.rootScope, 'FunctionType');

  @override
  void visitObjCMsgSendFunc(ObjCMsgSendFunc node) =>
      visitHasLocalScope(node, context.rootScope, 'objc_msgSend');

  @override
  void visitObjCMethod(ObjCMethod node) {
    currentScope.add(node.symbol);
    currentScope.add(node.protocolMethodName);
    visitHasLocalScope(node, context.rootScope, node.originalName);
  }

  void fillObjCInterfaceScopes(ObjCInterface? node) {
    if (node == null || node.localScopeFilled) return;
    fillObjCInterfaceScopes(node.superType);
    node.localScope = (node.superType?.localScope ?? context.rootScope)
        .addChild(node.originalName, preUsedNames: objCObjectBaseMethods);
  }
}
