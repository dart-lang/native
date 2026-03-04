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
  JList<JString> testDataList(Arena arena) {
    return [
      '1'.toJString()..releasedBy(arena),
      '2'.toJString()..releasedBy(arena),
      '3'.toJString()..releasedBy(arena),
    ].toJList()
      ..releasedBy(arena);
  }

  JList<JString?> testNullableDataList(Arena arena) {
    return [
      '1'.toJString()..releasedBy(arena),
      '2'.toJString()..releasedBy(arena),
      null,
    ].toJList()
      ..releasedBy(arena);
  }

  testRunner('length get', () {
    using((arena) {
      final list = testDataList(arena).asDart();
      expect(list.length, 3);
    });
  });
  testRunner('length set', () {
    using((arena) {
      final list = (<JString?>[
        '1'.toJString()..releasedBy(arena),
        '2'.toJString()..releasedBy(arena),
        '3'.toJString()..releasedBy(arena),
      ].toJList()
            ..releasedBy(arena))
          .asDart();
      list.length = 2;
      expect(list.length, 2);
      list.length = 3;
      expect(list.length, 3);
      expect(list.last, isNull);
    });
  });
  testRunner('[]', () {
    using((arena) {
      final list = testDataList(arena).asDart();
      expect(list[0].toDartString(releaseOriginal: true), '1');
      expect(list[1].toDartString(releaseOriginal: true), '2');
      expect(list[2].toDartString(releaseOriginal: true), '3');
    });
  });
  testRunner('nullable []', () {
    using((arena) {
      final list = testNullableDataList(arena).asDart();
      expect(list[0]!.toDartString(releaseOriginal: true), '1');
      expect(list[1]!.toDartString(releaseOriginal: true), '2');
      expect(list[2], isNull);
    });
  });
  testRunner('[]=', () {
    using((arena) {
      final list = testDataList(arena).asDart();
      expect(list[0].toDartString(releaseOriginal: true), '1');
      list[0] = '2'.toJString()..releasedBy(arena);
      expect(list[0].toDartString(releaseOriginal: true), '2');
    });
  });
  testRunner('nullable []=', () {
    using((arena) {
      final list = testNullableDataList(arena).asDart();
      expect(list[0]!.toDartString(releaseOriginal: true), '1');
      list[0] = '2'.toJString()..releasedBy(arena);
      expect(list[0]!.toDartString(releaseOriginal: true), '2');
      list[0] = null;
      expect(list[0], isNull);
    });
  });
  testRunner('add', () {
    using((arena) {
      final list = testDataList(arena).asDart();
      list.add('4'.toJString()..releasedBy(arena));
      expect(list.length, 4);
      expect(list[3].toDartString(releaseOriginal: true), '4');
    });
  });
  testRunner('nullable add', () {
    using((arena) {
      final list = testNullableDataList(arena).asDart();
      list.add('4'.toJString()..releasedBy(arena));
      expect(list.length, 4);
      expect(list[3]!.toDartString(releaseOriginal: true), '4');
      list.add(null);
      expect(list[3]!.toDartString(releaseOriginal: true), '4');
    });
  });
  testRunner('addAll', () {
    using((arena) {
      final list = testDataList(arena).asDart();
      final toAppend = testDataList(arena).asDart();
      list.addAll(toAppend);
      expect(list.length, 6);
      list.addAll(['4'.toJString()..releasedBy(arena)]);
      expect(list.length, 7);
    });
  });
  testRunner('clear, isEmpty, isNotEmpty', () {
    using((arena) {
      final list = testDataList(arena).asDart();
      expect(list.isNotEmpty, true);
      expect(list.isEmpty, false);
      list.clear();
      expect(list.isNotEmpty, false);
      expect(list.isEmpty, true);
    });
  });
  testRunner('contains', () {
    using((arena) {
      final list = testDataList(arena).asDart();
      expect((list as List<Object>).contains('1'), false);
      expect(list.contains('1'.toJString()..releasedBy(arena)), true);
      expect(list.contains('4'.toJString()..releasedBy(arena)), false);
    });
  });
  testRunner('nullable contains', () {
    using((arena) {
      final list = testNullableDataList(arena).asDart();
      expect((list as List<Object?>).contains('1'), false);
      expect(list.contains('1'.toJString()..releasedBy(arena)), true);
      expect(list.contains('4'.toJString()..releasedBy(arena)), false);
      expect(list.contains(null), true);
    });
  });
  testRunner('getRange', () {
    using((arena) {
      final list = testDataList(arena).asDart();
      final range = list.getRange(1, 2);
      expect(range.length, 1);
      expect(range.first.toDartString(releaseOriginal: true), '2');
    });
  });
  testRunner('indexOf', () {
    using((arena) {
      final list = testDataList(arena).asDart();
      expect((list as List<Object>).indexOf(1), -1);
      expect(list.indexOf('1'.toJString()..toDartString()), 0);
      expect(list.indexOf('2'.toJString()..toDartString()), 1);
      expect(list.indexOf('1'.toJString()..toDartString(), 1), -1);
      expect(list.indexOf('1'.toJString()..toDartString(), -1), 0);
    });
  });
  testRunner('nullable indexOf', () {
    using((arena) {
      final list = testNullableDataList(arena).asDart();
      expect((list as List<Object?>).indexOf(1), -1);
      expect(list.indexOf('1'.toJString()..toDartString()), 0);
      expect(list.indexOf('2'.toJString()..toDartString()), 1);
      expect(list.indexOf(null), 2);
      expect(list.indexOf('1'.toJString()..toDartString(), 1), -1);
      expect(list.indexOf('1'.toJString()..toDartString(), -1), 0);
    });
  });
  testRunner('lastIndexOf', () {
    using((arena) {
      final list = testDataList(arena).asDart();
      expect((list as List<Object>).lastIndexOf(1), -1);
      expect(list.lastIndexOf('1'.toJString()..toDartString()), 0);
      expect(list.lastIndexOf('2'.toJString()..toDartString()), 1);
      expect(list.lastIndexOf('3'.toJString()..toDartString()), 2);
      expect(list.lastIndexOf('3'.toJString()..toDartString(), 1), -1);
    });
  });
  testRunner('nullable lastIndexOf', () {
    using((arena) {
      final list = testNullableDataList(arena).asDart();
      expect((list as List<Object?>).lastIndexOf(1), -1);
      expect(list.lastIndexOf('1'.toJString()..toDartString()), 0);
      expect(list.lastIndexOf('2'.toJString()..toDartString()), 1);
      expect(list.lastIndexOf(null), 2);
      expect(list.lastIndexOf(null, 1), -1);
    });
  });
  testRunner('insert', () {
    using((arena) {
      final list = testDataList(arena).asDart();
      list.insert(1, '0'.toJString()..releasedBy(arena));
      expect(list.length, 4);
      expect(list[1].toDartString(releaseOriginal: true), '0');
    });
  });
  testRunner('insertAll', () {
    using((arena) {
      final list = testDataList(arena).asDart();
      final toInsert = testDataList(arena).asDart();
      list.insertAll(1, toInsert);
      expect(list[1].toDartString(releaseOriginal: true), '1');
      expect(list.length, 6);
      list.insertAll(1, ['4'.toJString()..releasedBy(arena)]);
      expect(list.length, 7);
      expect(list[1].toDartString(releaseOriginal: true), '4');
    });
  });
  testRunner('iterator', () {
    using((arena) {
      final list = testDataList(arena).asDart();
      final it = list.iterator;
      expect(it.moveNext(), true);
      expect(it.current.toDartString(releaseOriginal: true), '1');
      expect(it.moveNext(), true);
      expect(it.current.toDartString(releaseOriginal: true), '2');
      expect(it.moveNext(), true);
      expect(it.current.toDartString(releaseOriginal: true), '3');
      expect(it.moveNext(), false);
    });
  });
  testRunner('remove', () {
    using((arena) {
      final list = testDataList(arena).asDart();
      expect(list.remove('3'.toJString()..releasedBy(arena)), true);
      expect(list.length, 2);
      expect(list.remove('4'.toJString()..releasedBy(arena)), false);
      // ignore: collection_methods_unrelated_type
      expect(list.remove(1), false);
    });
  });
  testRunner('nullable remove', () {
    using((arena) {
      final list = testNullableDataList(arena).asDart();
      expect(list.remove('3'.toJString()..releasedBy(arena)), false);
      expect(list.length, 3);
      expect(list.remove(null), true);
      expect(list.length, 2);
      // ignore: collection_methods_unrelated_type
      expect(list.remove(1), false);
    });
  });
  testRunner('removeAt', () {
    using((arena) {
      final list = testDataList(arena).asDart();
      expect(list.removeAt(0).toDartString(releaseOriginal: true), '1');
      expect(list.removeAt(1).toDartString(releaseOriginal: true), '3');
    });
  });
  testRunner('removeRange', () {
    using((arena) {
      final list = testDataList(arena).asDart();
      list.removeRange(0, 2);
      expect(list.single.toDartString(releaseOriginal: true), '3');
    });
  });
  testRunner('==, hashCode', () {
    using((arena) {
      final a = testDataList(arena).asDart();
      final b = testDataList(arena).asDart();
      expect(a.hashCode, isNot(b.hashCode));
      expect(a, b);
      expect(a == b, isFalse);
    });
  });
  testRunner('toSet', () {
    using((arena) {
      final list = testDataList(arena).asDart();
      final set = list.toSet();
      expect(set.length, 3);
    });
  });
}
