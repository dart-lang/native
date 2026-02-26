// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:jni/jni.dart';
import 'package:test/test.dart';

import 'test_util/test_util.dart';

void main() {
  if (!Platform.isAndroid) {
    checkDylibIsUpToDate();
    spawnJvm();
  }
  run(testRunner: test);
}

void run({required TestRunnerCallback testRunner}) {
  testRunner('toJObject basic types', () {
    using((arena) {
      expect(toJObject(null), isNull);
      expect(toJObject(true)!.isA(JBoolean.type), isTrue);
      expect(toJObject(1)!.isA(JLong.type), isTrue);
      expect(toJObject(1.5)!.isA(JDouble.type), isTrue);
      expect(toJObject('abc')!.isA(JString.type), isTrue);
    });
  });

  testRunner('toDartObject basic types', () {
    using((arena) {
      expect(toDartObject(null), isNull);
      expect(toDartObject(true.toJBoolean()..releasedBy(arena)), true);
      expect(toDartObject(1.toJLong()..releasedBy(arena)), 1);
      expect(toDartObject(1.5.toJDouble()..releasedBy(arena)), 1.5);
      expect(toDartObject('abc'.toJString()..releasedBy(arena)), 'abc');
    });
  });

  testRunner('Deep conversion List', () {
    using((arena) {
      final list = [1, 'abc', true];
      final jList = toJObject(list)!..releasedBy(arena);
      expect(jList.isA(JList.type(JObject.nullableType)), isTrue);

      final back = toDartObject(jList);
      expect(back, isA<List>());
      final backList = back as List;
      expect(backList[0], 1);
      expect(backList[1], 'abc');
      expect(backList[2], true);
    });
  });

  testRunner('Deep conversion Map', () {
    using((arena) {
      final map = {'a': 1, 'b': 2};
      final jMap = toJObject(map)!..releasedBy(arena);
      expect(jMap.isA(JMap.type(JObject.nullableType, JObject.nullableType)),
          isTrue);

      final back = toDartObject(jMap);
      expect(back, isA<Map>());
      final backMap = back as Map;
      expect(backMap['a'], 1);
      expect(backMap['b'], 2);
    });
  });

  testRunner('Primitive arrays toJ*Array', () {
    using((arena) {
      final bools = [true, false].toJBooleanArray()..releasedBy(arena);
      expect(bools.isA(JBooleanArray.type), isTrue);
      expect(toDartObject(bools), [true, false]);

      final ints = [1, 2, 3].toJIntArray()..releasedBy(arena);
      expect(ints.isA(JIntArray.type), isTrue);
      expect(toDartObject(ints), [1, 2, 3]);

      final doubles = [1.5, 2.5].toJDoubleArray()..releasedBy(arena);
      expect(doubles.isA(JDoubleArray.type), isTrue);
      expect(toDartObject(doubles), [1.5, 2.5]);
    });
  });

  testRunner('Object array toJObjectArray', () {
    using((arena) {
      final strings = [
        'a'.toJString()..releasedBy(arena),
        'b'.toJString()..releasedBy(arena)
      ];
      final jArray = strings.toJObjectArray(JString.type)..releasedBy(arena);
      // Signature for JArray<JString> is [Ljava/lang/String;
      expect(jArray.isA(JArray.type(JString.type)), isTrue);

      final back = toDartObject(jArray);
      expect(back, ['a', 'b']);
    });
  });
}
