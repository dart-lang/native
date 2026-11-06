// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

import 'package:jni/jni.dart';
import 'package:test/test.dart';

import 'test_util/test_util.dart';

void main() {
  if (!Platform.isAndroid) {
    checkDylibIsUpToDate();
    var caught = false;
    try {
      // If library does not exist, a helpful error should be thrown.
      // we can't test this directly because `test` schedules functions
      // asynchronously.
      Jni.spawn(dylibDir: 'wrong_dir');
      // ignore: avoid_catching_errors
    } on HelperNotFoundError catch (_) {
      // stderr.write("\n$_\n");
      spawnJvm();
      caught = true;
      // ignore: avoid_catching_errors
    } on JniVmExistsError {
      stderr.writeln('cannot verify: HelperNotFoundError thrown');
    }
    if (!caught) {
      stderr.writeln('Expected HelperNotFoundException\n'
          'Read exception_test.dart for details.');
      exit(1);
    }
  }
  run(testRunner: test);
}

void run({required TestRunnerCallback testRunner}) {
  JObject newRandom(JClass randomClass) {
    return randomClass.constructorId('()V').call<JObject>(randomClass, []);
  }

  testRunner('double free throws exception', () {
    final rc = JClass.forName('java/util/Random');
    final r = newRandom(rc);
    r.release();
    expect(r.release, throwsA(isA<DoubleReleaseError>()));
  });

  testRunner('Use after free throws exception', () {
    final rc = JClass.forName('java/util/Random');
    final r = newRandom(rc);
    r.release();
    expect(
        () => rc
            .instanceMethodId('nextInt', '(I)I')
            .call(r, jint.type, [JValueInt(256)]),
        throwsA(isA<UseAfterReleaseError>()));
  });

  testRunner('An exception in JNI throws JThrowable in Dart', () {
    final rc = JClass.forName('java/util/Random');
    final r = newRandom(rc);
    expect(
        () => rc
            .instanceMethodId('nextInt', '(I)I')
            .call(r, jint.type, [JValueInt(-1)]),
        throwsA(isA<JThrowable>()));
  });

  testRunner('Jni.throwException rejects nullptr with JNullError', () async {
    await expectLater(
      Isolate.run(() => Jni.throwException(nullptr)),
      throwsA(isA<JNullError>()),
    );
    expect(() => Jni.throwException(nullptr), throwsA(isA<JNullError>()));
  });

  testRunner(
    'Jni.throwException works on a fresh unattached isolate thread and on '
    'java.lang.Error',
    () async {
      final errAddr = using((arena) {
        final errClass = JClass.forName('java/lang/AssertionError')
          ..releasedBy(arena);
        final msg = 'boom'.toJString()..releasedBy(arena);
        final err = errClass.constructorId('(Ljava/lang/Object;)V')(
          errClass,
          [msg],
        )..releasedBy(arena);
        return Jni.env.NewGlobalRef(err.reference.pointer).address;
      });
      var released = false;
      addTearDown(() {
        if (!released) {
          Jni.env.DeleteGlobalRef(Pointer.fromAddress(errAddr));
        }
      });
      final (message, stackTrace) = await Isolate.run(() {
        try {
          Jni.throwException(Pointer.fromAddress(errAddr));
        } on JThrowable catch (e) {
          e.release();
          return (e.message, e.javaStackTrace);
        }
        throw StateError('Expected JThrowable');
      });
      released = true;
      expect(message, allOf(contains('AssertionError'), contains('boom')));
      expect(stackTrace, contains('AssertionError'));
    },
  );
}
