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
  ClassDecl(this._classDecl) : binaryName = _classDecl.binaryName;
  final ast.ClassDecl _classDecl;

  // Ex: com.x.Foo.
  final String binaryName;

  bool get isExcluded => _classDecl.isExcluded;
  set isExcluded(bool value) => _classDecl.isExcluded = value;

  set newName(String newName) => _classDecl.userDefinedName = newName;

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

  String get name => _method.name;

  bool get isExcluded => _method.isExcluded;
  set isExcluded(bool value) => _method.isExcluded = value;

  set newName(String newName) => _method.userDefinedName = newName;

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

  String get name => _param.name;

  set newName(String newName) => _param.userDefinedName = newName;

  @override
  void accept(Visitor visitor) {
    visitor.visitParam(this);
  }
}

class Field implements Element {
  Field(this._field);

  final ast.Field _field;

  String get name => _field.name;

  bool get isExcluded => _field.isExcluded;
  set isExcluded(bool value) => _field.isExcluded = value;

  set newName(String newName) => _field.userDefinedName = newName;

  @override
  void accept(Visitor visitor) {
    visitor.visitField(this);
  }
}
