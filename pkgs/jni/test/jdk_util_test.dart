// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:jni/_internal.dart' as jdk_util;
import 'package:test/test.dart';

void main() {
  test('jdk_util.javaHome', () {
    final javaHome = jdk_util.javaHome;
    if (javaHome != null) {
      expect(Directory.fromUri(javaHome).existsSync(), isTrue);
    }
  });

  test('jdk_util.resolveJavaExecutable', () {
    final javaExeName = Platform.isWindows ? 'java.exe' : 'java';
    final javaExe = jdk_util.resolveJavaExecutable(javaExeName);
    if (jdk_util.javaHome != null) {
      expect(File(javaExe).existsSync(), isTrue);
    }
  });
}
