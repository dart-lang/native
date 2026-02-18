// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:jni/jni.dart';
import 'package:test/test.dart';

import 'test_util/test_util.dart';

void main() {
  // Don't forget to initialize JNI.
  if (!Platform.isAndroid) {
    checkDylibIsUpToDate();
    spawnJvm();
  }
  run(testRunner: test);
}

void run({required TestRunnerCallback testRunner}) {
  testRunner('JByte', () {
    const val = 1 << 5;
    using((arena) {
      expect(JByte(val).byteValue(releaseOriginal: true), val);
      expect((-val).toJByte().byteValue(releaseOriginal: true), -val);
    });
  });
  testRunner('JCharacter', () {
    const val = 1 << 5;
    using((arena) {
      expect(JCharacter(val).charValue(releaseOriginal: true), val);
      expect(JCharacter(0).charValue(releaseOriginal: true), 0);
    });
  });
  testRunner('JShort', () {
    const val = 1 << 10;
    using((arena) {
      expect(JShort(val).shortValue(releaseOriginal: true), val);
      expect((-val).toJShort().shortValue(releaseOriginal: true), -val);
    });
  });
  testRunner('JInteger', () {
    const val = 1 << 20;
    using((arena) {
      expect(JInteger(val).intValue(releaseOriginal: true), val);
      expect((-val).toJInteger().intValue(releaseOriginal: true), -val);
    });
  });
  testRunner('JLong', () {
    const val = 1 << 40;
    using((arena) {
      expect(JLong(val).longValue(releaseOriginal: true), val);
      expect((-val).toJLong().longValue(releaseOriginal: true), -val);
    });
  });
  testRunner('JFloat', () {
    const val = 3.14;
    const eps = 1e-6;
    using((arena) {
      expect(JFloat(val).floatValue(releaseOriginal: true), closeTo(val, eps));
      expect((-val).toJFloat().floatValue(releaseOriginal: true),
          closeTo(-val, eps));
    });
  });
  testRunner('JDouble', () {
    const val = 3.14;
    const eps = 1e-9;
    using((arena) {
      expect(
          JDouble(val).doubleValue(releaseOriginal: true), closeTo(val, eps));
      expect((-val).toJDouble().doubleValue(releaseOriginal: true),
          closeTo(-val, eps));
    });
  });
  testRunner('JBoolean', () {
    using((arena) {
      expect(JBoolean(false).booleanValue(releaseOriginal: true), false);
      expect(JBoolean(true).booleanValue(releaseOriginal: true), true);
    });
  });
}
