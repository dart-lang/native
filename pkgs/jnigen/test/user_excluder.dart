// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:jnigen/src/elements/elements.dart';
import 'package:jnigen/src/elements/simple_elements.dart';
import 'package:test/test.dart';


// this is customizable by the user
class UserExcluder extends Visitor {
  @override
  void visitClass(SimpleClassDecl c) {
    if (c.binaryName.contains('y')) {
      c.isExcluded = true;
    }
  }

  @override
  void visitMethod(SimpleMethod method) {
    if (method.name.compareTo('Bar') == 0) {
      method.isExcluded = true;
    }
  }

  @override
  void visitField(SimpleField field) {
    if (field.name.compareTo('Bar') == 0) {
      field.isExcluded = true;
    }
  }
}


void main() {
  test('Exclude something using the user excluder, Simple AST', () async {
    final classes = Classes({
      'Foo': ClassDecl(
        binaryName: 'Foo',
        declKind: DeclKind.classKind,
        superclass: TypeUsage.object,
        methods: [
          Method(name: 'foo', returnType: TypeUsage.object),
          Method(name: 'Bar', returnType: TypeUsage.object),
          Method(name: 'foo1', returnType: TypeUsage.object),
          Method(name: 'Bar', returnType: TypeUsage.object),
        ],
        fields: [
          Field(name: 'foo', type: TypeUsage.object),
          Field(name: 'Bar', type: TypeUsage.object),
          Field(name: 'foo1', type: TypeUsage.object),
          Field(name: 'Bar', type: TypeUsage.object),
        ],
      ),
      'y.Foo': ClassDecl(
          binaryName: 'y.Foo',
          declKind: DeclKind.classKind,
          superclass: TypeUsage.object,
          methods: [
            Method(name: 'foo', returnType: TypeUsage.object),
            Method(name: 'Bar', returnType: TypeUsage.object),
          ],
          fields: [
            Field(name: 'foo', type: TypeUsage.object),
            Field(name: 'Bar', type: TypeUsage.object),
          ]),
    });

    final simpleClasses = SimpleClasses(classes);
    simpleClasses.accept(UserExcluder());

    expect(classes.decls.containsKey('y.Foo'), false);
    expect(classes.decls.containsKey('Foo'), true);

    expect(classes.decls['Foo']?.fields.length, 2);
    expect(classes.decls['Foo']?.fields[0].name, 'foo');
    expect(classes.decls['Foo']?.fields[1].name, 'foo1');

    expect(classes.decls['Foo']?.methods.length, 2);
    expect(classes.decls['Foo']?.methods[0].name, 'foo');
    expect(classes.decls['Foo']?.methods[1].name, 'foo1');
  });
}
