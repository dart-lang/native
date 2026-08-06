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
  const Visitor();

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
  void visitParameter(Parameter node) {}
  void visitObjCMethod(ObjCMethod node) {}
  void visitCppMethod(CppMethod node) {}
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
  final List<Parameter> params;

  Func(this._func)
    : params = _func.functionType.parameters.map(Parameter.new).toList();

  @override
  void accept(Visitor visitor) {
    visitor.visitFunc(this);
    visitor.visitAll(params);
  }

  String get originalName => _func.originalName;
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

  String get originalName => _struct.originalName;
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

  String get originalName => _union.originalName;
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

  String get originalName => _enumClass.originalName;
  String get name => _enumClass.symbol.oldName;
  set name(String value) => _enumClass.symbol.oldName = value;
}

/// Public wrapper for [cg.Global].
class Global extends _AstNode {
  final cg.Global _global;

  Global(this._global);

  @override
  void accept(Visitor visitor) => visitor.visitGlobal(this);

  String get originalName => _global.originalName;
  String get name => _global.symbol.oldName;
  set name(String value) => _global.symbol.oldName = value;
}

/// Public wrapper for [cg.MacroConstant].
class MacroConstant extends _AstNode {
  final cg.MacroConstant _macro;

  MacroConstant(this._macro);

  @override
  void accept(Visitor visitor) => visitor.visitMacro(this);

  String get originalName => _macro.originalName;
  String get name => _macro.symbol.oldName;
  set name(String value) => _macro.symbol.oldName = value;
}

/// Public wrapper for [cg.Typealias].
class Typealias extends _AstNode {
  final cg.Typealias _typealias;

  Typealias(this._typealias);

  @override
  void accept(Visitor visitor) => visitor.visitTypealias(this);

  String get originalName => _typealias.originalName;
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

  String get originalName => _interface.originalName;
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

  String get originalName => _protocol.originalName;
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

  String get originalName => _category.originalName;
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

  String get originalName => _cppClass.originalName;
  String get name => _cppClass.symbol.oldName;
  set name(String value) => _cppClass.symbol.oldName = value;
}

/// Public wrapper for [cg.CompoundMember].
class Field extends _AstNode {
  final cg.CompoundMember _member;

  Field(this._member);

  @override
  void accept(Visitor visitor) => visitor.visitField(this);

  String get originalName => _member.originalName;
  String get name => _member.symbol.oldName;
  set name(String value) => _member.symbol.oldName = value;
}

/// Public wrapper for [cg.EnumConstant].
class EnumConstant extends _AstNode {
  final cg.EnumConstant _constant;

  EnumConstant(this._constant);

  @override
  void accept(Visitor visitor) => visitor.visitEnumConstant(this);

  String get originalName => _constant.originalName ?? _constant.name;
  String get name => _constant.symbol.oldName;
  set name(String value) => _constant.symbol.oldName = value;
}

/// Public wrapper for [cg.Parameter].
class Parameter extends _AstNode {
  final cg.Parameter _parameter;

  Parameter(this._parameter);

  @override
  void accept(Visitor visitor) => visitor.visitParameter(this);

  String get originalName => _parameter.originalName;
  String get name => _parameter.symbol.oldName;
  set name(String value) => _parameter.symbol.oldName = value;
}

/// Public wrapper for [cg.CppMethod].
class CppMethod extends _AstNode {
  final cg.CppMethod _method;
  final List<Parameter> params;

  CppMethod(this._method)
    : params = _method.parameters.map(Parameter.new).toList();

  @override
  void accept(Visitor visitor) {
    visitor.visitCppMethod(this);
    visitor.visitAll(params);
  }

  String get originalName => _method.originalName;
  String get name => _method.name.oldName;
  set name(String value) => _method.name.oldName = value;
}

/// Public wrapper for [cg.ObjCMethod].
class ObjCMethod extends _AstNode {
  final cg.ObjCMethod _method;
  final List<Parameter> params;

  ObjCMethod(this._method)
    : params = _method.params.map(Parameter.new).toList();

  @override
  void accept(Visitor visitor) {
    visitor.visitObjCMethod(this);
    visitor.visitAll(params);
  }

  String get selector => _method.originalName;
  String get originalName => _method.originalName;
  String get name => _method.symbol.oldName;
  set name(String value) => _method.symbol.oldName = value;
  bool get isPropertySetter => _method.kind == cg.ObjCMethodKind.propertySetter;
}

/// Public wrapper for [cg.UnnamedEnumConstant].
class UnnamedEnumConstant extends _AstNode {
  final cg.UnnamedEnumConstant _constant;

  UnnamedEnumConstant(this._constant);

  @override
  void accept(Visitor visitor) => visitor.visitUnnamedEnumConstant(this);

  String get originalName => _constant.originalName;
  String get name => _constant.symbol.oldName;
  set name(String value) => _constant.symbol.oldName = value;
}
