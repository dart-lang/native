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
  group('osVersion', () {
    setUpAll(() {
      // TODO(https://github.com/dart-lang/native/issues/1068): Remove this.
      DynamicLibrary.open(testDylib);
    });

    test('getter', () {
      // macOS 11 was released in 2020 and isn't supported anymore.
      final oldVersion = Version(11, 0, 0);
      expect(osVersion, greaterThan(oldVersion));
    });

    test('check', () {
      // This test is only run on macOS.
      expect(checkOSVersion(iOS: Version(1, 0, 0)), isFalse);
      expect(
        checkOSVersion(iOS: Version(1, 0, 0), macOS: Version(11, 0, 0)),
        isTrue,
      );
      expect(
        checkOSVersion(iOS: Version(1, 0, 0), macOS: Version(1000, 0, 0)),
        isFalse,
      );
      expect(checkOSVersion(macOS: Version(11, 0, 0)), isTrue);
      expect(checkOSVersion(macOS: Version(1000, 0, 0)), isFalse);
    });
  });
}
