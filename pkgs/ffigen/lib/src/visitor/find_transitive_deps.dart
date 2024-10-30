// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../code_generator.dart';

import 'ast.dart';

class FindTransitiveDepsVisitation extends Visitation {
  final transitives = <Binding>{};

  @override
  void visitBinding(Binding node) {
    node.visitChildren(visitor);
    transitives.add(node);
  }
}

class FindDirectTransitiveDepsVisitation extends Visitation {
  final Set<Binding> includes;
  final directTransitives = <Binding>{};

  FindDirectTransitiveDepsVisitation(this.includes);

  @override
  void visitObjCInterface(ObjCInterface node) {
    visitBinding(node);

    // Always visit the super type, regardless of whether the node is directly
    // included. This ensures that super types of stubs are also stubs, rather
    // than being omitted like the rest of the stub's children.
    visitor.visit(node.superType);
  }

  @override
  void visitBinding(Binding node) {
    if (includes.contains(node)) {
      node.visitChildren(visitor);
    } else {
      directTransitives.add(node);
    }
  }
}
