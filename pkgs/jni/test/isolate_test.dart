// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'dart:isolate';

import 'package:jni/jni.dart';
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
  testRunner("Sharing JObject across isolates", () async {
    final foo = 'foo'.toJString();
    final result = await Isolate.run(() => foo.toDartString());
    expect(result, 'foo');
  });

  testRunner("Creating an object on both two different isolates", () async {
    // This also means that [Jni._ensureInitialized()] has been called in both
    // isolates.
    final foo = 'foo'.toJString();
    final bar = await Isolate.run(() {
      return 'bar'.toJString();
    });
    expect(foo.toDartString(), 'foo');
    expect(bar.toDartString(), 'bar');
  });
}
