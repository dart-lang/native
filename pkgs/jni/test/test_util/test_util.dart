// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:jni/jni.dart';
import 'package:jni/src/build_util/build_util.dart';

typedef TestCaseCallback = void Function();
typedef TestRunnerCallback = void
    Function(String description, TestCaseCallback test, {Object? skip});

final currentDir = Directory.current.uri;
final dllSuffix =
    Platform.isWindows ? "dll" : (Platform.isMacOS ? "dylib" : "so");
final dllPrefix = Platform.isWindows ? '' : 'lib';
final dllPath =
    currentDir.resolve("build/jni_libs/${dllPrefix}dartjni.$dllSuffix");
final srcPath = currentDir.resolve("src/");

/// Fail if dartjni dll is stale.
void checkDylibIsUpToDate() {
  final dllFile = File.fromUri(dllPath);
  if (needsBuild(File.fromUri(dllPath), Directory.fromUri(srcPath))) {
    final cause = dllFile.existsSync()
        ? 'not up-to-date with source modifications'
        : 'not built';
    var message = '\nFatal: dartjni.$dllSuffix is $cause. Please run '
        '`dart run jni:setup` and try again.';
    if (stderr.supportsAnsiEscapes) {
      message = ansiRed + message + ansiDefault;
    }
    stderr.writeln(message);
    exit(1);
  }
}

void spawnJvm() {
  Jni.spawnIfNotExists(
      dylibDir: "build/jni_libs", jvmOptions: ["-Xmx128m", "-Xcheck:jni"]);
}
