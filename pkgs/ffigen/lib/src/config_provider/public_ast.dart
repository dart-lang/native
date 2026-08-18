// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../code_generator.dart' as internal;
import 'config.dart';
import 'config_types.dart';
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
  late final List<Param> params = _func.functionType.parameters
      .map((p) => Param(this, p))
      .toList();

  Func(this._func);

  /// Whether this function is a leaf function.
  ///
  /// This corresponds to the `isLeaf` parameter of FFI's `lookupFunction`.
  /// For more details, its documentation is here:
  /// https://api.dart.dev/dart-ffi/DynamicLibraryExtension/lookupFunction.html
  bool get isLeaf => _func.isLeaf;
  set isLeaf(bool value) => _func.isLeaf = value;

  /// Whether usage of this function should be recorded.
  ///
  /// When `true`, the generated Dart function is annotated with `@RecordUse()`
  /// from `package:meta`, allowing build tools and static analyzers to track
  /// references to this native function.
  bool get recordUse => _func.recordUse;
  set recordUse(bool value) => _func.recordUse = value;

  /// Whether to expose the symbol address for this function declaration in
  /// generated Dart bindings.
  ///
  /// When `true`, the function's symbol address is made available via the
  /// `addresses` getter as a `Pointer<NativeFunction<...>>`.
  bool get exposeSymbolAddress => _func.exposeSymbolAddress;
  set exposeSymbolAddress(bool value) => _func.exposeSymbolAddress = value;

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

  /// Whether this Func should be included in code generation.
  bool get isIncluded => _func.isIncluded;
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

  /// The byte alignment packing override for this struct declaration, or `null`
  /// if default alignment should be used.
  ///
  /// When specified, the generated Dart struct will be annotated with
  /// `@ffi.Packed(value)`. Supported values for packing are `1`, `2`, `4`, `8`,
  /// and `16`.
  int? get pack => _struct.pack;
  set pack(int? value) => _struct.pack = value;

  /// How dependencies of this struct should be generated.
  CompoundDependencies get dependencies => _struct.dependencies;
  set dependencies(CompoundDependencies value) => _struct.dependencies = value;

  /// Whether this Struct should be included in code generation.
  bool get isIncluded => _struct.isIncluded;
  set isIncluded(bool value) => _struct.isIncluded = value;
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

  /// How dependencies of this union should be generated.
  CompoundDependencies get dependencies => _union.dependencies;
  set dependencies(CompoundDependencies value) => _union.dependencies = value;

  /// Whether this Union should be included in code generation.
  bool get isIncluded => _union.isIncluded;
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

  /// The explicit [EnumStyle] configured for generating this enum declaration.
  ///
  /// If specified, this takes precedence over [suggestedStyle]. If `null`,
  /// [suggestedStyle] or the default style ([EnumStyle.dartEnum]) will be used.
  EnumStyle? get style => _enumClass.style;
  set style(EnumStyle? value) => _enumClass.style = value;

  /// The suggested [EnumStyle] for this enum declaration inferred during header
  /// parsing.
  ///
  /// Used when [style] is `null`.
  EnumStyle? get suggestedStyle => _enumClass.suggestedStyle;

  /// Whether warnings associated with this enum declaration should be
  /// suppressed.
  ///
  /// When `true`, warnings generated during processing of this enum (such as
  /// name collisions or unsupported enum features) will be silenced.
  bool get silenceWarning => _enumClass.silenceWarning;
  set silenceWarning(bool value) => _enumClass.silenceWarning = value;

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

  /// Whether this EnumClass should be included in code generation.
  bool get isIncluded => _enumClass.isIncluded;
  set isIncluded(bool value) => _enumClass.isIncluded = value;
}

/// A C global variable declaration.
class Global extends DeclNode {
  final internal.Global _global;

  Global(this._global);

  /// Whether to expose the symbol address for this global variable
  /// declaration in generated Dart bindings.
  ///
  /// When `true`, the global variable's symbol address is made available via
  /// the `addresses` getter as a `Pointer<...>`.
  bool get exposeSymbolAddress => _global.exposeSymbolAddress;
  set exposeSymbolAddress(bool value) => _global.exposeSymbolAddress = value;

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

  /// Whether this Global should be included in code generation.
  bool get isIncluded => _global.isIncluded;
  set isIncluded(bool value) => _global.isIncluded = value;
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

  /// Whether this MacroConstant should be included in code generation.
  bool get isIncluded => _macro.isIncluded;
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

  /// Whether this Typealias should be included in code generation.
  bool get isIncluded => _typealias.isIncluded;
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

  /// The module that the Objective-C interface belongs to.
  String? get module => _interface.module;
  set module(String? value) => _interface.module = value;

  /// Whether this ObjCInterface should be included in code generation.
  bool get isIncluded => _interface.isIncluded;
  set isIncluded(bool value) => _interface.isIncluded = value;
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

  /// The module that the Objective-C protocol belongs to.
  String? get module => _protocol.module;
  set module(String? value) => _protocol.module = value;

  /// Whether this ObjCProtocol should be included in code generation.
  bool get isIncluded => _protocol.isIncluded;
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

  /// Whether this ObjCCategory should be included in code generation.
  bool get isIncluded => _category.isIncluded;
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

  /// Whether this CppClass should be included in code generation.
  bool get isIncluded => _cppClass.isIncluded;
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
    visitor.visitAll(params);
  }

  @override
  String get originalName => _method.originalName;

  @override
  String get name => _method.name.oldName;

  @override
  set name(String value) => _method.name.oldName = value;

  /// Whether this CppMethod should be included in code generation.
  bool get isIncluded => _method.isIncluded;
  set isIncluded(bool value) => _method.isIncluded = value;
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

  /// Whether this ObjCMethod should be included in code generation.
  bool get isIncluded => _method.isIncluded;
  set isIncluded(bool value) => _method.isIncluded = value;
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

  /// Whether this UnnamedEnumConstant should be included in code generation.
  bool get isIncluded => _constant.isIncluded;
  set isIncluded(bool value) => _constant.isIncluded = value;
}
