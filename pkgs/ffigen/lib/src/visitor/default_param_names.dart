// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../code_generator/cpp_class.dart';
import '../code_generator/func.dart';
import '../code_generator/func_type.dart';
import '../code_generator/objc_block.dart';
import '../code_generator/objc_built_in_functions.dart';
import '../code_generator/objc_methods.dart';
import '../code_generator/scope.dart';
import 'ast.dart';

/// Visitation to set default names for unnamed parameters across all AST nodes.
class DefaultParameterNamesVisitation extends Visitation {
  void _defaultParamNames(Iterable<Parameter> params, {int startIndex = 0}) {
    var i = startIndex;
    for (final param in params) {
      if (param.symbol.oldName.isEmpty) {
        param.symbol = Symbol('arg$i', SymbolKind.field);
      }
      i++;
    }
  }

  @override
  void visitFunctionType(FunctionType node) {
    _defaultParamNames(node.parameters);
    _defaultParamNames(
      node.varArgParameters,
      startIndex: node.parameters.length,
    );
    visitor.visit(node.returnType);
    visitor.visitAll(node.parameters);
    visitor.visitAll(node.varArgParameters);
  }

  @override
  void visitObjCMethod(ObjCMethod node) {
    _defaultParamNames(node.params);
    visitor.visit(node.returnType);
    visitor.visitAll(node.params);
  }

  @override
  void visitCppMethod(CppMethod node) {
    _defaultParamNames(node.parameters);
    visitor.visit(node.returnType);
    visitor.visitAll(node.parameters);
  }

  @override
  void visitObjCBlock(ObjCBlock node) {
    _defaultParamNames(node.params);
    visitor.visit(node.returnType);
    visitor.visitAll(node.params);
  }

  @override
  void visitObjCMsgSendFunc(ObjCMsgSendFunc node) {}

  @override
  void visitObjCMsgSendVariantFunc(ObjCMsgSendVariantFunc node) {}
}
