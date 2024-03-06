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
    Jni.spawnIfNotExists(dylibDir: "build/jni_libs", jvmOptions: ["-Xmx128m"]);
  }
  run(testRunner: test);
}

const k4 = 4 * 1024;
const k64 = 64 * 1024;
const k256 = 256 * 1024;

const secureRandomSeedBound = 4294967296;

JObject getSystemOut() => Jni.retrieveStaticField<JObject>(
      'System',
      'out',
      'Ljava/io/PrintStream;',
    );

final random = Random.secure();

JObject newRandom() => Jni.newInstance(
      "java/util/Random",
      "(J)V",
      [random.nextInt(secureRandomSeedBound)],
    );

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
        expect(random.reference, isNot(nullptr));
      });
    }
  });

  testRunner('Create and release 256K references in a loop (explicit release)',
      () {
    for (int i = 0; i < k256; i++) {
      final random = newRandom();
      expect(random.reference, isNot(nullptr));
      random.release();
    }
  });

  testRunner('Create and release 64K references, in batches of 256', () {
    for (int i = 0; i < 64 * 4; i++) {
      using((arena) {
        for (int i = 0; i < 256; i++) {
          final r = newRandom()..releasedBy(arena);
          expect(r.reference, isNot(nullptr));
        }
      });
    }
  });

  // We don't have a direct way to check if something creates JNI references.
  // So we are checking if we can run this for large number of times.
  testRunner('Verify a call returning primitive can be run any times', () {
    final random = newRandom();
    final nextInt = random.getMethodID("nextInt", "()I");
    for (int i = 0; i < k256; i++) {
      final rInt = random.callMethod<int>(nextInt, []);
      expect(rInt, isA<int>());
    }
  });

  void testRefValidityAfterGC(int delayInSeconds) {
    testRunner('Validate reference after GC & ${delayInSeconds}s sleep', () {
      final random = newRandom();
      doGC();
      sleep(Duration(seconds: delayInSeconds));
      expect(
        random.callMethodByName<int>("nextInt", "()I", []),
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
    testRefValidityAfterGC(1);
    testRefValidityAfterGC(10);
  }
}
