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
  group('autoReleasePool', () {
    test('basics', () async {
      await using((arena) async {
        final objectTracker = ReferenceTracker(arena);
        autoReleasePool(() {
          {
            final object = NSObject();
            objectTracker.track(object);
            object.ref.retainAndAutorelease();
            expect(objectTracker.isAlive, true);
          }
          doGC();
          expect(objectTracker.isAlive, true);
        });

        doGC();
        await Future<void>.delayed(const Duration(milliseconds: 100));
        doGC();

        expect(objectTracker.isAlive, false);
      });
    });

    test('exception safe', () async {
      await using((arena) async {
        final objectTracker = ReferenceTracker(arena);
        expect(
          () => autoReleasePool(() {
            {
              final object = NSObject();
              objectTracker.track(object);
              object.ref.retainAndAutorelease();
              expect(objectTracker.isAlive, true);
            }
            doGC();
            expect(objectTracker.isAlive, true);
            throw Exception();
          }),
          throwsException,
        );

        doGC();
        await Future<void>.delayed(const Duration(milliseconds: 100));
        doGC();

        expect(objectTracker.isAlive, false);
      });
    });

    test('returns callback value', () async {
      await using((arena) async {
        final objectTracker = ReferenceTracker(arena);
        late Pointer<ObjCObjectImpl> pointer;

        final returnedPointer = autoReleasePool(() {
          final object = NSObject();
          objectTracker.track(object);
          pointer = object.ref.retainAndAutorelease();
          return pointer;
        });

        // Returned value should be exactly what the callback returned
        expect(returnedPointer, same(pointer));

        doGC();
        await Future<void>.delayed(const Duration(milliseconds: 100));
        doGC();

        // Object should be released once the pool is popped
        expect(objectTracker.isAlive, false);
      });
    });
  });
}
