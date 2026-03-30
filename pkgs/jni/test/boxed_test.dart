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
      expect(JByte(val).toDartInt(releaseOriginal: true), val);
      expect((-val).toJByte().toDartInt(releaseOriginal: true), -val);
    });
  });
  testRunner('JCharacter', () {
    const val = 1 << 5;
    using((arena) {
      expect(JCharacter(val).toDartInt(releaseOriginal: true), val);
      expect(JCharacter(0).toDartInt(releaseOriginal: true), 0);
    });
  });
  testRunner('JShort', () {
    const val = 1 << 10;
    using((arena) {
      expect(JShort(val).toDartInt(releaseOriginal: true), val);
      expect((-val).toJShort().toDartInt(releaseOriginal: true), -val);
    });
  });
  testRunner('JInteger', () {
    const val = 1 << 20;
    using((arena) {
      expect(JInteger(val).toDartInt(releaseOriginal: true), val);
      expect((-val).toJInteger().toDartInt(releaseOriginal: true), -val);
    });
  });
  testRunner('JLong', () {
    const val = 1 << 40;
    using((arena) {
      expect(JLong(val).toDartInt(releaseOriginal: true), val);
      expect((-val).toJLong().toDartInt(releaseOriginal: true), -val);
    });
  });
  testRunner('JFloat', () {
    const val = 3.14;
    const eps = 1e-6;
    using((arena) {
      expect(
          JFloat(val).toDartDouble(releaseOriginal: true), closeTo(val, eps));
      expect((-val).toJFloat().toDartDouble(releaseOriginal: true),
          closeTo(-val, eps));
    });
  });
  testRunner('JDouble', () {
    const val = 3.14;
    const eps = 1e-9;
    using((arena) {
      expect(
          JDouble(val).toDartDouble(releaseOriginal: true), closeTo(val, eps));
      expect((-val).toJDouble().toDartDouble(releaseOriginal: true),
          closeTo(-val, eps));
    });
  });
  testRunner('JBoolean', () {
    using((arena) {
      expect(JBoolean(false).toDartBool(releaseOriginal: true), false);
      expect(JBoolean(true).toDartBool(releaseOriginal: true), true);
    });
  });
  testRunner('JNumber conversion methods', () {
    using((arena) {
      final number = JInteger(42).as(JNumber.type, releaseOriginal: true);
      expect(
          number
              .toJByte(releaseOriginal: false)
              .toDartInt(releaseOriginal: true),
          42);
      expect(
          number
              .toJShort(releaseOriginal: false)
              .toDartInt(releaseOriginal: true),
          42);
      expect(
          number
              .toJInteger(releaseOriginal: false)
              .toDartInt(releaseOriginal: true),
          42);
      expect(
          number
              .toJLong(releaseOriginal: false)
              .toDartInt(releaseOriginal: true),
          42);
      expect(
          number
              .toJFloat(releaseOriginal: false)
              .toDartDouble(releaseOriginal: true),
          closeTo(42.0, 1e-6));
      expect(
          number
              .toJDouble(releaseOriginal: true)
              .toDartDouble(releaseOriginal: true),
          closeTo(42.0, 1e-9));
    });
  });
}
