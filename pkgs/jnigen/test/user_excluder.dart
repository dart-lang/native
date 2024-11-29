// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:jnigen/src/elements/elements.dart' as ast;
import 'package:jnigen/src/elements/public_elements.dart';
import 'package:test/test.dart';

extension on Iterable<ast.Method> {
  List<bool> get isExcludedValues => map((c) => c.isExcluded).toList();
}

extension on Iterable<ast.Field> {
  List<bool> get isExcludedValues => map((c) => c.isExcluded).toList();
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

    expect(classes.decls['Foo']!.fields.isExcludedValues,
        [false, true, false, true]);
    expect(classes.decls['Foo']!.methods.isExcludedValues,
        [false, true, false, true]);
  });
}
