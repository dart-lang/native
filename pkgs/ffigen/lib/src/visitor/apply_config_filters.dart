// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../code_generator.dart';
import '../config_provider/config.dart' show Config, DeclarationFilters;
import '../config_provider/config_types.dart' show Language;
import '../strings.dart' as strings;

import 'ast.dart';

class ApplyConfigFiltersVisitation extends Visitation {
  final Config config;
  final included = <Binding>{};
  ApplyConfigFiltersVisitation(this.config);

  void _visitImpl(Binding node, DeclarationFilters filters) {
    node.visitChildren(visitor);
    if (node.originalName == '') return;
    if (config.usrTypeMappings.containsKey(node.usr)) return;
    if (filters.shouldInclude(node)) included.add(node);
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
  void visitObjCInterface(ObjCInterface node) =>
      _visitImpl(node, config.objcInterfaces);

  @override
  void visitObjCProtocol(ObjCProtocol node) =>
      _visitImpl(node, config.objcProtocols);

  @override
  void visitUnnamedEnumConstant(UnnamedEnumConstant node) =>
      _visitImpl(node, config.unnamedEnumConstants);

  @override
  void visitGlobal(Global node) => _visitImpl(node, config.globals);

  @override
  void visitTypealias(Typealias node) {
    _visitImpl(node, config.typedefs);

    // Objective C has some core typedefs that are important to keep.
    if (config.language == Language.objc &&
        node.originalName == strings.objcInstanceType) {
      included.add(node);
    }
  }
}
