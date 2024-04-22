// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')

import 'dart:ffi';

import 'package:objective_c/objective_c.dart';
import 'package:test/test.dart';

void main() {
  group('NSString', () {
    setUpAll(() {
      DynamicLibrary.open('test/objective_c.dylib');
    });

    for (final s in ['Hello', '🇵🇬', 'Embedded\u0000Null']) {
      test('NSString to/from Dart string [$s]', () {
        final ns1 = NSString(s);
        expect(ns1.length, s.length);
        expect(ns1.toString().length, s.length);
        expect(ns1.toString(), s);

        final ns2 = s.toNSString();
        expect(ns2.length, s.length);
        expect(ns2.toString().length, s.length);
        expect(ns2.toString(), s);
      });
    }

    test('hello', () {
      expect(hello(), 123);
    });
  });
}
