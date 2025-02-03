// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';
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
  testRunner('Java boolean array', () {
    using((arena) {
      final array = JBooleanArray(3)..releasedBy(arena);
      var counter = 0;
      for (final element in array) {
        expect(element, array[counter]);
        ++counter;
      }
      expect(counter, array.length);
      expect(array.length, 3);
      array[0] = true;
      array[1] = false;
      array[2] = false;
      expect(array[0], true);
      expect(array[1], false);
      expect(array[2], false);
      final firstTwo = array.getRange(0, 2);
      expect(firstTwo.length, 2);
      expect(firstTwo.elementSizeInBytes, sizeOf<JBooleanMarker>());
      expect(firstTwo[0], 1);
      expect(firstTwo[1], 0);
      expect(() {
        array.getRange(0, 4);
      }, throwsRangeError);
      expect(() {
        array.setRange(0, 4, []);
      }, throwsRangeError);
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
  testRunner('Java char array', () {
    using((arena) {
      final array = JCharArray(3)..releasedBy(arena);
      var counter = 0;
      for (final element in array) {
        expect(element, array[counter]);
        ++counter;
      }
      expect(counter, array.length);
      expect(array.length, 3);
      array[0] = 1;
      array[1] = 2;
      array[2] = 3 + 256 * 256 * 5; // Truncates the input.
      expect(array[0], 1);
      expect(array[1], 2);
      expect(array[2], 3);
      final firstTwo = array.getRange(0, 2);
      expect(firstTwo.length, 2);
      expect(firstTwo.elementSizeInBytes, sizeOf<JCharMarker>());
      expect(firstTwo[0], 1);
      expect(firstTwo[1], 2);
      expect(() {
        array.getRange(0, 4);
      }, throwsRangeError);
      expect(() {
        array.setRange(0, 4, []);
      }, throwsRangeError);
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
  testRunner('Java byte array', () {
    using((arena) {
      expect(JByteArray.from([]), isEmpty);
      expect(JByteArray.from([1]), containsAllInOrder([1]));
      expect(JByteArray.from([1, 2]), containsAllInOrder([1, 2]));
      expect(JByteArray.from([-1, -2]), containsAllInOrder([-1, -2]));
      expect(JByteArray.from([127, 128, 129]),
          containsAllInOrder([127, -128, -127]));

      final array = JByteArray(3)..releasedBy(arena);
      var counter = 0;
      for (final element in array) {
        expect(element, array[counter]);
        ++counter;
      }
      expect(counter, array.length);
      expect(array.length, 3);
      array[0] = 1;
      array[1] = 2;
      array[2] = 3 + 256 * 5; // Truncates the input.;
      expect(array[0], 1);
      expect(array[1], 2);
      expect(array[2], 3);
      final firstTwo = array.getRange(0, 2);
      expect(firstTwo.length, 2);
      expect(firstTwo.elementSizeInBytes, sizeOf<JByteMarker>());
      expect(firstTwo[0], 1);
      expect(firstTwo[1], 2);
      expect(() {
        array.getRange(0, 4);
      }, throwsRangeError);
      expect(() {
        array.setRange(0, 4, []);
      }, throwsRangeError);
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
  testRunner('Java short array', () {
    using((arena) {
      final array = JShortArray(3)..releasedBy(arena);
      var counter = 0;
      for (final element in array) {
        expect(element, array[counter]);
        ++counter;
      }
      expect(counter, array.length);
      expect(array.length, 3);
      array[0] = 1;
      array[1] = 2;
      array[2] = 3 + 256 * 256 * 5; // Truncates the input.
      expect(array[0], 1);
      expect(array[1], 2);
      expect(array[2], 3);
      final firstTwo = array.getRange(0, 2);
      expect(firstTwo.length, 2);
      expect(firstTwo.elementSizeInBytes, sizeOf<JShortMarker>());
      expect(firstTwo[0], 1);
      expect(firstTwo[1], 2);
      expect(() {
        array.getRange(0, 4);
      }, throwsRangeError);
      expect(() {
        array.setRange(0, 4, []);
      }, throwsRangeError);
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
  testRunner('Java int array', () {
    using((arena) {
      final array = JIntArray(3)..releasedBy(arena);
      var counter = 0;
      for (final element in array) {
        expect(element, array[counter]);
        ++counter;
      }
      expect(counter, array.length);
      expect(array.length, 3);
      array[0] = 1;
      array[1] = 2;
      array[2] = 3 + 256 * 256 * 256 * 256 * 5; // Truncates the input.
      expect(array[0], 1);
      expect(array[1], 2);
      expect(array[2], 3);
      final firstTwo = array.getRange(0, 2);
      expect(firstTwo.length, 2);
      expect(firstTwo.elementSizeInBytes, sizeOf<JIntMarker>());
      expect(firstTwo[0], 1);
      expect(firstTwo[1], 2);
      expect(() {
        array.getRange(0, 4);
      }, throwsRangeError);
      expect(() {
        array.setRange(0, 4, []);
      }, throwsRangeError);
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
  testRunner('Java long array', () {
    using((arena) {
      final array = JLongArray(3)..releasedBy(arena);
      var counter = 0;
      for (final element in array) {
        expect(element, array[counter]);
        ++counter;
      }
      expect(counter, array.length);
      expect(array.length, 3);
      array[0] = 1;
      array[1] = 2;
      array[2] = 3 + 256 * 256 * 256 * 256 * 5;
      expect(array[0], 1);
      expect(array[1], 2);
      expect(array[2], 3 + 256 * 256 * 256 * 256 * 5);
      final firstTwo = array.getRange(0, 2);
      expect(firstTwo.length, 2);
      expect(firstTwo.elementSizeInBytes, sizeOf<JLongMarker>());
      expect(firstTwo[0], 1);
      expect(firstTwo[1], 2);
      expect(() {
        array.getRange(0, 4);
      }, throwsRangeError);
      expect(() {
        array.setRange(0, 4, []);
      }, throwsRangeError);
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
  testRunner('Java float array', () {
    using((arena) {
      final array = JFloatArray(3)..releasedBy(arena);
      var counter = 0;
      for (final element in array) {
        expect(element, array[counter]);
        ++counter;
      }
      expect(counter, array.length);
      expect(array.length, 3);
      array[0] = 0.5;
      array[1] = 2;
      array[2] = 3;
      expect(array[0], closeTo(0.5, epsilon));
      expect(array[1], closeTo(2, epsilon));
      expect(array[2], closeTo(3, epsilon));
      final firstTwo = array.getRange(0, 2);
      expect(firstTwo.length, 2);
      expect(firstTwo.elementSizeInBytes, sizeOf<JFloatMarker>());
      expect(firstTwo[0], closeTo(0.5, epsilon));
      expect(firstTwo[1], closeTo(2, epsilon));
      expect(() {
        array.getRange(0, 4);
      }, throwsRangeError);
      expect(() {
        array.setRange(0, 4, []);
      }, throwsRangeError);
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
  testRunner('Java double array', () {
    using((arena) {
      final array = JDoubleArray(3)..releasedBy(arena);
      var counter = 0;
      for (final element in array) {
        expect(element, array[counter]);
        ++counter;
      }
      expect(counter, array.length);
      expect(array.length, 3);
      array[0] = 0.5;
      array[1] = 2;
      array[2] = 3;
      expect(array[0], closeTo(0.5, epsilon));
      expect(array[1], closeTo(2, epsilon));
      expect(array[2], closeTo(3, epsilon));
      final firstTwo = array.getRange(0, 2);
      expect(firstTwo.length, 2);
      expect(firstTwo.elementSizeInBytes, sizeOf<JDoubleMarker>());
      expect(firstTwo[0], closeTo(0.5, epsilon));
      expect(firstTwo[1], closeTo(2, epsilon));
      expect(() {
        array.getRange(0, 4);
      }, throwsRangeError);
      expect(() {
        array.setRange(0, 4, []);
      }, throwsRangeError);
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
  testRunner('Java string array', () {
    using((arena) {
      final array = JArray(JString.nullableType, 3)..releasedBy(arena);
      var counter = 0;
      for (final element in array) {
        expect(element, array[counter]);
        ++counter;
      }
      expect(counter, array.length);
      expect(array.length, 3);
      array[0] = 'حس'.toJString()..releasedBy(arena);
      array[1] = '\$'.toJString()..releasedBy(arena);
      array[2] = '33'.toJString()..releasedBy(arena);
      expect(array[0]!.toDartString(releaseOriginal: true), 'حس');
      expect(array[1]!.toDartString(releaseOriginal: true), '\$');
      expect(array[2]!.toDartString(releaseOriginal: true), '33');
      array.setRange(
        0,
        3,
        [
          '44'.toJString()..releasedBy(arena),
          '55'.toJString()..releasedBy(arena),
          '66'.toJString()..releasedBy(arena),
          '77'.toJString()..releasedBy(arena),
        ],
        1,
      );
      expect(array[0]!.toDartString(releaseOriginal: true), '55');
      expect(array[1]!.toDartString(releaseOriginal: true), '66');
      expect(array[2]!.toDartString(releaseOriginal: true), '77');
      expect(() {
        final _ = array[-1];
      }, throwsRangeError);
      expect(() {
        array[-1] = '44'.toJString()..releasedBy(arena);
      }, throwsRangeError);
      expect(() {
        array[3] = '44'.toJString()..releasedBy(arena);
      }, throwsRangeError);
    });
  });
  testRunner('Java object array', () {
    using((arena) {
      final array = JArray(JObject.nullableType, 3)..releasedBy(arena);
      var counter = 0;
      for (final element in array) {
        expect(element, array[counter]);
        ++counter;
      }
      expect(counter, array.length);
      expect(array.length, 3);
      expect(array[0], isNull);
      expect(array[1], isNull);
      expect(array[2], isNull);

      expect(() => JArray(JObject.type, 3), throwsArgumentError);
    });
  });
  testRunner('Java 2d array', () {
    using((arena) {
      final array = JIntArray(3)..releasedBy(arena);
      array[0] = 1;
      array[1] = 2;
      array[2] = 3;
      final twoDimArray = JArray(JIntArray.nullableType, 3)..releasedBy(arena);
      expect(twoDimArray.length, 3);
      twoDimArray[0] = array;
      twoDimArray[1] = array;
      twoDimArray[2] = array;
      for (var i = 0; i < 3; ++i) {
        expect(twoDimArray[i]![0], 1);
        expect(twoDimArray[i]![1], 2);
        expect(twoDimArray[i]![2], 3);
      }
      twoDimArray[2]![2] = 4;
      expect(twoDimArray[2]![2], 4);
    });
  });
  testRunner('JArray.filled', () {
    using((arena) {
      final string = 'abc'.toJString()..releasedBy(arena);
      final array = JArray.filled(3, string)..releasedBy(arena);
      expect(
        () => JArray.filled(-3, 'abc'.toJString()..releasedBy(arena)),
        throwsA(isA<RangeError>()),
      );
      expect(array.length, 3);
      expect(array[0].toDartString(releaseOriginal: true), 'abc');
      expect(array[1].toDartString(releaseOriginal: true), 'abc');
      expect(array[2].toDartString(releaseOriginal: true), 'abc');
    });
  });
  testRunner('JArray.of', () {
    using((arena) {
      final array1 = JArray.of(JString.type, [
        'apple'.toJString()..releasedBy(arena),
        'banana'.toJString()..releasedBy(arena)
      ])
        ..releasedBy(arena);
      expect(array1.length, 2);
      expect(array1[0].toDartString(releaseOriginal: true), 'apple');
      expect(array1[1].toDartString(releaseOriginal: true), 'banana');

      final array2 = JArray.of(JString.nullableType, [
        'apple'.toJString()..releasedBy(arena),
        null,
        'banana'.toJString()..releasedBy(arena)
      ]);
      expect(array2.length, 3);
      expect(array2[0]!.toDartString(releaseOriginal: true), 'apple');
      expect(array2[1], isNull);
      expect(array2[2]!.toDartString(releaseOriginal: true), 'banana');

      final array3 = JArray.of<JObject>(JString.type, []);
      expect(array3.length, 0);

      final array4 = JArray.of<JObject?>(JString.nullableType, []);
      expect(array4.length, 0);
    });
  });
  testRunner('JArray of JByte', () {
    using((arena) {
      final arr = JArray(JByte.nullableType, 1)..releasedBy(arena);
      expect(arr[0], isNull);
    });
  });
  testRunner('JArray of JShort', () {
    using((arena) {
      final arr = JArray(JShort.nullableType, 1)..releasedBy(arena);
      expect(arr[0], isNull);
    });
  });
  testRunner('JArray of JInteger', () {
    using((arena) {
      final arr = JArray(JInteger.nullableType, 1)..releasedBy(arena);
      expect(arr[0], isNull);
    });
  });
  testRunner('JArray of JCharacter', () {
    using((arena) {
      final arr = JArray(JCharacter.nullableType, 1)..releasedBy(arena);
      expect(arr[0], isNull);
    });
  });
  testRunner('JArray of JLong', () {
    using((arena) {
      final arr = JArray(JLong.nullableType, 1)..releasedBy(arena);
      expect(arr[0], isNull);
    });
  });
  testRunner('JArray of JFloat', () {
    using((arena) {
      final arr = JArray(JFloat.nullableType, 1)..releasedBy(arena);
      expect(arr[0], isNull);
    });
  });
  testRunner('JArray of JDouble', () {
    using((arena) {
      final arr = JArray(JDouble.nullableType, 1)..releasedBy(arena);
      expect(arr[0], isNull);
    });
  });
  testRunner('JArray of JBoolean', () {
    using((arena) {
      final arr = JArray(JBoolean.nullableType, 1)..releasedBy(arena);
      expect(arr[0], isNull);
    });
  });
  testRunner('JArray of JSet', () {
    using((arena) {
      final arr = JArray(JSet.nullableType(JString.type), 1)..releasedBy(arena);
      expect(arr[0], isNull);
    });
  });
  testRunner('JArray of JList', () {
    using((arena) {
      final arr = JArray(JList.nullableType(JString.type), 1)
        ..releasedBy(arena);
      expect(arr[0], isNull);
    });
  });
  testRunner('JArray of JMap', () {
    using((arena) {
      final arr = JArray(JMap.nullableType(JString.type, JString.type), 1)
        ..releasedBy(arena);
      expect(arr[0], isNull);
    });
  });
  testRunner('JArray of JIterator', () {
    using((arena) {
      final arr = JArray(JIterator.nullableType(JString.type), 1)
        ..releasedBy(arena);
      expect(arr[0], isNull);
    });
  });
}
