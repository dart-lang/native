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
  group('autoReleasePool', () {
    setUpAll(() {
      // TODO(https://github.com/dart-lang/native/issues/1068): Remove this.
      DynamicLibrary.open(testDylib);
    });

    test('basics', () async {
      late Pointer<ObjCObject> pointer;
      autoReleasePool(() {
        {
          final object = NSObject();
          pointer = object.ref.retainAndAutorelease();
        }
        doGC();
        expect(objectRetainCount(pointer), greaterThan(0));
      });

      doGC();
      await Future<void>.delayed(Duration.zero);
      doGC();

      expect(objectRetainCount(pointer), 0);
    });

    test('exception safe', () async {
      late Pointer<ObjCObject> pointer;
      expect(
        () => autoReleasePool(() {
          {
            final object = NSObject();
            pointer = object.ref.retainAndAutorelease();
          }
          doGC();
          expect(objectRetainCount(pointer), greaterThan(0));
          throw Exception();
        }),
        throwsException,
      );

      doGC();
      await Future<void>.delayed(Duration.zero);
      doGC();

      expect(objectRetainCount(pointer), 0);
    });
  });
}
