// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')
library;

import 'dart:ffi';

import 'package:objective_c/objective_c.dart';
import 'package:test/test.dart';

import 'util.dart';

void main() {
  group('Observer', () {
    setUpAll(() {
      // TODO(https://github.com/dart-lang/native/issues/1068): Remove this.
      DynamicLibrary.open(testDylib);
    });

    test('receive updates', () {
      // Using NSProgress here because it's already part of our generated
      // bindings and has a property with a getter and setter.
      final observed = NSProgress();
      observed.totalUnitCount = 123;
      expect(observed.totalUnitCount, 123);

      final values = [];
      final observer = Observer.implement(
          observeValueForKeyPath_ofObject_change_context_: (NSString keyPath,
              ObjCObjectBase object,
              NSDictionary change,
              Pointer<Void> context) {
        expect(keyPath.toDartString(), 'totalUnitCount');
        expect(object, observed);
        expect(context.address, 0x1234);
        values.add(toDartObject(change[NSKeyValueChangeNewKey]!));
      });
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
    });

    test('cancel observation due to GC', () {
      final observed = NSProgress();

      final values = [];
      final observer = Observer.implement(
          observeValueForKeyPath_ofObject_change_context_: (NSString keyPath,
              ObjCObjectBase object,
              NSDictionary change,
              Pointer<Void> context) {
        values.add(toDartObject(change[NSKeyValueChangeNewKey]!));
      });

      () {
        final observation = observed.addObserver(observer,
            forKeyPath: 'totalUnitCount'.toNSString());

        observed.totalUnitCount = 123;
        expect(values, [123]);
      }();

      doGC();

      observed.totalUnitCount = 456;
      expect(values, [123]);
    });

    test('observer and observed kept alive by observation', () async {
      final values = [];

      final (observedRaw, observerRaw) = () {
        final (observedRaw, observerRaw, observation) = () {
          final pool = objc_autoreleasePoolPush();
          final observed = NSProgress();
          final observer = Observer.implement(
              observeValueForKeyPath_ofObject_change_context_:
                  (NSString keyPath, ObjCObjectBase object, NSDictionary change,
                      Pointer<Void> context) {
            values.add(toDartObject(change[NSKeyValueChangeNewKey]!));

            // This is testing that a captured reference from the observer to
            // the observed object does not cause leak.
            expect(object, observed);
          });
          objc_autoreleasePoolPop(pool);

          final observation = observed.addObserver(observer,
              forKeyPath: 'totalUnitCount'.toNSString());

          observed.totalUnitCount = 123;
          expect(values, [123]);

          return (observed.ref.pointer, observer.ref.pointer, observation);
        }();

        expect(objectRetainCount(observedRaw), greaterThan(0));
        expect(objectRetainCount(observerRaw), greaterThan(0));

        NSProgress.castFromPointer(observedRaw).totalUnitCount = 456;
        expect(values, [123, 456]);

        return (observedRaw, observerRaw);
      }();

      doGC();
      await Future<void>.delayed(Duration.zero);
      doGC();

      expect(objectRetainCount(observedRaw), 0);
      expect(objectRetainCount(observerRaw), 0);
    });
  });
}
