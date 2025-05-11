// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')
library;

import 'dart:ffi';

import 'package:objective_c/objective_c.dart';
import 'package:test/test.dart';

void main() {
  group('NSNumber', () {
    setUpAll(() {
      // TODO(https://github.com/dart-lang/native/issues/1068): Remove this.
      DynamicLibrary.open('test/objective_c.dylib');
    });

    test('from double', () {
      final n = 1.23.toNSNumber();

      expect(n.intValue, 1);
      expect(n.longLongValue, 1);
      expect(n.doubleValue, 1.23);
      expect(n.numValue, isA<double>());
      expect(n.numValue, 1.23);
    });

    test('from int', () {
      final n = 0x7fffffffffffffff.toNSNumber();

      expect(n.intValue, -1);
      expect(n.longLongValue, 0x7fffffffffffffff);
      expect(n.doubleValue, 0x7ffffffffffffff0);
      expect(n.numValue, isA<int>());
      expect(n.numValue, 0x7fffffffffffffff);
    });

    test('from num', () {
      late num x;

      x = 1.23;
      final n = x.toNSNumber();
      expect(n.intValue, 1);
      expect(n.longLongValue, 1);
      expect(n.doubleValue, 1.23);
      expect(n.numValue, isA<double>());
      expect(n.numValue, 1.23);

      x = 0x7fffffffffffffff;
      final m = x.toNSNumber();
      expect(m.intValue, -1);
      expect(m.longLongValue, 0x7fffffffffffffff);
      expect(m.doubleValue, 0x7ffffffffffffff0);
      expect(m.numValue, isA<int>());
      expect(m.numValue, 0x7fffffffffffffff);
    });
  });
}
