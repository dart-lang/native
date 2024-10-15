// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../code_generator.dart';

import 'ast.dart';

class ListBindingsVisitation extends Visitation {
  final bindings = <Binding>[];

  @override
  void visitNoLookUpBinding(NoLookUpBinding node) {
    if (!node.isObjCImport) visitBinding(node);
  }

  @override
  void visitBinding(Binding node) {
    node.visitChildren(visitor);
    bindings.add(node);
  }
}
