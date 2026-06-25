// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test/test.dart';

import 'cpp_class_test_bindings.dart';

void main() {
  group('CppClass', () {
    test('Animal bindings exist', () {
      expect(Animal, isNotNull);
    });

    test('Animal static methods do not clash', () {
      expect(Animal.Animal_new, isNotNull);
      expect(Animal.Animal_delete, isNotNull);
    });

    test('Animal full lifecycle', () {
      final animal = Animal(10);
      expect(animal.getAge(), 10);
      animal.speak();
      expect(Animal.getCount(), 42);

      expect(animal.isMammalClass(), isTrue);
      expect(animal.getWeight(2.0), 30.0);
      expect(animal.addAges(20, 0.5), 15);
      expect(Animal.sum(3, 4), 7);

      animal.dispose();
    });

    test('FinalizerTestSubject double dispose and GC', () async {
      final baseline1 = FinalizerTestSubject.getDestructorCallCount();
      final subject1 = FinalizerTestSubject();
      subject1.dispose();
      subject1.dispose();
      expect(FinalizerTestSubject.getDestructorCallCount(), baseline1 + 1);

      final baseline2 = FinalizerTestSubject.getDestructorCallCount();

      (() {
        final _ = FinalizerTestSubject();
      })();

      var attempts = 0;
      while (FinalizerTestSubject.getDestructorCallCount() == baseline2 &&
          attempts < 50) {
        List.generate(10000, (i) => Object());
        await Future<void>.delayed(const Duration(milliseconds: 20));
        attempts++;
      }

      expect(FinalizerTestSubject.getDestructorCallCount(), baseline2 + 1);
    });
  });
}
