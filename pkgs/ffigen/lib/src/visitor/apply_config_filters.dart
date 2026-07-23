// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../code_generator.dart';
import '../config_provider/config.dart' show Config;

import 'ast.dart';

class ApplyConfigFiltersVisitation extends Visitation {
  final Config config;
  final directlyIncluded = <Binding>{};
  final indirectlyIncluded = <Binding>{};
  ApplyConfigFiltersVisitation(this.config);

  void _visitImpl(Binding node) {
    if (node.isObjCImport &&
        !(config.objectiveC?.generateForPackageObjectiveC ?? false)) {
      return;
    }
    node.visitChildren(visitor);
    if (node.originalName == '') return;
    if (node.userDefinedIsExcluded == true) return;
    if (node.userDefinedIsExcluded == false) {
      directlyIncluded.add(node);
    }
  }

  @override
  void visitStruct(Struct node) => _visitImpl(node);

  @override
  void visitUnion(Union node) => _visitImpl(node);

  @override
  void visitEnumClass(EnumClass node) {
    if (node.isAnonymous) return;
    _visitImpl(node);
  }

  @override
  void visitCppClass(CppClass node) {
    _visitImpl(node);
  }

  @override
  void visitFunc(Func node) => _visitImpl(node);

  @override
  void visitMacroConstant(MacroConstant node) => _visitImpl(node);

  @override
  void visitObjCInterface(ObjCInterface node) {
    if (node.unavailable) return;

    node.filterMethods(
      (m) => m.userDefinedIsExcluded != true && !m.unavailable,
    );
    _visitImpl(node);

    // If this node is included, include all its super types.
    if (directlyIncluded.contains(node)) {
      for (ObjCInterface? t = node; t != null; t = t.superType) {
        if (!indirectlyIncluded.add(t)) break;
      }
    }
  }

  @override
  void visitObjCCategory(ObjCCategory node) {
    node.filterMethods((m) {
      if (m.userDefinedIsExcluded == true) return false;
      if (m.unavailable) return false;
      if (node.shouldCopyMethodToInterface(m)) return false;
      return m.userDefinedIsExcluded != true;
    });
    _visitImpl(node);
  }

  @override
  void visitObjCProtocol(ObjCProtocol node) {
    if (node.unavailable) return;

    node.filterMethods((m) {
      if (m.userDefinedIsExcluded == true) return false;
      if (m.unavailable) return false;
      if (m.isClassMethod) return false;

      return m.userDefinedIsExcluded != true;
    });
    _visitImpl(node);
  }

  @override
  void visitUnnamedEnumConstant(UnnamedEnumConstant node) => _visitImpl(node);

  @override
  void visitGlobal(Global node) => _visitImpl(node);

  @override
  void visitConstant(Constant node) {
    _visitImpl(node);
  }

  @override
  void visitTypealias(Typealias node) {
    if (node.isAnonymous) return;
    _visitImpl(node);
  }
}
