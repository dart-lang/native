// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:jni/jni.dart';
import 'package:jni_flutter/jni_flutter.dart';
import 'package:legacy_android_test_runner/legacy_bindings.g.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('1. Type system & JType.jClass', () {
    testWidgets('isA and as on LegacyFixture', (tester) async {
      using((arena) {
        final fixture = LegacyFixture()..releasedBy(arena);
        final obj = LegacyFixture.asObject(fixture)!..releasedBy(arena);
        expect(obj.isA(LegacyFixture.type), isTrue);
        expect(obj.isA(Color.type), isFalse);
        final cast = obj.as(LegacyFixture.type)..releasedBy(arena);
        expect(cast.textValue!.toDartString(releaseOriginal: true), 'default');
      });
    });

    testWidgets('JArray(LegacyFixture.type, length)', (tester) async {
      using((arena) {
        final f0 = LegacyFixture()..releasedBy(arena);
        final f1 =
            LegacyFixture.new$1(7, 'seven'.toJString()..releasedBy(arena))
              ..releasedBy(arena);
        final arr = JArray.withLength(LegacyFixture.type, 2)..releasedBy(arena);
        arr[0] = f0;
        arr[1] = f1;
        expect(LegacyFixture.countFixtures(arr), 2);
      });
    });

    testWidgets('androidApplicationContext.as(Context.type)', (tester) async {
      using((arena) {
        final ctx = androidApplicationContext.as(
          Context.type,
          releaseOriginal: true,
        )..releasedBy(arena);
        final pkg = LegacyFixture.getPackageName(ctx)!
            .toDartString(releaseOriginal: true);
        expect(pkg, 'com.github.dart_lang.jni_legacy_android_test_runner');
      });
    });
  });

  group('2. Constructors', () {
    testWidgets('default, overloaded, and nested constructors', (tester) async {
      using((arena) {
        final def = LegacyFixture()..releasedBy(arena);
        expect(def.intValue, 0);
        expect(def.textValue!.toDartString(releaseOriginal: true), 'default');

        final custom = LegacyFixture.new$1(
          99,
          'hello'.toJString()..releasedBy(arena),
        )..releasedBy(arena);
        expect(custom.intValue, 99);
        expect(custom.textValue!.toDartString(releaseOriginal: true), 'hello');

        final nested = LegacyFixture$Nested(
          'tag1'.toJString()..releasedBy(arena),
        )..releasedBy(arena);
        expect(
          nested.describe()!.toDartString(releaseOriginal: true),
          'Nested:tag1',
        );
      });
    });
  });

  group('3. Static & instance methods', () {
    testWidgets('primitives, strings, void, nullable, getter/setter', (
      tester,
    ) async {
      using((arena) {
        expect(LegacyFixture.negate(true), isFalse);
        expect(LegacyFixture.negate(false), isTrue);
        expect(LegacyFixture.add(13, 29), 42);
        expect(LegacyFixture.multiply(2.5, 4.0), 10.0);
        expect(LegacyFixture.nextChar('A'.codeUnitAt(0)), 'B'.codeUnitAt(0));

        expect(LegacyFixture.nullableEcho(null), isNull);
        expect(
          LegacyFixture.nullableEcho(
            'hi'.toJString()..releasedBy(arena),
          )!
              .toDartString(releaseOriginal: true),
          'echo:hi',
        );

        final fixture = LegacyFixture.new$1(
          5,
          'abc'.toJString()..releasedBy(arena),
        )..releasedBy(arena);
        expect(fixture.label!.toDartString(releaseOriginal: true), 'initial');
        fixture.label = 'updated'.toJString()..releasedBy(arena);
        expect(fixture.label!.toDartString(releaseOriginal: true), 'updated');

        fixture.reset();
        expect(fixture.intValue, 0);
        expect(fixture.textValue!.toDartString(releaseOriginal: true), '');
      });
    });
  });

  group('4. Fields', () {
    testWidgets('static final, mutable static, mutable instance fields', (
      tester,
    ) async {
      using((arena) {
        expect(LegacyFixture.CONSTANT_INT, 42);
        expect(
          LegacyFixture.CONSTANT_STRING!.toDartString(releaseOriginal: true),
          'legacy',
        );

        LegacyFixture.staticCounter = 123;
        expect(LegacyFixture.staticCounter, 123);
        LegacyFixture.staticCounter = 0;

        final fixture = LegacyFixture()..releasedBy(arena);
        fixture.intValue = 77;
        fixture.textValue = 'mutated'.toJString()..releasedBy(arena);
        expect(fixture.intValue, 77);
        expect(
          fixture.textValue!.toDartString(releaseOriginal: true),
          'mutated',
        );
      });
    });
  });

  group('5. Generics', () {
    testWidgets('generic class, generic method, concrete subclass', (
      tester,
    ) async {
      using((arena) {
        final box = Box<JString>('boxed'.toJString()..releasedBy(arena))
          ..releasedBy(arena);
        expect(box.value!.toDartString(releaseOriginal: true), 'boxed');
        box.value = 'reboxed'.toJString()..releasedBy(arena);
        expect(box.value!.toDartString(releaseOriginal: true), 'reboxed');

        final echoed = LegacyFixture.identity<JString>(
          'ident'.toJString()..releasedBy(arena),
        )!
          ..releasedBy(arena);
        expect(echoed.toDartString(), 'ident');

        final strBox = StringBox.new$1('abcdef'.toJString()..releasedBy(arena))
          ..releasedBy(arena);
        expect(strBox.length(), 6);
      });
    });
  });

  group('6. Arrays, Collections & Buffers', () {
    testWidgets('int[], List, Map, Set, ByteBuffer', (tester) async {
      using((arena) {
        final ints = JIntArray(3)..releasedBy(arena);
        ints[0] = 10;
        ints[1] = 20;
        ints[2] = 30;
        expect(LegacyFixture.sumIntArray(ints), 60);

        final list = LegacyFixture.makeList(
          'x'.toJString()..releasedBy(arena),
          'y'.toJString()..releasedBy(arena),
        )!
          ..releasedBy(arena);
        final dartList = list.asDart();
        expect(dartList.length, 2);
        expect(dartList[0]!.toDartString(releaseOriginal: true), 'x');
        expect(dartList[1]!.toDartString(releaseOriginal: true), 'y');

        final map = LegacyFixture.makeMap(
          'k'.toJString()..releasedBy(arena),
          42,
        )!
          ..releasedBy(arena);
        final key = 'k'.toJString()..releasedBy(arena);
        final val = map.asDart()[key]!..releasedBy(arena);
        expect(val.intValue(), 42);

        final set = LegacyFixture.makeSet(
          'a'.toJString()..releasedBy(arena),
          'b'.toJString()..releasedBy(arena),
        )!
          ..releasedBy(arena);
        final dartSet = set.asDart();
        expect(dartSet.length, 2);
        expect(dartSet.contains('a'.toJString()..releasedBy(arena)), isTrue);

        final byteBuf = JByteBuffer.fromList(Uint8List.fromList([1, 2, 3, 4]))
          ..releasedBy(arena);
        expect(LegacyFixture.sumByteBuffer(byteBuf), 10);
      });
    });
  });

  group('7. Enums', () {
    testWidgets('enum constants, values, valueOf, and method', (tester) async {
      using((arena) {
        final red = Color.RED..releasedBy(arena);
        final green = Color.GREEN..releasedBy(arena);
        final blue = Color.BLUE..releasedBy(arena);
        expect(red.code, 1);
        expect(green.code, 2);
        expect(blue.code, 3);

        final all = Color.values()!..releasedBy(arena);
        expect(all.length, 3);

        final parsed = Color.valueOf('GREEN'.toJString()..releasedBy(arena))!
          ..releasedBy(arena);
        expect(parsed.code, 2);
      });
    });
  });

  group('8. Exceptions', () {
    testWidgets('constructor & method throw custom LegacyException', (
      tester,
    ) async {
      expect(() => LegacyFixture.new$2(true), throwsA(isA<JThrowable>()));

      try {
        using((arena) {
          LegacyFixture.throwCustom('boom'.toJString()..releasedBy(arena));
        });
        fail('Expected LegacyException');
      } on JThrowable catch (e) {
        using((arena) {
          e.releasedBy(arena);
          expect(e.isA(LegacyException.type), isTrue);
          final legacyEx = e.as(LegacyException.type)..releasedBy(arena);
          expect(legacyEx.toString(), contains('boom'));
        });
      }
    });
  });

  group('9. Interfaces & Callbacks', () {
    testWidgets('sync callback and multi-interface', (tester) async {
      using((arena) {
        final transformer = IntTransformer.implement(
          $IntTransformer(transform: (x) => x * 3),
        )..releasedBy(arena);
        expect(LegacyFixture.invokeTransformer(transformer, 14), 42);

        String? multiMsg;
        final implementer = JImplementer()..releasedBy(arena);
        IntTransformer.implementIn(
          implementer,
          $IntTransformer(transform: (x) => x + 10),
        );
        StringListener.implementIn(
          implementer,
          $StringListener(
            onEvent: (msg) {
              multiMsg = msg!.toDartString(releaseOriginal: true);
            },
          ),
        );
        final multiProxy = implementer.implement<JObject>()..releasedBy(arena);
        final result = LegacyFixture.invokeMultiInterface(
          multiProxy,
          5,
          'multi'.toJString()..releasedBy(arena),
        );
        expect(result, 15);
        expect(multiMsg, 'multi');
      });
    });

    testWidgets('async callback on background thread', (tester) async {
      final received = Completer<String>();
      final asyncListener = StringListener.implement(
        $StringListener(
          onEvent: (msg) {
            received.complete(msg!.toDartString(releaseOriginal: true));
          },
          onEvent$async: true,
        ),
      );
      try {
        using((arena) {
          LegacyFixture.invokeListenerOnBackgroundThread(
            asyncListener,
            'bg-msg'.toJString()..releasedBy(arena),
          );
        });
        expect(await received.future, 'bg-msg');
      } finally {
        asyncListener.release();
      }
    });

    testWidgets('throwing from Dart callback into Java', (tester) async {
      using((arena) {
        final callback = ThrowingCallback.implement(
          $ThrowingCallback(call: () => throw StateError('dart-boom')),
        )..releasedBy(arena);
        final caught = LegacyFixture.invokeAndCatch(
          callback,
        )!
            .toDartString(releaseOriginal: true);
        expect(caught, contains('caught:'));
        expect(caught, contains('dart-boom'));
      });
    });
  });

  group('10. Kotlin suspend functions', () {
    testWidgets('suspend value, Unit, throwing, and Dart SuspendProvider', (
      tester,
    ) async {
      final arena = Arena();
      try {
        final kt = KotlinLegacy()..releasedBy(arena);
        final name = 'World'.toJString()..releasedBy(arena);
        final greeting = await kt.greet(name);
        expect(greeting.toDartString(releaseOriginal: true), 'Hello, World!');

        await kt.doNothing();

        final errMsg = 'suspend-boom'.toJString()..releasedBy(arena);
        await expectLater(kt.failSuspend(errMsg), throwsA(isA<JThrowable>()));

        final provider = SuspendProvider.implement(
          $SuspendProvider(
            fetch: (key) async {
              final k = key.toDartString(releaseOriginal: true);
              await Future<void>.delayed(const Duration(milliseconds: 10));
              return 'val:$k'.toJString();
            },
          ),
        )..releasedBy(arena);
        final key = 'abc'.toJString()..releasedBy(arena);
        final res = await kt.callProvider(provider, key);
        expect(res.toDartString(releaseOriginal: true), 'val:abc');
      } finally {
        arena.releaseAll();
      }
    });
  });

  group('11. Reference lifecycle', () {
    testWidgets('using/Arena, manual release, releaseOriginal', (tester) async {
      final manual = LegacyFixture();
      expect(manual.isReleased, isFalse);
      manual.release();
      expect(manual.isReleased, isTrue);

      late LegacyFixture arenaFixture;
      using((arena) {
        arenaFixture = LegacyFixture()..releasedBy(arena);
        expect(arenaFixture.isReleased, isFalse);
      });
      expect(arenaFixture.isReleased, isTrue);

      final tmp = LegacyFixture();
      final raw = LegacyFixture.asObject(tmp)!;
      tmp.release();
      final cast = raw.as(LegacyFixture.type, releaseOriginal: true);
      expect(raw.isReleased, isTrue);
      expect(cast.isReleased, isFalse);
      cast.release();
      expect(cast.isReleased, isTrue);
    });
  });
}
