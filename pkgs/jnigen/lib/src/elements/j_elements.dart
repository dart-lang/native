// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'elements.dart' as ast;

abstract class Element {
  void accept(Visitor visitor);
}

abstract class Visitor {
  void visitClass(ClassDecl c) {}
  void visitMethod(Method method) {}
  void visitField(Field field) {}
  void visitParam(Param parameter) {}
}

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

  void let(void Function(dynamic userClasses) param0) {}
}

class ClassDecl implements Element {
  ClassDecl(this._classDecl);
  final ast.ClassDecl _classDecl;

  String get binaryName => _classDecl.binaryName;

  bool get isExcluded => _classDecl.isExcluded;
  set isExcluded(bool value) => _classDecl.isExcluded = value;

  String get name => _classDecl.userDefinedName ?? _classDecl.name;
  set name(String newName) => _classDecl.userDefinedName = newName;

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

class Method implements Element {
  Method(this._method);

  final ast.Method _method;

  bool get isExcluded => _method.isExcluded;
  set isExcluded(bool value) => _method.isExcluded = value;

  String get name => _method.userDefinedName ?? _method.name;
  set name(String newName) => _method.userDefinedName = newName;

  String get originalName => _method.name;

  @override
  void accept(Visitor visitor) {
    visitor.visitMethod(this);
    if (_method.isExcluded) return;
    for (final param in _method.params) {
      Param(param).accept(visitor);
    }
  }
}

class Param implements Element {
  Param(this._param);

  final ast.Param _param;

  String get name => _param.userDefinedName ?? _param.name;
  set name(String newName) => _param.userDefinedName = newName;

  String get originalName => _param.name;

  @override
  void accept(Visitor visitor) {
    visitor.visitParam(this);
  }
}

class Field implements Element {
  Field(this._field);

  final ast.Field _field;

  bool get isExcluded => _field.isExcluded;
  set isExcluded(bool value) => _field.isExcluded = value;

  String get name => _field.userDefinedName ?? _field.name;
  set name(String newName) => _field.userDefinedName = newName;

  String get originalName => _field.name;

  @override
  void accept(Visitor visitor) {
    visitor.visitField(this);
  }
}
