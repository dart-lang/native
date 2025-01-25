// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../code_generator.dart';
import '../config_provider/config.dart' show Config;
import '../config_provider/config_types.dart' show CompoundDependencies;

import 'ast.dart';

class FindByValueCompoundsVisitation extends Visitation {
  // Set of [Compounds] that are either directly included, or referred to by
  // value (ie not by pointer).
  final byValueCompounds = <Compound>{};

  @override
  void visitCompound(Compound node) {
    node.visitChildren(visitor);
    byValueCompounds.add(node);
  }

  @override
  void visitPointerType(PointerType node) {
    if (node.child.typealiasType is Compound) {
      // Don't visit compounds through pointers. We're only interested in
      // compounds that are referred to by value.
    } else {
      node.visitChildren(visitor);
    }
  }

  // If a node is only referred to by value through a directly included
  // typealias, that doesn't count as by-value. The best way to implement this
  // logic is to just exclude typealiases from the root set.
  static Iterable<AstNode> rootNodes(Iterable<AstNode> included) =>
      included.where((n) => n is! Typealias);
}

class ClearOpaqueCompoundMembersVisitation extends Visitation {
  final Config config;
  final Set<Compound> byValueCompounds;
  final Set<Binding> included;

  ClearOpaqueCompoundMembersVisitation(
      this.config, this.byValueCompounds, this.included);

  void _visitImpl(Compound node, CompoundDependencies compondDepsConfig) {
    // If a compound isn't referred to by value, isn't explicitly included by
    // the config filters, and the config is using opaque deps, convert the
    // compound to be opaque by deleting its members.
    if (!byValueCompounds.contains(node) &&
        !included.contains(node) &&
        compondDepsConfig == CompoundDependencies.opaque) {
      node.members.clear();
    }
  }

  @override
  void visitStruct(Struct node) => _visitImpl(node, config.structDependencies);

  @override
  void visitUnion(Union node) => _visitImpl(node, config.unionDependencies);
}
