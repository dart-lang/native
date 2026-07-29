// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../code_generator.dart' as ast;
import '../config_provider.dart';

/// User-facing Visitor for FFIgen's Public AST.
class Visitor {
  final void Function(PublicAst ast)? _visitLibrary;
  final void Function(Struct node)? _visitStruct;
  final void Function(Union node)? _visitUnion;
  final void Function(EnumClass node)? _visitEnum;
  final void Function(UnnamedEnumConstant node)? _visitUnnamedEnumConstant;
  final void Function(Func node)? _visitFunc;
  final void Function(Global node)? _visitGlobal;
  final void Function(MacroConstant node)? _visitMacroConstant;
  final void Function(Typealias node)? _visitTypealias;
  final void Function(ObjCInterface node)? _visitObjCInterface;
  final void Function(ObjCProtocol node)? _visitObjCProtocol;
  final void Function(ObjCCategory node)? _visitObjCCategory;
  final void Function(CppClass node)? _visitCppClass;
  final void Function(Field node)? _visitField;
  final void Function(EnumConstant node)? _visitEnumConstant;
  final void Function(Parameter node)? _visitParameter;
  final void Function(ObjCMethod node)? _visitObjCMethod;
  final void Function(CppMethod node)? _visitCppMethod;

  const Visitor({
    void Function(PublicAst ast)? visitLibrary,
    void Function(Struct node)? visitStruct,
    void Function(Union node)? visitUnion,
    void Function(EnumClass node)? visitEnum,
    void Function(UnnamedEnumConstant node)? visitUnnamedEnumConstant,
    void Function(Func node)? visitFunc,
    void Function(Global node)? visitGlobal,
    void Function(MacroConstant node)? visitMacroConstant,
    void Function(Typealias node)? visitTypealias,
    void Function(ObjCInterface node)? visitObjCInterface,
    void Function(ObjCProtocol node)? visitObjCProtocol,
    void Function(ObjCCategory node)? visitObjCCategory,
    void Function(CppClass node)? visitCppClass,
    void Function(Field node)? visitField,
    void Function(EnumConstant node)? visitEnumConstant,
    void Function(Parameter node)? visitParameter,
    void Function(ObjCMethod node)? visitObjCMethod,
    void Function(CppMethod node)? visitCppMethod,
  })  : _visitLibrary = visitLibrary,
        _visitStruct = visitStruct,
        _visitUnion = visitUnion,
        _visitEnum = visitEnum,
        _visitUnnamedEnumConstant = visitUnnamedEnumConstant,
        _visitFunc = visitFunc,
        _visitGlobal = visitGlobal,
        _visitMacroConstant = visitMacroConstant,
        _visitTypealias = visitTypealias,
        _visitObjCInterface = visitObjCInterface,
        _visitObjCProtocol = visitObjCProtocol,
        _visitObjCCategory = visitObjCCategory,
        _visitCppClass = visitCppClass,
        _visitField = visitField,
        _visitEnumConstant = visitEnumConstant,
        _visitParameter = visitParameter,
        _visitObjCMethod = visitObjCMethod,
        _visitCppMethod = visitCppMethod;

  void visitLibrary(PublicAst ast) {
    _visitLibrary?.call(ast);
    ast.visitChildren(this);
  }

  void visitStruct(Struct node) {
    _visitStruct?.call(node);
    node.visitChildren(this);
  }

  void visitUnion(Union node) {
    _visitUnion?.call(node);
    node.visitChildren(this);
  }

  void visitEnum(EnumClass node) {
    _visitEnum?.call(node);
    node.visitChildren(this);
  }

  void visitUnnamedEnumConstant(UnnamedEnumConstant node) {
    _visitUnnamedEnumConstant?.call(node);
    node.visitChildren(this);
  }

  void visitFunc(Func node) {
    _visitFunc?.call(node);
    node.visitChildren(this);
  }

  void visitGlobal(Global node) {
    _visitGlobal?.call(node);
    node.visitChildren(this);
  }

  void visitMacroConstant(MacroConstant node) {
    _visitMacroConstant?.call(node);
    node.visitChildren(this);
  }

  void visitTypealias(Typealias node) {
    _visitTypealias?.call(node);
    node.visitChildren(this);
  }

  void visitObjCInterface(ObjCInterface node) {
    _visitObjCInterface?.call(node);
    node.visitChildren(this);
  }

  void visitObjCProtocol(ObjCProtocol node) {
    _visitObjCProtocol?.call(node);
    node.visitChildren(this);
  }

  void visitObjCCategory(ObjCCategory node) {
    _visitObjCCategory?.call(node);
    node.visitChildren(this);
  }

  void visitCppClass(CppClass node) {
    _visitCppClass?.call(node);
    node.visitChildren(this);
  }

  void visitField(Field node) {
    _visitField?.call(node);
    node.visitChildren(this);
  }

  void visitEnumConstant(EnumConstant node) {
    _visitEnumConstant?.call(node);
    node.visitChildren(this);
  }

  void visitParameter(Parameter node) {
    _visitParameter?.call(node);
    node.visitChildren(this);
  }

  void visitObjCMethod(ObjCMethod node) {
    _visitObjCMethod?.call(node);
    node.visitChildren(this);
  }

  void visitCppMethod(CppMethod node) {
    _visitCppMethod?.call(node);
    node.visitChildren(this);
  }
}

typedef FfiVisitor = Visitor;

/// Root AST container holding all top-level declarations.
class PublicAst {
  final List<Decl> declarations;

  PublicAst(this.declarations);

  factory PublicAst.fromBindings(List<ast.Binding> bindings) {
    final decls = <Decl>[];
    for (final b in bindings) {
      final shadow = _wrapBinding(b);
      if (shadow != null) decls.add(shadow);
    }
    return PublicAst(decls);
  }

  static Decl? _wrapBinding(ast.Binding binding) {
    return switch (binding) {
      final ast.Struct s => Struct(s),
      final ast.Union u => Union(u),
      final ast.EnumClass e => EnumClass(e),
      final ast.UnnamedEnumConstant c => UnnamedEnumConstant(c),
      final ast.Func f => Func(f),
      final ast.Global g => Global(g),
      final ast.MacroConstant m => MacroConstant(m),
      final ast.Typealias t => Typealias(t),
      final ast.ObjCInterface i => ObjCInterface(i),
      final ast.ObjCProtocol p => ObjCProtocol(p),
      final ast.ObjCCategory c => ObjCCategory(c),
      final ast.CppClass c => CppClass(c),
      _ => null,
    };
  }

  void accept(Visitor visitor) {
    visitor.visitLibrary(this);
  }

  void visitChildren(Visitor visitor) {
    for (final decl in declarations) {
      decl.accept(visitor);
    }
  }
}

typedef FfiAst = PublicAst;

/// Abstract base for all public AST nodes.
abstract class AstNode {
  void accept(Visitor visitor);
  void visitChildren(Visitor visitor) {}
}

/// Top-level declaration public AST element.
abstract class Decl extends AstNode {
  String get originalName;
  String get name;
  set name(String value);
  String get usr;

  bool get isExcluded;
  set isExcluded(bool value);
}

class Struct extends Decl {
  final ast.Struct _binding;

  Struct(this._binding);

  @override
  String get originalName => _binding.originalName;

  @override
  String get usr => _binding.usr;

  @override
  String get name => _binding.symbol.oldName;

  @override
  set name(String value) => _binding.symbol.oldName = value;

  @override
  bool get isExcluded => _binding.userDefinedIsExcluded ?? false;

  @override
  set isExcluded(bool value) => _binding.userDefinedIsExcluded = value;

  int? get pack => _binding.pack;
  set pack(int? value) => _binding.pack = value;

  List<Field> get fields => _binding.members.map(Field.new).toList();

  @override
  void accept(Visitor visitor) => visitor.visitStruct(this);

  @override
  void visitChildren(Visitor visitor) {
    for (final field in fields) {
      field.accept(visitor);
    }
  }
}

class Union implements Decl {
  final ast.Union _binding;

  Union(this._binding);

  @override
  String get originalName => _binding.originalName;

  @override
  String get usr => _binding.usr;

  @override
  String get name => _binding.symbol.oldName;

  @override
  set name(String value) => _binding.symbol.oldName = value;

  @override
  bool get isExcluded => _binding.userDefinedIsExcluded ?? false;

  @override
  set isExcluded(bool value) => _binding.userDefinedIsExcluded = value;

  List<Field> get fields => _binding.members.map(Field.new).toList();

  @override
  void accept(Visitor visitor) => visitor.visitUnion(this);

  @override
  void visitChildren(Visitor visitor) {
    for (final field in fields) {
      field.accept(visitor);
    }
  }
}

class EnumClass implements Decl {
  final ast.EnumClass _binding;

  EnumClass(this._binding);

  @override
  String get originalName => _binding.originalName;

  @override
  String get usr => _binding.usr;

  @override
  String get name => _binding.symbol.oldName;

  @override
  set name(String value) => _binding.symbol.oldName = value;

  @override
  bool get isExcluded => _binding.userDefinedIsExcluded ?? false;

  @override
  set isExcluded(bool value) => _binding.userDefinedIsExcluded = value;

  EnumStyle get style => _binding.style;
  set style(EnumStyle value) => _binding.style = value;

  List<EnumConstant> get constants =>
      _binding.enumConstants.map(EnumConstant.new).toList();

  @override
  void accept(Visitor visitor) => visitor.visitEnum(this);

  @override
  void visitChildren(Visitor visitor) {
    for (final constant in constants) {
      constant.accept(visitor);
    }
  }
}

class UnnamedEnumConstant extends Decl {
  final ast.UnnamedEnumConstant _binding;

  UnnamedEnumConstant(this._binding);

  @override
  String get originalName =>
      _binding.originalName.isNotEmpty ? _binding.originalName : _binding.name;

  @override
  String get usr => _binding.usr;

  @override
  String get name => _binding.symbol.oldName;

  @override
  set name(String value) => _binding.symbol.oldName = value;

  @override
  bool get isExcluded => _binding.userDefinedIsExcluded ?? false;

  @override
  set isExcluded(bool value) => _binding.userDefinedIsExcluded = value;

  @override
  void accept(Visitor visitor) => visitor.visitUnnamedEnumConstant(this);
}

class Func extends Decl {
  final ast.Func _binding;

  Func(this._binding);

  @override
  String get originalName => _binding.originalName;

  @override
  String get usr => _binding.usr;

  @override
  String get name => _binding.symbol.oldName;

  @override
  set name(String value) {
    _binding.symbol.oldName = value;
    _binding.funcVarSymbol.oldName = '_$value';
  }

  @override
  bool get isExcluded => _binding.userDefinedIsExcluded ?? false;

  @override
  set isExcluded(bool value) => _binding.userDefinedIsExcluded = value;

  bool get exposeSymbolAddress => _binding.exposeSymbolAddress;
  set exposeSymbolAddress(bool value) => _binding.exposeSymbolAddress = value;

  bool get exposeFunctionTypedefs => _binding.exposeFunctionTypedefs;
  set exposeFunctionTypedefs(bool value) =>
      _binding.exposeFunctionTypedefs = value;

  bool get isLeaf => _binding.isLeaf;
  set isLeaf(bool value) => _binding.isLeaf = value;

  bool get recordUse => _binding.recordUse;
  set recordUse(bool value) => _binding.recordUse = value;

  List<Parameter> get parameters =>
      _binding.functionType.parameters.map(Parameter.new).toList();

  @override
  void accept(Visitor visitor) => visitor.visitFunc(this);

  @override
  void visitChildren(Visitor visitor) {
    for (final param in parameters) {
      param.accept(visitor);
    }
  }
}

class Global extends Decl {
  final ast.Global _binding;

  Global(this._binding);

  @override
  String get originalName => _binding.originalName;

  @override
  String get usr => _binding.usr;

  @override
  String get name => _binding.symbol.oldName;

  @override
  set name(String value) => _binding.symbol.oldName = value;

  @override
  bool get isExcluded => _binding.userDefinedIsExcluded ?? false;

  @override
  set isExcluded(bool value) => _binding.userDefinedIsExcluded = value;

  bool get exposeSymbolAddress => _binding.exposeSymbolAddress;
  set exposeSymbolAddress(bool value) => _binding.exposeSymbolAddress = value;

  @override
  void accept(Visitor visitor) => visitor.visitGlobal(this);
}

class MacroConstant extends Decl {
  final ast.MacroConstant _binding;

  MacroConstant(this._binding);

  @override
  String get originalName =>
      _binding.originalName.isNotEmpty ? _binding.originalName : _binding.name;

  @override
  String get usr => _binding.usr;

  @override
  String get name => _binding.symbol.oldName;

  @override
  set name(String value) => _binding.symbol.oldName = value;

  @override
  bool get isExcluded => _binding.userDefinedIsExcluded ?? false;

  @override
  set isExcluded(bool value) => _binding.userDefinedIsExcluded = value;

  @override
  void accept(Visitor visitor) => visitor.visitMacroConstant(this);
}

class Typealias extends Decl {
  final ast.Typealias _binding;

  Typealias(this._binding);

  @override
  String get originalName => _binding.originalName;

  @override
  String get usr => _binding.usr;

  @override
  String get name => _binding.symbol.oldName;

  @override
  set name(String value) => _binding.symbol.oldName = value;

  @override
  bool get isExcluded => _binding.userDefinedIsExcluded ?? false;

  @override
  set isExcluded(bool value) => _binding.userDefinedIsExcluded = value;

  @override
  void accept(Visitor visitor) => visitor.visitTypealias(this);
}

class ObjCInterface extends Decl {
  final ast.ObjCInterface _binding;

  ObjCInterface(this._binding);

  @override
  String get originalName => _binding.originalName;

  @override
  String get usr => _binding.usr;

  @override
  String get name => _binding.symbol.oldName;

  @override
  set name(String value) => _binding.symbol.oldName = value;

  @override
  bool get isExcluded => _binding.userDefinedIsExcluded ?? false;

  @override
  set isExcluded(bool value) => _binding.userDefinedIsExcluded = value;

  String? get module => _binding.module;
  set module(String? value) => _binding.module = value;

  bool get isObjCImport => _binding.isObjCImport;

  List<ObjCMethod> get methods => _binding.methods.map(ObjCMethod.new).toList();

  @override
  void accept(Visitor visitor) => visitor.visitObjCInterface(this);

  @override
  void visitChildren(Visitor visitor) {
    for (final method in methods) {
      method.accept(visitor);
    }
  }
}

class ObjCProtocol extends Decl {
  final ast.ObjCProtocol _binding;

  ObjCProtocol(this._binding);

  @override
  String get originalName => _binding.originalName;

  @override
  String get usr => _binding.usr;

  @override
  String get name => _binding.symbol.oldName;

  @override
  set name(String value) => _binding.symbol.oldName = value;

  @override
  bool get isExcluded => _binding.userDefinedIsExcluded ?? false;

  @override
  set isExcluded(bool value) => _binding.userDefinedIsExcluded = value;

  String? get module => _binding.module;
  set module(String? value) => _binding.module = value;

  bool get isObjCImport => _binding.isObjCImport;

  List<ObjCMethod> get methods => _binding.methods.map(ObjCMethod.new).toList();

  @override
  void accept(Visitor visitor) => visitor.visitObjCProtocol(this);

  @override
  void visitChildren(Visitor visitor) {
    for (final method in methods) {
      method.accept(visitor);
    }
  }
}

class ObjCCategory extends Decl {
  final ast.ObjCCategory _binding;

  ObjCCategory(this._binding);

  @override
  String get originalName => _binding.originalName;

  @override
  String get usr => _binding.usr;

  @override
  String get name => _binding.symbol.oldName;

  @override
  set name(String value) => _binding.symbol.oldName = value;

  @override
  bool get isExcluded => _binding.userDefinedIsExcluded ?? false;

  @override
  set isExcluded(bool value) => _binding.userDefinedIsExcluded = value;

  bool get isObjCImport => _binding.isObjCImport;

  List<ObjCMethod> get methods => _binding.methods.map(ObjCMethod.new).toList();

  @override
  void accept(Visitor visitor) => visitor.visitObjCCategory(this);

  @override
  void visitChildren(Visitor visitor) {
    for (final method in methods) {
      method.accept(visitor);
    }
  }
}

class CppClass extends Decl {
  final ast.CppClass _binding;

  CppClass(this._binding);

  @override
  String get originalName => _binding.originalName;

  @override
  String get usr => _binding.usr;

  @override
  String get name => _binding.symbol.oldName;

  @override
  set name(String value) => _binding.symbol.oldName = value;

  @override
  bool get isExcluded => _binding.userDefinedIsExcluded ?? false;

  @override
  set isExcluded(bool value) => _binding.userDefinedIsExcluded = value;

  List<CppMethod> get methods => _binding.methods.map(CppMethod.new).toList();

  List<Field> get fields => _binding.fields.map(Field.new).toList();

  @override
  void accept(Visitor visitor) => visitor.visitCppClass(this);

  @override
  void visitChildren(Visitor visitor) {
    for (final method in methods) {
      method.accept(visitor);
    }
    for (final field in fields) {
      field.accept(visitor);
    }
  }
}

/// Member elements
class Field extends AstNode {
  final ast.CompoundMember _member;

  Field(this._member);

  String get originalName => _member.originalName;

  String get name => _member.symbol.oldName;

  set name(String value) => _member.symbol.oldName = value;

  bool get isExcluded => _member.userDefinedIsExcluded ?? false;

  set isExcluded(bool value) => _member.userDefinedIsExcluded = value;

  @override
  void accept(Visitor visitor) => visitor.visitField(this);
}

class EnumConstant extends AstNode {
  final ast.EnumConstant _constant;

  EnumConstant(this._constant);

  String? get originalName => _constant.originalName;

  String get name => _constant.symbol.oldName;

  set name(String value) => _constant.symbol.oldName = value;

  int get value => _constant.value;

  bool get isExcluded => _constant.userDefinedIsExcluded ?? false;

  set isExcluded(bool value) => _constant.userDefinedIsExcluded = value;

  @override
  void accept(Visitor visitor) => visitor.visitEnumConstant(this);
}

class Parameter extends AstNode {
  final ast.Parameter _param;

  Parameter(this._param);

  String get originalName => _param.originalName;

  String get name => _param.symbol.oldName;

  set name(String value) => _param.symbol.oldName = value;

  bool get isExcluded => _param.userDefinedIsExcluded ?? false;

  set isExcluded(bool value) => _param.userDefinedIsExcluded = value;

  @override
  void accept(Visitor visitor) => visitor.visitParameter(this);
}

class ObjCMethod extends AstNode {
  final ast.ObjCMethod _method;

  ObjCMethod(this._method);

  String get originalName => _method.originalName;

  String get name => _method.symbol.oldName;

  set name(String value) {
    _method.symbol.oldName = value;
    if (_method.protocolMethodName != null) {
      _method.protocolMethodName!.oldName = value;
    }
  }

  bool get isClassMethod => _method.isClassMethod;

  bool get isProperty => _method.isProperty;

  bool get isExcluded => _method.userDefinedIsExcluded ?? false;

  set isExcluded(bool value) => _method.userDefinedIsExcluded = value;

  List<Parameter> get parameters => _method.params.map(Parameter.new).toList();

  @override
  void accept(Visitor visitor) => visitor.visitObjCMethod(this);

  @override
  void visitChildren(Visitor visitor) {
    for (final param in parameters) {
      param.accept(visitor);
    }
  }
}

class CppMethod extends AstNode {
  final ast.CppMethod _method;

  CppMethod(this._method);

  String get originalName => _method.originalName;

  String get name => _method.name.oldName;

  set name(String value) => _method.name.oldName = value;

  bool get isExcluded => _method.userDefinedIsExcluded ?? false;

  set isExcluded(bool value) => _method.userDefinedIsExcluded = value;

  @override
  void accept(Visitor visitor) => visitor.visitCppMethod(this);
}

/// Built-in Helper Visitors
class IncludeAllVisitor extends Visitor {
  const IncludeAllVisitor();

  @override
  void visitStruct(Struct node) => node.isExcluded = false;

  @override
  void visitUnion(Union node) => node.isExcluded = false;

  @override
  void visitEnum(EnumClass node) => node.isExcluded = false;

  @override
  void visitFunc(Func node) => node.isExcluded = false;

  @override
  void visitGlobal(Global node) => node.isExcluded = false;

  @override
  void visitMacroConstant(MacroConstant node) => node.isExcluded = false;

  @override
  void visitTypealias(Typealias node) => node.isExcluded = false;

  @override
  void visitObjCInterface(ObjCInterface node) => node.isExcluded = false;

  @override
  void visitObjCProtocol(ObjCProtocol node) => node.isExcluded = false;

  @override
  void visitObjCCategory(ObjCCategory node) => node.isExcluded = false;

  @override
  void visitUnnamedEnumConstant(UnnamedEnumConstant node) =>
      node.isExcluded = false;

  @override
  void visitCppClass(CppClass node) => node.isExcluded = false;
}

class ExcludeAllVisitor extends Visitor {
  const ExcludeAllVisitor();

  @override
  void visitStruct(Struct node) => node.isExcluded = true;

  @override
  void visitUnion(Union node) => node.isExcluded = true;

  @override
  void visitEnum(EnumClass node) => node.isExcluded = true;

  @override
  void visitFunc(Func node) => node.isExcluded = true;

  @override
  void visitGlobal(Global node) => node.isExcluded = true;

  @override
  void visitMacroConstant(MacroConstant node) => node.isExcluded = true;

  @override
  void visitTypealias(Typealias node) => node.isExcluded = true;

  @override
  void visitObjCInterface(ObjCInterface node) => node.isExcluded = true;

  @override
  void visitObjCProtocol(ObjCProtocol node) => node.isExcluded = true;

  @override
  void visitObjCCategory(ObjCCategory node) => node.isExcluded = true;

  @override
  void visitUnnamedEnumConstant(UnnamedEnumConstant node) =>
      node.isExcluded = true;

  @override
  void visitCppClass(CppClass node) => node.isExcluded = true;
}

class IncludeSetVisitor extends Visitor {
  final Set<String> names;

  const IncludeSetVisitor(this.names);

  void _check(Decl node) {
    node.isExcluded = !names.contains(node.originalName);
  }

  @override
  void visitStruct(Struct node) => _check(node);
  @override
  void visitUnion(Union node) => _check(node);
  @override
  void visitEnum(EnumClass node) => _check(node);
  @override
  void visitUnnamedEnumConstant(UnnamedEnumConstant node) => _check(node);
  @override
  void visitFunc(Func node) => _check(node);
  @override
  void visitGlobal(Global node) => _check(node);
  @override
  void visitMacroConstant(MacroConstant node) => _check(node);
  @override
  void visitTypealias(Typealias node) => _check(node);
  @override
  void visitObjCInterface(ObjCInterface node) => _check(node);
  @override
  void visitObjCProtocol(ObjCProtocol node) => _check(node);
  @override
  void visitObjCCategory(ObjCCategory node) => _check(node);
  @override
  void visitCppClass(CppClass node) => _check(node);
}

class RecordUseVisitor extends Visitor {
  const RecordUseVisitor();

  @override
  void visitFunc(Func node) {
    node.recordUse = true;
  }
}

class ExposeSymbolAddressVisitor extends Visitor {
  const ExposeSymbolAddressVisitor();

  @override
  void visitFunc(Func node) {
    node.exposeSymbolAddress = true;
  }

  @override
  void visitGlobal(Global node) {
    node.exposeSymbolAddress = true;
  }
}

class RenameMapVisitor extends Visitor {
  final Map<String, String> renames;

  const RenameMapVisitor(this.renames);

  void _rename(Decl node) {
    if (renames.containsKey(node.originalName)) {
      node.name = renames[node.originalName]!;
    }
  }

  @override
  void visitStruct(Struct node) => _rename(node);
  @override
  void visitUnion(Union node) => _rename(node);
  @override
  void visitEnum(EnumClass node) => _rename(node);
  @override
  void visitUnnamedEnumConstant(UnnamedEnumConstant node) => _rename(node);
  @override
  void visitFunc(Func node) => _rename(node);
  @override
  void visitGlobal(Global node) => _rename(node);
  @override
  void visitMacroConstant(MacroConstant node) => _rename(node);
  @override
  void visitTypealias(Typealias node) => _rename(node);
  @override
  void visitObjCInterface(ObjCInterface node) => _rename(node);
  @override
  void visitObjCProtocol(ObjCProtocol node) => _rename(node);
  @override
  void visitObjCCategory(ObjCCategory node) => _rename(node);
  @override
  void visitCppClass(CppClass node) => _rename(node);
}


