// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')
library;

import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:objective_c/objective_c.dart';
import 'package:test/test.dart';

import 'util.dart';

void main() {
  group('Observer', () {
    test('receive updates', () {
      // Using NSProgress here because it's already part of our generated
      // bindings and has a property with a getter and setter.
      final observed = NSProgress();
      observed.totalUnitCount = 123;
      expect(observed.totalUnitCount, 123);

      final values = <dynamic>[];
      final observer = Observer$Builder.implement(
        observeValueForKeyPath_ofObject_change_context_:
            (
              NSString keyPath,
              ObjCObject object,
              NSDictionary change,
              Pointer<Void> context,
            ) {
              expect(keyPath.toDartString(), 'totalUnitCount');
              expect(object, observed);
              expect(context.address, 0x1234);
              values.add(
                toDartObject(change.asDart()[NSKeyValueChangeNewKey]!),
              );
            },
      );
      final observation = observed.addObserver(
        observer,
        forKeyPath: 'totalUnitCount'.toNSString(),
        context: Pointer<Void>.fromAddress(0x1234),
      );

      observed.totalUnitCount = 456;
      expect(values, [456]);

      observed.totalUnitCount = 789;
      expect(values, [456, 789]);

      observation.remove();

      observed.totalUnitCount = 246;
      expect(values, [456, 789]);

      observation.remove();

      observed.totalUnitCount = 999;
      expect(values, [456, 789]);
    });

    test('cancel observation due to GC', () {
      final observed = NSProgress();

      final values = <dynamic>[];
      final observer = Observer$Builder.implement(
        observeValueForKeyPath_ofObject_change_context_:
            (
              NSString keyPath,
              ObjCObject object,
              NSDictionary change,
              Pointer<Void> context,
            ) {
              values.add(
                toDartObject(change.asDart()[NSKeyValueChangeNewKey]!),
              );
            },
      );

      () {
        final observation = observed.addObserver(
          observer,
          forKeyPath: 'totalUnitCount'.toNSString(),
        );

        observed.totalUnitCount = 123;
        expect(values, [123]);

        // Force observation to stay in scope.
        expect(observation, isNotNull);
      }();

      doGC();

      observed.totalUnitCount = 456;
      expect(values, [123]);
    });

    test('observer and observed kept alive by observation', () async {
      final arena = Arena();
      try {
        final tObserved = ReferenceTracker(arena);
        final tObserver = ReferenceTracker(arena);
        final values = <dynamic>[];

        NSProgress? observed;
        Observer? observer;
        Observation? observation;
        autoReleasePool(() {
          observed = NSProgress();
          observer = Observer$Builder.implement(
            observeValueForKeyPath_ofObject_change_context_:
                (
                  NSString keyPath,
                  ObjCObject object,
                  NSDictionary change,
                  Pointer<Void> context,
                ) {
                  values.add(
                    toDartObject(change.asDart()[NSKeyValueChangeNewKey]!),
                  );

                  // This is testing that a captured reference from the observer
                  // to the observed object does not cause leak.
                  expect(object, observed);
                },
          );

          tObserved.track(observed!.ref.pointer.cast());
          tObserver.track(observer!.ref.pointer.cast());

          observation = observed!.addObserver(
            observer!,
            forKeyPath: 'totalUnitCount'.toNSString(),
          );
        });

        observed!.totalUnitCount = 123;
        expect(values, [123]);

        final observedRaw = observed!.ref.pointer;

        observed = null;
        observer = null;

        expect(tObserved.isAlive, true);
        expect(tObserver.isAlive, true);

        NSProgress.fromPointer(observedRaw).totalUnitCount = 456;
        expect(values, [123, 456]);

        // Force observation to stay in scope.
        expect(observation, isNotNull);
        observation = null;
        expect(observation, isNull);

        doGC();
        await Future<void>.delayed(const Duration(milliseconds: 100));
        doGC();

        expect(tObserved.isAlive, false);
        expect(tObserver.isAlive, false);
      } finally {
        arena.releaseAll();
      }
    });

    test('remove method drops references', () async {
      final arena = Arena();
      try {
        final tObserved = ReferenceTracker(arena);
        final tObserver = ReferenceTracker(arena);
        NSProgress? observed;
        Observer? observer;
        Observation? observation;
        autoReleasePool(() {
          observed = NSProgress();
          observer = Observer$Builder.implement(
            observeValueForKeyPath_ofObject_change_context_:
                (
                  NSString keyPath,
                  ObjCObject object,
                  NSDictionary change,
                  Pointer<Void> context,
                ) {},
          );

          tObserved.track(observed!.ref.pointer.cast());
          tObserver.track(observer!.ref.pointer.cast());

          observation = observed!.addObserver(
            observer!,
            forKeyPath: 'totalUnitCount'.toNSString(),
          );
        });

        observed = null;
        observer = null;

        doGC();
        await Future<void>.delayed(const Duration(milliseconds: 100));
        doGC();

        // Still holding a reference to observation.
        expect(tObserved.isAlive, true);
        expect(tObserver.isAlive, true);

        observation!.remove();

        doGC();
        await Future<void>.delayed(const Duration(milliseconds: 100));
        doGC();

        // Still holding a reference to observation, but we've called remove.
        expect(tObserved.isAlive, false);
        expect(tObserver.isAlive, false);

        // Force observation to stay in scope.
        expect(observation, isNotNull);
      } finally {
        arena.releaseAll();
      }
    });
  });
}
