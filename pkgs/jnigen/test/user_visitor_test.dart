// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:jnigen/jnigen.dart';
import 'package:jnigen/src/bindings/dart_generator.dart';
import 'package:jnigen/src/bindings/linker.dart';
import 'package:jnigen/src/bindings/renamer.dart';
import 'package:jnigen/src/elements/elements.dart' as ast;
import 'package:test/test.dart';

extension on Iterable<ast.Method> {
  List<bool> get isIncludedValues =>
      map((c) => c.userDefinedIsIncluded).toList();
}

extension on Iterable<ast.Field> {
  List<bool> get isIncludedValues => map((c) => c.isIncluded).toList();
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

Future<void> rename(ast.Classes classes) async {
  final config = JniGenerator(
    input: Input(classes: []),
    output: Output(
      dart: DartCodeOutput(
        path: Uri.file('test.dart'),
        structure: OutputStructure.singleFile,
      ),
    ),
  );
  await classes.accept(Linker(config));
  classes.accept(Renamer(config));
}

base class CustomVisitor extends Visitor {
  CustomVisitor() : super.base();

  @override
  void visitClass(ClassDecl c) {
    if (c.binaryName.contains('y')) {
      c.isIncluded = false;
    }
  }

  @override
  void visitMethod(Method method) {
    if (method.name == 'Bar') {
      method.isIncluded = false;
    }
  }

  @override
  void visitField(Field field) {
    if (field.name == 'Bar') {
      field.isIncluded = false;
    }
  }
}

void main() {
  test('Exclude something using custom Visitor subclass', () async {
    final classes = ast.Classes({
      'Foo': ast.ClassDecl(
        binaryName: 'Foo',
        declKind: ast.DeclKind.classKind,
        superclass: ast.DeclaredType.object,
        methods: [
          ast.Method(name: 'foo', returnType: ast.DeclaredType.object),
          ast.Method(name: 'Bar', returnType: ast.DeclaredType.object),
          ast.Method(name: 'foo1', returnType: ast.DeclaredType.object),
          ast.Method(name: 'Bar', returnType: ast.DeclaredType.object),
        ],
        fields: [
          ast.Field(name: 'foo', type: ast.DeclaredType.object),
          ast.Field(name: 'Bar', type: ast.DeclaredType.object),
          ast.Field(name: 'foo1', type: ast.DeclaredType.object),
          ast.Field(name: 'Bar', type: ast.DeclaredType.object),
        ],
      ),
      'y.Foo': ast.ClassDecl(
          binaryName: 'y.Foo',
          declKind: ast.DeclKind.classKind,
          superclass: ast.DeclaredType.object,
          methods: [
            ast.Method(name: 'foo', returnType: ast.DeclaredType.object),
            ast.Method(name: 'Bar', returnType: ast.DeclaredType.object),
          ],
          fields: [
            ast.Field(name: 'foo', type: ast.DeclaredType.object),
            ast.Field(name: 'Bar', type: ast.DeclaredType.object),
          ]),
    });

    final simpleClasses = Classes(classes);
    simpleClasses.accept(CustomVisitor());

    expect(classes.decls['y.Foo']?.isIncluded, false);
    expect(classes.decls['Foo']?.isIncluded, true);

    expect(classes.decls['Foo']?.fields.isIncludedValues,
        [true, false, true, false]);
    expect(classes.decls['Foo']?.methods.isIncludedValues,
        [true, false, true, false]);
  });
  test('Exclude something using the user excluder, Simple AST', () async {
    final classes = ast.Classes({
      'Foo': ast.ClassDecl(
        binaryName: 'Foo',
        declKind: ast.DeclKind.classKind,
        superclass: ast.DeclaredType.object,
        methods: [
          ast.Method(name: 'foo', returnType: ast.DeclaredType.object),
          ast.Method(name: 'Bar', returnType: ast.DeclaredType.object),
          ast.Method(name: 'foo1', returnType: ast.DeclaredType.object),
          ast.Method(name: 'Bar', returnType: ast.DeclaredType.object),
        ],
        fields: [
          ast.Field(name: 'foo', type: ast.DeclaredType.object),
          ast.Field(name: 'Bar', type: ast.DeclaredType.object),
          ast.Field(name: 'foo1', type: ast.DeclaredType.object),
          ast.Field(name: 'Bar', type: ast.DeclaredType.object),
        ],
      ),
      'y.Foo': ast.ClassDecl(
          binaryName: 'y.Foo',
          declKind: ast.DeclKind.classKind,
          superclass: ast.DeclaredType.object,
          methods: [
            ast.Method(name: 'foo', returnType: ast.DeclaredType.object),
            ast.Method(name: 'Bar', returnType: ast.DeclaredType.object),
          ],
          fields: [
            ast.Field(name: 'foo', type: ast.DeclaredType.object),
            ast.Field(name: 'Bar', type: ast.DeclaredType.object),
          ]),
    });

    final simpleClasses = Classes(classes);
    simpleClasses.accept(
      Visitor(
        classDecl: (c) {
          if (c.binaryName.contains('y')) {
            c.isIncluded = false;
          }
        },
        method: (method) {
          if (method.name == 'Bar') {
            method.isIncluded = false;
          }
        },
        field: (field) {
          if (field.name == 'Bar') {
            field.isIncluded = false;
          }
        },
      ),
    );

    expect(classes.decls['y.Foo']?.isIncluded, false);
    expect(classes.decls['Foo']?.isIncluded, true);

    expect(classes.decls['Foo']?.fields.isIncludedValues,
        [true, false, true, false]);
    expect(classes.decls['Foo']?.methods.isIncludedValues,
        [true, false, true, false]);
  });

  test('Rename classes, fields, methods and params using the user renamer',
      () async {
    final classes = ast.Classes({
      'Foo': ast.ClassDecl(
        binaryName: 'Foo',
        declKind: ast.DeclKind.classKind,
        superclass: ast.DeclaredType.object,
        methods: [
          ast.Method(name: 'Foo', returnType: ast.DeclaredType.object),
          ast.Method(name: 'Foo', returnType: ast.DeclaredType.object),
          ast.Method(name: 'Foo1', returnType: ast.DeclaredType.object),
          ast.Method(name: 'Foo1', returnType: ast.DeclaredType.object),
        ],
        fields: [
          ast.Field(name: 'Foo', type: ast.DeclaredType.object),
          ast.Field(name: 'Foo', type: ast.DeclaredType.object),
          ast.Field(name: 'Foo1', type: ast.DeclaredType.object),
          ast.Field(name: 'Foo1', type: ast.DeclaredType.object),
        ],
      ),
      'y.Foo': ast.ClassDecl(
        binaryName: 'y.Foo',
        declKind: ast.DeclKind.classKind,
        superclass: ast.DeclaredType.object,
        methods: [
          ast.Method(name: 'Foo', returnType: ast.DeclaredType.object, params: [
            ast.Param(name: 'Foo', type: ast.DeclaredType.object),
            ast.Param(name: 'Foo1', type: ast.DeclaredType.object),
          ]),
          ast.Method(name: '<init>', returnType: ast.DeclaredType.object)
        ],
      ),
    });

    final simpleClasses = Classes(classes);
    simpleClasses.accept(
      Visitor(
        classDecl: (c) {
          if (c.originalName.contains('Foo')) {
            c.name = c.originalName.replaceAll('Foo', 'Bar');
          }
        },
        method: (method) {
          if (method.originalName.contains('Foo')) {
            method.name = method.originalName.replaceAll('Foo', 'Bar');
          }
          if (method.isConstructor) {
            method.name = 'constructor';
          }
        },
        field: (field) {
          if (field.originalName.contains('Foo')) {
            field.name = field.originalName.replaceAll('Foo', 'Bar');
          }
        },
        param: (parameter) {
          if (parameter.originalName.contains('Foo')) {
            parameter.name = parameter.originalName.replaceAll('Foo', 'Bar');
          }
        },
      ),
    );

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

  test('Rename interface mixin using the user visitor', () async {
    final classes = ast.Classes({
      'Foo': ast.ClassDecl(
        binaryName: 'Foo',
        declKind: ast.DeclKind.interfaceKind,
        superclass: ast.DeclaredType.object,
      ),
    });

    Classes(classes).accept(
      Visitor(
        classDecl: (c) {
          if (c.originalName == 'Foo') {
            c.interfaceMixinName = 'FooInterface';
          }
        },
      ),
    );

    expect(
      classes.decls['Foo']!.userDefinedInterfaceMixinName,
      'FooInterface',
    );

    await rename(classes);

    expect(
      classes.decls['Foo']!.finalInterfaceMixinName,
      'FooInterface',
    );
  });

  test('Use the renamed interface mixin in generated bindings', () async {
    final tempDirectory = Directory.systemTemp.createTempSync(
      'jnigen_interface_mixin_test_',
    );
    addTearDown(() => tempDirectory.deleteSync(recursive: true));

    final output = tempDirectory.uri.resolve('bindings.dart');
    final config = JniGenerator(
      input: Input(classes: []),
      output: Output(
        dart: DartCodeOutput(
          path: output,
          structure: OutputStructure.singleFile,
        ),
      ),
    );

    final classes = ast.Classes({
      'Foo': ast.ClassDecl(
        binaryName: 'Foo',
        declKind: ast.DeclKind.interfaceKind,
        superclass: ast.DeclaredType.object,
        methods: [
          ast.Method(
            name: 'run',
            returnType: ast.PrimitiveType.fromJson({'name': 'void'}),
          ),
        ],
      ),
    });

    Classes(classes).accept(
      Visitor(
        classDecl: (c) {
          if (c.originalName == 'Foo') {
            c.interfaceMixinName = 'FooInterface';
          }
        },
      ),
    );

    await classes.accept(Linker(config));
    classes.accept(Renamer(config));
    await classes.accept(DartGenerator(config));

    final content = File.fromUri(output).readAsStringSync();

    expect(
      content,
      contains('abstract base mixin class FooInterface'),
    );
    expect(
      content,
      contains('final class _FooInterface with FooInterface'),
    );
    expect(
      content,
      contains(r'FooInterface $impl'),
    );
    expect(
      content,
      isNot(contains(r'abstract base mixin class $Foo')),
    );
  });
}
