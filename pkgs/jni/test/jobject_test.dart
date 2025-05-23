// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

import 'package:jni/jni.dart';
import 'package:test/test.dart';

import 'test_util/test_util.dart';

const maxLongInJava = 9223372036854775807;

void main() {
  // Don't forget to initialize JNI.
  if (!Platform.isAndroid) {
    checkDylibIsUpToDate();
    spawnJvm();
  }
  run(testRunner: test);
}

void run({required TestRunnerCallback testRunner}) {
  // The API based on JniEnv is intended to closely mimic C API of JNI,
  // And thus can be too verbose for simple experimenting and one-off uses
  // JClass API provides an easier way to perform some common operations.
  //
  // However, if binding generation using jnigen is possible, that should be
  // the first choice.
  testRunner('Long.intValue() using JClass', () {
    // JClass wraps a local class reference, and
    // provides convenience functions.
    final longClass = JClass.forName('java/lang/Long');

    // Looks for a constructor with given signature.
    // equivalently you can lookup a method with name <init>
    final longCtor = longClass.constructorId('(J)V');

    // Note that the arguments are just passed as a list.
    // Allowed argument types are primitive types, JObject and its subclasses,
    // and raw JNI references (JObject). Strings will be automatically converted
    // to JNI strings.
    final long = longCtor(longClass, JObject.type, [176]);
    final intValueMethod = longClass.instanceMethodId('intValue', '()I');
    final intValue = intValueMethod(
      long,
      jint.type,
      [],
    );
    expect(intValue, 176);

    // Release any JObject and JClass instances using `.release()` after use.
    // This is not strictly required since JNI objects / classes have
    // a [NativeFinalizer]. But deleting them after use is a good practice.
    long.release();
    longClass.release();
  });

  testRunner('call a static method using JClass APIs', () {
    final integerClass = JClass.forName('java/lang/Integer');
    final result =
        integerClass.staticMethodId('toHexString', '(I)Ljava/lang/String;')(
            integerClass, JString.type, [JValueInt(31)]);

    // If the object is supposed to be a Java string you can call
    // [toDartString] on it.
    final resultString = result.toDartString();

    // Dart string is a copy, original object can be released.
    result.release();
    expect(resultString, '1f');

    // Also don't forget to release the class.
    integerClass.release();
  });

  testRunner('Call method with null argument, expect exception', () {
    final integerClass = JClass.forName('java/lang/Integer');
    expect(
        () => integerClass.staticMethodId('parseInt', '(Ljava/lang/String;)I')(
            integerClass, jint.type, [nullptr]),
        throwsException);
    integerClass.release();
  });

  // Skip this test on Android integration test because it fails there, possibly
  // due to a CheckJNI precondition check.
  if (!Platform.isAndroid) {
    testRunner('Try to find a non-exisiting class, expect exception', () {
      expect(() => JClass.forName('java/lang/NotExists'), throwsException);
    });
  }

  testRunner('Example for using methods', () {
    final longClass = JClass.forName('java/lang/Long');
    final bitCountMethod = longClass.staticMethodId('bitCount', '(J)I');

    final randomClass = JClass.forName('java/util/Random');
    final random =
        randomClass.constructorId('()V').call(randomClass, JObject.type, []);

    final nextIntMethod = randomClass.instanceMethodId('nextInt', '(I)I');

    for (var i = 0; i < 100; i++) {
      var r = nextIntMethod(
        random,
        jint.type,
        [JValueInt(256 * 256)],
      );
      var bits = 0;
      final jbc = bitCountMethod(
        longClass,
        jint.type,
        [r],
      );
      while (r != 0) {
        bits += r % 2;
        r = (r / 2).floor();
      }
      expect(jbc, bits);
    }
    random.release();
    longClass.release();
  });

  testRunner('Static method with multiple args', () {
    final shortClass = JShort.type.jClass;
    final m = shortClass.staticMethodId('compare', '(SS)I').call(
      shortClass,
      jint.type,
      [JValueShort(1234), JValueShort(1324)],
    );
    expect(m, 1234 - 1324);
    shortClass.release();
  });

  testRunner('Get static field', () {
    final shortClass = JShort.type.jClass;
    final maxLong =
        shortClass.staticFieldId('MAX_VALUE', 'S').get(shortClass, jshort.type);
    expect(maxLong, 32767);
    shortClass.release();
  });

  testRunner('Call static method on Long', () {
    final longClass = JClass.forName('java/lang/Long');
    const n = 1223334444;
    final strFromJava = longClass
        .staticMethodId('toOctalString', '(J)Ljava/lang/String;')
        .call(longClass, JString.type, [n]);
    expect(strFromJava.toDartString(releaseOriginal: true), n.toRadixString(8));
    longClass.release();
  });

  testRunner('Passing strings in arguments', () {
    final byteClass = JByte.type.jClass;
    final parseByte =
        byteClass.staticMethodId('parseByte', '(Ljava/lang/String;)B');
    final twelve = parseByte(byteClass, const jbyteType(), ['12'.toJString()]);
    expect(twelve, 12);
    byteClass.release();
  });

  // You can use() method on JObject for using once and deleting.
  testRunner('use() method', () {
    final randomInt = JClass.forName('java/util/Random').use((randomClass) {
      return randomClass
          .constructorId('()V')
          .call(randomClass, JObject.type, []).use((random) {
        return randomClass
            .instanceMethodId('nextInt', '(I)I')
            .call(random, jint.type, [JValueInt(15)]);
      });
    });
    expect(randomInt, lessThan(15));
    const JObject? nullableJObject = null;
    expect(nullableJObject.use((_) => 'foo'), equals('foo'));
  });

  // The JObject and JClass have NativeFinalizer. However, it's possible to
  // explicitly use `Arena`.
  testRunner('Using arena', () {
    final objects = <JObject>[];
    using((arena) {
      final randomClass = JClass.forName('java/util/Random')..releasedBy(arena);
      final constructor = randomClass.constructorId('()V');
      for (var i = 0; i < 10; i++) {
        objects
            .add(constructor(randomClass, JObject.type, [])..releasedBy(arena));
      }
    });
    for (var object in objects) {
      expect(object.isReleased, isTrue);
    }
  });

  testRunner('enums', () {
    // Don't forget to escape $ in nested type names
    final proxyTypeClass = JClass.forName('java/net/Proxy\$Type');
    final ordinal = proxyTypeClass
        .staticFieldId('HTTP', 'Ljava/net/Proxy\$Type;')
        .get(proxyTypeClass, JObject.type)
        .use(
          (http) => proxyTypeClass
              .instanceMethodId('ordinal', '()I')
              .call(http, jint.type, []),
        );
    expect(ordinal, 1);
    proxyTypeClass.release();
  });

  testRunner('casting', () {
    using((arena) {
      final str = 'hello'.toJString()..releasedBy(arena);
      final obj = str.as(JObject.type)..releasedBy(arena);
      final backToStr = obj.as(JString.type);
      expect(backToStr.toDartString(), str.toDartString());
      final _ = backToStr.as(JObject.type, releaseOriginal: true)
        ..releasedBy(arena);
      expect(backToStr.toDartString, throwsA(isA<UseAfterReleaseError>()));
      expect(backToStr.release, throwsA(isA<DoubleReleaseError>()));
    });
  });

  testRunner('Isolate', () async {
    final receivePort = ReceivePort();
    await Isolate.spawn((sendPort) {
      final randomClass = JClass.forName('java/util/Random');
      final random =
          randomClass.constructorId('()V').call(randomClass, JObject.type, []);
      final result = randomClass
          .instanceMethodId('nextInt', '(I)I')
          .call(random, jint.type, [256]);
      random.release();
      randomClass.release();
      // A workaround for `--pause-isolates-on-exit`. Otherwise getting test
      // with coverage pauses indefinitely here.
      // https://github.com/dart-lang/coverage/issues/472
      sendPort.send(result);
      Isolate.current.kill();
    }, receivePort.sendPort);
    final random = await receivePort.first as int;

    expect(random, greaterThanOrEqualTo(0));
    expect(random, lessThan(256));
  });

  testRunner('Methods rethrow exceptions in Java as JniException', () {
    expect(
      () {
        final integerClass = JInteger.type.jClass;
        return JClass.forName('java/lang/Integer')
            .staticMethodId('parseInt', '(Ljava/lang/String;)I')
            .call(integerClass, jint.type, ['X'.toJString()]);
      },
      throwsA(isA<JniException>()),
    );
  });

  testRunner('Passing long integer values to JNI', () {
    final longClass = JLong.type.jClass;
    final maxLongStr = longClass
        .staticMethodId(
      'toString',
      '(J)Ljava/lang/String;',
    )
        .call(longClass, JString.type, [maxLongInJava]);
    expect(maxLongStr.toDartString(), '$maxLongInJava');
    longClass.release();
    maxLongStr.release();
  });

  testRunner('Returning long integers from JNI', () {
    final longClass = JLong.type.jClass;
    final maxLong =
        longClass.staticFieldId('MAX_VALUE', 'J').get(longClass, jlong.type);
    expect(maxLong, maxLongInJava);
  });

  testRunner('isA returns true', () {
    final long = JLong(1);
    expect(long.isA(JLong.type), isTrue);
    expect(long.isA(JLong.nullableType), isTrue);
    expect(long.isA(JNumber.type), isTrue);
    expect(long.isA(JNumber.nullableType), isTrue);
    expect(long.isA(JObject.type), isTrue);
    expect(long.isA(JObject.nullableType), isTrue);
  });

  testRunner('isA returns false', () {
    final long = JLong(1);
    expect(long.isA(JInteger.type), isFalse);
    expect(long.isA(JInteger.nullableType), isFalse);
    expect(long.isA(JString.type), isFalse);
    expect(long.isA(JString.nullableType), isFalse);
  });

  testRunner('Casting correctly succeeds', () {
    final long = JLong(1);
    final long2 = long.as(JLong.type, releaseOriginal: true);
    expect(long2.longValue(releaseOriginal: true), 1);
  });

  testRunner('Casting incorrectly fails', () {
    final long = JLong(1);
    expect(
      () => long.as(JInteger.type, releaseOriginal: true),
      throwsA(isA<CastError>().having(
          (e) => e.toString(), 'toString()', contains('java/lang/Integer'))),
    );
  });

  testRunner('Disallow construction of null JObject', () {
    expect(
      () => JObject.fromReference(jNullReference),
      throwsA(isA<JNullError>()),
    );
  });
}
