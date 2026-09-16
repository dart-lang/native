// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')
library;

import 'package:ffi/ffi.dart';
import 'package:objective_c/objective_c.dart';
import 'package:test/test.dart';

import 'util.dart';

// Strings short enough to be stored as tagged pointers are never
// deallocated, so use one that is long enough to be a real object.
const _longString =
    'a string that is far too long to be stored as a tagged pointer';

void main() {
  group('NSString', () {
    for (final s in ['Hello', '🇵🇬', 'Embedded\u0000Null']) {
      test('NSString to/from Dart string [$s]', () {
        final ns1 = NSString(s);
        expect(ns1.length, s.length);
        expect(ns1.toDartString().length, s.length);
        expect(ns1.toDartString(), s);

        final ns2 = s.toNSString();
        expect(ns2.length, s.length);
        expect(ns2.toDartString().length, s.length);
        expect(ns2.toDartString(), s);
      });
    }

    test('`NSString.new` garbage collected', () async {
      await using((arena) async {
        final tracker = ReferenceTracker(arena);
        () {
          tracker.track(NSString(_longString));
        }();

        doGC();
        await Future<void>.delayed(Duration.zero);
        doGC();
        expect(tracker.isAlive, isFalse);
      });
    });

    test('`String.toNSString` garbage collected', () async {
      await using((arena) async {
        final tracker = ReferenceTracker(arena);
        () {
          tracker.track(_longString.toNSString());
        }();

        doGC();
        await Future<void>.delayed(Duration.zero);
        doGC();
        expect(tracker.isAlive, isFalse);
      });
    });
  });
}
