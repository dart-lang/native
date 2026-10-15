// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:test/test.dart';

import '../test_utils.dart';
import 'cpp_class_test_bindings.dart';

// Expose the symbol so we can pass its address as a custom finalizer in tests.
@Native<Void Function(Pointer<Void>)>(
  symbol: 'FinalizerTestSubject_delete',
  assetId: 'package:ffigen/cpp_test',
)
external void _testFinalizerTestSubjectDelete(Pointer<Void> self);

// Top-level @Native declarations needed by Native.addressOf in
// 'Function pointer args/returns' tests.
@Native<Pointer<Void> Function(Int age)>(
  symbol: 'createAnimalPointer',
  assetId: 'package:ffigen/cpp_test',
)
external Pointer<Void> _nativeFactory(int age);

@Native<Int Function(Pointer<Void> a)>(
  symbol: 'getAgeFromPointer',
  assetId: 'package:ffigen/cpp_test',
)
external int _nativeProcessor(Pointer<Void> a);

@Native<Void Function(Pointer<Void> a, Int value)>(
  symbol: 'setAgeFromPointer',
  assetId: 'package:ffigen/cpp_test',
)
external void _nativeTransform(Pointer<Void> a, int value);

final _customDeleteFinalizer = NativeFinalizer(
  Native.addressOf<NativeFunction<Void Function(Pointer<Void>)>>(
    _testFinalizerTestSubjectDelete,
  ),
);

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

    test('Animal pass and return by value', () {
      final dog = Animal(10);
      final cat = Animal(20);

      final combined = dog.copyAndAddAge(cat);
      expect(combined.getAge(), 30);
      expect(Animal.haveSameAge(dog, cat), isFalse);

      combined.dispose();
      dog.dispose();
      cat.dispose();
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

    test('Animal methods throw StateError after dispose', () {
      final animal = Animal(10);
      animal.dispose();
      expect(animal.getAge, throwsStateError);
      expect(animal.speak, throwsStateError);
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

  group('Ownership management', () {
    @pragma('vm:never-inline')
    void releaseOwnershipInner(Pointer<Int32> counter) {
      // Construct with ownership, then immediately release it.
      // The GC should NOT call delete when this object is collected.
      final subject = FinalizerTestSubject(counter.cast())..releaseOwnership();
      // Keep subject alive until the end of this scope to make the test clear.
      expect(subject, isNotNull);
    }

    test('releaseOwnership suppresses GC finalizer', () {
      final counter = calloc<Int>().cast<Int32>();
      counter.value = 0;
      releaseOwnershipInner(counter);
      doGC();
      // The finalizer was detached, so the counter must still be 0.
      expect(counter.value, 0);
      // Manually free to avoid a real leak in the test.
      calloc.free(counter);
    }, skip: !canDoGC);

    @pragma('vm:never-inline')
    void retainAfterReleaseInner(Pointer<Int32> counter) {
      // Release then re-take ownership; GC should now call delete.
      final subject = FinalizerTestSubject(counter.cast())
        ..releaseOwnership()
        ..retainOwnership();
      expect(subject, isNotNull);
    }

    test('retainOwnership after releaseOwnership re-enables GC finalizer', () {
      final counter = calloc<Int>().cast<Int32>();
      counter.value = 0;
      retainAfterReleaseInner(counter);
      doGC();
      expect(counter.value, 1);
      calloc.free(counter);
    }, skip: !canDoGC);

    test('retainOwnership throws StateError if already owned', () {
      final counter = calloc<Int>().cast<Int32>();
      counter.value = 0;
      final subject = FinalizerTestSubject(counter.cast());
      // Calling retainOwnership on an already-owned object throws StateError.
      expect(subject.retainOwnership, throwsStateError);
      // dispose() detaches the finalizer and calls the destructor directly.
      subject.dispose();
      expect(counter.value, 1);
      calloc.free(counter);
    });

    test('releaseOwnership throws StateError if already unowned', () {
      final counter = calloc<Int>().cast<Int32>();
      counter.value = 0;
      final subject = FinalizerTestSubject(counter.cast());
      subject.releaseOwnership();
      // Calling releaseOwnership on already unowned object throws StateError.
      expect(subject.releaseOwnership, throwsStateError);
      // Restore ownership so dispose() can destroy the native object as part of
      // test cleanup.
      subject.retainOwnership();
      subject.dispose();
      expect(counter.value, 1);
      calloc.free(counter);
    });

    test('retainOwnership throws StateError after dispose', () {
      final counter = calloc<Int>().cast<Int32>();
      counter.value = 0;
      final subject = FinalizerTestSubject(counter.cast());
      subject.dispose();
      expect(subject.retainOwnership, throwsStateError);
      calloc.free(counter);
    });

    test('releaseOwnership throws StateError after dispose', () {
      final counter = calloc<Int>().cast<Int32>();
      counter.value = 0;
      final subject = FinalizerTestSubject(counter.cast());
      subject.dispose();
      expect(subject.releaseOwnership, throwsStateError);
      calloc.free(counter);
    });

    test('retainOwnership with custom finalizer calls it on dispose', () {
      final counter = calloc<Int>().cast<Int32>();
      counter.value = 0;
      final subject = FinalizerTestSubject(counter.cast());
      subject.releaseOwnership();
      final customFinalizerFn =
          Native.addressOf<NativeFunction<Void Function(Pointer<Void>)>>(
            _testFinalizerTestSubjectDelete,
          );
      subject.retainOwnership(_customDeleteFinalizer, customFinalizerFn);
      // dispose() must call the custom finalizer, not the default _deleteGlue.
      subject.dispose();
      expect(counter.value, 1);
      calloc.free(counter);
    });

    @pragma('vm:never-inline')
    void customFinalizerGCInner(
      Pointer<Int32> counter,
      NativeFinalizer customFinalizer,
      Pointer<NativeFunction<Void Function(Pointer<Void>)>> customFinalizerFn,
    ) {
      final subject = FinalizerTestSubject(counter.cast())
        ..releaseOwnership()
        ..retainOwnership(customFinalizer, customFinalizerFn);
      expect(subject, isNotNull);
    }

    test('retainOwnership with custom finalizer is called by GC', () {
      final counter = calloc<Int>().cast<Int32>();
      counter.value = 0;
      final customFinalizerFn =
          Native.addressOf<NativeFunction<Void Function(Pointer<Void>)>>(
            _testFinalizerTestSubjectDelete,
          );
      customFinalizerGCInner(
        counter,
        _customDeleteFinalizer,
        customFinalizerFn,
      );
      doGC();
      expect(counter.value, 1);
      calloc.free(counter);
    }, skip: !canDoGC);
  });

  group('Pointer management', () {
    test('Top-level function args and returns with Animal*', () {
      final animal = createAnimalPointer(15);
      expect(animal.getAge(), 15);

      expect(getAgeFromPointer(animal), 15);
      setAgeFromPointer(animal, 25);
      expect(animal.getAge(), 25);

      animal.retainOwnership();
      animal.dispose();
    });

    test('Global Animal pointer', () {
      expect(getGlobalAnimalAge(), -1);
      expect(globalAnimal.getAge, throwsStateError);

      final animal = Animal(7);
      globalAnimal = animal;

      expect(getGlobalAnimalAge(), 7);
      expect(globalAnimal.getAge(), 7);
      setGlobalAnimalAge(42);
      expect(globalAnimal.getAge(), 42);
      expect(animal.getAge(), 42);

      globalAnimal = Animal.fromPointer(nullptr);
      expect(getGlobalAnimalAge(), -1);
      animal.dispose();
    });

    test('Struct with Animal* field', () {
      final owner = calloc<AnimalOwner>();
      expect(getAnimalOwnerAge(owner), -1);
      expect(owner.ref.animal.getAge, throwsStateError);

      final animal = Animal(12);
      owner.ref.animal = animal;
      owner.ref.id = 101;

      expect(owner.ref.id, 101);
      expect(getAnimalOwnerAge(owner), 12);
      expect(owner.ref.animal.getAge(), 12);

      setAnimalOwnerAge(owner, 33);
      expect(owner.ref.animal.getAge(), 33);
      expect(animal.getAge(), 33);

      final allocatedOwner = AnimalOwner.$allocate(
        calloc,
        animal: animal,
        id: 202,
      );
      expect(allocatedOwner.ref.id, 202);
      expect(allocatedOwner.ref.animal.getAge(), 33);
      expect(getAnimalOwnerAge(allocatedOwner), 33);
      calloc.free(allocatedOwner);

      final ownerByVal = createAnimalOwner(animal, 303);
      expect(ownerByVal.id, 303);
      expect(ownerByVal.animal.getAge(), 33);

      owner.ref.animal = Animal.fromPointer(nullptr);
      expect(getAnimalOwnerAge(owner), -1);
      expect(owner.ref.animal.getAge, throwsStateError);

      animal.dispose();
      calloc.free(owner);
    });
  });

  group('Function pointer args/returns', () {
    test('Function pointer returning Animal* (factory)', () {
      final factoryPtr =
          Native.addressOf<NativeFunction<Pointer<Void> Function(Int age)>>(
            _nativeFactory,
          );

      final animal = applyFactory(factoryPtr, 42);
      expect(animal.getAge(), 42);
      animal.retainOwnership();
      animal.dispose();
    });

    test('Function pointer taking Animal* (processor)', () {
      final animal = Animal(17);
      final processorPtr =
          Native.addressOf<NativeFunction<Int Function(Pointer<Void> a)>>(
            _nativeProcessor,
          );

      final age = applyProcessor(processorPtr, animal);
      expect(age, 17);
      animal.dispose();
    });

    test('Function pointer taking Animal* and mutating it (transform)', () {
      final animal = Animal(5);
      final transformPtr =
          Native.addressOf<
            NativeFunction<Void Function(Pointer<Void> a, Int value)>
          >(_nativeTransform);

      applyTransform(transformPtr, animal, 99);
      expect(animal.getAge(), 99);
      animal.dispose();
    });
  });
}
