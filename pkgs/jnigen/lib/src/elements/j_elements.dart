// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'elements.dart' as ast;

/// An element in the Java AST that can be visited.
abstract class _Element {
  /// Accepts a [Visitor] to traverse this element and its children.
  void accept(Visitor visitor);
}

/// A visitor that can traverse the AST of Java elements.
///
/// Users can extend this class to create custom visitors that modify the AST
/// before code generation.
abstract base class Visitor {
  const Visitor.base();

  factory Visitor({
    void Function(ClassDecl node)? classDecl,
    void Function(Method node)? method,
    void Function(Field node)? field,
    void Function(Param node)? param,
  }) = _VisitorImpl;

  /// Visits a class declaration.
  void visitClass(ClassDecl c) {}

  /// Visits a method declaration.
  void visitMethod(Method method) {}

  /// Visits a field declaration.
  void visitField(Field field) {}

  /// Visits a parameter declaration.
  void visitParam(Param parameter) {}
}

final class _VisitorImpl extends Visitor {
  const _VisitorImpl({
    void Function(ClassDecl node)? classDecl,
    void Function(Method node)? method,
    void Function(Field node)? field,
    void Function(Param node)? param,
  })  : _classDecl = classDecl,
        _method = method,
        _field = field,
        _param = param,
        super.base();

  final void Function(ClassDecl node)? _classDecl;
  final void Function(Method node)? _method;
  final void Function(Field node)? _field;
  final void Function(Param node)? _param;

  @override
  void visitClass(ClassDecl c) {
    _classDecl?.call(c);
  }

  @override
  void visitMethod(Method method) {
    _method?.call(method);
  }

  @override
  void visitField(Field field) {
    _field?.call(field);
  }

  @override
  void visitParam(Param parameter) {
    _param?.call(parameter);
  }
}

/// A collection of class declarations.
class Classes implements _Element {
  Classes(this._classes);
  final ast.Classes _classes;

  @override
  void accept(Visitor visitor) {
    for (final value in _classes.decls.values) {
      final classDecl = ClassDecl(value);
      classDecl.accept(visitor);
    }
  }
}

/// Represents a Java class declaration.
class ClassDecl implements _Element {
  ClassDecl(this._classDecl);
  final ast.ClassDecl _classDecl;

  /// The binary name of the class (e.g., "java.lang.Object").
  String get binaryName => _classDecl.binaryName;

  /// Whether this class should be included in code generation.
  bool get isIncluded => _classDecl.isIncluded;
  set isIncluded(bool value) => _classDecl.bindingMode =
      value ? ast.BindingMode.full : ast.BindingMode.excluded;

  /// The name of the class that will appear in generated code, subject to
  /// renaming to resolve conflicts (eg with keywords or other names).
  String get name => _classDecl.userDefinedName ?? _classDecl.name;
  set name(String newName) => _classDecl.userDefinedName = newName;

  /// The original name of the class in Java.
  String get originalName => _classDecl.name;

  /// The custom name of the mixin generated for implementing this Java
  /// interface
  ///
  /// If null, the default generated name is used.
  String? get interfaceMixinName => _classDecl.userDefinedInterfaceMixinName;

  set interfaceMixinName(String? newName) =>
      _classDecl.userDefinedInterfaceMixinName = newName;

  /// Documentation that appears in the generated Dart.
  ///
  /// Starts as the original Javadoc, if any. Assign an empty string to omit it.
  String get documentation => _classDecl.javadoc?.comment ?? '';
  set documentation(String value) {
    _classDecl.javadoc ??= ast.JavaDocComment();
    _classDecl.javadoc!.userDefinedComment = value;
  }

  @override
  void accept(Visitor visitor) {
    visitor.visitClass(this);
    if (!_classDecl.isIncluded) return;
    for (final method in _classDecl.methods) {
      Method(method).accept(visitor);
    }
    for (var field in _classDecl.fields) {
      Field(field).accept(visitor);
    }
  }
}

/// Represents a Java method declaration.
class Method implements _Element {
  Method(this._method);

  final ast.Method _method;

  /// Whether this method should be included in code generation.
  bool get isIncluded => _method.userDefinedIsIncluded;
  set isIncluded(bool value) => _method.userDefinedIsIncluded = value;

  /// The name of the method that will appear in generated code, subject to
  /// renaming to resolve conflicts (eg with keywords or other names).
  String get name => _method.userDefinedName ?? _method.name;
  set name(String newName) => _method.userDefinedName = newName;

  /// The original name of the method in Java.
  String get originalName => _method.name;

  /// Whether this method is a constructor.
  bool get isConstructor => _method.isConstructor;

  /// Documentation that appears in the generated Dart.
  ///
  /// Starts as the original Javadoc, if any. Assign an empty string to omit it.
  String get documentation => _method.javadoc?.comment ?? '';
  set documentation(String value) {
    _method.javadoc ??= ast.JavaDocComment();
    _method.javadoc!.userDefinedComment = value;
  }

  @override
  void accept(Visitor visitor) {
    visitor.visitMethod(this);
    if (!_method.userDefinedIsIncluded) return;
    for (final param in _method.params) {
      Param(param).accept(visitor);
    }
  }
}

/// Represents a Java parameter declaration.
class Param implements _Element {
  Param(this._param);

  final ast.Param _param;

  /// The name of the parameter that will appear in generated code, subject to
  /// renaming to resolve conflicts (eg with keywords or other names).
  String get name => _param.userDefinedName ?? _param.name;
  set name(String newName) => _param.userDefinedName = newName;

  /// The original name of the parameter in Java.
  String get originalName => _param.name;

  /// Documentation that appears in the generated Dart.
  ///
  /// Starts as the original Javadoc, if any. Assign an empty string to omit it.
  String get documentation => _param.javadoc?.comment ?? '';
  set documentation(String value) {
    _param.javadoc ??= ast.JavaDocComment();
    _param.javadoc!.userDefinedComment = value;
  }

  @override
  void accept(Visitor visitor) {
    visitor.visitParam(this);
  }
}

/// Represents a Java field declaration.
class Field implements _Element {
  Field(this._field);

  final ast.Field _field;

  /// Whether this field should be included in code generation.
  bool get isIncluded => _field.isIncluded;
  set isIncluded(bool value) => _field.isIncluded = value;

  /// The name of the field that will appear in generated code, subject to
  /// renaming to resolve conflicts (eg with keywords or other names).
  String get name => _field.userDefinedName ?? _field.name;
  set name(String newName) => _field.userDefinedName = newName;

  /// The original name of the field in Java.
  String get originalName => _field.name;

  /// Documentation that appears in the generated Dart.
  ///
  /// Starts as the original Javadoc, if any. Assign an empty string to omit it.
  String get documentation => _field.javadoc?.comment ?? '';
  set documentation(String value) {
    _field.javadoc ??= ast.JavaDocComment();
    _field.javadoc!.userDefinedComment = value;
  }

  @override
  void accept(Visitor visitor) {
    visitor.visitField(this);
  }
}
