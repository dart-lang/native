// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'ast.dart';

String generateBindingsSummary(String sourceCode) {
  final abstractor = PublicAbstractor();
  parseString(content: sourceCode).unit.visitChildren(abstractor);
  final summary = abstractor.getClassesSummary().join('\n\n');
  return summary.replaceAll('jni\$_.', '').replaceAll('core\$_.', '');
}

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

  @override
  void visitFieldDeclaration(FieldDeclaration node) {
    final className =
        (node.parent is ClassDeclaration)
            ? (node.parent as ClassDeclaration).name.lexeme
            : '';

    if (className.isEmpty || !_isPublic(className)) return;

    for (final variable in node.fields.variables) {
      final fieldName = variable.name.lexeme;
      if (_isPublic(fieldName)) {
        _classes[className]!.addField(
          Field(
            fieldName,
            node.fields.type?.toSource() ?? 'dynamic',
            isStatic: node.isStatic,
          ),
        );
      }
    }
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    final className =
        (node.parent is ClassDeclaration)
            ? (node.parent as ClassDeclaration).name.lexeme
            : '';

    final methodName = node.name.lexeme;

    if (className.isEmpty || !_isPublic(className) || !_isPublic(methodName)) {
      return;
    }

    final returnType = node.returnType?.toSource() ?? 'dynamic';
    final parameters = node.parameters?.toSource() ?? '()';
    final typeParameters = node.typeParameters?.toSource() ?? '';
    final operatorKeyword = node.operatorKeyword?.stringValue ?? '';

    if (node.isGetter) {
      _classes[className]!.getters.add(
        Getter(methodName, returnType, node.isStatic),
      );
      return;
    }

    if (node.isSetter) {
      _classes[className]!.setters.add(
        Setter(
          methodName,
          returnType,
          node.isStatic,
          node.parameters?.toSource() ?? '()',
        ),
      );
      return;
    }

    _classes[className]!.addMethod(
      Method(
        methodName,
        returnType,
        node.isStatic,
        parameters,
        typeParameters,
        operatorKeyword: operatorKeyword,
      ),
    );
  }

  @override
  void visitConstructorDeclaration(ConstructorDeclaration node) {
    final className =
        (node.parent is ClassDeclaration)
            ? (node.parent as ClassDeclaration).name.lexeme
            : '';

    final constructorName = node.name?.lexeme ?? '';

    if (className.isEmpty ||
        !_isPublic(className) ||
        !_isPublic(constructorName)) {
      return;
    }

    final parameters = node.parameters.toSource();

    _classes[className]!.constructors.add(
      Constructor(
        className,
        constructorName,
        parameters,
        node.factoryKeyword?.stringValue,
      ),
    );
  }

  List<String> getClassesSummary() {
    final classesSummary = <String>[];

    for (final classInfo in _classes.values) {
      classesSummary.add(classInfo.toDartLikeRepresentaion());
    }
    return classesSummary;
  }
}
