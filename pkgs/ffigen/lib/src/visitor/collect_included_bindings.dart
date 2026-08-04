// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../code_generator.dart';
import '../config_provider/config.dart' show Config;

import 'ast.dart';

class CollectIncludedBindingsVisitation extends Visitation {
  final Config config;
  final directlyIncluded = <Binding>{};
  final indirectlyIncluded = <Binding>{};
  CollectIncludedBindingsVisitation(this.config);

  @override
  void visitBinding(Binding node) {
    if (node.originalName.isEmpty) return;
    if (node.userDefinedIsIncluded == false) return;
    if (node.userDefinedIsIncluded == true) {
      directlyIncluded.add(node);
    }
    if (node.isObjCImport &&
        !(config.objectiveC?.generateForPackageObjectiveC ?? false)) {
      return;
    }
    node.visitChildren(visitor);
  }

  @override
  void visitEnumClass(EnumClass node) {
    if (node.isAnonymous) return;
    visitBinding(node);
  }

  @override
  void visitObjCInterface(ObjCInterface node) {
    if (node.unavailable) return;

    if (!node.isInternal) {
      node.filterMethods(
        (m) => m.userDefinedIsIncluded != false && !m.unavailable,
      );
    }
    visitBinding(node);

    // If this node is included, include all its super types.
    if (directlyIncluded.contains(node)) {
      for (ObjCInterface? t = node; t != null; t = t.superType) {
        if (t.isObjCImport) break;
        if (!indirectlyIncluded.add(t)) break;
      }
    }
  }

  @override
  void visitObjCCategory(ObjCCategory node) {
    node.filterMethods(
      (m) =>
          m.userDefinedIsIncluded != false &&
          !m.unavailable &&
          !node.shouldCopyMethodToInterface(m),
    );
    visitBinding(node);
  }

  @override
  void visitObjCProtocol(ObjCProtocol node) {
    if (node.unavailable) return;

    node.filterMethods(
      (m) =>
          m.userDefinedIsIncluded != false &&
          !m.unavailable &&
          !m.isClassMethod,
    );
    visitBinding(node);
  }

  @override
  void visitTypealias(Typealias node) {
    if (node.isAnonymous) return;
    visitBinding(node);
  }
}
