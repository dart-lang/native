// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
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
  testRunner("Java boolean array", () {
    using((arena) {
      final array = JArray(jboolean.type, 3)..releasedBy(arena);
      expect(array.length, 3);
      array[0] = true;
      array[1] = false;
      array[2] = false;
      expect(array[0], true);
      expect(array[1], false);
      expect(array[2], false);
      array.setRange(0, 3, [false, true, true, true], 1);
      expect(array[0], true);
      expect(array[1], true);
      expect(array[2], true);
      expect(() {
        final _ = array[-1];
      }, throwsRangeError);
      expect(() {
        array[-1] = false;
      }, throwsRangeError);
      expect(() {
        array[3] = false;
      }, throwsRangeError);
    });
  });
  testRunner("Java char array", () {
    using((arena) {
      final array = JArray(jchar.type, 3)..releasedBy(arena);
      expect(array.length, 3);
      array[0] = 'ح';
      array[1] = '2';
      array[2] = '3';
      expect(array[0], 'ح');
      expect(array[1], '2');
      expect(array[2], '3');
      array.setRange(0, 3, ['4', '5', '6', '7'], 1);
      expect(array[0], '5');
      expect(array[1], '6');
      expect(array[2], '7');
      expect(() {
        final _ = array[-1];
      }, throwsRangeError);
      expect(() {
        array[-1] = '4';
      }, throwsRangeError);
      expect(() {
        array[3] = '4';
      }, throwsRangeError);
    });
  });
  testRunner("Java byte array", () {
    using((arena) {
      final array = JArray(jbyte.type, 3)..releasedBy(arena);
      expect(array.length, 3);
      array[0] = 1;
      array[1] = 2;
      array[2] = 3 + 256 * 5; // truncates the input;
      expect(array[0], 1);
      expect(array[1], 2);
      expect(array[2], 3);
      array.setRange(0, 3, [4, 5, 6, 7], 1);
      expect(array[0], 5);
      expect(array[1], 6);
      expect(array[2], 7);
      expect(() {
        final _ = array[-1];
      }, throwsRangeError);
      expect(() {
        array[-1] = 4;
      }, throwsRangeError);
      expect(() {
        array[3] = 4;
      }, throwsRangeError);
    });
  });
  testRunner("Java short array", () {
    using((arena) {
      final array = JArray(jshort.type, 3)..releasedBy(arena);
      expect(array.length, 3);
      array[0] = 1;
      array[1] = 2;
      array[2] = 3 + 256 * 256 * 5; // truncates the input
      expect(array[0], 1);
      expect(array[1], 2);
      expect(array[2], 3);
      array.setRange(0, 3, [4, 5, 6, 7], 1);
      expect(array[0], 5);
      expect(array[1], 6);
      expect(array[2], 7);
      expect(() {
        final _ = array[-1];
      }, throwsRangeError);
      expect(() {
        array[-1] = 4;
      }, throwsRangeError);
      expect(() {
        array[3] = 4;
      }, throwsRangeError);
    });
  });
  testRunner("Java int array", () {
    using((arena) {
      final array = JArray(jint.type, 3)..releasedBy(arena);
      expect(array.length, 3);
      array[0] = 1;
      array[1] = 2;
      array[2] = 3 + 256 * 256 * 256 * 256 * 5; // truncates the input
      expect(array[0], 1);
      expect(array[1], 2);
      expect(array[2], 3);
      array.setRange(0, 3, [4, 5, 6, 7], 1);
      expect(array[0], 5);
      expect(array[1], 6);
      expect(array[2], 7);
      expect(() {
        final _ = array[-1];
      }, throwsRangeError);
      expect(() {
        array[-1] = 4;
      }, throwsRangeError);
      expect(() {
        array[3] = 4;
      }, throwsRangeError);
    });
  });
  testRunner("Java long array", () {
    using((arena) {
      final array = JArray(jlong.type, 3)..releasedBy(arena);
      expect(array.length, 3);
      array[0] = 1;
      array[1] = 2;
      array[2] = 3 + 256 * 256 * 256 * 256 * 5;
      expect(array[0], 1);
      expect(array[1], 2);
      expect(array[2], 3 + 256 * 256 * 256 * 256 * 5);
      array.setRange(0, 3, [4, 5, 6, 7], 1);
      expect(array[0], 5);
      expect(array[1], 6);
      expect(array[2], 7);
      expect(() {
        final _ = array[-1];
      }, throwsRangeError);
      expect(() {
        array[-1] = 4;
      }, throwsRangeError);
      expect(() {
        array[3] = 4;
      }, throwsRangeError);
    });
  });
  const epsilon = 1e-6;
  testRunner("Java float array", () {
    using((arena) {
      final array = JArray(jfloat.type, 3)..releasedBy(arena);
      expect(array.length, 3);
      array[0] = 0.5;
      array[1] = 2;
      array[2] = 3;
      expect(array[0], closeTo(0.5, epsilon));
      expect(array[1], closeTo(2, epsilon));
      expect(array[2], closeTo(3, epsilon));
      array.setRange(0, 3, [4, 5, 6, 7], 1);
      expect(array[0], closeTo(5, epsilon));
      expect(array[1], closeTo(6, epsilon));
      expect(array[2], closeTo(7, epsilon));
      expect(() {
        final _ = array[-1];
      }, throwsRangeError);
      expect(() {
        array[-1] = 4;
      }, throwsRangeError);
      expect(() {
        array[3] = 4;
      }, throwsRangeError);
    });
  });
  testRunner("Java double array", () {
    using((arena) {
      final array = JArray(jdouble.type, 3)..releasedBy(arena);
      expect(array.length, 3);
      array[0] = 0.5;
      array[1] = 2;
      array[2] = 3;
      expect(array[0], closeTo(0.5, epsilon));
      expect(array[1], closeTo(2, epsilon));
      expect(array[2], closeTo(3, epsilon));
      array.setRange(0, 3, [4, 5, 6, 7], 1);
      expect(array[0], closeTo(5, epsilon));
      expect(array[1], closeTo(6, epsilon));
      expect(array[2], closeTo(7, epsilon));
      expect(() {
        final _ = array[-1];
      }, throwsRangeError);
      expect(() {
        array[-1] = 4;
      }, throwsRangeError);
      expect(() {
        array[3] = 4;
      }, throwsRangeError);
    });
  });
  testRunner("Java string array", () {
    using((arena) {
      final array = JArray(JString.type, 3)..releasedBy(arena);
      expect(array.length, 3);
      array[0] = "حس".toJString()..releasedBy(arena);
      array[1] = "\$".toJString()..releasedBy(arena);
      array[2] = "33".toJString()..releasedBy(arena);
      expect(array[0].toDartString(releaseOriginal: true), "حس");
      expect(array[1].toDartString(releaseOriginal: true), "\$");
      expect(array[2].toDartString(releaseOriginal: true), "33");
      array.setRange(
        0,
        3,
        [
          "44".toJString()..releasedBy(arena),
          "55".toJString()..releasedBy(arena),
          "66".toJString()..releasedBy(arena),
          "77".toJString()..releasedBy(arena),
        ],
        1,
      );
      expect(array[0].toDartString(releaseOriginal: true), "55");
      expect(array[1].toDartString(releaseOriginal: true), "66");
      expect(array[2].toDartString(releaseOriginal: true), "77");
      expect(() {
        final _ = array[-1];
      }, throwsRangeError);
      expect(() {
        array[-1] = "44".toJString()..releasedBy(arena);
      }, throwsRangeError);
      expect(() {
        array[3] = "44".toJString()..releasedBy(arena);
      }, throwsRangeError);
    });
  });
  testRunner("Java object array", () {
    using((arena) {
      final array = JArray(JObject.type, 3)..releasedBy(arena);
      expect(array.length, 3);
      expect(array[0].reference.pointer, nullptr);
      expect(array[1].reference.pointer, nullptr);
      expect(array[2].reference.pointer, nullptr);
    });
  });
  testRunner("Java 2d array", () {
    using((arena) {
      final array = JArray(jint.type, 3)..releasedBy(arena);
      array[0] = 1;
      array[1] = 2;
      array[2] = 3;
      final twoDimArray = JArray(JArray.type(jint.type), 3)..releasedBy(arena);
      expect(twoDimArray.length, 3);
      twoDimArray[0] = array;
      twoDimArray[1] = array;
      twoDimArray[2] = array;
      for (var i = 0; i < 3; ++i) {
        expect(twoDimArray[i][0], 1);
        expect(twoDimArray[i][1], 2);
        expect(twoDimArray[i][2], 3);
      }
      twoDimArray[2][2] = 4;
      expect(twoDimArray[2][2], 4);
    });
  });
  testRunner("JArray.filled", () {
    using((arena) {
      final string = "abc".toJString()..releasedBy(arena);
      final array = JArray.filled(3, string)..releasedBy(arena);
      expect(
        () => JArray.filled(-3, JString.fromReference(jNullReference)),
        throwsA(isA<RangeError>()),
      );
      expect(array.length, 3);
      expect(array[0].toDartString(releaseOriginal: true), "abc");
      expect(array[1].toDartString(releaseOriginal: true), "abc");
      expect(array[2].toDartString(releaseOriginal: true), "abc");
    });
  });
  testRunner('JArray of JByte', () {
    using((arena) {
      final arr = JArray(JByte.type, 1)..releasedBy(arena);
      expect((arr[0]..releasedBy(arena)).isNull, true);
    });
  });
  testRunner('JArray of JShort', () {
    using((arena) {
      final arr = JArray(JShort.type, 1)..releasedBy(arena);
      expect((arr[0]..releasedBy(arena)).isNull, true);
    });
  });
  testRunner('JArray of JInteger', () {
    using((arena) {
      final arr = JArray(JInteger.type, 1)..releasedBy(arena);
      expect((arr[0]..releasedBy(arena)).isNull, true);
    });
  });
  testRunner('JArray of JCharacter', () {
    using((arena) {
      final arr = JArray(JCharacter.type, 1)..releasedBy(arena);
      expect((arr[0]..releasedBy(arena)).isNull, true);
    });
  });
  testRunner('JArray of JLong', () {
    using((arena) {
      final arr = JArray(JLong.type, 1)..releasedBy(arena);
      expect((arr[0]..releasedBy(arena)).isNull, true);
    });
  });
  testRunner('JArray of JFloat', () {
    using((arena) {
      final arr = JArray(JFloat.type, 1)..releasedBy(arena);
      expect((arr[0]..releasedBy(arena)).isNull, true);
    });
  });
  testRunner('JArray of JDouble', () {
    using((arena) {
      final arr = JArray(JDouble.type, 1)..releasedBy(arena);
      expect((arr[0]..releasedBy(arena)).isNull, true);
    });
  });
  testRunner('JArray of JBoolean', () {
    using((arena) {
      final arr = JArray(JBoolean.type, 1)..releasedBy(arena);
      expect((arr[0]..releasedBy(arena)).isNull, true);
    });
  });
  testRunner('JArray of JSet', () {
    using((arena) {
      final arr = JArray(JSet.type(JString.type), 1)..releasedBy(arena);
      expect((arr[0]..releasedBy(arena)).isNull, true);
    });
  });
  testRunner('JArray of JList', () {
    using((arena) {
      final arr = JArray(JList.type(JString.type), 1)..releasedBy(arena);
      expect((arr[0]..releasedBy(arena)).isNull, true);
    });
  });
  testRunner('JArray of JMap', () {
    using((arena) {
      final arr = JArray(JMap.type(JString.type, JString.type), 1)
        ..releasedBy(arena);
      expect((arr[0]..releasedBy(arena)).isNull, true);
    });
  });
  testRunner('JArray of JIterator', () {
    using((arena) {
      final arr = JArray(JIterator.type(JString.type), 1)..releasedBy(arena);
      expect((arr[0]..releasedBy(arena)).isNull, true);
    });
  });
}
