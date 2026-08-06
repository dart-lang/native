// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'code_generator.dart' as cg;

/// Abstract base class for all public AST nodes.
abstract class AstNode {
  const AstNode();
  void accept(Visitor visitor);
}

/// Base class for AST visitors that inspect and transform AST nodes.
///
/// Implementations can extend [Visitor] by calling [Visitor.base] or use the
/// [Visitor] factory constructor to provide inline callbacks for specific
/// nodes.
abstract class Visitor {
  /// Base constructor for subclasses extending [Visitor].
  const Visitor.base();

  /// Creates a [Visitor] that delegates visiting to the provided callbacks.
  ///
  /// Unprovided callbacks default to no-op handlers.
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

/// A container holding top-level public AST nodes for visitor traversal.
class PublicAst {
  final List<AstNode> nodes;

  PublicAst(List<cg.Binding> rawBindings)
    : nodes = rawBindings
          .map((b) => b.toPublicAstNode())
          .whereType<AstNode>()
          .toList();

  void accept(Visitor visitor) {
    visitor.visitAll(nodes);
  }
}

/// Public AST node representing a C function declaration.
class Func extends AstNode {
  final cg.Func _func;

  /// The parameters of this function.
  final List<Param> params;

  /// Creates a public [Func] AST node wrapper.
  Func(this._func) : params = [] {
    params.addAll(
      _func.functionType.parameters.map((p) => Param(p, parent: this)),
    );
  }

  @override
  void accept(Visitor visitor) {
    visitor.visitFunc(this);
    visitor.visitAll(params);
  }

  /// The Unified Symbol Resolution (USR) identifier of this function.
  String get usr => _func.usr;

  /// The generated Dart name for this function.
  String get name => _func.symbol.oldName;

  /// Sets the generated Dart name for this function.
  set name(String value) {
    _func.symbol.oldName = value;
    _func.funcVarSymbol.oldName = '_$value';
  }
}

/// Public AST node representing a C struct declaration.
class Struct extends AstNode {
  final cg.Struct _struct;

  /// The fields belonging to this struct.
  final List<Field> members;

  /// Creates a public [Struct] AST node wrapper.
  Struct(this._struct) : members = [] {
    members.addAll(_struct.members.map((m) => Field(m, parent: this)));
  }

  @override
  void accept(Visitor visitor) {
    visitor.visitStruct(this);
    visitor.visitAll(members);
  }

  /// The Unified Symbol Resolution (USR) identifier of this struct.
  String get usr => _struct.usr;

  /// The generated Dart name for this struct.
  String get name => _struct.symbol.oldName;

  /// Sets the generated Dart name for this struct.
  set name(String value) => _struct.symbol.oldName = value;
}

/// Public AST node representing a C union declaration.
class Union extends AstNode {
  final cg.Union _union;

  /// The fields belonging to this union.
  final List<Field> members;

  /// Creates a public [Union] AST node wrapper.
  Union(this._union) : members = [] {
    members.addAll(_union.members.map((m) => Field(m, parent: this)));
  }

  @override
  void accept(Visitor visitor) {
    visitor.visitUnion(this);
    visitor.visitAll(members);
  }

  /// The Unified Symbol Resolution (USR) identifier of this union.
  String get usr => _union.usr;

  /// The generated Dart name for this union.
  String get name => _union.symbol.oldName;

  /// Sets the generated Dart name for this union.
  set name(String value) => _union.symbol.oldName = value;
}

/// Public AST node representing an enum declaration.
class EnumClass extends AstNode {
  final cg.EnumClass _enumClass;

  /// The constants belonging to this enum.
  final List<EnumConstant> constants;

  /// Creates a public [EnumClass] AST node wrapper.
  EnumClass(this._enumClass) : constants = [] {
    constants.addAll(
      _enumClass.enumConstants.map((c) => EnumConstant(c, parent: this)),
    );
  }

  @override
  void accept(Visitor visitor) {
    visitor.visitEnum(this);
    visitor.visitAll(constants);
  }

  /// The Unified Symbol Resolution (USR) identifier of this enum.
  String get usr => _enumClass.usr;

  /// The generated Dart name for this enum.
  String get name => _enumClass.symbol.oldName;

  /// Sets the generated Dart name for this enum.
  set name(String value) => _enumClass.symbol.oldName = value;
}

/// Public AST node representing a C global variable declaration.
class Global extends AstNode {
  final cg.Global _global;

  /// Creates a public [Global] AST node wrapper.
  Global(this._global);

  @override
  void accept(Visitor visitor) => visitor.visitGlobal(this);

  /// The Unified Symbol Resolution (USR) identifier of this global variable.
  String get usr => _global.usr;

  /// The generated Dart name for this global variable.
  String get name => _global.symbol.oldName;

  /// Sets the generated Dart name for this global variable.
  set name(String value) => _global.symbol.oldName = value;
}

/// Public AST node representing a C macro constant declaration.
class MacroConstant extends AstNode {
  final cg.MacroConstant _macro;

  /// Creates a public [MacroConstant] AST node wrapper.
  MacroConstant(this._macro);

  @override
  void accept(Visitor visitor) => visitor.visitMacro(this);

  /// The Unified Symbol Resolution (USR) identifier of this macro constant.
  String get usr => _macro.usr;

  /// The generated Dart name for this macro constant.
  String get name => _macro.symbol.oldName;

  /// Sets the generated Dart name for this macro constant.
  set name(String value) => _macro.symbol.oldName = value;
}

/// Public AST node representing a C typedef (type alias) declaration.
class Typealias extends AstNode {
  final cg.Typealias _typealias;

  /// Creates a public [Typealias] AST node wrapper.
  Typealias(this._typealias);

  @override
  void accept(Visitor visitor) => visitor.visitTypealias(this);

  /// The Unified Symbol Resolution (USR) identifier of this typedef.
  String get usr => _typealias.usr;

  /// The generated Dart name for this typedef.
  String get name => _typealias.symbol.oldName;

  /// Sets the generated Dart name for this typedef.
  set name(String value) => _typealias.symbol.oldName = value;
}

/// Public AST node representing an Objective-C interface (class) declaration.
class ObjCInterface extends AstNode {
  final cg.ObjCInterface _interface;

  /// The methods belonging to this Objective-C interface.
  final List<ObjCMethod> methods;

  /// Creates a public [ObjCInterface] AST node wrapper.
  ObjCInterface(this._interface) : methods = [] {
    methods.addAll(_interface.methods.map((m) => ObjCMethod(m, parent: this)));
  }

  @override
  void accept(Visitor visitor) {
    visitor.visitObjCInterface(this);
    visitor.visitAll(methods);
  }

  /// The Unified Symbol Resolution (USR) identifier of this Objective-C
  /// interface.
  String get usr => _interface.usr;

  /// The generated Dart name for this Objective-C interface.
  String get name => _interface.symbol.oldName;

  /// Sets the generated Dart name for this Objective-C interface.
  set name(String value) {
    _interface.symbol.oldName = value;
    _interface.classObject.symbol.oldName = '_class_$value';
    _interface.classObject.rawSymbol.oldName = '_class_${value}_raw';
  }
}

/// Public AST node representing an Objective-C protocol declaration.
class ObjCProtocol extends AstNode {
  final cg.ObjCProtocol _protocol;

  /// The methods belonging to this Objective-C protocol.
  final List<ObjCMethod> methods;

  /// Creates a public [ObjCProtocol] AST node wrapper.
  ObjCProtocol(this._protocol) : methods = [] {
    methods.addAll(_protocol.methods.map((m) => ObjCMethod(m, parent: this)));
  }

  @override
  void accept(Visitor visitor) {
    visitor.visitObjCProtocol(this);
    visitor.visitAll(methods);
  }

  /// The Unified Symbol Resolution (USR) identifier of this Objective-C
  /// protocol.
  String get usr => _protocol.usr;

  /// The generated Dart name for this Objective-C protocol.
  String get name => _protocol.symbol.oldName;

  /// Sets the generated Dart name for this Objective-C protocol.
  set name(String value) => _protocol.symbol.oldName = value;
}

/// Public AST node representing an Objective-C category declaration.
class ObjCCategory extends AstNode {
  final cg.ObjCCategory _category;

  /// The methods belonging to this Objective-C category.
  final List<ObjCMethod> methods;

  /// Creates a public [ObjCCategory] AST node wrapper.
  ObjCCategory(this._category) : methods = [] {
    methods.addAll(_category.methods.map((m) => ObjCMethod(m, parent: this)));
  }

  /// The [ObjCInterface] that this category extends.
  ObjCInterface get interface => ObjCInterface(_category.parent);

  @override
  void accept(Visitor visitor) {
    visitor.visitObjCCategory(this);
    visitor.visitAll(methods);
  }

  /// The Unified Symbol Resolution (USR) identifier of this Objective-C
  /// category.
  String get usr => _category.usr;

  /// The generated Dart name for this Objective-C category.
  String get name => _category.symbol.oldName;

  /// Sets the generated Dart name for this Objective-C category.
  set name(String value) => _category.symbol.oldName = value;
}

/// Public AST node representing a C++ class declaration.
class CppClass extends AstNode {
  final cg.CppClass _cppClass;

  /// The methods belonging to this C++ class.
  final List<CppMethod> methods;

  /// Creates a public [CppClass] AST node wrapper.
  CppClass(this._cppClass) : methods = [] {
    methods.addAll(_cppClass.methods.map((m) => CppMethod(m, parent: this)));
  }

  @override
  void accept(Visitor visitor) {
    visitor.visitCppClass(this);
    visitor.visitAll(methods);
  }

  /// The Unified Symbol Resolution (USR) identifier of this C++ class.
  String get usr => _cppClass.usr;

  /// The generated Dart name for this C++ class.
  String get name => _cppClass.symbol.oldName;

  /// Sets the generated Dart name for this C++ class.
  set name(String value) => _cppClass.symbol.oldName = value;
}

/// Public AST node representing a field in a struct or union.
class Field extends AstNode {
  final cg.CompoundMember _member;

  /// The parent AST node containing this field (a [Struct] or [Union]).
  final AstNode? parent;

  /// Creates a public [Field] AST node wrapper.
  Field(this._member, {this.parent});

  @override
  void accept(Visitor visitor) => visitor.visitField(this);

  /// The generated Dart name for this field.
  String get name => _member.symbol.oldName;

  /// Sets the generated Dart name for this field.
  set name(String value) => _member.symbol.oldName = value;
}

/// Public AST node representing a constant inside a named enum.
class EnumConstant extends AstNode {
  final cg.EnumConstant _constant;

  /// The parent [EnumClass] containing this constant.
  final EnumClass? parent;

  /// Creates a public [EnumConstant] AST node wrapper.
  EnumConstant(this._constant, {this.parent});

  @override
  void accept(Visitor visitor) => visitor.visitEnumConstant(this);

  /// The generated Dart name for this enum constant.
  String get name => _constant.symbol.oldName;

  /// Sets the generated Dart name for this enum constant.
  set name(String value) => _constant.symbol.oldName = value;
}

/// Public AST node representing a function or method parameter.
class Param extends AstNode {
  final cg.Parameter _parameter;

  /// The parent AST node containing this parameter (a [Func], [ObjCMethod], or
  /// [CppMethod]).
  final AstNode? parent;

  /// Creates a public [Param] AST node wrapper.
  Param(this._parameter, {this.parent});

  @override
  void accept(Visitor visitor) => visitor.visitParam(this);

  /// The generated Dart name for this parameter.
  String get name => _parameter.symbol.oldName;

  /// Sets the generated Dart name for this parameter.
  set name(String value) => _parameter.symbol.oldName = value;
}

/// Public AST node representing a C++ method declaration.
class CppMethod extends AstNode {
  final cg.CppMethod _method;

  /// The parameters of this C++ method.
  final List<Param> params;

  /// The parent [CppClass] containing this C++ method.
  final CppClass? parent;

  /// Creates a public [CppMethod] AST node wrapper.
  CppMethod(this._method, {this.parent}) : params = [] {
    params.addAll(_method.parameters.map((p) => Param(p, parent: this)));
  }

  @override
  void accept(Visitor visitor) {
    visitor.visitCppMethod(this);
    visitor.visitAll(params);
  }

  /// The generated Dart name for this C++ method.
  String get name => _method.name.oldName;

  /// Sets the generated Dart name for this C++ method.
  set name(String value) => _method.name.oldName = value;
}

/// Public AST node representing an Objective-C method declaration.
class ObjCMethod extends AstNode {
  final cg.ObjCMethod _method;

  /// The parameters of this Objective-C method.
  final List<Param> params;

  /// The parent AST node containing this Objective-C method (an
  /// [ObjCInterface], [ObjCProtocol], or [ObjCCategory]).
  final AstNode? parent;

  /// Creates a public [ObjCMethod] AST node wrapper.
  ObjCMethod(this._method, {this.parent}) : params = [] {
    params.addAll(_method.params.map((p) => Param(p, parent: this)));
  }

  @override
  void accept(Visitor visitor) {
    visitor.visitObjCMethod(this);
    visitor.visitAll(params);
  }

  /// The Objective-C method selector string.
  String get selector => _method.originalName;

  /// The generated Dart name for this Objective-C method.
  String get name => _method.symbol.oldName;

  /// Sets the generated Dart name for this Objective-C method.
  set name(String value) => _method.symbol.oldName = value;

  /// Whether this method is a property getter.
  bool get isPropertyGetter => _method.isPropertyGetter;

  /// Whether this method is a property setter.
  bool get isPropertySetter => _method.isPropertySetter;
}

/// Public AST node representing an unnamed enum constant.
class UnnamedEnumConstant extends AstNode {
  final cg.UnnamedEnumConstant _constant;

  /// Creates a public [UnnamedEnumConstant] AST node wrapper.
  UnnamedEnumConstant(this._constant);

  @override
  void accept(Visitor visitor) => visitor.visitUnnamedEnumConstant(this);

  /// The Unified Symbol Resolution (USR) identifier of this unnamed enum
  /// constant.
  String get usr => _constant.usr;

  /// The generated Dart name for this unnamed enum constant.
  String get name => _constant.symbol.oldName;

  /// Sets the generated Dart name for this unnamed enum constant.
  set name(String value) => _constant.symbol.oldName = value;
}
