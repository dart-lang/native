// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@Tags(['load_test'])

import 'dart:io';
import 'dart:ffi';
import 'dart:math';

import 'package:ffi/ffi.dart';
import 'package:test/test.dart';

import 'package:jni/jni.dart';

import 'test_util/test_util.dart';

const maxLongInJava = 9223372036854775807;

/// Taken from
/// https://github.com/dart-lang/ffigen/blob/master/test/native_objc_test/automated_ref_count_test.dart
final executeInternalCommand = DynamicLibrary.process().lookupFunction<
    Void Function(Pointer<Char>, Pointer<Void>),
    void Function(Pointer<Char>, Pointer<Void>)>('Dart_ExecuteInternalCommand');

void doGC() {
  final gcNow = "gc-now".toNativeUtf8();
  executeInternalCommand(gcNow.cast(), nullptr);
  calloc.free(gcNow);
}

void main() {
  if (!Platform.isAndroid) {
    checkDylibIsUpToDate();
    spawnJvm();
  }
  run(testRunner: test);
}

const k4 = 4 * 1024;
const k64 = 64 * 1024;
const k256 = 256 * 1024;

const secureRandomSeedBound = 4294967296;

final random = Random.secure();

final randomClass = JClass.forName('java/util/Random');
JObject newRandom() => randomClass.constructorId('(J)V').call(
    randomClass, const JObjectType(), [random.nextInt(secureRandomSeedBound)]);

void run({required TestRunnerCallback testRunner}) {
  testRunner('Test 4K refs can be created in a row', () {
    final list = <JObject>[];
    for (int i = 0; i < k4; i++) {
      list.add(newRandom());
    }
    for (final jobject in list) {
      jobject.release();
    }
  });

  testRunner('Create and release 256K references in a loop using arena', () {
    for (int i = 0; i < k256; i++) {
      using((arena) {
        final random = newRandom()..releasedBy(arena);
        // The actual expect here does not matter. I am just being paranoid
        // against assigning to `_` because compiler may optimize it. (It has
        // side effect of calling FFI but still.)
        expect(random.reference.pointer, isNot(nullptr));
      });
    }
  });

  testRunner('Create and release 256K references in a loop (explicit release)',
      () {
    for (int i = 0; i < k256; i++) {
      final random = newRandom();
      expect(random.reference.pointer, isNot(nullptr));
      random.release();
    }
  });

  testRunner('Create and release 64K references, in batches of 256', () {
    for (int i = 0; i < 64 * 4; i++) {
      using((arena) {
        for (int i = 0; i < 256; i++) {
          final r = newRandom()..releasedBy(arena);
          expect(r.reference.pointer, isNot(nullptr));
        }
      });
    }
  });

  // We don't have a direct way to check if something creates JNI references.
  // So we are checking if we can run this for large number of times.
  testRunner('Verify a call returning primitive can be run any times', () {
    final random = newRandom();
    final nextInt = randomClass.instanceMethodId('nextInt', '()I');
    for (int i = 0; i < k256; i++) {
      final rInt = nextInt(random, const jintType(), []);
      expect(rInt, isA<int>());
    }
  });

  void testFinalizer() {
    testRunner('Finalizer correctly removes the references', () {
      // We are checking if we can run this for large number of times.
      // More than the number of available global references.
      for (var i = 0; i < k256; ++i) {
        final random = newRandom();
        expect(random.reference.pointer, isNot(nullptr));
        if (i % k4 == 0) {
          doGC();
        }
      }
    });
  }

  void testRefValidityAfterGC(int delayInSeconds) {
    testRunner('Validate reference after GC & ${delayInSeconds}s sleep', () {
      final random = newRandom();
      final nextInt = randomClass.instanceMethodId('nextInt', '()I');
      doGC();
      sleep(Duration(seconds: delayInSeconds));
      expect(
        nextInt(random, const jintType(), []),
        isA<int>(),
      );
      expect(
        Jni.env.GetObjectRefType(random.reference.pointer),
        equals(JObjectRefType.JNIGlobalRefType),
      );
    });
  }

  // Dart_ExecuteInternalCommand doesn't exist in Android.
  if (!Platform.isAndroid) {
    testFinalizer();
    testRefValidityAfterGC(1);
    testRefValidityAfterGC(10);
  }
}
