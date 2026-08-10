// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../code_generator.dart' as internal;
import 'config.dart';
import 'public_visitor.dart';

export 'public_visitor.dart';

/// Base class for all AST nodes.
abstract class AstNode {
  const AstNode();

  void accept(Visitor visitor);
}

/// Base class for AST nodes with a name.
abstract class NamedNode extends AstNode {
  const NamedNode();

  /// Original C/C++/Objective-C name of this AST node.
  String get originalName;

  /// The generated Dart name for this AST node.
  String get name;
  set name(String value);
}

/// Base class for declaration AST nodes.
abstract class DeclNode extends NamedNode {
  const DeclNode();

  /// USR identifier for this declaration.
  String get usr;
}

/// A C function declaration.
class Func extends DeclNode {
  final internal.Func _func;

  /// The parameters of this function.
  final List<Param> params;

  Func(this._func) : params = [] {
    params.addAll(_func.functionType.parameters.map((p) => Param(this, p)));
  }

  @override
  void accept(Visitor visitor) {
    visitor.visitFunc(this);
    visitor.visitAll(params);
  }

  @override
  String get usr => _func.usr;

  @override
  String get originalName => _func.originalName;

  @override
  String get name => _func.symbol.oldName;

  @override
  set name(String value) => _func.symbol.oldName = value;
}

/// A C struct declaration.
class Struct extends DeclNode {
  final internal.Struct _struct;

  /// The fields belonging to this struct.
  final List<Field> members;

  Struct(this._struct) : members = [] {
    members.addAll(_struct.members.map((m) => Field(this, m)));
  }

  @override
  void accept(Visitor visitor) {
    visitor.visitStruct(this);
    visitor.visitAll(members);
  }

  @override
  String get usr => _struct.usr;

  @override
  String get originalName => _struct.originalName;

  @override
  String get name => _struct.symbol.oldName;

  @override
  set name(String value) => _struct.symbol.oldName = value;
}

/// A C union declaration.
class Union extends DeclNode {
  final internal.Union _union;

  /// The fields belonging to this union.
  final List<Field> members;

  Union(this._union) : members = [] {
    members.addAll(_union.members.map((m) => Field(this, m)));
  }

  @override
  void accept(Visitor visitor) {
    visitor.visitUnion(this);
    visitor.visitAll(members);
  }

  @override
  String get usr => _union.usr;

  @override
  String get originalName => _union.originalName;

  @override
  String get name => _union.symbol.oldName;

  @override
  set name(String value) => _union.symbol.oldName = value;
}

/// An enum declaration.
class EnumClass extends DeclNode {
  final internal.EnumClass _enumClass;

  /// The constants belonging to this enum.
  final List<EnumConstant> constants;

  EnumClass(this._enumClass) : constants = [] {
    constants.addAll(
      _enumClass.enumConstants.map((c) => EnumConstant(this, c)),
    );
  }

  /// The [EnumStyle] for this enum declaration.
  EnumStyle? get style => _enumClass.style;
  set style(EnumStyle? value) => _enumClass.style = value;

  /// The suggested [EnumStyle] for this enum declaration.
  EnumStyle? get suggestedStyle => _enumClass.suggestedStyle;

  @override
  void accept(Visitor visitor) {
    visitor.visitEnum(this);
    visitor.visitAll(constants);
  }

  @override
  String get usr => _enumClass.usr;

  @override
  String get originalName => _enumClass.originalName;

  @override
  String get name => _enumClass.symbol.oldName;

  @override
  set name(String value) => _enumClass.symbol.oldName = value;
}

/// A C global variable declaration.
class Global extends DeclNode {
  final internal.Global _global;

  Global(this._global);

  @override
  void accept(Visitor visitor) => visitor.visitGlobal(this);

  @override
  String get usr => _global.usr;

  @override
  String get originalName => _global.originalName;

  @override
  String get name => _global.symbol.oldName;

  @override
  set name(String value) => _global.symbol.oldName = value;
}

/// A C macro constant declaration.
class MacroConstant extends DeclNode {
  final internal.MacroConstant _macro;

  MacroConstant(this._macro);

  @override
  void accept(Visitor visitor) => visitor.visitMacro(this);

  @override
  String get usr => _macro.usr;

  @override
  String get originalName => _macro.originalName;

  @override
  String get name => _macro.symbol.oldName;

  @override
  set name(String value) => _macro.symbol.oldName = value;
}

/// A C typedef (type alias) declaration.
class Typealias extends DeclNode {
  final internal.Typealias _typealias;

  Typealias(this._typealias);

  @override
  void accept(Visitor visitor) => visitor.visitTypealias(this);

  @override
  String get usr => _typealias.usr;

  @override
  String get originalName => _typealias.originalName;

  @override
  String get name => _typealias.symbol.oldName;

  @override
  set name(String value) => _typealias.symbol.oldName = value;
}

/// An Objective-C interface (class) declaration.
class ObjCInterface extends DeclNode {
  final internal.ObjCInterface _interface;

  /// The methods belonging to this Objective-C interface.
  final List<ObjCMethod> methods;

  ObjCInterface(this._interface) : methods = [] {
    methods.addAll(_interface.methods.map((m) => ObjCMethod(this, m)));
  }

  @override
  void accept(Visitor visitor) {
    visitor.visitObjCInterface(this);
    visitor.visitAll(methods);
  }

  @override
  String get usr => _interface.usr;

  @override
  String get originalName => _interface.originalName;

  @override
  String get name => _interface.symbol.oldName;

  @override
  set name(String value) => _interface.symbol.oldName = value;
}

/// An Objective-C protocol declaration.
class ObjCProtocol extends DeclNode {
  final internal.ObjCProtocol _protocol;

  /// The methods belonging to this Objective-C protocol.
  final List<ObjCMethod> methods;

  ObjCProtocol(this._protocol) : methods = [] {
    methods.addAll(_protocol.methods.map((m) => ObjCMethod(this, m)));
  }

  @override
  void accept(Visitor visitor) {
    visitor.visitObjCProtocol(this);
    visitor.visitAll(methods);
  }

  @override
  String get usr => _protocol.usr;

  @override
  String get originalName => _protocol.originalName;

  @override
  String get name => _protocol.symbol.oldName;

  @override
  set name(String value) => _protocol.symbol.oldName = value;
}

/// An Objective-C category declaration.
class ObjCCategory extends DeclNode {
  final internal.ObjCCategory _category;

  /// The methods belonging to this Objective-C category.
  final List<ObjCMethod> methods;

  ObjCCategory(this._category) : methods = [] {
    methods.addAll(_category.methods.map((m) => ObjCMethod(this, m)));
  }

  /// The [ObjCInterface] that this category extends.
  ObjCInterface get interface => ObjCInterface(_category.parent);

  @override
  void accept(Visitor visitor) {
    visitor.visitObjCCategory(this);
    visitor.visitAll(methods);
  }

  @override
  String get usr => _category.usr;

  @override
  String get originalName => _category.originalName;

  @override
  String get name => _category.symbol.oldName;

  @override
  set name(String value) => _category.symbol.oldName = value;
}

/// A C++ class declaration.
class CppClass extends DeclNode {
  final internal.CppClass _cppClass;

  /// The methods belonging to this C++ class.
  final List<CppMethod> methods;

  CppClass(this._cppClass) : methods = [] {
    methods.addAll(_cppClass.methods.map((m) => CppMethod(this, m)));
  }

  @override
  void accept(Visitor visitor) {
    visitor.visitCppClass(this);
    visitor.visitAll(methods);
  }

  @override
  String get usr => _cppClass.usr;

  @override
  String get originalName => _cppClass.originalName;

  @override
  String get name => _cppClass.symbol.oldName;

  @override
  set name(String value) => _cppClass.symbol.oldName = value;
}

/// A field in a struct or union.
class Field extends NamedNode {
  final internal.CompoundMember _member;

  /// The parent AST node containing this field (a [Struct] or [Union]).
  final DeclNode parent;

  Field(this.parent, this._member);

  @override
  void accept(Visitor visitor) => visitor.visitField(this);

  @override
  String get originalName => _member.originalName;

  @override
  String get name => _member.symbol.oldName;

  @override
  set name(String value) => _member.symbol.oldName = value;
}

/// A constant inside a named enum.
class EnumConstant extends NamedNode {
  final internal.EnumConstant _constant;

  /// The parent [EnumClass] containing this constant.
  final EnumClass parent;

  EnumConstant(this.parent, this._constant);

  @override
  void accept(Visitor visitor) => visitor.visitEnumConstant(this);

  @override
  String get originalName => _constant.originalName ?? _constant.name;

  @override
  String get name => _constant.symbol.oldName;

  @override
  set name(String value) => _constant.symbol.oldName = value;
}

/// A function or method parameter.
class Param extends NamedNode {
  final internal.Parameter _parameter;

  /// The parent AST node containing this parameter (a [Func], [ObjCMethod], or
  /// [CppMethod]).
  final NamedNode parent;

  Param(this.parent, this._parameter);

  @override
  void accept(Visitor visitor) => visitor.visitParam(this);

  @override
  String get originalName => _parameter.originalName;

  @override
  String get name => _parameter.symbol.oldName;

  @override
  set name(String value) => _parameter.symbol.oldName = value;
}

/// A C++ method declaration.
class CppMethod extends NamedNode {
  final internal.CppMethod _method;

  /// The parameters of this C++ method.
  final List<Param> params;

  /// The parent [CppClass] containing this C++ method.
  final CppClass parent;

  CppMethod(this.parent, this._method) : params = [] {
    params.addAll(_method.parameters.map((p) => Param(this, p)));
  }

  @override
  void accept(Visitor visitor) {
    visitor.visitCppMethod(this);
    visitor.visitAll(params);
  }

  @override
  String get originalName => _method.originalName;

  @override
  String get name => _method.name.oldName;

  @override
  set name(String value) => _method.name.oldName = value;
}

/// An Objective-C method declaration.
class ObjCMethod extends NamedNode {
  final internal.ObjCMethod _method;

  /// The parameters of this Objective-C method.
  final List<Param> params;

  /// The parent AST node containing this Objective-C method (an
  /// [ObjCInterface], [ObjCProtocol], or [ObjCCategory]).
  final DeclNode parent;

  ObjCMethod(this.parent, this._method) : params = [] {
    params.addAll(_method.params.map((p) => Param(this, p)));
  }

  @override
  void accept(Visitor visitor) {
    visitor.visitObjCMethod(this);
    visitor.visitAll(params);
  }

  /// The Objective-C method selector string.
  String get selector => _method.originalName;

  @override
  String get originalName => _method.originalName;

  @override
  String get name => _method.symbol.oldName;

  @override
  set name(String value) => _method.symbol.oldName = value;

  /// Whether this method is a property getter.
  bool get isPropertyGetter => _method.isPropertyGetter;

  /// Whether this method is a property setter.
  bool get isPropertySetter => _method.isPropertySetter;
}

/// An unnamed enum constant.
class UnnamedEnumConstant extends DeclNode {
  final internal.UnnamedEnumConstant _constant;

  UnnamedEnumConstant(this._constant);

  @override
  void accept(Visitor visitor) => visitor.visitUnnamedEnumConstant(this);

  @override
  String get usr => _constant.usr;

  @override
  String get originalName => _constant.originalName;

  @override
  String get name => _constant.symbol.oldName;

  @override
  set name(String value) => _constant.symbol.oldName = value;
}
