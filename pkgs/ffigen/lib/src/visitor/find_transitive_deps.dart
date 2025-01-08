// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../code_generator.dart';
import '../config_provider/config.dart' show Config;

import 'ast.dart';

class FindTransitiveDepsVisitation extends Visitation {
  final transitives = <Binding>{};

  @override
  void visitBinding(Binding node) {
    if (node.isObjCImport) return;
    node.visitChildren(visitor);
    transitives.add(node);
  }
}

class FindDirectTransitiveDepsVisitation extends Visitation {
  final Config config;
  final Set<Binding> includes;
  final directTransitives = <Binding>{};

  FindDirectTransitiveDepsVisitation(this.config, this.includes);

  void _visitImpl(Binding node, bool forceVisitChildren) {
    if (node.isObjCImport) return;
    directTransitives.add(node);
    if (forceVisitChildren || includes.contains(node)) {
      node.visitChildren(visitor);
    }
  }

  @override
  void visitObjCInterface(ObjCInterface node) {
    _visitImpl(node, config.includeTransitiveObjCInterfaces);

    // Always visit the super type, regardless of whether the node is directly
    // included. This ensures that super types of stubs are also stubs, rather
    // than being omitted like the rest of the stub's children.
    visitor.visit(node.superType);

    // Visit the categories of built-in interfaces that have been explicitly
    // included. https://github.com/dart-lang/native/issues/1820
    if (node.isObjCImport && includes.contains(node)) {
      visitor.visitAll(node.categories);
    }
  }

  @override
  void visitObjCCategory(ObjCCategory node) {
    _visitImpl(node, config.includeTransitiveObjCCategories);

    // Same as visitObjCInterface's visit of superType.
    visitor.visit(node.parent);
  }

  @override
  void visitObjCProtocol(ObjCProtocol node) =>
      _visitImpl(node, config.includeTransitiveObjCInterfaces);

  @override
  void visitBinding(Binding node) => _visitImpl(node, true);
}
