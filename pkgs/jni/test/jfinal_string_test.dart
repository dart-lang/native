// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:jni/jni.dart';
import 'package:jni/src/jfinal_string.dart';
import 'package:test/test.dart';

import 'test_util/test_util.dart';

void main() {
  // Don't forget to initialize JNI.
  if (!Platform.isAndroid) {
    checkDylibIsUpToDate();
    Jni.spawnIfNotExists(dylibDir: "build/jni_libs", jvmOptions: ["-Xmx128m"]);
  }
  run(testRunner: test);
}

void run({required TestRunnerCallback testRunner}) {
  testRunner('JFinalString', () {
    const string = 'abc';
    var referenceFetchedCount = 0;
    final finalString = JFinalString(
      () {
        ++referenceFetchedCount;
        return string.toJString().reference;
      },
      string,
    );
    expect(finalString.toDartString(), string);
    expect(referenceFetchedCount, 0);
    expect(finalString.reference, isNot(nullptr));
    expect(referenceFetchedCount, 1);
    finalString.reference;
    expect(referenceFetchedCount, 1);
    expect(finalString.toDartString(releaseOriginal: true), string);
    expect(() => finalString.reference, throwsA(isA<UseAfterReleaseError>()));
    expect(finalString.release, throwsA(isA<DoubleReleaseError>()));
  });
}
