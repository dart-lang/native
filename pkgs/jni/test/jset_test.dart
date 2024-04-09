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
      "1".toJString()..releasedBy(arena),
      "2".toJString()..releasedBy(arena),
      "3".toJString()..releasedBy(arena),
    }.toJSet(JString.type)
      ..releasedBy(arena);
  }

  testRunner('length', () {
    using((arena) {
      final set = testDataSet(arena);
      expect(set.length, 3);
    });
  });
  testRunner('add', () {
    using((arena) {
      final set = testDataSet(arena);
      set.add("1".toJString()..releasedBy(arena));
      expect(set.length, 3);
      set.add("4".toJString()..releasedBy(arena));
      expect(set.length, 4);
    });
  });
  testRunner('addAll', () {
    using((arena) {
      final set = testDataSet(arena);
      final toAdd = testDataSet(arena);
      toAdd.add("4".toJString()..releasedBy(arena));
      set.addAll(toAdd);
      expect(set.length, 4);
      set.addAll([
        "1".toJString()..releasedBy(arena),
        "5".toJString()..releasedBy(arena),
      ]);
      expect(set.length, 5);
    });
  });
  testRunner('clear, isEmpty, isNotEmpty', () {
    using((arena) {
      final set = testDataSet(arena);
      set.clear();
      expect(set.isEmpty, true);
      expect(set.isNotEmpty, false);
    });
  });
  testRunner('contains', () {
    using((arena) {
      final set = testDataSet(arena);
      // ignore: iterable_contains_unrelated_type
      expect(set.contains(1), false);
      expect(set.contains("1".toJString()..releasedBy(arena)), true);
      expect(set.contains("4".toJString()..releasedBy(arena)), false);
    });
  });
  testRunner('containsAll', () {
    using((arena) {
      final set = testDataSet(arena);
      expect(set.containsAll(set), true);
      expect(
        set.containsAll([
          "1".toJString()..releasedBy(arena),
          "2".toJString()..releasedBy(arena),
        ]),
        true,
      );
      final testSet = testDataSet(arena);
      testSet.add("4".toJString()..releasedBy(arena));
      expect(set.containsAll(testSet), false);
      expect(set.containsAll(["4".toJString()..releasedBy(arena)]), false);
    });
  });
  testRunner('iterator', () {
    using((arena) {
      final set = testDataSet(arena);
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
      expect(dartSet, {"1", "2", "3"});
    });
  });
  testRunner('remove', () {
    using((arena) {
      final set = testDataSet(arena);
      // ignore: collection_methods_unrelated_type
      expect(set.remove(1), false);
      expect(set.remove("4".toJString()..releasedBy(arena)), false);
      expect(set.length, 3);
      expect(set.remove("3".toJString()..releasedBy(arena)), true);
      expect(set.length, 2);
    });
  });
  testRunner('removeAll', () {
    using((arena) {
      final set = testDataSet(arena);
      final toRemoveExclusive = {"4".toJString()..releasedBy(arena)}
          .toJSet(JString.type)
        ..releasedBy(arena);
      set.removeAll(toRemoveExclusive);
      expect(set.length, 3);
      final toRemoveInclusive = {
        "1".toJString()..releasedBy(arena),
        "4".toJString()..releasedBy(arena),
      }.toJSet(JString.type)
        ..releasedBy(arena);
      set.removeAll(toRemoveInclusive);
      expect(set.length, 2);
      set.removeAll(["2".toJString()..releasedBy(arena)]);
      expect(set.length, 1);
    });
  });
  testRunner('retainAll', () {
    using((arena) {
      final set = testDataSet(arena);
      final toRetain = {
        "1".toJString()..releasedBy(arena),
        "3".toJString()..releasedBy(arena),
        "4".toJString()..releasedBy(arena),
      };
      set.retainAll(set);
      expect(set.length, 3);
      set.retainAll(toRetain);
      expect(set.length, 2);
      final toRetainJSet = toRetain.toJSet(JString.type)..releasedBy(arena);
      set.retainAll(toRetainJSet);
      expect(set.length, 2);
    });
  });
  testRunner('==, hashCode', () {
    using((arena) {
      final a = testDataSet(arena);
      final b = testDataSet(arena);
      expect(a.hashCode, b.hashCode);
      expect(a, b);
      b.add("4".toJString()..releasedBy(arena));
      expect(a.hashCode, isNot(b.hashCode));
      expect(a, isNot(b));
    });
  });
  testRunner('lookup', () {
    using((arena) {
      final set = testDataSet(arena);
      // ignore: iterable_contains_unrelated_type
      expect(set.lookup(1), null);
      expect(
        set.lookup("1".toJString())?.toDartString(releaseOriginal: true),
        "1",
      );
      expect(set.lookup("4".toJString()..releasedBy(arena)), null);
    });
  });
  testRunner('toSet', () {
    using((arena) {
      // Test if the set gets copied.
      final set = testDataSet(arena);
      final setCopy = set.toSet()..releasedBy(arena);
      expect(set, setCopy);
      set.add("4".toJString()..releasedBy(arena));
      expect(set, isNot(setCopy));
    });
  });
  testRunner('type hashCode, ==', () {
    using((arena) {
      final a = testDataSet(arena);
      final b = testDataSet(arena);
      expect(a.$type, b.$type);
      expect(a.$type.hashCode, b.$type.hashCode);
      final c = JSet.hash(JObject.type)..releasedBy(arena);
      expect(a.$type, isNot(c.$type));
      expect(a.$type.hashCode, isNot(c.$type.hashCode));
    });
  });
}
