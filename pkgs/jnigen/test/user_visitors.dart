// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:jnigen/jnigen.dart' as jnigen;
import 'package:jnigen/src/bindings/linker.dart';
import 'package:jnigen/src/bindings/renamer.dart';
import 'package:jnigen/src/elements/elements.dart' as ast;
import 'package:jnigen/src/elements/j_elements.dart';
import 'package:test/test.dart';

extension on Iterable<ast.Method> {
  List<bool> get isExcludedValues => map((c) => c.isExcluded).toList();
}

extension on Iterable<ast.Field> {
  List<bool> get isExcludedValues => map((c) => c.isExcluded).toList();
}

extension on Iterable<ast.Method> {
  List<String> get finalNames => map((m) => m.finalName).toList();
}

extension on Iterable<ast.Param> {
  List<String> get finalNames => map((p) => p.finalName).toList();
}

extension on Iterable<ast.Field> {
  List<String> get finalNames => map((f) => f.finalName).toList();
}

// This is customizable by the user
class UserExcluder extends Visitor {
  @override
  void visitClass(ClassDecl c) {
    if (c.binaryName.contains('y')) {
      c.isExcluded = true;
    }
  }

  @override
  void visitMethod(Method method) {
    if (method.name == 'Bar') {
      method.isExcluded = true;
    }
  }

  @override
  void visitField(Field field) {
    if (field.name == 'Bar') {
      field.isExcluded = true;
    }
  }
}

// This is customizable by the user
class UserRenamer extends Visitor {
  @override
  void visitClass(ClassDecl c) {
    if (c.originalName.contains('Foo')) {
      c.name = c.originalName.replaceAll('Foo', 'Bar');
    }
  }

  @override
  void visitMethod(Method method) {
    if (method.originalName.contains('Foo')) {
      method.name = method.originalName.replaceAll('Foo', 'Bar');
    }
    if (method.isConstructor) {
      method.name = 'constructor';
    }
  }

  @override
  void visitField(Field field) {
    if (field.originalName.contains('Foo')) {
      field.name = field.originalName.replaceAll('Foo', 'Bar');
    }
  }

  @override
  void visitParam(Param parameter) {
    if (parameter.originalName.contains('Foo')) {
      parameter.name = parameter.originalName.replaceAll('Foo', 'Bar');
    }
  }
}

Future<void> rename(ast.Classes classes) async {
  final config = jnigen.Config(
      outputConfig: jnigen.OutputConfig(
        dartConfig: jnigen.DartCodeOutputConfig(
          path: Uri.file('test.dart'),
          structure: jnigen.OutputStructure.singleFile,
        ),
      ),
      classes: []);
  await classes.accept(Linker(config));
  classes.accept(Renamer(config));
}

void main() {
  test('Exclude something using the user excluder, Simple AST', () async {
    final classes = ast.Classes({
      'Foo': ast.ClassDecl(
        binaryName: 'Foo',
        declKind: ast.DeclKind.classKind,
        superclass: ast.TypeUsage.object,
        methods: [
          ast.Method(name: 'foo', returnType: ast.TypeUsage.object),
          ast.Method(name: 'Bar', returnType: ast.TypeUsage.object),
          ast.Method(name: 'foo1', returnType: ast.TypeUsage.object),
          ast.Method(name: 'Bar', returnType: ast.TypeUsage.object),
        ],
        fields: [
          ast.Field(name: 'foo', type: ast.TypeUsage.object),
          ast.Field(name: 'Bar', type: ast.TypeUsage.object),
          ast.Field(name: 'foo1', type: ast.TypeUsage.object),
          ast.Field(name: 'Bar', type: ast.TypeUsage.object),
        ],
      ),
      'y.Foo': ast.ClassDecl(
          binaryName: 'y.Foo',
          declKind: ast.DeclKind.classKind,
          superclass: ast.TypeUsage.object,
          methods: [
            ast.Method(name: 'foo', returnType: ast.TypeUsage.object),
            ast.Method(name: 'Bar', returnType: ast.TypeUsage.object),
          ],
          fields: [
            ast.Field(name: 'foo', type: ast.TypeUsage.object),
            ast.Field(name: 'Bar', type: ast.TypeUsage.object),
          ]),
    });

    final simpleClasses = Classes(classes);
    simpleClasses.accept(UserExcluder());

    expect(classes.decls['y.Foo']?.isExcluded, true);
    expect(classes.decls['Foo']?.isExcluded, false);

    expect(classes.decls['Foo']?.fields.isExcludedValues,
        [false, true, false, true]);
    expect(classes.decls['Foo']?.methods.isExcludedValues,
        [false, true, false, true]);
  });

  test('Rename classes, fields, methods and params using the user renamer',
      () async {
    final classes = ast.Classes({
      'Foo': ast.ClassDecl(
        binaryName: 'Foo',
        declKind: ast.DeclKind.classKind,
        superclass: ast.TypeUsage.object,
        methods: [
          ast.Method(name: 'Foo', returnType: ast.TypeUsage.object),
          ast.Method(name: 'Foo', returnType: ast.TypeUsage.object),
          ast.Method(name: 'Foo1', returnType: ast.TypeUsage.object),
          ast.Method(name: 'Foo1', returnType: ast.TypeUsage.object),
        ],
        fields: [
          ast.Field(name: 'Foo', type: ast.TypeUsage.object),
          ast.Field(name: 'Foo', type: ast.TypeUsage.object),
          ast.Field(name: 'Foo1', type: ast.TypeUsage.object),
          ast.Field(name: 'Foo1', type: ast.TypeUsage.object),
        ],
      ),
      'y.Foo': ast.ClassDecl(
        binaryName: 'y.Foo',
        declKind: ast.DeclKind.classKind,
        superclass: ast.TypeUsage.object,
        methods: [
          ast.Method(name: 'Foo', returnType: ast.TypeUsage.object, params: [
            ast.Param(name: 'Foo', type: ast.TypeUsage.object),
            ast.Param(name: 'Foo1', type: ast.TypeUsage.object),
          ]),
          ast.Method(name: '<init>', returnType: ast.TypeUsage.object)
        ],
      ),
    });

    final simpleClasses = Classes(classes);
    simpleClasses.accept(UserRenamer());

    await rename(classes);

    expect(classes.decls['Foo']?.finalName, 'Bar');
    expect(classes.decls['y.Foo']?.finalName, r'Bar$1');

    expect(classes.decls['Foo']?.fields.finalNames,
        ['Bar', r'Bar$1', 'Bar1', r'Bar1$1']);

    expect(classes.decls['Foo']?.methods.finalNames,
        [r'Bar$2', r'Bar$3', r'Bar1$2', r'Bar1$3']);

    expect(classes.decls['y.Foo']?.methods.finalNames, [r'Bar', 'constructor']);

    expect(classes.decls['y.Foo']?.methods.first.params.finalNames,
        ['Bar', 'Bar1']);
  });
}
