// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

/// The Java Home path used by Flutter using `flutter config --machine`.
///
/// null if detection fails (eg Java is not installed, or is not set up for
/// Android development).
final javaHome = () {
  try {
    final result =
        Process.runSync('flutter', ['config', '--machine'], runInShell: true);
    if (result.exitCode != 0) {
      return null;
    }
    final json = jsonDecode(result.stdout as String) as Map<dynamic, dynamic>;
    final jdkDir = json['jdk-dir'];
    if (jdkDir is String && jdkDir.isNotEmpty) {
      final dir = Directory(jdkDir);
      if (dir.existsSync()) {
        return dir.uri;
      }
    }
  } catch (_) {}
  return null;
}();

/// A copy of `Platform.environment` with `JAVA_HOME` set to Flutter's JDK (if
/// detected) and `JAVA_HOME/bin` prepended to `PATH`.
final javaEnvironment = () {
  final env = Map<String, String>.from(Platform.environment);
  final resolvedJavaHome = javaHome;
  if (resolvedJavaHome != null) {
    final homePath = resolvedJavaHome.toFilePath();
    final binPath = p.join(homePath, 'bin');
    final pathSeparator = Platform.isWindows ? ';' : ':';
    final oldPath = env['PATH'] ?? '';
    env['JAVA_HOME'] = homePath;
    env['PATH'] = oldPath.isEmpty ? binPath : '$binPath$pathSeparator$oldPath';
  }
  return env;
}();

/// Resolves executable names like `java`, `javac`, or `javap` to their full
/// path inside `JAVA_HOME/bin` if Flutter's Java Home is detected.
String resolveJavaExecutable(String exec) {
  final home = javaHome;
  if (home != null) {
    final candidate = p.join(home.toFilePath(), 'bin', exec);
    if (File(candidate).existsSync()) {
      return candidate;
    }
  }
  return exec;
}
