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
}
