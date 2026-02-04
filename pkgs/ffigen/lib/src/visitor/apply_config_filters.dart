// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../code_generator.dart';
import '../config_provider/config.dart' show Config, Declarations;

import 'ast.dart';

class ApplyConfigFiltersVisitation extends Visitation {
  final Config config;
  final directlyIncluded = <Binding>{};
  final indirectlyIncluded = <Binding>{};
  ApplyConfigFiltersVisitation(this.config);

  void _visitImpl(Binding node, Declarations filters) {
    node.visitChildren(visitor);
    if (node.originalName == '') return;
    if (config.importedTypesByUsr.containsKey(node.usr)) return;
    if (filters.include(node)) directlyIncluded.add(node);
  }

  @override
  void visitStruct(Struct node) => _visitImpl(node, config.structs);

  @override
  void visitUnion(Union node) => _visitImpl(node, config.unions);

  @override
  void visitEnumClass(EnumClass node) {
    if (node.isAnonymous) return;
    _visitImpl(node, config.enums);
  }

  @override
  void visitFunc(Func node) => _visitImpl(node, config.functions);

  @override
  void visitMacroConstant(MacroConstant node) =>
      _visitImpl(node, config.macros);

  @override
  void visitObjCInterface(ObjCInterface node) {
    if (node.unavailable) return;
    final objcInterfaces = config.objectiveC?.interfaces;
    if (objcInterfaces == null) return;

    node.filterMethods(
      (m) => objcInterfaces.includeMember(node, m.originalName),
    );
    _visitImpl(node, objcInterfaces);

    // If this node is included, include all its super types.
    if (directlyIncluded.contains(node)) {
      for (ObjCInterface? t = node; t != null; t = t.superType) {
        if (!indirectlyIncluded.add(t)) break;
      }
    }
  }

  @override
  void visitObjCCategory(ObjCCategory node) {
    final objcCategories = config.objectiveC?.categories;
    if (objcCategories == null) return;
    node.filterMethods((m) {
      if (node.shouldCopyMethodToInterface(m)) return false;
      return objcCategories.includeMember(node, m.originalName);
    });
    _visitImpl(node, objcCategories);
  }

  @override
  void visitObjCProtocol(ObjCProtocol node) {
    if (node.unavailable) return;
    final objcProtocols = config.objectiveC?.protocols;
    if (objcProtocols == null) return;

    node.filterMethods((m) {
      // TODO(https://github.com/dart-lang/native/issues/1149): Support class
      // methods on protocols if there's a use case. For now filter them. We
      // filter here instead of during parsing so that these methods are still
      // copied to any interfaces that implement the protocol.
      if (m.isClassMethod) return false;

      return objcProtocols.includeMember(node, m.originalName);
    });
    _visitImpl(node, objcProtocols);
  }

  @override
  void visitUnnamedEnumConstant(UnnamedEnumConstant node) =>
      _visitImpl(node, config.unnamedEnums);

  @override
  void visitGlobal(Global node) => _visitImpl(node, config.globals);

  @override
  void visitConstant(Constant node) {
    // MacroConstant and UnnamedEnumConstant have their own overrides, so this
    // only applies to base Constants (e.g. from static const variables).
    _visitImpl(node, config.globals);
  }

  @override
  void visitTypealias(Typealias node) {
    if (node.isAnonymous) return;
    _visitImpl(node, config.typedefs);
  }
}
