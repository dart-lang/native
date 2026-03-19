// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'dart:typed_data';

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
  final throwsAJThrowable = throwsA(isA<JThrowable>());
  JByteBuffer testDataBuffer(Arena arena) {
    final buffer = JByteBuffer.allocate(3)!..releasedBy(arena);
    buffer.nextByte = 1;
    buffer.nextByte = 2;
    buffer.nextByte = 3;
    buffer.jPosition = 0;
    return buffer;
  }

  testRunner('wrap whole array', () {
    using((arena) {
      final array = JByteArray(3)..releasedBy(arena);
      array[0] = 1;
      array[1] = 2;
      array[2] = 3;
      final buffer = JByteBuffer.wrap(array)!..releasedBy(arena);
      expect(buffer, testDataBuffer(arena));
    });
  });

  testRunner('wrap partial array', () {
    using((arena) {
      final array = JByteArray(3)..releasedBy(arena);
      array[0] = 1;
      array[1] = 2;
      array[2] = 3;
      final buffer = JByteBuffer.wrap$1(array, 1, 1)!..releasedBy(arena);
      expect(buffer.nextByte, 2);
      expect(() => buffer.nextByte, throwsAJThrowable);
    });
  });

  testRunner('capacity', () {
    using((arena) {
      final buffer = testDataBuffer(arena);
      expect(buffer.jCapacity, 3);
    });
  });

  testRunner('position', () {
    using((arena) {
      final buffer = testDataBuffer(arena);
      expect(buffer.jPosition, 0);
      buffer.jPosition = 2;
      expect(buffer.jPosition, 2);
    });
  });

  testRunner('limit', () {
    using((arena) {
      final buffer = testDataBuffer(arena);
      expect(buffer.jLimit, 3);
      buffer.jLimit = 2;
      expect(buffer.jLimit, 2);
    });
  });

  testRunner('mark and reset', () {
    using((arena) {
      final buffer = testDataBuffer(arena);
      buffer.jPosition = 1;
      buffer.mark();
      buffer.jPosition = 2;
      buffer.reset();
      expect(buffer.jPosition, 1);
    });
  });

  testRunner('clear', () {
    using((arena) {
      final buffer = testDataBuffer(arena);
      buffer.jPosition = 2;
      buffer.jLimit = 2;
      buffer.clear();
      expect(buffer.jLimit, 3);
      expect(buffer.jPosition, 0);
    });
  });

  testRunner('flip', () {
    using((arena) {
      final buffer = testDataBuffer(arena);
      buffer.jPosition = 2;
      buffer.flip();
      expect(buffer.jLimit, 2);
      expect(buffer.jPosition, 0);
    });
  });

  testRunner('rewind', () {
    using((arena) {
      final buffer = testDataBuffer(arena);
      buffer.mark();
      buffer.jPosition = 2;
      buffer.rewind();
      expect(buffer.jPosition, 0);
      expect(() => buffer.reset(), throwsAJThrowable);
    });
  });

  testRunner('remaining and hasRemaining', () {
    using((arena) {
      final buffer = testDataBuffer(arena);
      buffer.jPosition = 2;
      expect(buffer.jRemaining, 1);
      expect(buffer.jHasRemaining, true);
      buffer.jPosition = 3;
      expect(buffer.jRemaining, 0);
      expect(buffer.jHasRemaining, false);
    });
  });

  testRunner('isReadOnly and asReadOnlyBuffer', () {
    using((arena) {
      final buffer = testDataBuffer(arena);
      expect(buffer.jIsReadOnly, false);
      final readOnly = buffer.asReadOnlyBuffer()!..releasedBy(arena);
      expect(readOnly.jIsReadOnly, true);
    });
  });

  testRunner('hasArray, array and arrayOffset', () {
    using((arena) {
      final buffer = testDataBuffer(arena);
      expect(buffer.jHasArray, true);
      expect(buffer.jArrayOffset, 0);
      expect(buffer.jArray.length, 3);
      final directBuffer = JByteBuffer.allocateDirect(3)!..releasedBy(arena);
      expect(directBuffer.jHasArray, false);
    });
  });

  testRunner('isDirect', () {
    using((arena) {
      final buffer = testDataBuffer(arena);
      expect(buffer.jIsDirect, false);
      final directBuffer = JByteBuffer.allocateDirect(3)!..releasedBy(arena);
      expect(directBuffer.jIsDirect, true);
    });
  });

  testRunner('slice', () {
    using((arena) {
      final buffer = testDataBuffer(arena);
      buffer.jPosition = 1;
      buffer.jLimit = 2;
      final sliced = buffer.slice()!.as(JByteBuffer.type)..releasedBy(arena);
      expect(sliced.jCapacity, 1);
      expect(sliced.nextByte, 2);
    });
  });

  testRunner('duplicate', () {
    using((arena) {
      final buffer = testDataBuffer(arena);
      buffer.jPosition = 1;
      buffer.jLimit = 2;
      final duplicate = buffer.duplicate$1()!..releasedBy(arena);
      expect(duplicate.jCapacity, 3);
      expect(duplicate.jPosition, 1);
      expect(duplicate.jLimit, 2);
    });
  });

  testRunner('asUint8List', () {
    using((arena) {
      final buffer = testDataBuffer(arena);
      expect(() => buffer.asUint8List(), throwsA(isA<StateError>()));
      final list = Uint8List.fromList([1, 2, 3]);
      final directBuffer = list.toJByteBuffer()..releasedBy(arena);
      expect(directBuffer.asUint8List(), list);
    });
  });

  testRunner('asUint8List releasing original', () {
    using((arena) {
      // Used as an example in [JByteBuffer].
      final directBuffer = JByteBuffer.allocateDirect(3)!;
      final data1 = directBuffer.asUint8List();
      directBuffer.nextByte = 42; // No problem!
      expect(data1[0], 42);
      final data2 = directBuffer.asUint8List(releaseOriginal: true);
      expect(
        () => directBuffer.nextByte = 42,
        throwsA(isA<UseAfterReleaseError>()),
      );
      expect(data2[0], 42);
    });
  });
}
