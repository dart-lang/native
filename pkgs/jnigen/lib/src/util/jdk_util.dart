// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../logging/logging.dart';

Uri? _detectedJavaHome;

/// Detects the Java Home path used by Flutter using `flutter config --machine`.
///
/// Returns null if detection fails or `jdk-dir` is not set.
Uri? detectFlutterJavaHome() {
  if (_detectedJavaHome != null) {
    return _detectedJavaHome;
  }
  try {
    final result =
        Process.runSync('flutter', ['config', '--machine'], runInShell: true);
    if (result.exitCode != 0) {
      log.warning('flutter config --machine failed: ${result.stderr}');
      return null;
    }
    final stdout = result.stdout as String;
    final json = jsonDecode(stdout) as Map<dynamic, dynamic>;
    final jdkDir = json['jdk-dir'] as String?;
    if (jdkDir != null && jdkDir.isNotEmpty) {
      final dir = Directory(jdkDir);
      if (dir.existsSync()) {
        _detectedJavaHome = dir.uri;
        log.info('Detected Java Home from flutter config: $_detectedJavaHome');
        return _detectedJavaHome;
      } else {
        log.warning('Detected Java Home directory does not exist: $jdkDir');
      }
    }
  } catch (e) {
    log.warning('Failed to detect Java Home: $e');
  }
  return null;
}

/// Returns an environment map with `JAVA_HOME` set to Flutter's JDK
/// (if detected) and `JAVA_HOME/bin` prepended to `PATH`.
Map<String, String> getJavaEnvironment({Map<String, String>? baseEnvironment}) {
  final env = Map<String, String>.from(baseEnvironment ?? Platform.environment);
  final resolvedJavaHome = detectFlutterJavaHome()?.toFilePath();
  if (resolvedJavaHome != null) {
    env['JAVA_HOME'] = resolvedJavaHome;
    final pathSeparator = Platform.isWindows ? ';' : ':';
    final binPath = p.join(resolvedJavaHome, 'bin');
    final oldPath = env['PATH'] ?? '';
    env['PATH'] = oldPath.isEmpty ? binPath : '$binPath$pathSeparator$oldPath';
  }
  return env;
}

/// Resolves executable names like `java`, `javac`, or `javap` to their full
/// path inside `JAVA_HOME/bin` if Flutter's Java Home is detected.
String resolveJavaExecutable(String exec) {
  final baseName = p.basenameWithoutExtension(exec);
  if (baseName == 'java' || baseName == 'javac' || baseName == 'javap') {
    final javaHome = detectFlutterJavaHome();
    if (javaHome != null) {
      final exeName = Platform.isWindows ? '$baseName.exe' : baseName;
      final file = File.fromUri(javaHome.resolve('bin/$exeName'));
      if (file.existsSync()) {
        return file.path;
      }
    }
  }
  return exec;
}
