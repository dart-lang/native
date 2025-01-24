// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../code_generator.dart';
import '../config_provider/config.dart' show Config;
import '../config_provider/config_types.dart' show Language;
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

  ListBindingsVisitation(this.config, this.includes,
      Set<Binding> indirectTransitives, this.directTransitives)
      : transitives = {...indirectTransitives, ...directTransitives};

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
    if (!_visitImpl(
            node,
            config.includeTransitiveObjCInterfaces
                ? _IncludeBehavior.configOrTransitive
                : _IncludeBehavior.configOnly) &&
        directTransitives.contains(node)) {
      node.generateAsStub = true;
      bindings.add(node);
    }
  }

  @override
  void visitObjCCategory(ObjCCategory node) => _visitImpl(
      node,
      config.includeTransitiveObjCCategories
          ? _IncludeBehavior.configOrDirectTransitive
          : _IncludeBehavior.configOnly);

  @override
  void visitObjCProtocol(ObjCProtocol node) => _visitImpl(
      node,
      config.includeTransitiveObjCProtocols
          ? _IncludeBehavior.configOrTransitive
          : _IncludeBehavior.configOnly);

  @override
  void visitTypealias(Typealias node) {
    _visitImpl(
        node,
        config.includeUnusedTypedefs
            ? _IncludeBehavior.configOnly
            : _IncludeBehavior.configAndTransitive);

    // Objective C has some core typedefs that are important to keep.
    if (config.language == Language.objc &&
        node.originalName == strings.objcInstanceType) {
      _add(node);
    }

    // Visit typealias children if it's transitively referenced, regardless of
    // whether the typealias itself is included by the config.
    if (transitives.contains(node)) {
      node.visitChildren(visitor);
    }
  }
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
