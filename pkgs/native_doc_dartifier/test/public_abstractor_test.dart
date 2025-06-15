// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:native_doc_dartifier/src/public_abstractor.dart';
import 'package:test/test.dart';

void main() {
  group('Class summary group', () {
    final publicAbstractor = PublicAbstractor();

    test('Private class and Public class', () {
      const code = '''
      class Bar {
        void method() {}
      }

      class _Foo {}
      ''';

      parseString(content: code).unit.visitChildren(publicAbstractor);
      final classes = publicAbstractor.classes;

      expect(classes.containsKey('Bar'), isTrue);
      expect(classes.containsKey('_Foo'), isFalse);
      expect(classes['Bar']?.name, 'Bar');
      expect(classes['Bar']?.implementedInterfaces, isEmpty);
      expect(classes['Bar']?.extendedClass, isEmpty);
      expect(classes['Bar']?.isAbstract, isFalse);

      expect(classes['Bar']?.toString(), '- class Bar ');
    });

    test('interface class and abstract class', () {
      const code = '''      
      interface class Bar {
        void method() {}
      }

      abstract class Foo {
        void method();
      }
      ''';

      parseString(content: code).unit.visitChildren(publicAbstractor);
      final classes = publicAbstractor.classes;

      expect(classes.containsKey('Bar'), isTrue);
      expect(classes.containsKey('Foo'), isTrue);

      expect(classes['Bar']?.name, 'Bar');
      expect(classes['Bar']?.implementedInterfaces, isEmpty);
      expect(classes['Bar']?.isAbstract, isFalse);
      expect(classes['Bar']?.isInterface, isTrue);
      expect(classes['Bar']?.toString(), '- interface class Bar ');

      expect(classes['Foo']?.name, 'Foo');
      expect(classes['Foo']?.implementedInterfaces, isEmpty);
      expect(classes['Foo']?.isAbstract, isTrue);
      expect(classes['Foo']?.isInterface, isFalse);
      expect(classes['Foo']?.toString(), '- abstract class Foo ');
    });

    test('implements and extends classes', () {
      const code = '''
      class Bar extends _Foo implements Foo, _Baz {
        void method() {}
      }
      ''';

      parseString(content: code).unit.visitChildren(publicAbstractor);
      final classes = publicAbstractor.classes;

      expect(classes.containsKey('Bar'), isTrue);

      expect(classes['Bar']?.name, 'Bar');
      expect(classes['Bar']?.implementedInterfaces, ['Foo', '_Baz']);
      expect(classes['Bar']?.extendedClass, '_Foo');
      expect(classes['Bar']?.isAbstract, isFalse);
      expect(classes['Bar']?.isInterface, isFalse);

      expect(
        classes['Bar']?.toString(),
        '- class Bar extends _Foo implements Foo, _Baz ',
      );
    });
  });

  group('Field summary cases', () {
    final publicAbstractor = PublicAbstractor();
    const code = '''
    class Bar {
      int _privateField;
      int publicField;

      final implicitField = "value";
      final dynamicField;

      static int? a, a1, a2;
    }
    ''';

    parseString(content: code).unit.visitChildren(publicAbstractor);
    final fields = publicAbstractor.classes['Bar']!.fields;

    expect(fields, isNotNull);
    expect(fields.length, 6);

    test('Private and Public fields', () {
      expect(fields.any((field) => field.name == '_privateField'), isFalse);
      expect(fields.any((field) => field.name == 'publicField'), isTrue);

      expect(
        fields.firstWhere((field) => field.name == 'publicField').type,
        'int',
      );

      expect(
        fields.firstWhere((field) => field.name == 'publicField').isStatic,
        isFalse,
      );
    });

    test('final field type inference', () {
      expect(
        fields.firstWhere((field) => field.name == 'implicitField').type,
        'String',
      );
      expect(
        fields.firstWhere((field) => field.name == 'dynamicField').type,
        'dynamic',
      );
    });

    test('static nullable multiple fields in one decleration', () {
      expect(fields.any((field) => field.name == 'a'), isTrue);
      expect(fields.any((field) => field.name == 'a1'), isTrue);
      expect(fields.any((field) => field.name == 'a2'), isTrue);

      expect(fields.firstWhere((field) => field.name == 'a').type, 'int?');
      expect(fields.firstWhere((field) => field.name == 'a1').type, 'int?');
      expect(fields.firstWhere((field) => field.name == 'a2').type, 'int?');

      expect(fields.firstWhere((field) => field.name == 'a').isStatic, isTrue);
      expect(fields.firstWhere((field) => field.name == 'a1').isStatic, isTrue);
      expect(fields.firstWhere((field) => field.name == 'a2').isStatic, isTrue);
    });
  });
}
