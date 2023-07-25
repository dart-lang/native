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
    Jni.spawnIfNotExists(dylibDir: "build/jni_libs", jvmOptions: ["-Xmx128m"]);
  }
  run(testRunner: test);
}

void run({required TestRunnerCallback testRunner}) {
  testRunner('JByte', () {
    const val = 1 << 5;
    using((arena) {
      expect(JByte(val).byteValue(deleteOriginal: true), val);
      expect((-val).toJByte().byteValue(deleteOriginal: true), -val);
    });
  });
  testRunner('JCharacter', () {
    const val = 1 << 5;
    using((arena) {
      expect(JCharacter(val).charValue(deleteOriginal: true), val);
      expect(JCharacter(0).charValue(deleteOriginal: true), 0);
    });
  });
  testRunner('JShort', () {
    const val = 1 << 10;
    using((arena) {
      expect(JShort(val).shortValue(deleteOriginal: true), val);
      expect((-val).toJShort().shortValue(deleteOriginal: true), -val);
    });
  });
  testRunner('JInteger', () {
    const val = 1 << 20;
    using((arena) {
      expect(JInteger(val).intValue(deleteOriginal: true), val);
      expect((-val).toJInteger().intValue(deleteOriginal: true), -val);
    });
  });
  testRunner('JLong', () {
    const val = 1 << 40;
    using((arena) {
      expect(JLong(val).longValue(deleteOriginal: true), val);
      expect((-val).toJLong().longValue(deleteOriginal: true), -val);
    });
  });
  testRunner('JFloat', () {
    const val = 3.14;
    const eps = 1e-6;
    using((arena) {
      expect(JFloat(val).floatValue(deleteOriginal: true), closeTo(val, eps));
      expect((-val).toJFloat().floatValue(deleteOriginal: true),
          closeTo(-val, eps));
    });
  });
  testRunner('JDouble', () {
    const val = 3.14;
    const eps = 1e-9;
    using((arena) {
      expect(JDouble(val).doubleValue(deleteOriginal: true), closeTo(val, eps));
      expect((-val).toJDouble().doubleValue(deleteOriginal: true),
          closeTo(-val, eps));
    });
  });
  testRunner('JBoolean', () {
    using((arena) {
      expect(JBoolean(false).booleanValue(deleteOriginal: true), false);
      expect(JBoolean(true).booleanValue(deleteOriginal: true), true);
    });
  });
  testRunner('JByte.\$type hashCode and ==', () {
    using((arena) {
      final a = JByte(1)..deletedIn(arena);
      final b = JByte(2)..deletedIn(arena);
      expect(a.$type, b.$type);
      expect(a.$type.hashCode, b.$type.hashCode);
    });
  });
  testRunner('JCharacter.\$type hashCode and ==', () {
    using((arena) {
      final a = JCharacter(1)..deletedIn(arena);
      final b = JCharacter(2)..deletedIn(arena);
      expect(a.$type, b.$type);
      expect(a.$type.hashCode, b.$type.hashCode);
    });
  });
  testRunner('JShort.\$type hashCode and ==', () {
    using((arena) {
      final a = JShort(1)..deletedIn(arena);
      final b = JShort(2)..deletedIn(arena);
      expect(a.$type, b.$type);
      expect(a.$type.hashCode, b.$type.hashCode);
    });
  });
  testRunner('JInteger.\$type hashCode and ==', () {
    using((arena) {
      final a = JInteger(1)..deletedIn(arena);
      final b = JInteger(2)..deletedIn(arena);
      expect(a.$type, b.$type);
      expect(a.$type.hashCode, b.$type.hashCode);
    });
  });
  testRunner('JLong.\$type hashCode and ==', () {
    using((arena) {
      final a = JLong(1)..deletedIn(arena);
      final b = JLong(2)..deletedIn(arena);
      expect(a.$type, b.$type);
      expect(a.$type.hashCode, b.$type.hashCode);
    });
  });
  testRunner('JFloat.\$type hashCode and ==', () {
    using((arena) {
      final a = JFloat(1.0)..deletedIn(arena);
      final b = JFloat(2.0)..deletedIn(arena);
      expect(a.$type, b.$type);
      expect(a.$type.hashCode, b.$type.hashCode);
    });
  });
  testRunner('JDouble.\$type hashCode and ==', () {
    using((arena) {
      final a = JDouble(1.0)..deletedIn(arena);
      final b = JDouble(2.0)..deletedIn(arena);
      expect(a.$type, b.$type);
      expect(a.$type.hashCode, b.$type.hashCode);
    });
  });
  testRunner('JBoolean.\$type hashCode and ==', () {
    using((arena) {
      final a = JBoolean(true)..deletedIn(arena);
      final b = JBoolean(false)..deletedIn(arena);
      expect(a.$type, b.$type);
      expect(a.$type.hashCode, b.$type.hashCode);
    });
  });
}
