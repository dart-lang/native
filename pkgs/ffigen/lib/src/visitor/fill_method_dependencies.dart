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

class _MethodDepAdderVisitation extends Visitation {
  final Set<Binding> _bindings;

  _MethodDepAdderVisitation(this._bindings);

  @override
  void visitBinding(Binding node) {
    if (!_bindings.contains(node)) {
      node.visitChildren(visitor);
      _bindings.add(node);
    }
  }
}
