// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'code_generator.dart' as cg;

/// Abstract base class for all public AST nodes.
abstract class _AstNode {
  const _AstNode();
  void accept(Visitor visitor);
}

/// Base class for AST visitors.
abstract class Visitor {
  const Visitor.base();

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

  // ignore: library_private_types_in_public_api
  void visitAll(Iterable<_AstNode> nodes) {
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

class _CallbackVisitor extends Visitor {
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

/// A container holding the AST node wrappers for public AST traversal.
class PublicAst {
  // ignore: library_private_types_in_public_api
  final List<_AstNode> nodes;

  PublicAst(List<cg.Binding> rawBindings)
    : nodes = rawBindings
          .map((b) => b.toPublicAstNode())
          .whereType<_AstNode>()
          .toList();

  void accept(Visitor visitor) {
    visitor.visitAll(nodes);
  }
}

/// Public wrapper for [cg.Func].
class Func extends _AstNode {
  final cg.Func _func;
  final List<Param> params;

  Func(this._func)
    : params = _func.functionType.parameters.map(Param.new).toList();

  @override
  void accept(Visitor visitor) {
    visitor.visitFunc(this);
    visitor.visitAll(params);
  }

  String get usr => _func.usr;
  String get name => _func.symbol.oldName;
  set name(String value) {
    _func.symbol.oldName = value;
    _func.funcVarSymbol.oldName = '_$value';
  }
}

/// Public wrapper for [cg.Struct].
class Struct extends _AstNode {
  final cg.Struct _struct;
  final List<Field> members;

  Struct(this._struct) : members = _struct.members.map(Field.new).toList();

  @override
  void accept(Visitor visitor) {
    visitor.visitStruct(this);
    visitor.visitAll(members);
  }

  String get usr => _struct.usr;
  String get name => _struct.symbol.oldName;
  set name(String value) => _struct.symbol.oldName = value;
}

/// Public wrapper for [cg.Union].
class Union extends _AstNode {
  final cg.Union _union;
  final List<Field> members;

  Union(this._union) : members = _union.members.map(Field.new).toList();

  @override
  void accept(Visitor visitor) {
    visitor.visitUnion(this);
    visitor.visitAll(members);
  }

  String get usr => _union.usr;
  String get name => _union.symbol.oldName;
  set name(String value) => _union.symbol.oldName = value;
}

/// Public wrapper for [cg.EnumClass].
class EnumClass extends _AstNode {
  final cg.EnumClass _enumClass;
  final List<EnumConstant> constants;

  EnumClass(this._enumClass)
    : constants = _enumClass.enumConstants.map(EnumConstant.new).toList();

  @override
  void accept(Visitor visitor) {
    visitor.visitEnum(this);
    visitor.visitAll(constants);
  }

  String get usr => _enumClass.usr;
  String get name => _enumClass.symbol.oldName;
  set name(String value) => _enumClass.symbol.oldName = value;
}

/// Public wrapper for [cg.Global].
class Global extends _AstNode {
  final cg.Global _global;

  Global(this._global);

  @override
  void accept(Visitor visitor) => visitor.visitGlobal(this);

  String get usr => _global.usr;
  String get name => _global.symbol.oldName;
  set name(String value) => _global.symbol.oldName = value;
}

/// Public wrapper for [cg.MacroConstant].
class MacroConstant extends _AstNode {
  final cg.MacroConstant _macro;

  MacroConstant(this._macro);

  @override
  void accept(Visitor visitor) => visitor.visitMacro(this);

  String get usr => _macro.usr;
  String get name => _macro.symbol.oldName;
  set name(String value) => _macro.symbol.oldName = value;
}

/// Public wrapper for [cg.Typealias].
class Typealias extends _AstNode {
  final cg.Typealias _typealias;

  Typealias(this._typealias);

  @override
  void accept(Visitor visitor) => visitor.visitTypealias(this);

  String get usr => _typealias.usr;
  String get name => _typealias.symbol.oldName;
  set name(String value) => _typealias.symbol.oldName = value;
}

/// Public wrapper for [cg.ObjCInterface].
class ObjCInterface extends _AstNode {
  final cg.ObjCInterface _interface;
  final List<ObjCMethod> methods;

  ObjCInterface(this._interface)
    : methods = _interface.methods.map(ObjCMethod.new).toList();

  @override
  void accept(Visitor visitor) {
    visitor.visitObjCInterface(this);
    visitor.visitAll(methods);
  }

  String get usr => _interface.usr;
  String get name => _interface.symbol.oldName;
  set name(String value) {
    _interface.symbol.oldName = value;
    _interface.classObject.symbol.oldName = '_class_$value';
    _interface.classObject.rawSymbol.oldName = '_class_${value}_raw';
  }
}

/// Public wrapper for [cg.ObjCProtocol].
class ObjCProtocol extends _AstNode {
  final cg.ObjCProtocol _protocol;
  final List<ObjCMethod> methods;

  ObjCProtocol(this._protocol)
    : methods = _protocol.methods.map(ObjCMethod.new).toList();

  @override
  void accept(Visitor visitor) {
    visitor.visitObjCProtocol(this);
    visitor.visitAll(methods);
  }

  String get usr => _protocol.usr;
  String get name => _protocol.symbol.oldName;
  set name(String value) => _protocol.symbol.oldName = value;
}

/// Public wrapper for [cg.ObjCCategory].
class ObjCCategory extends _AstNode {
  final cg.ObjCCategory _category;
  final List<ObjCMethod> methods;

  ObjCCategory(this._category)
    : methods = _category.methods.map(ObjCMethod.new).toList();

  @override
  void accept(Visitor visitor) {
    visitor.visitObjCCategory(this);
    visitor.visitAll(methods);
  }

  String get usr => _category.usr;
  String get name => _category.symbol.oldName;
  set name(String value) => _category.symbol.oldName = value;
}

/// Public wrapper for [cg.CppClass].
class CppClass extends _AstNode {
  final cg.CppClass _cppClass;
  final List<CppMethod> methods;

  CppClass(this._cppClass)
    : methods = _cppClass.methods.map(CppMethod.new).toList();

  @override
  void accept(Visitor visitor) {
    visitor.visitCppClass(this);
    visitor.visitAll(methods);
  }

  String get usr => _cppClass.usr;
  String get name => _cppClass.symbol.oldName;
  set name(String value) => _cppClass.symbol.oldName = value;
}

/// Public wrapper for [cg.CompoundMember].
class Field extends _AstNode {
  final cg.CompoundMember _member;

  Field(this._member);

  @override
  void accept(Visitor visitor) => visitor.visitField(this);

  String get name => _member.symbol.oldName;
  set name(String value) => _member.symbol.oldName = value;
}

/// Public wrapper for [cg.EnumConstant].
class EnumConstant extends _AstNode {
  final cg.EnumConstant _constant;

  EnumConstant(this._constant);

  @override
  void accept(Visitor visitor) => visitor.visitEnumConstant(this);

  String get name => _constant.symbol.oldName;
  set name(String value) => _constant.symbol.oldName = value;
}

/// Public wrapper for [cg.Parameter].
class Param extends _AstNode {
  final cg.Parameter _parameter;

  Param(this._parameter);

  @override
  void accept(Visitor visitor) => visitor.visitParam(this);

  String get name => _parameter.symbol.oldName;
  set name(String value) => _parameter.symbol.oldName = value;
}

/// Public wrapper for [cg.CppMethod].
class CppMethod extends _AstNode {
  final cg.CppMethod _method;
  final List<Param> params;

  CppMethod(this._method) : params = _method.parameters.map(Param.new).toList();

  @override
  void accept(Visitor visitor) {
    visitor.visitCppMethod(this);
    visitor.visitAll(params);
  }

  String get name => _method.name.oldName;
  set name(String value) => _method.name.oldName = value;
}

/// Public wrapper for [cg.ObjCMethod].
class ObjCMethod extends _AstNode {
  final cg.ObjCMethod _method;
  final List<Param> params;

  ObjCMethod(this._method) : params = _method.params.map(Param.new).toList();

  @override
  void accept(Visitor visitor) {
    visitor.visitObjCMethod(this);
    visitor.visitAll(params);
  }

  String get selector => _method.originalName;
  String get name => _method.symbol.oldName;
  set name(String value) => _method.symbol.oldName = value;
  bool get isPropertyGetter => _method.isPropertyGetter;
  bool get isPropertySetter => _method.isPropertySetter;
}

/// Public wrapper for [cg.UnnamedEnumConstant].
class UnnamedEnumConstant extends _AstNode {
  final cg.UnnamedEnumConstant _constant;

  UnnamedEnumConstant(this._constant);

  @override
  void accept(Visitor visitor) => visitor.visitUnnamedEnumConstant(this);

  String get usr => _constant.usr;
  String get name => _constant.symbol.oldName;
  set name(String value) => _constant.symbol.oldName = value;
}
