// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'j_elements.dart';

/// A visitor that dumps all visited Java AST nodes in a concise, greppable
/// format.
///
/// Output format examples:
/// ```text
/// ClassDecl(java.lang.Object)
/// Method(toString, ClassDecl(java.lang.Object))
/// Param(obj, Method(equals, ClassDecl(java.lang.Object)))
/// Field(myField, ClassDecl(com.example.MyClass))
/// ```
final class ApiDumperVisitor extends Visitor {
  final StringSink _sink;
  ClassDecl? _currentClass;
  Method? _currentMethod;

  /// Creates an [ApiDumperVisitor] that writes to [sink] (defaults to
  /// [stdout]).
  ApiDumperVisitor([StringSink? sink])
      : _sink = sink ?? stdout,
        super.base();

  /// Dumps all [classes] and returns the formatted output string.
  static String dump(Classes classes) {
    final buffer = StringBuffer();
    final visitor = ApiDumperVisitor(buffer);
    classes.accept(visitor);
    return buffer.toString();
  }

  static String _classString(ClassDecl? c) =>
      'ClassDecl(${c?.binaryName ?? 'unknown'})';

  static String _methodString(Method? m, ClassDecl? c) =>
      'Method(${m?.originalName ?? 'unknown'}, ${_classString(c)})';

  @override
  void visitClass(ClassDecl c) {
    _currentClass = c;
    _sink.writeln(_classString(c));
  }

  @override
  void visitMethod(Method method) {
    _currentMethod = method;
    _sink.writeln(_methodString(method, _currentClass));
  }

  @override
  void visitField(Field field) {
    _sink.writeln(
      'Field(${field.originalName}, ${_classString(_currentClass)})',
    );
  }

  @override
  void visitParam(Param parameter) {
    _sink.writeln(
      'Param(${parameter.originalName}, '
      '${_methodString(_currentMethod, _currentClass)})',
    );
  }
}
