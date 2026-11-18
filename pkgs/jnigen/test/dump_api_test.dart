// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:jnigen/jnigen.dart';
import 'package:jnigen/src/elements/elements.dart' as ast;
import 'package:test/test.dart';

void main() {
  group('ApiDumperVisitor Tests (jnigen)', () {
    test('Dumps Java classes, methods, fields, and parameters', () {
      final classes = ast.Classes({
        'com.example.MyClass': ast.ClassDecl(
          binaryName: 'com.example.MyClass',
          declKind: ast.DeclKind.classKind,
          superclass: ast.DeclaredType.object,
          methods: [
            ast.Method(
              name: 'doWork',
              returnType: ast.DeclaredType.object,
              params: [
                ast.Param(name: 'amount', type: ast.DeclaredType.object),
              ],
            ),
          ],
          fields: [ast.Field(name: 'isActive', type: ast.DeclaredType.object)],
        ),
      });

      final dumped = ApiDumperVisitor.dump(Classes(classes));

      expect(dumped, '''
ClassDecl(com.example.MyClass)
Method(doWork, ClassDecl(com.example.MyClass))
Param(amount, Method(doWork, ClassDecl(com.example.MyClass)))
Field(isActive, ClassDecl(com.example.MyClass))
''');
    });

    test('ApiDumperVisitor can be used in visitor pipeline', () {
      final classes = ast.Classes({
        'pkg.Foo': ast.ClassDecl(
          binaryName: 'pkg.Foo',
          declKind: ast.DeclKind.classKind,
          superclass: ast.DeclaredType.object,
          methods: [
            ast.Method(name: 'bar', returnType: ast.DeclaredType.object),
          ],
          fields: [ast.Field(name: 'baz', type: ast.DeclaredType.object)],
        ),
      });

      final buffer = StringBuffer();
      final dumper = ApiDumperVisitor(buffer);
      final userClasses = Classes(classes);

      userClasses.accept(dumper);

      final output = buffer.toString();
      expect(output, contains('ClassDecl(pkg.Foo)'));
      expect(output, contains('Method(bar, ClassDecl(pkg.Foo))'));
      expect(output, contains('Field(baz, ClassDecl(pkg.Foo))'));
    });
  });
}
