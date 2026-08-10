// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:jni_util/jni_util.dart' as jni_util;
import 'package:test/test.dart';

void main() {
  test('jni_util.javaHome', () {
    final javaHome = jni_util.javaHome;
    if (javaHome != null) {
      expect(Directory.fromUri(javaHome).existsSync(), isTrue);
    }
  });

  test('jni_util.resolveJavaExecutable', () {
    final javaExeName = Platform.isWindows ? 'java.exe' : 'java';
    final javaExe = jni_util.resolveJavaExecutable(javaExeName);
    if (jni_util.javaHome != null) {
      expect(File(javaExe).existsSync(), isTrue);
    }
    const winPath = r'D:\a\native\native\pkgs\jni\java\gradlew.bat';
    expect(jni_util.resolveJavaExecutable(winPath), equals(winPath));
    const unixPath = '/a/native/native/pkgs/jni/java/gradlew';
    expect(jni_util.resolveJavaExecutable(unixPath), equals(unixPath));
  });
}
