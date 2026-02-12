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
        final noDelayNullableHello =
            await suspendFun.nullableHelloWithoutDelay(false);
        expect(noDelayNullableHello!.toDartString(releaseOriginal: true),
            'Hello!');
        final nullableHello = await suspendFun.nullableHello(false);
        expect(nullableHello!.toDartString(releaseOriginal: true), 'Hello!');
        final noDelayNull = await suspendFun.nullableHelloWithoutDelay(true);
        expect(noDelayNull, null);
        final asyncNull = await suspendFun.nullableHello(true);
        expect(asyncNull, null);

        expect(suspendFun.getResult(), 0);
        final voidFuture = suspendFun.noReturn();
        expect(voidFuture, isA<Future<void>>());
        expect(voidFuture, isNot(isA<Future<JObject>>()));
        await voidFuture;
        expect(suspendFun.getResult(), 123);
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

    group('Interface with suspend functions', () {
      test('return immediately', () async {
        var result = 0;
        final itf = SuspendInterface.implement($SuspendInterface(
          sayHello: () async => JString.fromString('Hello'),
          sayHello$1: (JString name) async =>
              JString.fromString('Hello ${name.toDartString()}'),
          nullableHello: (bool returnNull) async =>
              returnNull ? null : JString.fromString('Hello'),
          sayInt: () async => JInteger(123),
          sayInt$1: (JInteger value) async => JInteger(10 * value.intValue()),
          nullableInt: (bool returnNull) async =>
              returnNull ? null : JInteger(123),
          noReturn: () async => result = 123,
        ));

        expect((await itf.sayHello()).toDartString(), 'Hello');
        expect((await itf.sayHello$1(JString.fromString('Bob'))).toDartString(),
            'Hello Bob');
        expect((await itf.nullableHello(false))?.toDartString(), 'Hello');
        expect(await itf.nullableHello(true), null);
        expect((await itf.sayInt()).intValue(), 123);
        expect((await itf.sayInt$1(JInteger(456))).intValue(), 4560);
        expect((await itf.nullableInt(false))?.intValue(), 123);
        expect(await itf.nullableInt(true), null);
        await itf.noReturn();
        expect(result, 123);

        expect(
            (await consumeOnSameThread(itf)).toDartString(),
            '''
Hello
Hello Alice
Hello
123
7890
123
kotlin.Unit
'''
                .trim());
        expect(
            (await consumeOnAnotherThread(itf)).toDartString(),
            '''
Hello
Hello Alice
Hello
123
7890
123
kotlin.Unit
'''
                .trim());
      });

      test('return delayed', () async {
        var result = 0;
        final itf = SuspendInterface.implement($SuspendInterface(
          sayHello: () async {
            await Future<void>.delayed(const Duration(milliseconds: 100));
            return JString.fromString('Hello');
          },
          sayHello$1: (JString name) async {
            await Future<void>.delayed(const Duration(milliseconds: 100));
            return JString.fromString('Hello ${name.toDartString()}');
          },
          nullableHello: (bool returnNull) async {
            await Future<void>.delayed(const Duration(milliseconds: 100));
            return returnNull ? null : JString.fromString('Hello');
          },
          sayInt: () async {
            await Future<void>.delayed(const Duration(milliseconds: 100));
            return JInteger(123);
          },
          sayInt$1: (JInteger value) async {
            await Future<void>.delayed(const Duration(milliseconds: 100));
            return JInteger(10 * value.intValue());
          },
          nullableInt: (bool returnNull) async {
            await Future<void>.delayed(const Duration(milliseconds: 100));
            return returnNull ? null : JInteger(123);
          },
          noReturn: () async {
            await Future<void>.delayed(const Duration(milliseconds: 100));
            result = 123;
          },
        ));

        expect((await itf.sayHello()).toDartString(), 'Hello');
        expect((await itf.sayHello$1(JString.fromString('Bob'))).toDartString(),
            'Hello Bob');
        expect((await itf.nullableHello(false))?.toDartString(), 'Hello');
        expect(await itf.nullableHello(true), null);
        expect((await itf.sayInt()).intValue(), 123);
        expect((await itf.sayInt$1(JInteger(456))).intValue(), 4560);
        expect((await itf.nullableInt(false))?.intValue(), 123);
        expect(await itf.nullableInt(true), null);
        await itf.noReturn();
        expect(result, 123);

        expect(
            (await consumeOnSameThread(itf)).toDartString(),
            '''
Hello
Hello Alice
Hello
123
7890
123
kotlin.Unit
'''
                .trim());
        expect(
            (await consumeOnAnotherThread(itf)).toDartString(),
            '''
Hello
Hello Alice
Hello
123
7890
123
kotlin.Unit
'''
                .trim());
      });

      test('throw immediately', () async {
        final itf = SuspendInterface.implement($SuspendInterface(
          sayHello: () async => throw Exception(),
          sayHello$1: (JString name) async => throw Exception(),
          nullableHello: (bool returnNull) async => throw Exception(),
          sayInt: () async => throw Exception(),
          sayInt$1: (JInteger value) async => throw Exception(),
          nullableInt: (bool returnNull) async => throw Exception(),
          noReturn: () async => throw Exception(),
        ));

        await expectLater(itf.sayHello(), throwsA(isA<JniException>()));
        await expectLater(itf.sayHello$1(JString.fromString('Bob')),
            throwsA(isA<JniException>()));
        await expectLater(
            itf.nullableHello(false), throwsA(isA<JniException>()));
        await expectLater(itf.sayInt(), throwsA(isA<JniException>()));
        await expectLater(
            itf.sayInt$1(JInteger(456)), throwsA(isA<JniException>()));
        await expectLater(itf.nullableInt(false), throwsA(isA<JniException>()));
        await expectLater(itf.noReturn(), throwsA(isA<JniException>()));

        await expectLater(
            consumeOnSameThread(itf), throwsA(isA<JniException>()));
        await expectLater(
            consumeOnAnotherThread(itf), throwsA(isA<JniException>()));
      });

      test('throw delayed', () async {
        final itf = SuspendInterface.implement($SuspendInterface(
          sayHello: () async {
            await Future<void>.delayed(const Duration(milliseconds: 100));
            throw Exception();
          },
          sayHello$1: (JString name) async {
            await Future<void>.delayed(const Duration(milliseconds: 100));
            throw Exception();
          },
          nullableHello: (bool returnNull) async {
            await Future<void>.delayed(const Duration(milliseconds: 100));
            throw Exception();
          },
          sayInt: () async {
            await Future<void>.delayed(const Duration(milliseconds: 100));
            throw Exception();
          },
          sayInt$1: (JInteger value) async {
            await Future<void>.delayed(const Duration(milliseconds: 100));
            throw Exception();
          },
          nullableInt: (bool returnNull) async {
            await Future<void>.delayed(const Duration(milliseconds: 100));
            throw Exception();
          },
          noReturn: () async {
            await Future<void>.delayed(const Duration(milliseconds: 100));
            throw Exception();
          },
        ));

        await expectLater(itf.sayHello(), throwsA(isA<JniException>()));
        await expectLater(itf.sayHello$1(JString.fromString('Bob')),
            throwsA(isA<JniException>()));
        await expectLater(
            itf.nullableHello(false), throwsA(isA<JniException>()));
        await expectLater(itf.sayInt(), throwsA(isA<JniException>()));
        await expectLater(
            itf.sayInt$1(JInteger(456)), throwsA(isA<JniException>()));
        await expectLater(itf.nullableInt(false), throwsA(isA<JniException>()));
        await expectLater(itf.noReturn(), throwsA(isA<JniException>()));

        await expectLater(
            consumeOnSameThread(itf), throwsA(isA<JniException>()));
        await expectLater(
            consumeOnAnotherThread(itf), throwsA(isA<JniException>()));
      });
    });

    group('Default parameters', () {
      test('DefaultParams - no-arg constructor', () {
        using((arena) {
          final obj = DefaultParams.new$1()..releasedBy(arena);
          expect(
              obj.greet().toDartString(releaseOriginal: true), 'x=42, y=hello');
        });
      });

      test('DefaultParams - constructor with explicit arguments', () {
        using((arena) {
          final obj = DefaultParams(100, 'world'.toJString()..releasedBy(arena))
            ..releasedBy(arena);
          expect(obj.greet().toDartString(releaseOriginal: true),
              'x=100, y=world');
        });
      });

      test('MixedParams - required and optional parameters', () {
        using((arena) {
          // Both parameters provided
          final obj = MixedParams('test'.toJString()..releasedBy(arena), 200)
            ..releasedBy(arena);
          expect(obj.describe().toDartString(releaseOriginal: true),
              'required=test, optional=200');
        });
      });

      test('AllDefaults - no-arg constructor', () {
        using((arena) {
          final obj = AllDefaults.new$1()..releasedBy(arena);
          expect(obj.summary().toDartString(releaseOriginal: true),
              'a=1, b=two, c=true');
        });
      });

      test('AllDefaults - constructor with explicit arguments', () {
        using((arena) {
          final obj = AllDefaults(
            42,
            'forty-two'.toJString()..releasedBy(arena),
            false,
          )..releasedBy(arena);
          expect(obj.summary().toDartString(releaseOriginal: true),
              'a=42, b=forty-two, c=false');
        });
      });

      test('No DefaultConstructorMarker in generated API', () {
        // This is a compile-time check - if DefaultConstructorMarker
        // parameter is exposed in constructors that should use defaults,
        // it would require passing it explicitly, breaking the API.
        // By successfully instantiating these classes using simple constructors
        // we prove the synthetic parameter is correctly handled internally.
        using((arena) {
          DefaultParams.new$1().releasedBy(arena);
          // ignore: avoid_single_cascade_in_expression_statements
          MixedParams('test'.toJString()..releasedBy(arena), 123)
            ..releasedBy(arena);
          AllDefaults.new$1().releasedBy(arena);
        });
      });
    });
  });
}
