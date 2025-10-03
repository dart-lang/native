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
import '../context.dart';
import 'ast.dart';

// Visitation to create all the scopes.
//
// Most local scopes are parented to the root scope (eg functions or structs),
// but some are parented to a non-root scope (eg ObjC interfaces are parented to
// their supertype).
//
// We first do a pass with orderedPass = true, which ensures that supertypes are
// visited before subtypes (but will miss some AST nodes), so that the parenting
// relationships between the ObjC object scopes are setup correctly. Then we do
// a pass with orderedPass = false, to catch the AST nodes that weren't hit in
// the first pass.
class CreateScopesVisitation extends Visitation {
  final Context context;
  final Set<Binding> bindings;
  final bool orderedPass;

  CreateScopesVisitation(
    this.context,
    this.bindings, {
    required this.orderedPass,
  });

  Scope createScope(
    HasLocalScope node,
    Scope parentScope,
    String debugName, {
    Set<String> preUsedNames = const {},
  }) {
    if (!node.localScopeFilled) {
      node.localScope = parentScope.addChild(
        debugName,
        preUsedNames: preUsedNames,
      );
    }
    return node.localScope;
  }

  void visitHasLocalScope(HasLocalScope node, String debugName) {
    createScope(node, context.rootScope, debugName);
    node.visitChildren(visitor);
  }

  @override
  void visitBinding(Binding node) {
    if (node case final HasLocalScope hasLocalScope) {
      visitHasLocalScope(hasLocalScope, node.originalName);
    } else {
      node.visitChildren(visitor);
    }
  }

  @override
  void visitFunctionType(FunctionType node) =>
      visitHasLocalScope(node, 'FunctionType');

  @override
  void visitObjCMsgSendFunc(ObjCMsgSendFunc node) =>
      visitHasLocalScope(node, 'objc_msgSend');

  static const objCObjectBaseMethods = {
    'ref',
    'toString',
    'hashCode',
    'runtimeType',
    'noSuchMethod',
  };

  void visitObjCMethods(ObjCMethods node, Scope localScope) {
    for (final m in node.methods) {
      createScope(m, localScope, m.originalName);
    }
  }

  @override
  void visitObjCCategory(ObjCCategory node) {
    if (!bindings.contains(node)) return;
    node.visitChildren(visitor, typeGraphOnly: orderedPass);
    visitObjCMethods(
      node,
      createScope(
        node,
        node.parent.localScope,
        node.originalName,
        preUsedNames: objCObjectBaseMethods,
      ),
    );
  }

  @override
  void visitObjCInterface(ObjCInterface node) {
    if (node.generateAsStub) {
      // The supertype heirarchy is generated even if this is a stub.
      visitor.visit(node.superType);
    } else {
      node.visitChildren(visitor, typeGraphOnly: orderedPass);
    }
    visitObjCMethods(
      node,
      createScope(
        node,
        node.superType?.localScope ?? context.rootScope,
        node.originalName,
        preUsedNames: objCObjectBaseMethods,
      ),
    );
  }

  @override
  void visitObjCProtocol(ObjCProtocol node) {
    if (!node.generateAsStub) {
      node.visitChildren(visitor, typeGraphOnly: orderedPass);
    }
    visitObjCMethods(
      node,
      createScope(
        node,
        context.rootScope,
        node.originalName,
        preUsedNames: objCObjectBaseMethods,
      ),
    );
  }
}
