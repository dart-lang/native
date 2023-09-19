// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:test/test.dart';
import 'package:jni/jni.dart';

import 'test_util/test_util.dart';

void main() {
  if (!Platform.isAndroid) {
    checkDylibIsUpToDate();
    bool caught = false;
    try {
      // If library does not exist, a helpful error should be thrown.
      // we can't test this directly because `test` schedules functions
      // asynchronously.
      Jni.spawn(dylibDir: "wrong_dir");
    } on HelperNotFoundError catch (_) {
      // stderr.write("\n$_\n");
      Jni.spawnIfNotExists(
          dylibDir: "build/jni_libs", jvmOptions: ["-Xmx128m"]);
      caught = true;
    } on JniVmExistsError {
      stderr.writeln('cannot verify: HelperNotFoundError thrown');
    }
    if (!caught) {
      throw "Expected HelperNotFoundException\n"
          "Read exception_test.dart for details.";
    }
  }
  run(testRunner: test);
}

void run({required TestRunnerCallback testRunner}) {
  testRunner("double free throws exception", () {
    final r = Jni.newInstance("java/util/Random", "()V", []);
    r.release();
    expect(r.release, throwsA(isA<DoubleReleaseError>()));
  });

  testRunner("Use after free throws exception", () {
    final r = Jni.newInstance("java/util/Random", "()V", []);
    r.release();
    expect(() => r.callMethodByName<int>("nextInt", "(I)I", [JValueInt(256)]),
        throwsA(isA<UseAfterReleaseError>()));
  });

  testRunner("void fieldType throws exception", () {
    final r = Jni.newInstance("java/util/Random", "()V", []);
    expect(() => r.getField<void>(nullptr, JniCallType.voidType),
        throwsArgumentError);
    expect(() => r.getStaticField<void>(nullptr, JniCallType.voidType),
        throwsArgumentError);
  });

  testRunner("Wrong callType throws error", () {
    final r = Jni.newInstance("java/util/Random", "()V", []);
    expect(
        () => r.callMethodByName<int>(
            "nextInt", "(I)I", [JValueInt(256)], JniCallType.doubleType),
        throwsA(isA<InvalidCallTypeError>()));
  });

  testRunner("An exception in JNI throws JniException in Dart", () {
    final r = Jni.newInstance("java/util/Random", "()V", []);
    expect(() => r.callMethodByName<int>("nextInt", "(I)I", [JValueInt(-1)]),
        throwsA(isA<JniException>()));
  });
}
