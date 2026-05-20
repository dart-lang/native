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
        final tracker = ReferenceTracker(arena);
        autoReleasePool(() {
          {
            final object = NSObject();
            tracker.track(object);
            object.ref.retainAndAutorelease();
            expect(tracker.isAlive, true);
          }
          doGC();
          expect(tracker.isAlive, true);
        });

        doGC();
        await Future<void>.delayed(const Duration(milliseconds: 100));
        doGC();

        expect(tracker.isAlive, false);
      });
    });

    test('exception safe', () async {
      await using((arena) async {
        final tracker = ReferenceTracker(arena);
        expect(
          () => autoReleasePool(() {
            {
              final object = NSObject();
              tracker.track(object);
              object.ref.retainAndAutorelease();
              expect(tracker.isAlive, true);
            }
            doGC();
            expect(tracker.isAlive, true);
            throw Exception();
          }),
          throwsException,
        );

        doGC();
        await Future<void>.delayed(const Duration(milliseconds: 100));
        doGC();

        expect(tracker.isAlive, false);
      });
    });

    test('returns callback value', () async {
      await using((arena) async {
        final tracker = ReferenceTracker(arena);
        late Pointer<ObjCObjectImpl> pointer;

        final returnedPointer = autoReleasePool(() {
          final object = NSObject();
          tracker.track(object);
          pointer = object.ref.retainAndAutorelease();
          return pointer;
        });

        expect(returnedPointer, same(pointer));

        doGC();
        await Future<void>.delayed(const Duration(milliseconds: 100));
        doGC();

        expect(tracker.isAlive, false);
      });
    });
  });
}
