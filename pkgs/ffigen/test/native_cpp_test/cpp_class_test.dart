// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:test/test.dart';

import '../test_utils.dart';
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

    @pragma('vm:never-inline')
    void gcTestSubjectInner(Pointer<Int32> counter) {
      final _ = FinalizerTestSubject(counter.cast());
    }

    test('FinalizerTestSubject double dispose', () {
      final counter = calloc<Int>().cast<Int32>();
      counter.value = 0;
      final subject = FinalizerTestSubject(counter.cast());
      subject.dispose();
      expect(subject.dispose, throwsStateError);
      expect(counter.value, 1);
      calloc.free(counter);
    });

    test('FinalizerTestSubject GC', () {
      final counter = calloc<Int>().cast<Int32>();
      counter.value = 0;
      gcTestSubjectInner(counter);
      doGC();
      expect(counter.value, 1);
      calloc.free(counter);
    }, skip: !canDoGC);
  });
}
