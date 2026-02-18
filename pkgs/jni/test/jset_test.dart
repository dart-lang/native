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
  JSet<JString> testDataSet(Arena arena) {
    return {
      '1'.toJString()..releasedBy(arena),
      '2'.toJString()..releasedBy(arena),
      '3'.toJString()..releasedBy(arena),
    }.toJSet()
      ..releasedBy(arena);
  }

  JSet<JString?> testNullableDataSet(Arena arena) {
    return {
      '1'.toJString()..releasedBy(arena),
      '2'.toJString()..releasedBy(arena),
      null,
    }.toJSet()
      ..releasedBy(arena);
  }

  testRunner('length', () {
    using((arena) {
      final set = testDataSet(arena).asDart();
      expect(set.length, 3);
    });
  });
  testRunner('add', () {
    using((arena) {
      final set = testDataSet(arena).asDart();
      set.add('1'.toJString()..releasedBy(arena));
      expect(set.length, 3);
      set.add('4'.toJString()..releasedBy(arena));
      expect(set.length, 4);
    });
  });
  testRunner('nullable add', () {
    using((arena) {
      final set = testNullableDataSet(arena).asDart();
      set.add('1'.toJString()..releasedBy(arena));
      expect(set.length, 3);
      set.add('4'.toJString()..releasedBy(arena));
      expect(set.length, 4);
      set.add(null);
      expect(set.length, 4);
    });
  });
  testRunner('addAll', () {
    using((arena) {
      final set = testDataSet(arena).asDart();
      final toAdd = testDataSet(arena).asDart();
      toAdd.add('4'.toJString()..releasedBy(arena));
      set.addAll(toAdd);
      expect(set.length, 4);
      set.addAll([
        '1'.toJString()..releasedBy(arena),
        '5'.toJString()..releasedBy(arena),
      ]);
      expect(set.length, 5);
    });
  });
  testRunner('clear, isEmpty, isNotEmpty', () {
    using((arena) {
      final set = testDataSet(arena).asDart();
      set.clear();
      expect(set.isEmpty, true);
      expect(set.isNotEmpty, false);
    });
  });
  testRunner('contains', () {
    using((arena) {
      final set = testDataSet(arena).asDart();
      // ignore: collection_methods_unrelated_type
      expect(set.contains(1), false);
      expect(set.contains('1'.toJString()..releasedBy(arena)), true);
      expect(set.contains('4'.toJString()..releasedBy(arena)), false);
    });
  });
  testRunner('nullable contains', () {
    using((arena) {
      final set = testNullableDataSet(arena).asDart();
      // ignore: collection_methods_unrelated_type
      expect(set.contains(1), false);
      expect(set.contains('1'.toJString()..releasedBy(arena)), true);
      expect(set.contains(null), true);
      expect(set.contains('4'.toJString()..releasedBy(arena)), false);
    });
  });
  testRunner('containsAll', () {
    using((arena) {
      final set = testDataSet(arena).asDart();
      expect(set.containsAll(set), true);
      expect(
        set.containsAll([
          '1'.toJString()..releasedBy(arena),
          '2'.toJString()..releasedBy(arena),
        ]),
        true,
      );
      final testSet = testDataSet(arena).asDart();
      testSet.add('4'.toJString()..releasedBy(arena));
      expect(set.containsAll(testSet), false);
      expect(set.containsAll(['4'.toJString()..releasedBy(arena)]), false);
    });
  });
  testRunner('iterator', () {
    using((arena) {
      final set = testDataSet(arena).asDart();
      final it = set.iterator;
      // There are no order guarantees in a hashset.
      final dartSet = <String>{};
      expect(it.moveNext(), true);
      dartSet.add(it.current.toDartString(releaseOriginal: true));
      expect(it.moveNext(), true);
      dartSet.add(it.current.toDartString(releaseOriginal: true));
      expect(it.moveNext(), true);
      dartSet.add(it.current.toDartString(releaseOriginal: true));
      expect(it.moveNext(), false);
      // So we just check if the elements have appeared in some order.
      expect(dartSet, {'1', '2', '3'});
    });
  });
  testRunner('remove', () {
    using((arena) {
      final set = testDataSet(arena).asDart();
      // ignore: collection_methods_unrelated_type
      expect(set.remove(1), false);
      expect(set.remove('4'.toJString()..releasedBy(arena)), false);
      expect(set.length, 3);
      expect(set.remove('3'.toJString()..releasedBy(arena)), true);
      expect(set.length, 2);
    });
  });
  testRunner('nullable remove', () {
    using((arena) {
      final set = testNullableDataSet(arena).asDart();
      // ignore: collection_methods_unrelated_type
      expect(set.remove(1), false);
      expect(set.remove('4'.toJString()..releasedBy(arena)), false);
      expect(set.length, 3);
      expect(set.remove(null), true);
      expect(set.length, 2);
    });
  });
  testRunner('removeAll', () {
    using((arena) {
      final set = testDataSet(arena).asDart();
      final toRemoveExclusive = {'4'.toJString()..releasedBy(arena)}.toJSet()
        ..releasedBy(arena);
      set.removeAll(toRemoveExclusive.asDart());
      expect(set.length, 3);
      final toRemoveInclusive = {
        '1'.toJString()..releasedBy(arena),
        '4'.toJString()..releasedBy(arena),
      }.toJSet()
        ..releasedBy(arena);
      set.removeAll(toRemoveInclusive.asDart());
      expect(set.length, 2);
      set.removeAll(['2'.toJString()..releasedBy(arena)]);
      expect(set.length, 1);
    });
  });
  testRunner('retainAll', () {
    using((arena) {
      final set = testDataSet(arena).asDart();
      final toRetain = {
        '1'.toJString()..releasedBy(arena),
        '3'.toJString()..releasedBy(arena),
        '4'.toJString()..releasedBy(arena),
      };
      set.retainAll(set);
      expect(set.length, 3);
      set.retainAll(toRetain);
      expect(set.length, 2);
      final toRetainJSet = toRetain.toJSet()..releasedBy(arena);
      set.retainAll(toRetainJSet.asDart());
      expect(set.length, 2);
    });
  });
  testRunner('==, hashCode', () {
    using((arena) {
      final a = testDataSet(arena).asDart();
      final b = testDataSet(arena).asDart();
      expect(a.hashCode, isNot(b.hashCode));
      expect(a, b);
      expect(a == b, isFalse);
    });
  });
  testRunner('lookup', () {
    using((arena) {
      final set = testDataSet(arena).asDart();
      expect(() => set.lookup('1'.toJString()), throwsUnsupportedError);
    });
  });
  testRunner('toSet', () {
    using((arena) {
      // Test if the set gets copied.
      final set = testDataSet(arena).asDart();
      final setCopy = set.toSet();
      expect(set, setCopy);
      set.add('4'.toJString()..releasedBy(arena));
      expect(set, isNot(setCopy));
    });
  });
}
