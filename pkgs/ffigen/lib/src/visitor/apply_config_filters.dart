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
    _visitImpl(node, node.isIncluded);
  }

  @override
  void visitFunc(Func node) {
    if (node.isIncluded) {
      node.exposedFunctionTypealias?.isIncluded = true;
    }
    _visitImpl(node, node.isIncluded);
  }

  @override
  void visitMacroConstant(MacroConstant node) =>
      _visitImpl(node, node.isIncluded);

  @override
  void visitObjCInterface(ObjCInterface node) {
    if (node.unavailable) return;
    if (context.config.objectiveC == null) return;

    if (!node.isInternal) {
      node.filterMethods((m) => !m.unavailable && m.isIncluded);
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
  void visitConstant(Constant node) {
    // MacroConstant and UnnamedEnumConstant have their own overrides, so this
    // only applies to base Constants (e.g. from static const variables).
    _visitImpl(node, node.isIncluded);
  }

  @override
  void visitTypealias(Typealias node) {
    if (node.isAnonymous) return;
    if (node.isIncluded) {
      final internalFunc = _getFunctionTypealias(node.type);
      if (internalFunc != null) {
        internalFunc.isIncluded = true;
      }
    }
    _visitImpl(node, node.isIncluded);
  }
}

Typealias? _getFunctionTypealias(Type type) {
  if (type is Typealias) {
    type = type.type;
  }
  if (type is PointerType) {
    final child = type.child;
    if (child is NativeFunc) {
      return child.functionTypealias;
    }
  }
  return null;
}
