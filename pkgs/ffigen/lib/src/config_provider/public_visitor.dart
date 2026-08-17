// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'public_ast.dart';

/// Base class for AST visitors that inspect and transform AST nodes.
///
/// Implementations can extend [Visitor] (must call the [Visitor.base]
/// constructor) or use the [Visitor] factory constructor to provide inline
/// callbacks for specific nodes.
///
/// ### Examples
///
/// Filtering declarations:
/// ```dart
/// final class FilterVisitor extends Visitor {
///   FilterVisitor() : super.base();
///
///   @override
///   void visitFunc(Func node) {
///     if (node.name.startsWith('_')) {
///       node.isIncluded = false;
///     }
///   }
/// }
/// ```
///
/// Renaming declarations:
/// ```dart
/// final class RenameVisitor extends Visitor {
///   RenameVisitor() : super.base();
///
///   @override
///   void visitStruct(Struct node) {
///     if (node.name == 'custom_type') {
///       node.name = 'CustomType';
///     }
///   }
/// }
/// ```
abstract base class Visitor {
  const Visitor.base();

  /// Creates a [Visitor] that delegates visiting to the provided callbacks.
  ///
  /// ### Examples
  ///
  /// Filtering declarations:
  /// ```dart
  /// Visitor(
  ///   func: (node) {
  ///     if (node.name.startsWith('_')) {
  ///       node.isIncluded = false;
  ///     }
  ///   },
  /// )
  /// ```
  ///
  /// Renaming declarations:
  /// ```dart
  /// Visitor(
  ///   struct: (node) {
  ///     if (node.name == 'custom_type') {
  ///       node.name = 'CustomType';
  ///     }
  ///   },
  /// )
  /// ```
  factory Visitor({
    void Function(Func) func,
    void Function(Struct) struct,
    void Function(Union) union,
    void Function(EnumClass) enumClass,
    void Function(Global) global,
    void Function(Constant) constant,
    void Function(MacroConstant) macroConstant,
    void Function(Typealias) typealias,
    void Function(ObjCInterface) objCInterface,
    void Function(ObjCProtocol) objCProtocol,
    void Function(ObjCCategory) objCCategory,
    void Function(CppClass) cppClass,
    void Function(Field) field,
    void Function(EnumConstant) enumConstant,
    void Function(UnnamedEnumConstant) unnamedEnumConstant,
    void Function(Param) param,
    void Function(ObjCMethod) objCMethod,
    void Function(CppMethod) cppMethod,
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
  void visitConstant(Constant node) {}
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
  final void Function(Func) _func;
  final void Function(Struct) _struct;
  final void Function(Union) _union;
  final void Function(EnumClass) _enumClass;
  final void Function(Global) _global;
  final void Function(Constant) _constant;
  final void Function(MacroConstant) _macroConstant;
  final void Function(Typealias) _typealias;
  final void Function(ObjCInterface) _objCInterface;
  final void Function(ObjCProtocol) _objCProtocol;
  final void Function(ObjCCategory) _objCCategory;
  final void Function(CppClass) _cppClass;
  final void Function(Field) _field;
  final void Function(EnumConstant) _enumConstant;
  final void Function(UnnamedEnumConstant) _unnamedEnumConstant;
  final void Function(Param) _param;
  final void Function(ObjCMethod) _objCMethod;
  final void Function(CppMethod) _cppMethod;

  const _CallbackVisitor({
    void Function(Func) func = _defaultVisit,
    void Function(Struct) struct = _defaultVisit,
    void Function(Union) union = _defaultVisit,
    void Function(EnumClass) enumClass = _defaultVisit,
    void Function(Global) global = _defaultVisit,
    void Function(Constant) constant = _defaultVisit,
    void Function(MacroConstant) macroConstant = _defaultVisit,
    void Function(Typealias) typealias = _defaultVisit,
    void Function(ObjCInterface) objCInterface = _defaultVisit,
    void Function(ObjCProtocol) objCProtocol = _defaultVisit,
    void Function(ObjCCategory) objCCategory = _defaultVisit,
    void Function(CppClass) cppClass = _defaultVisit,
    void Function(Field) field = _defaultVisit,
    void Function(EnumConstant) enumConstant = _defaultVisit,
    void Function(UnnamedEnumConstant) unnamedEnumConstant = _defaultVisit,
    void Function(Param) param = _defaultVisit,
    void Function(ObjCMethod) objCMethod = _defaultVisit,
    void Function(CppMethod) cppMethod = _defaultVisit,
  }) : _func = func,
       _struct = struct,
       _union = union,
       _enumClass = enumClass,
       _global = global,
       _constant = constant,
       _macroConstant = macroConstant,
       _typealias = typealias,
       _objCInterface = objCInterface,
       _objCProtocol = objCProtocol,
       _objCCategory = objCCategory,
       _cppClass = cppClass,
       _field = field,
       _enumConstant = enumConstant,
       _unnamedEnumConstant = unnamedEnumConstant,
       _param = param,
       _objCMethod = objCMethod,
       _cppMethod = cppMethod,
       super.base();

  static void _defaultVisit(Object _) {}

  @override
  void visitFunc(Func node) => _func(node);

  @override
  void visitStruct(Struct node) => _struct(node);

  @override
  void visitUnion(Union node) => _union(node);

  @override
  void visitEnum(EnumClass node) => _enumClass(node);

  @override
  void visitGlobal(Global node) => _global(node);

  @override
  void visitConstant(Constant node) => _constant(node);

  @override
  void visitMacro(MacroConstant node) => _macroConstant(node);

  @override
  void visitTypealias(Typealias node) => _typealias(node);

  @override
  void visitObjCInterface(ObjCInterface node) => _objCInterface(node);

  @override
  void visitObjCProtocol(ObjCProtocol node) => _objCProtocol(node);

  @override
  void visitObjCCategory(ObjCCategory node) => _objCCategory(node);

  @override
  void visitCppClass(CppClass node) => _cppClass(node);

  @override
  void visitField(Field node) => _field(node);

  @override
  void visitEnumConstant(EnumConstant node) => _enumConstant(node);

  @override
  void visitUnnamedEnumConstant(UnnamedEnumConstant node) =>
      _unnamedEnumConstant(node);

  @override
  void visitParam(Param node) => _param(node);

  @override
  void visitObjCMethod(ObjCMethod node) => _objCMethod(node);

  @override
  void visitCppMethod(CppMethod node) => _cppMethod(node);
}
