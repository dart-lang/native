// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:jni/_internal.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

void main() {
  test('JniVersionCheck runtime assert', () {
    // We use a local constructor tear-off to prevent it being const-folded.
    // ignore: prefer_final_locals
    var check = JniVersionCheck.new;
    expect(
        () => check(JniVersionCheck.actualMajorVersion,
            JniVersionCheck.actualMinorVersion),
        returnsNormally);

    // Major version mismatch always fails.
    expect(() => check(0, 0), throwsA(isA<AssertionError>()));
    expect(() => check(1234, 0), throwsA(isA<AssertionError>()));

    // Minor version mismatch fails only if the required version is newer.
    expect(() => check(JniVersionCheck.actualMajorVersion, 0), returnsNormally);
    expect(() => check(JniVersionCheck.actualMajorVersion, 1234),
        throwsA(isA<AssertionError>()));
  });

  group('JniVersionCheck compile-time assert', () {
    final testDir = path.join(Directory.current.path, 'test', 'version_check');

    void testAnalyze(String fileName, {required bool shouldPass}) {
      test('dart analyze $fileName', () {
        final result = Process.runSync(
          'dart',
          ['analyze', path.join(testDir, fileName)],
        );

        final stdout = result.stdout.toString();
        if (shouldPass) {
          expect(result.exitCode, 0, reason: stdout);
        } else {
          expect(result.exitCode, isNot(0));
          expect(stdout, contains('The generated bindings expect package:jni'));
        }
      });
    }

    testAnalyze('pass.dart', shouldPass: true);
    testAnalyze('fail_major.dart', shouldPass: false);
    testAnalyze('fail_minor.dart', shouldPass: false);
  });

  test('JniVersionCheck constants match pubspec', () {
    final pubspecFile = File('pubspec.yaml');
    final pubspecContent = pubspecFile.readAsStringSync();
    final versionRegex =
        RegExp(r'^version:\s+(\d+)\.(\d+)\.\d+', multiLine: true);
    final match = versionRegex.firstMatch(pubspecContent);
    expect(match, isNotNull);
    final major = int.parse(match!.group(1)!);
    final minor = int.parse(match.group(2)!);

    expect(JniVersionCheck.actualMajorVersion, major);
    expect(JniVersionCheck.actualMinorVersion, minor);
  });
}
