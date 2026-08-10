// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../code_generator.dart' as internal;
import 'public_visitor.dart';

export 'public_visitor.dart';

/// Base class for all AST nodes.
abstract class AstNode {
  const AstNode();

  void accept(Visitor visitor);

  bool get isIncluded => true;
  set isIncluded(bool value) {}
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
  late final List<Param> params = _func.functionType.parameters
      .map((p) => Param(this, p))
      .toList();

  Func(this._func);

  @override
  void accept(Visitor visitor) {
    visitor.visitFunc(this);
    if (isIncluded) visitor.visitAll(params);
  }

  @override
  String get usr => _func.usr;

  @override
  String get originalName => _func.originalName;

  @override
  String get name => _func.symbol.oldName;

  @override
  set name(String value) => _func.symbol.oldName = value;

  @override
  bool get isIncluded => _func.isIncluded;

  @override
  set isIncluded(bool value) => _func.isIncluded = value;
}

/// A C struct declaration.
class Struct extends DeclNode {
  final internal.Struct _struct;

  /// The fields belonging to this struct.
  late final List<Field> members = _struct.members
      .map((m) => Field(this, m))
      .toList();

  Struct(this._struct);

  @override
  void accept(Visitor visitor) {
    visitor.visitStruct(this);
    if (isIncluded) visitor.visitAll(members);
  }

  @override
  String get usr => _struct.usr;

  @override
  String get originalName => _struct.originalName;

  @override
  String get name => _struct.symbol.oldName;

  @override
  set name(String value) => _struct.symbol.oldName = value;

  bool get isInternal => _struct.isInternal;

  @override
  bool get isIncluded => _struct.isIncluded;

  @override
  set isIncluded(bool value) {
    if (_struct.isInternal) return;
    _struct.isIncluded = value;
  }
}

/// A C union declaration.
class Union extends DeclNode {
  final internal.Union _union;

  /// The fields belonging to this union.
  late final List<Field> members = _union.members
      .map((m) => Field(this, m))
      .toList();

  Union(this._union);

  @override
  void accept(Visitor visitor) {
    visitor.visitUnion(this);
    if (isIncluded) visitor.visitAll(members);
  }

  @override
  String get usr => _union.usr;

  @override
  String get originalName => _union.originalName;

  @override
  String get name => _union.symbol.oldName;

  @override
  set name(String value) => _union.symbol.oldName = value;

  @override
  bool get isIncluded => _union.isIncluded;

  @override
  set isIncluded(bool value) => _union.isIncluded = value;
}

/// An enum declaration.
class EnumClass extends DeclNode {
  final internal.EnumClass _enumClass;

  /// The constants belonging to this enum.
  late final List<EnumConstant> constants = _enumClass.enumConstants
      .map((c) => EnumConstant(this, c))
      .toList();

  EnumClass(this._enumClass);

  @override
  void accept(Visitor visitor) {
    visitor.visitEnum(this);
    if (isIncluded) visitor.visitAll(constants);
  }

  @override
  String get usr => _enumClass.usr;

  @override
  String get originalName => _enumClass.originalName;

  @override
  String get name => _enumClass.symbol.oldName;

  @override
  set name(String value) => _enumClass.symbol.oldName = value;

  @override
  bool get isIncluded => _enumClass.isIncluded;

  @override
  set isIncluded(bool value) => _enumClass.isIncluded = value;
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

  @override
  bool get isIncluded => _global.isIncluded;

  @override
  set isIncluded(bool value) => _global.isIncluded = value;
}

/// A C constant declaration.
class Constant extends DeclNode {
  final internal.Constant _constant;

  Constant(this._constant);

  @override
  void accept(Visitor visitor) => visitor.visitConstant(this);

  @override
  String get usr => _constant.usr;

  @override
  String get originalName => _constant.originalName;

  @override
  String get name => _constant.symbol.oldName;

  @override
  set name(String value) => _constant.symbol.oldName = value;

  @override
  bool get isIncluded => _constant.isIncluded;

  @override
  set isIncluded(bool value) => _constant.isIncluded = value;
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

  @override
  bool get isIncluded => _macro.isIncluded;

  @override
  set isIncluded(bool value) => _macro.isIncluded = value;
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

  @override
  bool get isIncluded => _typealias.isIncluded;

  @override
  set isIncluded(bool value) => _typealias.isIncluded = value;
}

/// An Objective-C interface (class) declaration.
class ObjCInterface extends DeclNode {
  final internal.ObjCInterface _interface;

  /// The methods belonging to this Objective-C interface.
  late final List<ObjCMethod> methods = _interface.methods
      .map((m) => ObjCMethod(this, m))
      .toList();

  ObjCInterface(this._interface);

  @override
  void accept(Visitor visitor) {
    visitor.visitObjCInterface(this);
    if (isIncluded) visitor.visitAll(methods);
  }

  @override
  String get usr => _interface.usr;

  @override
  String get originalName => _interface.originalName;

  @override
  String get name => _interface.symbol.oldName;

  @override
  set name(String value) => _interface.symbol.oldName = value;

  @override
  bool get isIncluded => _interface.isIncluded;

  @override
  set isIncluded(bool value) {
    if (_interface.isInternal) return;
    _interface.isIncluded = value;
  }

  bool get isInternal => _interface.isInternal;
}

/// An Objective-C protocol declaration.
class ObjCProtocol extends DeclNode {
  final internal.ObjCProtocol _protocol;

  /// The methods belonging to this Objective-C protocol.
  late final List<ObjCMethod> methods = _protocol.methods
      .map((m) => ObjCMethod(this, m))
      .toList();

  ObjCProtocol(this._protocol);

  @override
  void accept(Visitor visitor) {
    visitor.visitObjCProtocol(this);
    if (isIncluded) visitor.visitAll(methods);
  }

  @override
  String get usr => _protocol.usr;

  @override
  String get originalName => _protocol.originalName;

  @override
  String get name => _protocol.symbol.oldName;

  @override
  set name(String value) => _protocol.symbol.oldName = value;

  @override
  bool get isIncluded => _protocol.isIncluded;

  @override
  set isIncluded(bool value) => _protocol.isIncluded = value;
}

/// An Objective-C category declaration.
class ObjCCategory extends DeclNode {
  final internal.ObjCCategory _category;

  /// The methods belonging to this Objective-C category.
  late final List<ObjCMethod> methods = _category.methods
      .map((m) => ObjCMethod(this, m))
      .toList();

  /// The [ObjCInterface] that this category extends.
  late final ObjCInterface interface = ObjCInterface(_category.parent);

  ObjCCategory(this._category);

  @override
  void accept(Visitor visitor) {
    visitor.visitObjCCategory(this);
    if (isIncluded) visitor.visitAll(methods);
  }

  @override
  String get usr => _category.usr;

  @override
  String get originalName => _category.originalName;

  @override
  String get name => _category.symbol.oldName;

  @override
  set name(String value) => _category.symbol.oldName = value;

  @override
  bool get isIncluded => _category.isIncluded;

  @override
  set isIncluded(bool value) => _category.isIncluded = value;
}

/// A C++ class declaration.
class CppClass extends DeclNode {
  final internal.CppClass _cppClass;

  /// The methods belonging to this C++ class.
  late final List<CppMethod> methods = _cppClass.methods
      .map((m) => CppMethod(this, m))
      .toList();

  CppClass(this._cppClass);

  @override
  void accept(Visitor visitor) {
    visitor.visitCppClass(this);
    if (isIncluded) visitor.visitAll(methods);
  }

  @override
  String get usr => _cppClass.usr;

  @override
  String get originalName => _cppClass.originalName;

  @override
  String get name => _cppClass.symbol.oldName;

  @override
  set name(String value) => _cppClass.symbol.oldName = value;

  @override
  bool get isIncluded => _cppClass.isIncluded;

  @override
  set isIncluded(bool value) => _cppClass.isIncluded = value;
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
  late final List<Param> params = _method.parameters
      .map((p) => Param(this, p))
      .toList();

  /// The parent [CppClass] containing this C++ method.
  final CppClass parent;

  CppMethod(this.parent, this._method);

  @override
  void accept(Visitor visitor) {
    visitor.visitCppMethod(this);
    if (isIncluded) visitor.visitAll(params);
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
  late final List<Param> params = _method.params
      .map((p) => Param(this, p))
      .toList();

  /// The parent AST node containing this Objective-C method (an
  /// [ObjCInterface], [ObjCProtocol], or [ObjCCategory]).
  final DeclNode parent;

  ObjCMethod(this.parent, this._method);

  @override
  void accept(Visitor visitor) {
    visitor.visitObjCMethod(this);
    if (isIncluded) visitor.visitAll(params);
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

  @override
  bool get isIncluded => _method.isIncluded;

  @override
  set isIncluded(bool value) {
    if (parent case final ObjCInterface itf when itf.isInternal) return;
    _method.isIncluded = value;
  }
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

  @override
  bool get isIncluded => _constant.isIncluded;

  @override
  set isIncluded(bool value) => _constant.isIncluded = value;
}
