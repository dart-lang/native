// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'ast.dart';

class PublicAbstractor extends RecursiveAstVisitor<void> {
  final Map<String, Class> _classes = {};

  bool _isPublic(String name) => !name.startsWith('_');

  Map<String, Class> get classes => _classes;

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    final className = node.name.lexeme;
    if (_isPublic(className)) {
      final isAbstract = node.abstractKeyword != null;
      final isInterface = node.interfaceKeyword != null;
      final extendedClass = node.extendsClause?.superclass.toSource();
      final interfaces =
          node.implementsClause?.interfaces
              .map((type) => type.toSource())
              .toList();
      _classes[className] = Class(
        className,
        isAbstract,
        isInterface,
        extendedClass ?? '',
        interfaces ?? [],
      );
      node.visitChildren(this);
    }
  }

  String generateClassRepresentation() {
    final buffer = StringBuffer();

    for (final classInfo in _classes.values) {
      buffer.writeln(classInfo.toString());
      buffer.writeln();
    }
    return buffer.toString();
  }
}
