// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../code_generator.dart';
import '../context.dart';

import 'ast.dart';

class ApplyConfigFiltersVisitation extends Visitation {
  final Context context;
  final directlyIncluded = <Binding>{};
  final indirectlyIncluded = <Binding>{};
  ApplyConfigFiltersVisitation(this.context);

  void _visitImpl(Binding node) {
    if (node.originalName == '') return;
    if (context.config.importType(node) != null) return;
    if (node.isIncluded) {
      directlyIncluded.add(node);
    }
  }

  void _visitWithChildren(Binding node) {
    _visitImpl(node);
    if (directlyIncluded.contains(node)) {
      node.visitChildren(visitor);
    }
  }

  @override
  void visitStruct(Struct node) => _visitWithChildren(node);

  @override
  void visitUnion(Union node) => _visitWithChildren(node);

  @override
  void visitEnumClass(EnumClass node) {
    if (node.isAnonymous) return;
    _visitWithChildren(node);
  }

  @override
  void visitCppClass(CppClass node) {
    if (context.config.cpp == null) return;
    _visitWithChildren(node);
  }

  @override
  void visitFunc(Func node) {
    _visitImpl(node);
    if (directlyIncluded.contains(node)) {
      visitor.visit(node.exposedFunctionTypealias);
    }
  }

  @override
  void visitMacroConstant(MacroConstant node) => _visitImpl(node);

  @override
  void visitObjCInterface(ObjCInterface node) {
    if (node.unavailable) return;
    if (context.config.objectiveC == null) return;

    if (!node.isObjCImport) {
      node.filterMethods((m) => !m.unavailable && m.isIncluded);
    }
    if (!node.isInternal) {
      _visitImpl(node);
    }

    // If this node is included, include all its super types.
    if (directlyIncluded.contains(node)) {
      for (var t = node.superType; t != null; t = t.superType) {
        if (!t.isObjCImport) {
          if (!indirectlyIncluded.add(t)) break;
        }
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
    if (!node.isInternal) {
      _visitImpl(node);
    }
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
    if (!node.isInternal) {
      _visitImpl(node);
    }
  }

  @override
  void visitUnnamedEnumConstant(UnnamedEnumConstant node) => _visitImpl(node);

  @override
  void visitGlobal(Global node) => _visitImpl(node);

  @override
  void visitConstant(Constant node) {
    // MacroConstant and UnnamedEnumConstant have their own overrides, so this
    // only applies to base Constants (e.g. from static const variables).
    _visitImpl(node);
  }

  @override
  void visitTypealias(Typealias node) {
    if (node.isAnonymous) return;
    _visitWithChildren(node);
  }
}
