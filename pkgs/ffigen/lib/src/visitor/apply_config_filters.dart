// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../code_generator.dart';
import '../config_provider/config.dart' show Config, DeclarationFilters;

import 'ast.dart';

class ApplyConfigFiltersVisitation extends Visitation {
  final Config config;
  final directlyIncluded = <Binding>{};
  final indirectlyIncluded = <Binding>{};
  ApplyConfigFiltersVisitation(this.config);

  void _visitImpl(Binding node, DeclarationFilters filters) {
    node.visitChildren(visitor);
    if (node.originalName == '') return;
    if (config.usrTypeMappings.containsKey(node.usr)) return;
    if (filters.shouldInclude(node)) directlyIncluded.add(node);
  }

  @override
  void visitStruct(Struct node) => _visitImpl(node, config.structDecl);

  @override
  void visitUnion(Union node) => _visitImpl(node, config.unionDecl);

  @override
  void visitEnumClass(EnumClass node) => _visitImpl(node, config.enumClassDecl);

  @override
  void visitFunc(Func node) => _visitImpl(node, config.functionDecl);

  @override
  void visitMacroConstant(MacroConstant node) =>
      _visitImpl(node, config.macroDecl);

  @override
  void visitObjCInterface(ObjCInterface node) {
    node.filterMethods(
        (m) => config.objcInterfaces.shouldIncludeMember(node, m.originalName));
    _visitImpl(node, config.objcInterfaces);

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
      if (node.shouldCopyMethodToInterface(m)) return false;
      return config.objcCategories.shouldIncludeMember(node, m.originalName);
    });
    _visitImpl(node, config.objcCategories);
  }

  @override
  void visitObjCProtocol(ObjCProtocol node) {
    node.filterMethods((m) {
      // TODO(https://github.com/dart-lang/native/issues/1149): Support class
      // methods on protocols if there's a use case. For now filter them. We
      // filter here instead of during parsing so that these methods are still
      // copied to any interfaces that implement the protocol.
      if (m.isClassMethod) return false;

      return config.objcProtocols.shouldIncludeMember(node, m.originalName);
    });
    _visitImpl(node, config.objcProtocols);
  }

  @override
  void visitUnnamedEnumConstant(UnnamedEnumConstant node) =>
      _visitImpl(node, config.unnamedEnumConstants);

  @override
  void visitGlobal(Global node) => _visitImpl(node, config.globals);

  @override
  void visitTypealias(Typealias node) => _visitImpl(node, config.typedefs);
}
