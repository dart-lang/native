// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:jni/jni.dart';
import 'package:test/test.dart';

import '../test_util/callback_types.dart';
import 'bindings/kotlin.dart';

void registerTests(String groupName, TestRunnerCallback test) {
  group(groupName, () {
    test('Suspend functions', () async {
      await using((arena) async {
        final suspendFun = SuspendFun()..releasedBy(arena);
        final hello = await suspendFun.sayHello();
        expect(hello.toDartString(releaseOriginal: true), 'Hello!');
        const name = 'Bob';
        final helloBob =
            await suspendFun.sayHello$1(name.toJString()..releasedBy(arena));
        expect(helloBob.toDartString(releaseOriginal: true), 'Hello $name!');
        final noDelayHello = await suspendFun.sayHelloWithoutDelay();
        expect(noDelayHello.toDartString(releaseOriginal: true), 'Hello!');
        await expectLater(suspendFun.fail, throwsA(isA<JniException>()));
        await expectLater(
            suspendFun.failWithoutDelay, throwsA(isA<JniException>()));
      });
    });

    test('Top levels', () {
      expect(topLevel(), 42);
      expect(topLevel$1(), 42);
      expect(topLevelSum(10, 20), 30);
      expect(getTopLevelField(), 42);
      expect(getTopLevelField$1(), 42);
      setTopLevelField(30);
      setTopLevelField$1(30);
      expect(getTopLevelField(), 30);
      expect(getTopLevelField$1(), 30);
    });

    test('Generics', () {
      using((arena) {
        final speed = Speed(10, SpeedUnit.MetrePerSec)..releasedBy(arena);
        expect(speed.convertValue(SpeedUnit.KmPerHour), closeTo(36, 1e-6));
      });
    });

    group('Operators', () {
      Operators testObject(int value, Arena arena) {
        return Operators(value)..releasedBy(arena);
      }

      test('+', () {
        using((arena) {
          final o24 = testObject(24, arena);
          final o18 = testObject(18, arena);
          expect((o24.plus(o18)..releasedBy(arena)).getValue(), 42);
          expect(((o24 + o18)..releasedBy(arena)).getValue(), 42);
        });
      });

      test('-', () {
        using((arena) {
          final o24 = testObject(24, arena);
          final o18 = testObject(18, arena);
          expect((o24.minus(o18)..releasedBy(arena)).getValue(), 6);
          expect(((o24 - o18)..releasedBy(arena)).getValue(), 6);
        });
      });

      test('*', () {
        using((arena) {
          final o2 = testObject(2, arena);
          final o3 = testObject(3, arena);
          expect((o2.times(o3)..releasedBy(arena)).getValue(), 6);
          expect(((o2 * o3)..releasedBy(arena)).getValue(), 6);
        });
      });

      test('/', () {
        using((arena) {
          final o24 = testObject(24, arena);
          final o3 = testObject(3, arena);
          expect((o24.div(o3)..releasedBy(arena)).getValue(), 8);
          expect(((o24 / o3)..releasedBy(arena)).getValue(), 8);
        });
      });

      test('%', () {
        using((arena) {
          final o24 = testObject(24, arena);
          final o5 = testObject(5, arena);
          expect((o24.rem(o5)..releasedBy(arena)).getValue(), 4);
          expect(((o24 % o5)..releasedBy(arena)).getValue(), 4);
        });
      });

      test('[], []=', () {
        using((arena) {
          // 25 in binary: 11001
          final o = testObject(25, arena);
          expect(o[0], true); // 1100[1]
          expect(o[1], false); // 110[0]1
          expect(o.get(2), false); // 11[0]01

          o[0] = false; // 1100[0]
          expect(o[0], false); // 1100[0]
          o.set(1, true); // 110[1]0
          expect(o[1], true); // 110[1]0
        });
      });

      test('<, <=, >, >=', () {
        using((arena) {
          final o24 = testObject(24, arena);
          final o18 = testObject(18, arena);
          expect(o24.compareTo(o18), greaterThan(0));
          expect(o18.compareTo(o24), lessThan(0));

          expect(o24 < o18, isFalse);
          expect(o24 <= o18, isFalse);
          expect(o24 > o18, isTrue);
          expect(o24 >= o18, isTrue);

          expect(o24 >= o24, isTrue);
          expect(o18 <= o18, isTrue);
        });
      });
    });

    group('Nullability', () {
      Nullability<JString?, JString> testObject(Arena arena) {
        return Nullability(
          null,
          'hello'.toJString(),
          null,
          T: JString.nullableType,
          U: JString.type,
        )..releasedBy(arena);
      }

      test('Getters', () {
        using((arena) {
          final obj = testObject(arena);
          expect(
            obj.getU().toDartString(releaseOriginal: true),
            'hello',
          );
          expect(obj.getT(), null);
          expect(obj.getNullableU(), null);
        });
      });
      test('Setters', () {
        using((arena) {
          final obj = testObject(arena);
          obj.setNullableU('hello'.toJString()..releasedBy(arena));
          expect(
            obj.getNullableU()!.toDartString(releaseOriginal: true),
            'hello',
          );
          obj.setNullableU(null);
          expect(
            obj.getNullableU(),
            null,
          );
        });
      });
      test('Methods', () {
        using((arena) {
          final obj = testObject(arena);
          expect(
            obj
                .list()
                .first!
                .as(JString.type, releaseOriginal: true)
                .toDartString(releaseOriginal: true),
            'hello',
          );
          expect(obj.hello().toDartString(releaseOriginal: true), 'hello');
          expect(
            obj.nullableHello(false)!.toDartString(releaseOriginal: true),
            'hello',
          );
          expect(obj.nullableHello(true), null);
          expect(
            obj
                .classGenericEcho('hello'.toJString()..releasedBy(arena))
                .toDartString(releaseOriginal: true),
            'hello',
          );
          expect(
            obj
                .classGenericNullableEcho(
                    'hello'.toJString()..releasedBy(arena))!
                .toDartString(releaseOriginal: true),
            'hello',
          );
          expect(obj.classGenericNullableEcho(null), null);
          expect(
            obj
                .methodGenericEcho(
                  'hello'.toJString()..releasedBy(arena),
                  V: JString.type,
                )
                .toDartString(releaseOriginal: true),
            'hello',
          );
          expect(
            obj
                .methodGenericNullableEcho(
                  'hello'.toJString()..releasedBy(arena),
                  V: JString.nullableType,
                )!
                .toDartString(releaseOriginal: true),
            'hello',
          );
          expect(
            obj.methodGenericNullableEcho(null, V: JString.nullableType),
            null,
          );
          expect(
            obj
                .stringListOf('hello'.toJString()..releasedBy(arena))[0]
                .toDartString(releaseOriginal: true),
            'hello',
          );
          expect(
            obj
                .nullableListOf('hello'.toJString()..releasedBy(arena))[0]!
                .toDartString(releaseOriginal: true),
            'hello',
          );
          expect(obj.nullableListOf(null)[0], null);
          expect(
            obj
                .classGenericListOf('hello'.toJString()..releasedBy(arena))[0]
                .toDartString(releaseOriginal: true),
            'hello',
          );
          expect(
            obj
                .classGenericNullableListOf(
                    'hello'.toJString()..releasedBy(arena))[0]!
                .toDartString(releaseOriginal: true),
            'hello',
          );
          expect(obj.classGenericNullableListOf(null)[0], null);
          expect(
            obj
                .methodGenericListOf('hello'.toJString()..releasedBy(arena))[0]
                .toDartString(releaseOriginal: true),
            'hello',
          );
          expect(
            obj
                .methodGenericNullableListOf(
                  'hello'.toJString()..releasedBy(arena),
                  V: JString.nullableType,
                )[0]!
                .toDartString(releaseOriginal: true),
            'hello',
          );
          expect(
            obj.methodGenericNullableListOf(null, V: JString.nullableType)[0],
            null,
          );
          expect(
            obj
                .firstOf(['hello'.toJString()..releasedBy(arena)]
                    .toJList(JString.type))
                .toDartString(releaseOriginal: true),
            'hello',
          );
          expect(
            obj
                .firstOfNullable(['hello'.toJString()..releasedBy(arena), null]
                    .toJList(JString.nullableType))!
                .toDartString(releaseOriginal: true),
            'hello',
          );
          expect(
            obj.firstOfNullable([null, 'hello'.toJString()..releasedBy(arena)]
                .toJList(JString.nullableType)),
            null,
          );
          expect(
            obj
                .classGenericFirstOf(['hello'.toJString()..releasedBy(arena)]
                    .toJList(JString.type))
                .toDartString(releaseOriginal: true),
            'hello',
          );
          expect(
            obj
                .classGenericFirstOfNullable([
                  'hello'.toJString()..releasedBy(arena),
                  null,
                ].toJList(JString.nullableType))!
                .toDartString(releaseOriginal: true),
            'hello',
          );
          expect(
            obj.classGenericFirstOfNullable([
              null,
              'hello'.toJString()..releasedBy(arena),
            ].toJList(JString.nullableType)),
            null,
          );
          expect(
            obj
                .methodGenericFirstOf(['hello'.toJString()..releasedBy(arena)]
                    .toJList(JString.type))
                .toDartString(releaseOriginal: true),
            'hello',
          );
          expect(
            obj
                .methodGenericFirstOfNullable([
                  'hello'.toJString()..releasedBy(arena),
                  null,
                ].toJList(JString.nullableType))!
                .toDartString(releaseOriginal: true),
            'hello',
          );
          expect(
            obj.methodGenericFirstOfNullable([
              null,
              'hello'.toJString()..releasedBy(arena),
            ].toJList(JString.nullableType)),
            null,
          );
        });
      });
      test('Inner class', () {
        using((arena) {
          final obj = testObject(arena);
          final innerObj = Nullability$InnerClass<JString?, JString, JInteger>(
              obj,
              V: JInteger.type);
          expect(
            innerObj.f,
            isA<void Function(JString?, JString, JInteger)>(),
          );
        });
      });
    });
  });
}
