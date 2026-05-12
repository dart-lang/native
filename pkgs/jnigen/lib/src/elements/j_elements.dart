// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'elements.dart' as ast;

/// An element in the Java AST that can be visited.
abstract class Element {
  /// Accepts a [Visitor] to traverse this element and its children.
  void accept(Visitor visitor);
}

/// A visitor that can traverse the AST of Java elements.
///
/// Users can extend this class to create custom visitors that modify the AST
/// before code generation.
abstract class Visitor {
  /// Visits a class declaration.
  void visitClass(ClassDecl c) {}

  /// Visits a method declaration.
  void visitMethod(Method method) {}

  /// Visits a field declaration.
  void visitField(Field field) {}

  /// Visits a parameter declaration.
  void visitParam(Param parameter) {}
}

/// A collection of class declarations.
class Classes implements Element {
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
class ClassDecl implements Element {
  ClassDecl(this._classDecl);
  final ast.ClassDecl _classDecl;

  /// The binary name of the class (e.g., "java.lang.Object").
  String get binaryName => _classDecl.binaryName;

  /// Whether this class should be excluded from code generation.
  bool get isExcluded => _classDecl.isExcluded;
  set isExcluded(bool value) => _classDecl.isExcluded = value;

  /// The name of the class that will appear in generated code.
  String get name => _classDecl.userDefinedName ?? _classDecl.name;
  set name(String newName) => _classDecl.userDefinedName = newName;

  /// The original name of the class in Java.
  String get originalName => _classDecl.name;

  @override
  void accept(Visitor visitor) {
    visitor.visitClass(this);
    if (_classDecl.isExcluded) return;
    for (final method in _classDecl.methods) {
      Method(method).accept(visitor);
    }
    for (var field in _classDecl.fields) {
      Field(field).accept(visitor);
    }
  }
}

/// Represents a Java method declaration.
class Method implements Element {
  Method(this._method);

  final ast.Method _method;

  /// Whether this method should be excluded from code generation.
  bool get isExcluded => _method.userDefinedIsExcluded;
  set isExcluded(bool value) => _method.userDefinedIsExcluded = value;

  /// The name of the method that will appear in generated code.
  String get name => _method.userDefinedName ?? _method.name;
  set name(String newName) => _method.userDefinedName = newName;

  /// The original name of the method in Java.
  String get originalName => _method.name;

  /// Whether this method is a constructor.
  bool get isConstructor => _method.isConstructor;

  @override
  void accept(Visitor visitor) {
    visitor.visitMethod(this);
    if (_method.userDefinedIsExcluded) return;
    for (final param in _method.params) {
      Param(param).accept(visitor);
    }
  }
}

/// Represents a Java method parameter declaration.
class Param implements Element {
  Param(this._param);

  final ast.Param _param;

  /// The name of the parameter that will appear in generated code.
  String get name => _param.userDefinedName ?? _param.name;
  set name(String newName) => _param.userDefinedName = newName;

  /// The original name of the parameter in Java.
  String get originalName => _param.name;

  @override
  void accept(Visitor visitor) {
    visitor.visitParam(this);
  }
}

/// Represents a Java field declaration.
class Field implements Element {
  Field(this._field);

  final ast.Field _field;

  /// Whether this field should be excluded from code generation.
  bool get isExcluded => _field.isExcluded;
  set isExcluded(bool value) => _field.isExcluded = value;

  /// The name of the field that will appear in generated code.
  String get name => _field.userDefinedName ?? _field.name;
  set name(String newName) => _field.userDefinedName = newName;

  /// The original name of the field in Java.
  String get originalName => _field.name;

  @override
  void accept(Visitor visitor) {
    visitor.visitField(this);
  }
}
