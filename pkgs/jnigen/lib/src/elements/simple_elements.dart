// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'elements.dart';

// as the list of methods and the list of fields is not modifiable and not final
extension on ClassDecl {
  void updateMethods(List<Method> methods) {
    this.methods = methods;
  }

  void updateFields(List<Field> fields) {
    this.fields = fields;
  }
}

abstract class Element {
  void accept(Visitor visitor);
}

// making the functions empty, as if the user will not use some of them
// he is not required to override them
abstract class Visitor {
  void visitClass(SimpleClassDecl c) {}
  void visitMethod(SimpleMethod method) {}
  void visitField(SimpleField field) {}
}

class SimpleClasses implements Element {
  SimpleClasses(this._classes);
  final Classes _classes;

  @override
  void accept(Visitor visitor) {
    final excludedClasses = <ClassDecl>[];
    for (var c in _classes.decls.values) {
      final simpleClassDecl = SimpleClassDecl(c);
      simpleClassDecl.accept(visitor);
      if (simpleClassDecl.isExcluded) {
        excludedClasses.add(c);
      }
    }
    _classes.decls.removeWhere((key, value) => excludedClasses.contains(value));
  }
}

class SimpleClassDecl implements Element {
  SimpleClassDecl(this._classDecl) : binaryName = _classDecl.binaryName;
  final ClassDecl _classDecl;

  // ex: com.x.Foo
  String binaryName;
  bool isExcluded = false;

  @override
  void accept(Visitor visitor) {
    final notExcludedMethods = <Method>[];
    final notExcludedFields = <Field>[];
    visitor.visitClass(this);
    if (isExcluded) return;
    for (var method in _classDecl.methods) {
      final simpleMethod = SimpleMethod(method);
      simpleMethod.accept(visitor);
      if (!simpleMethod.isExcluded) {
        notExcludedMethods.add(method);
      }
    }
    for (var field in _classDecl.fields) {
      final simpleField = SimpleField(field);
      simpleField.accept(visitor);
      if (!simpleField.isExcluded) {
        notExcludedFields.add(field);
      }
    }
    _classDecl.updateMethods(notExcludedMethods);
    _classDecl.updateFields(notExcludedFields);
  }
}

class SimpleMethod implements Element {
  SimpleMethod(Method method) : name = method.name;
  String name;
  bool isExcluded = false;

  @override
  void accept(Visitor visitor) {
    visitor.visitMethod(this);
  }
}

class SimpleField implements Element {
  SimpleField(Field field) : name = field.name;
  String name;
  bool isExcluded = false;

  @override
  void accept(Visitor visitor) {
    visitor.visitField(this);
  }
}
