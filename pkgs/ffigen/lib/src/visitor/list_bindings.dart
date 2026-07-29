// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../code_generator.dart';
import '../config_provider/config.dart' show Config;
import '../strings.dart' as strings;

import 'ast.dart';

enum _IncludeBehavior {
  configOnly,
  configOrTransitive,
  configAndTransitive,
  configOrDirectTransitive,
}

class ListBindingsVisitation extends Visitation {
  final Config config;
  final Set<Binding> includes;
  final Set<Binding> transitives;
  final Set<Binding> directTransitives;
  final bindings = <Binding>{};

  ListBindingsVisitation(
    this.config,
    this.includes,
    Set<Binding> indirectTransitives,
    this.directTransitives,
  ) : transitives = {...indirectTransitives, ...directTransitives};

  void _add(Binding node) {
    node.visitChildren(visitor);
    bindings.add(node);
  }

  bool _shouldInclude(Binding node, _IncludeBehavior behavior) {
    if (node.isObjCImport) return false;
    switch (behavior) {
      case _IncludeBehavior.configOnly:
        return includes.contains(node);
      case _IncludeBehavior.configOrTransitive:
        return includes.contains(node) || transitives.contains(node);
      case _IncludeBehavior.configAndTransitive:
        return includes.contains(node) && transitives.contains(node);
      case _IncludeBehavior.configOrDirectTransitive:
        return includes.contains(node) || directTransitives.contains(node);
    }
  }

  bool _visitImpl(Binding node, _IncludeBehavior behavior) {
    if (_shouldInclude(node, behavior)) {
      _add(node);
      return true;
    }
    return false;
  }

  @override
  void visitBinding(Binding node) =>
      _visitImpl(node, _IncludeBehavior.configOrTransitive);

  @override
  void visitObjCInterface(ObjCInterface node) {
    final omit =
        node.unavailable || !_visitImpl(node, _IncludeBehavior.configOnly);

    if (omit && !node.isObjCImport && directTransitives.contains(node)) {
      node.generateAsStub = true;
      bindings.add(node);

      // Always visit the supertypes and protocols, even if this is a stub.
      visitor.visit(node.superType);
      visitor.visitAll(node.protocols);
    }

    if (node.includeCategories && includes.contains(node)) {
      // Always visit the categories of explicitly included interfaces, even if
      // they're built-in types: https://github.com/dart-lang/native/issues/1820
      visitor.visitAll(node.categories);
    }
  }

  @override
  void visitObjCCategory(ObjCCategory node) {
    final parentIncluded = includes.contains(node.parent);
    final behavior = node.parent.includeCategories && parentIncluded
        ? _IncludeBehavior.configOrDirectTransitive
        : _IncludeBehavior.configOnly;
    _visitImpl(node, behavior);
  }

  @override
  void visitObjCProtocol(ObjCProtocol node) {
    final omit =
        node.unavailable || !_visitImpl(node, _IncludeBehavior.configOnly);

    if (omit && !node.isObjCImport && directTransitives.contains(node)) {
      node.generateAsStub = true;
      bindings.add(node);

      // Always visit the super protocols, even if this is a stub.
      visitor.visitAll(node.superProtocols);
    }
  }

  @override
  void visitStruct(Struct node) =>
      _visitImpl(node, _IncludeBehavior.configOrDirectTransitive);

  @override
  void visitUnion(Union node) =>
      _visitImpl(node, _IncludeBehavior.configOrDirectTransitive);

  @override
  void visitTypealias(Typealias node) {
    _visitImpl(
      node,
      node.includeUnused
          ? _IncludeBehavior.configOnly
          : _IncludeBehavior.configAndTransitive,
    );

    // Objective C has some core typedefs that are important to keep.
    if (config.objectiveC != null &&
        node.originalName == strings.objcInstanceType) {
      _add(node);
    }

    // Visit typealias children if it's transitively referenced, regardless of
    // whether the typealias itself is included by the config.
    if (transitives.contains(node)) {
      node.visitChildren(visitor);
    }
  }

  @override
  void visitObjCBlock(ObjCBlock node) =>
      _visitImpl(node, _IncludeBehavior.configOrDirectTransitive);
}

class MarkBindingsVisitation extends Visitation {
  final Set<Binding> bindings;

  MarkBindingsVisitation(this.bindings);

  @override
  void visitBinding(Binding node) {
    node.visitChildren(visitor);
    node.generateBindings = bindings.contains(node);
  }
}
