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

      expect(classes['Foo']?.name, 'Foo');
      expect(classes['Foo']?.implementedInterfaces, isEmpty);
      expect(classes['Foo']?.isAbstract, isTrue);
      expect(classes['Foo']?.isInterface, isFalse);
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
    });
  });

  group('Field summary cases', () {
    final publicAbstractor = PublicAbstractor();
    const code = '''
    class Bar {
      int _privateField;
      int publicField = 10;

      static final staticField;

      int? a, a1, a2;
    }
    ''';

    parseString(content: code).unit.visitChildren(publicAbstractor);
    final fields = publicAbstractor.classes['Bar']!.fields;

    test('Total number of fields in snippet', () {
      expect(fields, isNotNull);
      expect(fields.length, 5);
    });

    test('Private, Public, Static fields', () {
      expect(fields.any((field) => field.name == '_privateField'), isFalse);

      expect(
        fields.firstWhere((field) => field.name == 'publicField').type,
        'int',
      );

      expect(
        fields.firstWhere((field) => field.name == 'publicField').isStatic,
        isFalse,
      );

      expect(
        fields.firstWhere((field) => field.name == 'staticField').type,
        'dynamic',
      );

      expect(
        fields.firstWhere((field) => field.name == 'staticField').isStatic,
        isTrue,
      );
    });

    test('multiple fields in one decleration', () {
      final a = fields.firstWhere((field) => field.name == 'a');
      final a1 = fields.firstWhere((field) => field.name == 'a1');
      final a2 = fields.firstWhere((field) => field.name == 'a2');

      expect(a.type, 'int?');
      expect(a1.type, 'int?');
      expect(a2.type, 'int?');

      expect(a.isStatic, isFalse);
      expect(a1.isStatic, isFalse);
      expect(a2.isStatic, isFalse);
    });
  });
  group('Method summary cases', () {
    final publicAbstractor = PublicAbstractor();
    const code = '''
    class Foo {
      void _privateMethod() {}
      static void publicMethod() {}
      
      void methodWithPositionalParams(int a, String b) {}
      void methodWithNamedParams({String name}) {}
      void methodWithFunctionalParams(void Function(String, int) callback) {}
      void methodWithTypeParameters<T>(T value) {}
      Foo operator +(Foo other) {}
    }
    ''';

    parseString(content: code).unit.visitChildren(publicAbstractor);
    final methods = publicAbstractor.classes['Foo']!.methods;

    test('Number of methods', () {
      expect(methods, isNotNull);
      expect(methods.length, 6);
    });

    test('private, public, static methods', () {
      expect(methods.any((method) => method.name == '_privateMethod'), isFalse);

      final publicMethod = methods.firstWhere(
        (method) => method.name == 'publicMethod',
      );
      expect(publicMethod.isStatic, isTrue);
      expect(publicMethod.returnType, 'void');
      expect(publicMethod.parameters, equals('()'));
      expect(publicMethod.typeParameters, isEmpty);
    });

    test('positional parameters', () {
      final positionalMethod = methods.firstWhere(
        (method) => method.name == 'methodWithPositionalParams',
      );
      expect(positionalMethod.name, 'methodWithPositionalParams');
      expect(positionalMethod.isStatic, isFalse);
      expect(positionalMethod.returnType, 'void');
      expect(positionalMethod.parameters, '(int a, String b)');
      expect(positionalMethod.typeParameters, isEmpty);
    });

    test('functional parameters', () {
      final functionalMethod = methods.firstWhere(
        (method) => method.name == 'methodWithFunctionalParams',
      );
      expect(functionalMethod.name, 'methodWithFunctionalParams');
      expect(functionalMethod.isStatic, isFalse);
      expect(functionalMethod.returnType, 'void');
      expect(
        functionalMethod.parameters,
        '(void Function(String, int) callback)',
      );
      expect(functionalMethod.typeParameters, isEmpty);
    });

    test('named parameters', () {
      final m = methods.firstWhere(
        (method) => method.name == 'methodWithNamedParams',
      );
      expect(m.name, 'methodWithNamedParams');
      expect(m.isStatic, isFalse);
      expect(m.returnType, 'void');
      expect(m.parameters, '({String name})');
      expect(m.typeParameters, isEmpty);
    });

    test('method with type parameters', () {
      final typeParamMethod = methods.firstWhere(
        (method) => method.name == 'methodWithTypeParameters',
      );
      expect(typeParamMethod.name, 'methodWithTypeParameters');
      expect(typeParamMethod.isStatic, isFalse);
      expect(typeParamMethod.returnType, 'void');
      expect(typeParamMethod.parameters, '(T value)');
      expect(typeParamMethod.typeParameters, '<T>');
    });

    test('operator method', () {
      final operatorMethod = methods.firstWhere((method) => method.name == '+');
      expect(operatorMethod.name, '+');
      expect(operatorMethod.isStatic, isFalse);
      expect(operatorMethod.returnType, 'Foo');
      expect(operatorMethod.parameters, '(Foo other)');
      expect(operatorMethod.typeParameters, isEmpty);
    });
  });

  group('Constructors cases', () {
    const code = '''
    class Bar {
      int? a, b;

      Bar() {
        print('something');
      }
      Bar._privateConstructor() {
        print('something');
      }
      Bar.withParams(this.a, this.b, {int? k}) {
        print('something');
      }
      factory Bar.factoryConstructor(int x) => Bar.withParams(x, x);
    }
    ''';

    final publicAbstractor = PublicAbstractor();
    parseString(content: code).unit.visitChildren(publicAbstractor);
    final constructors = publicAbstractor.classes['Bar']!.constructors;

    test('Total number of constructors', () {
      expect(constructors.length, 3);
    });

    test('Default and Private constructor', () {
      expect(constructors.any((c) => c.name == '_privateConstructor'), isFalse);

      final defaultConstructor = constructors.firstWhere((c) => c.name.isEmpty);
      expect(defaultConstructor.parameters, '()');
    });

    test('with parameters and factory constructors', () {
      final withParamsConstructor = constructors.firstWhere(
        (c) => c.name == 'withParams',
      );

      expect(withParamsConstructor.className, 'Bar');
      expect(withParamsConstructor.name, 'withParams');
      expect(withParamsConstructor.factoryKeyword, isNull);
      expect(withParamsConstructor.parameters, '(this.a, this.b, {int? k})');

      final factoryConstructor = constructors.firstWhere(
        (c) => c.name == 'factoryConstructor',
      );
      expect(factoryConstructor.className, 'Bar');
      expect(factoryConstructor.name, 'factoryConstructor');
      expect(factoryConstructor.factoryKeyword, 'factory');
      expect(factoryConstructor.parameters, '(int x)');
    });
  });

  group('Getters and Setters', () {
    const code = '''
    class Bar {
      int _privateNum = 10;

      static int get publicGetter => _privateNum;
      static set publicSetter(int value) {
        _privateNum = value;
      }
      
      int get _privateGetter => 100;
      set _privateSetter(int value) {}
    }
    ''';

    final publicAbstractor = PublicAbstractor();
    parseString(content: code).unit.visitChildren(publicAbstractor);
    final getters = publicAbstractor.classes['Bar']!.getters;
    final setters = publicAbstractor.classes['Bar']!.setters;

    test('Getters and Setters count', () {
      expect(getters.length, 1);
      expect(setters.length, 1);
    });

    test('Getters', () {
      expect(
        getters.every((getter) => getter.name == '_privateGetter'),
        isFalse,
      );

      final publicGetter = getters.firstWhere((g) => g.name == 'publicGetter');
      expect(publicGetter.name, 'publicGetter');
      expect(publicGetter.returnType, 'int');
      expect(publicGetter.isStatic, isTrue);
    });

    test('Setters', () {
      expect(setters.any((setter) => setter.name == '_privateSetter'), isFalse);

      final publicSetter = setters.firstWhere((s) => s.name == 'publicSetter');
      expect(publicSetter.name, 'publicSetter');
      expect(publicSetter.isStatic, isTrue);
      expect(publicSetter.parameter, '(int value)');
    });
  });
}
