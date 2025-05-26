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
  group('NSDate', () {
    test('from DateTime', () {
      final dartFirstAppeared = DateTime.utc(2011, 10, 10);
      final nsDate = dartFirstAppeared.toNSDate();
      expect(nsDate.description.toDartString(), '2011-10-10 00:00:00 +0000');
    });

    test('to DateTime', () {
      final dartFirstAppeared =
          NSDate.dateWithTimeIntervalSince1970(1318204800);
      final dateTime = dartFirstAppeared.toDateTime();
      expect(dateTime.toUtc().toString(), '2011-10-10 00:00:00.000Z');
    });
  });
}
