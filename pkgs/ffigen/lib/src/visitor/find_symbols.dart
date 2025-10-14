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

// Visitation to add all the symbols to the correct scope.
//
// A Binding's name Symbol is always added to the root scope. If the Binding has
// a local scope, its other symbols (eg a struct's field names) are added to
// that local scope. If the Binding doesn't have a local scope all its symbols
// are added to the root scope.
class FindSymbolsVisitation extends Visitation {
  final Context context;
  final Set<Binding> bindings;
  Scope currentScope;

  FindSymbolsVisitation(this.context, this.bindings)
    : currentScope = context.rootScope;

  void insideScope(Scope localScope, void Function() fn) {
    final oldScope = currentScope;
    currentScope = localScope;
    fn();
    currentScope = oldScope;
  }

  void visitInsideScope(AstNode node, Scope localScope) =>
      insideScope(localScope, () => node.visitChildren(visitor));

  @override
  void visitSymbol(Symbol node) => currentScope.add(node);

  @override
  void visitBinding(Binding node) {
    // Explicitly add the Binding's symbol to the root scope before visiting
    // the children, because the name shouldn't be part of the local scope.
    // Visiting the children will also add the symbol to the local scope,
    // but that's ok because `Scope.fillNames` is built to handle that.
    context.rootScope.add(node.symbol);
    visitInsideScope(node, switch (node) {
      final HasLocalScope hasLocalScope => hasLocalScope.localScope,
      _ => context.rootScope,
    });
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

  @override
  void visitFunctionType(FunctionType node) =>
      visitInsideScope(node, node.localScope);

  @override
  void visitObjCMsgSendFunc(ObjCMsgSendFunc node) =>
      visitInsideScope(node, node.localScope);

  @override
  void visitObjCMethod(ObjCMethod node) => insideScope(
    node.localScope,
    () => node.visitChildren(visitor, omitMethodName: true),
  );

  void visitObjCMethods(ObjCMethods node) {
    // Since the methods are AST nodes, the visitor dedupes our implicit visits
    // to them. But we want to add each method's symbols to all its classes's,
    // so we explicitly visit them here.
    for (final m in node.methods) {
      node.methodNameScope!.add(m.symbol);
      node.methodNameScope!.add(m.protocolMethodName);
    }

    visitBinding(node as Binding); // All ObjCMethods are Bindings.
  }

  @override
  void visitObjCCategory(ObjCCategory node) {
    if (!bindings.contains(node)) return;
    visitObjCMethods(node);
  }

  @override
  void visitObjCInterface(ObjCInterface node) {
    context.rootScope.add(node.symbol);
    if (node.generateAsStub) {
      // The supertype heirarchy is generated even if this is a stub.
      visitor.visit(node.superType);
    } else {
      visitObjCMethods(node);
    }
  }

  @override
  void visitObjCProtocol(ObjCProtocol node) {
    context.rootScope.add(node.symbol);
    if (!node.generateAsStub) {
      visitObjCMethods(node);
    }
  }
}
