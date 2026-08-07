// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'public_ast.dart';

/// Base class for AST visitors that inspect and transform AST nodes.
///
/// Implementations can extend [Visitor] (must call the [Visitor.base]
/// constructor) or use the [Visitor] factory constructor to provide inline
/// callbacks for specific nodes.
abstract base class Visitor {
  const Visitor.base();

  /// Creates a [Visitor] that delegates visiting to the provided callbacks.
  factory Visitor({
    void Function(Func) visitFunc,
    void Function(Struct) visitStruct,
    void Function(Union) visitUnion,
    void Function(EnumClass) visitEnum,
    void Function(Global) visitGlobal,
    void Function(MacroConstant) visitMacro,
    void Function(Typealias) visitTypealias,
    void Function(ObjCInterface) visitObjCInterface,
    void Function(ObjCProtocol) visitObjCProtocol,
    void Function(ObjCCategory) visitObjCCategory,
    void Function(CppClass) visitCppClass,
    void Function(Field) visitField,
    void Function(EnumConstant) visitEnumConstant,
    void Function(UnnamedEnumConstant) visitUnnamedEnumConstant,
    void Function(Param) visitParam,
    void Function(ObjCMethod) visitObjCMethod,
    void Function(CppMethod) visitCppMethod,
  }) = _CallbackVisitor;

  void visitAll(Iterable<AstNode> nodes) {
    for (final node in nodes) {
      node.accept(this);
    }
  }

  void visitFunc(Func node) {}
  void visitStruct(Struct node) {}
  void visitUnion(Union node) {}
  void visitEnum(EnumClass node) {}
  void visitGlobal(Global node) {}
  void visitMacro(MacroConstant node) {}
  void visitTypealias(Typealias node) {}
  void visitObjCInterface(ObjCInterface node) {}
  void visitObjCProtocol(ObjCProtocol node) {}
  void visitObjCCategory(ObjCCategory node) {}
  void visitCppClass(CppClass node) {}
  void visitField(Field node) {}
  void visitEnumConstant(EnumConstant node) {}
  void visitUnnamedEnumConstant(UnnamedEnumConstant node) {}
  void visitParam(Param node) {}
  void visitObjCMethod(ObjCMethod node) {}
  void visitCppMethod(CppMethod node) {}
}

final class _CallbackVisitor extends Visitor {
  final void Function(Func) _visitFunc;
  final void Function(Struct) _visitStruct;
  final void Function(Union) _visitUnion;
  final void Function(EnumClass) _visitEnum;
  final void Function(Global) _visitGlobal;
  final void Function(MacroConstant) _visitMacro;
  final void Function(Typealias) _visitTypealias;
  final void Function(ObjCInterface) _visitObjCInterface;
  final void Function(ObjCProtocol) _visitObjCProtocol;
  final void Function(ObjCCategory) _visitObjCCategory;
  final void Function(CppClass) _visitCppClass;
  final void Function(Field) _visitField;
  final void Function(EnumConstant) _visitEnumConstant;
  final void Function(UnnamedEnumConstant) _visitUnnamedEnumConstant;
  final void Function(Param) _visitParam;
  final void Function(ObjCMethod) _visitObjCMethod;
  final void Function(CppMethod) _visitCppMethod;

  const _CallbackVisitor({
    void Function(Func) visitFunc = _defaultVisit,
    void Function(Struct) visitStruct = _defaultVisit,
    void Function(Union) visitUnion = _defaultVisit,
    void Function(EnumClass) visitEnum = _defaultVisit,
    void Function(Global) visitGlobal = _defaultVisit,
    void Function(MacroConstant) visitMacro = _defaultVisit,
    void Function(Typealias) visitTypealias = _defaultVisit,
    void Function(ObjCInterface) visitObjCInterface = _defaultVisit,
    void Function(ObjCProtocol) visitObjCProtocol = _defaultVisit,
    void Function(ObjCCategory) visitObjCCategory = _defaultVisit,
    void Function(CppClass) visitCppClass = _defaultVisit,
    void Function(Field) visitField = _defaultVisit,
    void Function(EnumConstant) visitEnumConstant = _defaultVisit,
    void Function(UnnamedEnumConstant) visitUnnamedEnumConstant = _defaultVisit,
    void Function(Param) visitParam = _defaultVisit,
    void Function(ObjCMethod) visitObjCMethod = _defaultVisit,
    void Function(CppMethod) visitCppMethod = _defaultVisit,
  }) : _visitFunc = visitFunc,
       _visitStruct = visitStruct,
       _visitUnion = visitUnion,
       _visitEnum = visitEnum,
       _visitGlobal = visitGlobal,
       _visitMacro = visitMacro,
       _visitTypealias = visitTypealias,
       _visitObjCInterface = visitObjCInterface,
       _visitObjCProtocol = visitObjCProtocol,
       _visitObjCCategory = visitObjCCategory,
       _visitCppClass = visitCppClass,
       _visitField = visitField,
       _visitEnumConstant = visitEnumConstant,
       _visitUnnamedEnumConstant = visitUnnamedEnumConstant,
       _visitParam = visitParam,
       _visitObjCMethod = visitObjCMethod,
       _visitCppMethod = visitCppMethod,
       super.base();

  static void _defaultVisit(Object _) {}

  @override
  void visitFunc(Func node) => _visitFunc(node);

  @override
  void visitStruct(Struct node) => _visitStruct(node);

  @override
  void visitUnion(Union node) => _visitUnion(node);

  @override
  void visitEnum(EnumClass node) => _visitEnum(node);

  @override
  void visitGlobal(Global node) => _visitGlobal(node);

  @override
  void visitMacro(MacroConstant node) => _visitMacro(node);

  @override
  void visitTypealias(Typealias node) => _visitTypealias(node);

  @override
  void visitObjCInterface(ObjCInterface node) => _visitObjCInterface(node);

  @override
  void visitObjCProtocol(ObjCProtocol node) => _visitObjCProtocol(node);

  @override
  void visitObjCCategory(ObjCCategory node) => _visitObjCCategory(node);

  @override
  void visitCppClass(CppClass node) => _visitCppClass(node);

  @override
  void visitField(Field node) => _visitField(node);

  @override
  void visitEnumConstant(EnumConstant node) => _visitEnumConstant(node);

  @override
  void visitUnnamedEnumConstant(UnnamedEnumConstant node) =>
      _visitUnnamedEnumConstant(node);

  @override
  void visitParam(Param node) => _visitParam(node);

  @override
  void visitObjCMethod(ObjCMethod node) => _visitObjCMethod(node);

  @override
  void visitCppMethod(CppMethod node) => _visitCppMethod(node);
}
