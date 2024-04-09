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
    spawnJvm();
  }
  run(testRunner: test);
}

void run({required TestRunnerCallback testRunner}) {
  testRunner("Sharing JObject across isolates",
      skip: 'Not yet available on Dart stable', () async {
    final foo = 'foo'.toJString();
    final port = ReceivePort();
    await Isolate.spawn((sendPort) {
      Jni.setDylibDir(dylibDir: 'build/jni_libs');
      sendPort.send(foo.toDartString());
      Isolate.current.kill();
    }, port.sendPort);
    final result = await port.first;
    expect(result, 'foo');
  });

  testRunner("Creating an object on two different isolates", () async {
    // This also means that [Jni._ensureInitialized()] has been called in both
    // isolates.
    'foo'.toJString();
    await Isolate.spawn((_) {
      Jni.setDylibDir(dylibDir: 'build/jni_libs');
      'bar'.toJString();
      Isolate.current.kill();
    }, null);
  });
}
