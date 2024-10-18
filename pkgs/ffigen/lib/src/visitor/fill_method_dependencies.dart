// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../code_generator.dart';

import 'ast.dart';

class FillMethodDependenciesVisitation extends Visitation {
  @override
  void visitObjCInterface(ObjCInterface node) {
    node.visitChildren(visitor);

    for (final method in node.methods) {
      method.fillMsgSend();
    }
  }

  @override
  void visitObjCProtocol(ObjCProtocol node) {
    node.visitChildren(visitor);

    for (final method in node.methods) {
      method.fillProtocolBlock();
    }
  }
}
