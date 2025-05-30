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
    ].toJList(JString.type)
      ..releasedBy(arena);
  }

  JList<JString?> testNullableDataList(Arena arena) {
    return [
      '1'.toJString()..releasedBy(arena),
      '2'.toJString()..releasedBy(arena),
      null,
    ].toJList(JString.nullableType)
      ..releasedBy(arena);
  }

  testRunner('length get', () {
    using((arena) {
      final list = testDataList(arena);
      expect(list.length, 3);
    });
  });
  testRunner('length set', () {
    using((arena) {
      final list = <JString?>[
        '1'.toJString()..releasedBy(arena),
        '2'.toJString()..releasedBy(arena),
        '3'.toJString()..releasedBy(arena),
      ].toJList(JString.nullableType)
        ..releasedBy(arena);
      list.length = 2;
      expect(list.length, 2);
      list.length = 3;
      expect(list.length, 3);
      expect(list.last, isNull);
    });
  });
  testRunner('[]', () {
    using((arena) {
      final list = testDataList(arena);
      expect(list[0].toDartString(releaseOriginal: true), '1');
      expect(list[1].toDartString(releaseOriginal: true), '2');
      expect(list[2].toDartString(releaseOriginal: true), '3');
    });
  });
  testRunner('nullable []', () {
    using((arena) {
      final list = testNullableDataList(arena);
      expect(list[0]!.toDartString(releaseOriginal: true), '1');
      expect(list[1]!.toDartString(releaseOriginal: true), '2');
      expect(list[2], isNull);
    });
  });
  testRunner('[]=', () {
    using((arena) {
      final list = testDataList(arena);
      expect(list[0].toDartString(releaseOriginal: true), '1');
      list[0] = '2'.toJString()..releasedBy(arena);
      expect(list[0].toDartString(releaseOriginal: true), '2');
    });
  });
  testRunner('nullable []=', () {
    using((arena) {
      final list = testNullableDataList(arena);
      expect(list[0]!.toDartString(releaseOriginal: true), '1');
      list[0] = '2'.toJString()..releasedBy(arena);
      expect(list[0]!.toDartString(releaseOriginal: true), '2');
      list[0] = null;
      expect(list[0], isNull);
    });
  });
  testRunner('add', () {
    using((arena) {
      final list = testDataList(arena);
      list.add('4'.toJString()..releasedBy(arena));
      expect(list.length, 4);
      expect(list[3].toDartString(releaseOriginal: true), '4');
    });
  });
  testRunner('nullable add', () {
    using((arena) {
      final list = testNullableDataList(arena);
      list.add('4'.toJString()..releasedBy(arena));
      expect(list.length, 4);
      expect(list[3]!.toDartString(releaseOriginal: true), '4');
      list.add(null);
      expect(list[3]!.toDartString(releaseOriginal: true), '4');
    });
  });
  testRunner('addAll', () {
    using((arena) {
      final list = testDataList(arena);
      final toAppend = testDataList(arena);
      list.addAll(toAppend);
      expect(list.length, 6);
      list.addAll(['4'.toJString()..releasedBy(arena)]);
      expect(list.length, 7);
    });
  });
  testRunner('clear, isEmpty, isNotEmpty', () {
    using((arena) {
      final list = testDataList(arena);
      expect(list.isNotEmpty, true);
      expect(list.isEmpty, false);
      list.clear();
      expect(list.isNotEmpty, false);
      expect(list.isEmpty, true);
    });
  });
  testRunner('contains', () {
    using((arena) {
      final list = testDataList(arena);
      // ignore: collection_methods_unrelated_type
      expect(list.contains('1'), false);
      expect(list.contains('1'.toJString()..releasedBy(arena)), true);
      expect(list.contains('4'.toJString()..releasedBy(arena)), false);
    });
  });
  testRunner('nullable contains', () {
    using((arena) {
      final list = testNullableDataList(arena);
      // ignore: collection_methods_unrelated_type
      expect(list.contains('1'), false);
      expect(list.contains('1'.toJString()..releasedBy(arena)), true);
      expect(list.contains('4'.toJString()..releasedBy(arena)), false);
      expect(list.contains(null), true);
    });
  });
  testRunner('getRange', () {
    using((arena) {
      final list = testDataList(arena);
      // ignore: iterable_contains_unrelated_type
      final range = list.getRange(1, 2)..releasedBy(arena);
      expect(range.length, 1);
      expect(range.first.toDartString(releaseOriginal: true), '2');
    });
  });
  testRunner('indexOf', () {
    using((arena) {
      final list = testDataList(arena);
      expect(list.indexOf(1), -1);
      expect(list.indexOf('1'.toJString()..toDartString()), 0);
      expect(list.indexOf('2'.toJString()..toDartString()), 1);
      expect(list.indexOf('1'.toJString()..toDartString(), 1), -1);
      expect(list.indexOf('1'.toJString()..toDartString(), -1), 0);
    });
  });
  testRunner('nullable indexOf', () {
    using((arena) {
      final list = testNullableDataList(arena);
      expect(list.indexOf(1), -1);
      expect(list.indexOf('1'.toJString()..toDartString()), 0);
      expect(list.indexOf('2'.toJString()..toDartString()), 1);
      expect(list.indexOf(null), 2);
      expect(list.indexOf('1'.toJString()..toDartString(), 1), -1);
      expect(list.indexOf('1'.toJString()..toDartString(), -1), 0);
    });
  });
  testRunner('lastIndexOf', () {
    using((arena) {
      final list = testDataList(arena);
      expect(list.lastIndexOf(1), -1);
      expect(list.lastIndexOf('1'.toJString()..toDartString()), 0);
      expect(list.lastIndexOf('2'.toJString()..toDartString()), 1);
      expect(list.lastIndexOf('3'.toJString()..toDartString()), 2);
      expect(list.lastIndexOf('3'.toJString()..toDartString(), 1), -1);
    });
  });
  testRunner('nullable lastIndexOf', () {
    using((arena) {
      final list = testNullableDataList(arena);
      expect(list.lastIndexOf(1), -1);
      expect(list.lastIndexOf('1'.toJString()..toDartString()), 0);
      expect(list.lastIndexOf('2'.toJString()..toDartString()), 1);
      expect(list.lastIndexOf(null), 2);
      expect(list.lastIndexOf(null, 1), -1);
    });
  });
  testRunner('insert', () {
    using((arena) {
      final list = testDataList(arena);
      list.insert(1, '0'.toJString()..releasedBy(arena));
      expect(list.length, 4);
      expect(list[1].toDartString(releaseOriginal: true), '0');
    });
  });
  testRunner('insertAll', () {
    using((arena) {
      final list = testDataList(arena);
      final toInsert = testDataList(arena);
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
      final list = testDataList(arena);
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
      final list = testDataList(arena);
      expect(list.remove('3'.toJString()..releasedBy(arena)), true);
      expect(list.length, 2);
      expect(list.remove('4'.toJString()..releasedBy(arena)), false);
      // ignore: collection_methods_unrelated_type
      expect(list.remove(1), false);
    });
  });
  testRunner('nullable remove', () {
    using((arena) {
      final list = testNullableDataList(arena);
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
      final list = testDataList(arena);
      expect(list.removeAt(0).toDartString(releaseOriginal: true), '1');
      expect(list.removeAt(1).toDartString(releaseOriginal: true), '3');
    });
  });
  testRunner('removeRange', () {
    using((arena) {
      final list = testDataList(arena);
      list.removeRange(0, 2);
      expect(list.single.toDartString(releaseOriginal: true), '3');
    });
  });
  testRunner('==, hashCode', () {
    using((arena) {
      final a = testDataList(arena);
      final b = testDataList(arena);
      expect(a.hashCode, b.hashCode);
      expect(a, b);
      b.add('4'.toJString()..releasedBy(arena));
      expect(a.hashCode, isNot(b.hashCode));
      expect(a, isNot(b));
    });
  });
  testRunner('toSet', () {
    using((arena) {
      final list = testDataList(arena);
      final set = list.toSet()..releasedBy(arena);
      expect(set.length, 3);
    });
  });
  testRunner('type hashCode, ==', () {
    using((arena) {
      final a = testDataList(arena);
      final b = testDataList(arena);
      expect(a.$type, b.$type);
      expect(a.$type.hashCode, b.$type.hashCode);
      final c = JList.array(JObject.type)..releasedBy(arena);
      expect(a.$type, isNot(c.$type));
      expect(a.$type.hashCode, isNot(c.$type.hashCode));
    });
  });
  testRunner('JIterator type hashCode, ==', () {
    using((arena) {
      final a = testDataList(arena);
      final b = testDataList(arena);
      expect(a.iterator.$type, b.iterator.$type);
      expect(a.iterator.$type.hashCode, b.iterator.$type.hashCode);
      final c = JList.array(JObject.type)..releasedBy(arena);
      expect(a.iterator.$type, isNot(c.iterator.$type));
      expect(a.iterator.$type.hashCode, isNot(c.iterator.$type.hashCode));
    });
  });
}
