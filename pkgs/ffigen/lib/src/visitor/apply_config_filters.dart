// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../code_generator.dart';
import '../config_provider/config_types.dart';
import '../context.dart';

import 'ast.dart';

class ApplyConfigFiltersVisitation extends Visitation {
  final Context context;
  final directlyIncluded = <Binding>{};
  final indirectlyIncluded = <Binding>{};
  ApplyConfigFiltersVisitation(this.context);

  void _visitImpl(Binding node, bool isIncluded) {
    node.visitChildren(visitor);
    if (node.originalName == '') return;
    if (context.config.importType(node) != null) return;
    if (isIncluded) directlyIncluded.add(node);
  }

  @override
  void visitStruct(Struct node) => _visitImpl(node, node.isIncluded);

  @override
  void visitUnion(Union node) => _visitImpl(node, node.isIncluded);

  @override
  void visitEnumClass(EnumClass node) {
    if (node.isAnonymous) return;
    _visitImpl(node, node.isIncluded);
  }

  @override
  void visitCppClass(CppClass node) {
    if (context.config.cpp == null) return;
    node.filterMethods((m) => m.isIncluded);
    _visitImpl(node, node.isIncluded);
  }

  @override
  void visitFunc(Func node) => _visitImpl(node, node.isIncluded);

  @override
  void visitMacroConstant(MacroConstant node) =>
      _visitImpl(node, node.isIncluded);

  @override
  void visitObjCInterface(ObjCInterface node) {
    if (node.unavailable) return;
    if (context.config.objectiveC == null) return;

    if (!node.isInternal) {
      node.filterMethods((m) {
        if (m.unavailable) return false;
        if (m.originCategory != null &&
            m.originCategory!.originalName.isNotEmpty &&
            !m.originCategory!.isIncluded) {
          return false;
        }
        return m.isIncluded;
      });
    }
    _visitImpl(node, node.isIncluded);

    // If this node is included, include all its super types.
    if (directlyIncluded.contains(node)) {
      for (ObjCInterface? t = node; t != null; t = t.superType) {
        if (!indirectlyIncluded.add(t)) break;
      }
    }
  }

  @override
  void visitObjCCategory(ObjCCategory node) {
    if (context.config.objectiveC == null) return;

    node.filterMethods((m) {
      if (m.unavailable) return false;
      if (node.shouldCopyMethodToInterface(m)) return false;
      return m.isIncluded;
    });
    _visitImpl(node, node.isIncluded);
  }

  @override
  void visitObjCProtocol(ObjCProtocol node) {
    if (node.unavailable) return;
    if (context.config.objectiveC == null) return;

    node.filterMethods((m) {
      // TODO(https://github.com/dart-lang/native/issues/1149): Support class
      // methods on protocols if there's a use case. For now filter them. We
      // filter here instead of during parsing so that these methods are still
      // copied to any interfaces that implement the protocol.
      if (m.unavailable) return false;
      if (m.isClassMethod) return false;

      return m.isIncluded;
    });
    _visitImpl(node, node.isIncluded);
  }

  @override
  void visitUnnamedEnumConstant(UnnamedEnumConstant node) =>
      _visitImpl(node, node.isIncluded);

  @override
  void visitGlobal(Global node) => _visitImpl(node, node.isIncluded);

  @override
  void visitTypealias(Typealias node) {
    if (node.isAnonymous) return;
    _visitImpl(node, node.isIncluded != TypealiasInclude.never);
  }
}
