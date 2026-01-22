// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../code_generator.dart';
import '../context.dart';
import 'ast.dart';

class FillMethodDependenciesVisitation extends Visitation {
  final Set<Binding> finalBindings;
  late final Visitor _adder;

  FillMethodDependenciesVisitation(Context context, Set<Binding> bindings) :
      finalBindings = bindings.toSet() {
    _adder = Visitor(context, _MethodDepAdderVisitation(finalBindings));
  }

  @override
  void visitAstNode(AstNode node) {
    // Don't visit children by default.
  }

  @override
  void visitObjCInterface(ObjCInterface node) {
    if (!finalBindings.contains(node)) return;

    if (!node.generateAsStub) {
      node.visitChildren(visitor);
      for (final method in node.methods) {
        final msgSend = method.fillMsgSend();
        _adder.visit(msgSend);
        if (Visitor.debuggable(msgSend)) {
          print('!!! ${node.runtimeType}(${node.originalName})');
        }
      }
    }
  }

  @override
  void visitObjCCategory(ObjCCategory node) {
    if (!finalBindings.contains(node)) return;
    node.visitChildren(visitor);

    for (final method in node.methods) {
      final msgSend = method.fillMsgSend();
      _adder.visit(msgSend);
      if (Visitor.debuggable(msgSend)) {
        print('!!! ${node.runtimeType}(${node.originalName})');
      }
    }
  }

  @override
  void visitObjCProtocol(ObjCProtocol node) {
    if (!finalBindings.contains(node)) return;

    if (!node.generateAsStub) {
      node.visitChildren(visitor);
      for (final method in node.methods) {
        _adder.visit(method.fillProtocolBlock());
        final msgSend = method.fillMsgSend();
        _adder.visit(msgSend);
        if (Visitor.debuggable(msgSend)) {
          print('!!! ${node.runtimeType}(${node.originalName})');
        }
      }
    }
  }
}

// Adding the method deps can introduce some new bindings, so add those to the
// final bindings set.
class _MethodDepAdderVisitation extends Visitation {
  final Set<Binding> finalBindings;

  _MethodDepAdderVisitation(this.finalBindings);

  @override
  void visitAstNode(AstNode node) {
    // Don't visit children by default.
  }

  @override
  void visitObjCMsgSendFunc(ObjCMsgSendFunc node) =>
      node.visitChildren(visitor);

  @override
  void visitObjCMsgSendVariantFunc(ObjCMsgSendVariantFunc node) =>
      finalBindings.add(node);

  @override
  void visitObjCBlock(ObjCBlock node) {
    node.visitChildren(visitor);
    finalBindings.add(node);
  }

  @override
  void visitFunc(Func node) => finalBindings.add(node);

  @override
  void visitObjCProtocolMethodTrampoline(ObjCProtocolMethodTrampoline node) =>
      node.visitChildren(visitor);

  @override
  void visitObjCBlockWrapperFuncs(ObjCBlockWrapperFuncs node) =>
      node.visitChildren(visitor);
}
