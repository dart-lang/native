// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:jnigen/src/tools/android_sdk_tools.dart';
import 'package:test/test.dart';

void main() {
  test('Detect Flutter Java Home', () {
    final javaHome = AndroidSdkTools.detectFlutterJavaHome();
    final isCI = Platform.environment['GITHUB_ACTIONS'] == 'true';

    if (isCI) {
      expect(javaHome, isNotNull,
          reason: 'Java Home should be detectable on GitHub Actions CI.');
    }

    if (javaHome != null) {
      final dir = Directory.fromUri(javaHome);
      expect(dir.existsSync(), isTrue,
          reason: 'Detected Java Home directory should exist.');

      final javaExeName = Platform.isWindows ? 'java.exe' : 'java';
      final javaExe = File.fromUri(javaHome.resolve('bin/$javaExeName'));
      expect(javaExe.existsSync(), isTrue,
          reason: 'java executable should exist inside bin/ of Java Home.');
    } else {
      print(
          'Java Home was not detected (this is allowed if Android Studio/JDK is not configured in Flutter).');
    }
  });
}
