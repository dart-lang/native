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
  final throwsAJniException = throwsA(isA<JniException>());
  JByteBuffer testDataBuffer(Arena arena) {
    final buffer = JByteBuffer.allocate(3)..releasedBy(arena);
    buffer.nextByte = 1;
    buffer.nextByte = 2;
    buffer.nextByte = 3;
    buffer.position = 0;
    return buffer;
  }

  testRunner('wrap whole array', () {
    using((arena) {
      final array = JArray(jbyte.type, 3)..releasedBy(arena);
      array[0] = 1;
      array[1] = 2;
      array[2] = 3;
      final buffer = JByteBuffer.wrap(array)..releasedBy(arena);
      expect(buffer, testDataBuffer(arena));
    });
  });

  testRunner('wrap partial array', () {
    using((arena) {
      final array = JArray(jbyte.type, 3)..releasedBy(arena);
      array[0] = 1;
      array[1] = 2;
      array[2] = 3;
      final buffer = JByteBuffer.wrap(array, 1, 1)..releasedBy(arena);
      expect(buffer.nextByte, 2);
      expect(() => buffer.nextByte, throwsAJniException);
    });
  });

  testRunner('capacity', () {
    using((arena) {
      final buffer = testDataBuffer(arena);
      expect(buffer.capacity, 3);
    });
  });

  testRunner('position', () {
    using((arena) {
      final buffer = testDataBuffer(arena);
      expect(buffer.position, 0);
      buffer.position = 2;
      expect(buffer.position, 2);
    });
  });

  testRunner('limit', () {
    using((arena) {
      final buffer = testDataBuffer(arena);
      expect(buffer.limit, 3);
      buffer.limit = 2;
      expect(buffer.limit, 2);
    });
  });

  testRunner('mark and reset', () {
    using((arena) {
      final buffer = testDataBuffer(arena);
      buffer.position = 1;
      buffer.mark();
      buffer.position = 2;
      buffer.reset();
      expect(buffer.position, 1);
    });
  });

  testRunner('clear', () {
    using((arena) {
      final buffer = testDataBuffer(arena);
      buffer.position = 2;
      buffer.limit = 2;
      buffer.clear();
      expect(buffer.limit, 3);
      expect(buffer.position, 0);
    });
  });

  testRunner('flip', () {
    using((arena) {
      final buffer = testDataBuffer(arena);
      buffer.position = 2;
      buffer.flip();
      expect(buffer.limit, 2);
      expect(buffer.position, 0);
    });
  });

  testRunner('rewind', () {
    using((arena) {
      final buffer = testDataBuffer(arena);
      buffer.mark();
      buffer.position = 2;
      buffer.rewind();
      expect(buffer.position, 0);
      expect(buffer.reset, throwsAJniException);
    });
  });

  testRunner('remaining and hasRemaining', () {
    using((arena) {
      final buffer = testDataBuffer(arena);
      buffer.position = 2;
      expect(buffer.remaining, 1);
      expect(buffer.hasRemaining, true);
      buffer.position = 3;
      expect(buffer.remaining, 0);
      expect(buffer.hasRemaining, false);
    });
  });

  testRunner('isReadOnly and asReadOnlyBuffer', () {
    using((arena) {
      final buffer = testDataBuffer(arena);
      expect(buffer.isReadOnly, false);
      final readOnly = buffer.asReadOnlyBuffer()..releasedBy(arena);
      expect(readOnly.isReadOnly, true);
    });
  });

  testRunner('hasArray, array and arrayOffset', () {
    using((arena) {
      final buffer = testDataBuffer(arena);
      expect(buffer.hasArray, true);
      expect(buffer.arrayOffset, 0);
      expect(buffer.array.length, 3);
      final directBuffer = JByteBuffer.allocateDirect(3)..releasedBy(arena);
      expect(directBuffer.hasArray, false);
    });
  });

  testRunner('isDirect', () {
    using((arena) {
      final buffer = testDataBuffer(arena);
      expect(buffer.isDirect, false);
      final directBuffer = JByteBuffer.allocateDirect(3)..releasedBy(arena);
      expect(directBuffer.isDirect, true);
    });
  });

  testRunner('slice', () {
    using((arena) {
      final buffer = testDataBuffer(arena);
      buffer.position = 1;
      buffer.limit = 2;
      final sliced = buffer.slice()..releasedBy(arena);
      expect(sliced.capacity, 1);
      expect(sliced.nextByte, 2);
    });
  });

  testRunner('duplicate', () {
    using((arena) {
      final buffer = testDataBuffer(arena);
      buffer.position = 1;
      buffer.limit = 2;
      final duplicate = buffer.duplicate()..releasedBy(arena);
      expect(duplicate.capacity, 3);
      expect(duplicate.position, 1);
      expect(duplicate.limit, 2);
    });
  });

  testRunner('asUint8List', () {
    using((arena) {
      final buffer = testDataBuffer(arena);
      expect(buffer.asUint8List, throwsA(isA<StateError>()));
      final list = Uint8List.fromList([1, 2, 3]);
      final directBuffer = list.toJByteBuffer()..releasedBy(arena);
      expect(directBuffer.asUint8List(), list);
    });
  });

  testRunner('type hashCode, ==', () {
    using((arena) {
      final a = testDataBuffer(arena);
      final b = testDataBuffer(arena);
      expect(a.$type, b.$type);
      expect(a.$type.hashCode, b.$type.hashCode);
      final c = JBuffer.fromReference(jNullReference);
      final d = JBuffer.fromReference(jNullReference);
      expect(c.$type, d.$type);
      expect(c.$type.hashCode, d.$type.hashCode);

      expect(a.$type, isNot(c.$type));
      expect(a.$type.hashCode, isNot(c.$type.hashCode));
    });
  });

  testRunner('asUint8List releasing original', () {
    using((arena) {
      // Used as an example in [JByteBuffer].
      final directBuffer = JByteBuffer.allocateDirect(3);
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
