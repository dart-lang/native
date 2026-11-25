// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:jni_util/src/flutter_util.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('flutter_util_test_');
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  File createFile(String relativePath) {
    final file = File(p.join(tempDir.path, relativePath));
    file.createSync(recursive: true);
    return file;
  }

  test('finds flutter in Flutter SDK layout', () {
    final flutter = createFile(p.join('sdk', 'bin', 'flutter'));
    final dart = createFile(
      p.join('sdk', 'bin', 'cache', 'dart-sdk', 'bin', 'dart'),
    );

    final result = findFlutterExecutable(
      resolvedExecutable: dart.path,
      isWindows: false,
    );

    expect(result, flutter.path);
  });

  test('finds flutter in flutter_tester layout', () {
    final flutter = createFile(p.join('sdk', 'bin', 'flutter'));
    final tester = createFile(
      p.join(
        'sdk',
        'bin',
        'cache',
        'artifacts',
        'engine',
        'darwin-x64',
        'flutter_tester',
      ),
    );

    final result = findFlutterExecutable(
      resolvedExecutable: tester.path,
      isWindows: false,
    );

    expect(result, flutter.path);
  });

  test('finds flutter.bat when isWindows is true', () {
    final flutterBat = createFile(p.join('sdk', 'bin', 'flutter.bat'));
    final dartExe = createFile(
      p.join('sdk', 'bin', 'cache', 'dart-sdk', 'bin', 'dart.exe'),
    );

    final result = findFlutterExecutable(
      resolvedExecutable: dartExe.path,
      isWindows: true,
    );

    expect(result, flutterBat.path);
  });

  test('ignores a directory named flutter', () {
    Directory(
      p.join(tempDir.path, 'sdk', 'bin', 'flutter'),
    ).createSync(recursive: true);
    final dart = createFile(
      p.join('sdk', 'bin', 'cache', 'dart-sdk', 'bin', 'dart'),
    );

    final result = findFlutterExecutable(
      resolvedExecutable: dart.path,
      isWindows: false,
    );

    expect(result, 'flutter');
  });

  test('ignores stray flutter file in unrelated ancestor directory', () {
    createFile(p.join('other', 'flutter'));
    createFile(p.join('other', 'bin', 'flutter'));
    final dart = createFile(p.join('other', 'bin', 'dart-sdk', 'bin', 'dart'));

    final result = findFlutterExecutable(
      resolvedExecutable: dart.path,
      isWindows: false,
    );

    expect(result, 'flutter');
  });

  test('ignores bare, relative, or empty resolvedExecutable', () {
    final savedCwd = Directory.current;
    addTearDown(() => Directory.current = savedCwd);
    createFile('flutter');
    createFile(p.join('bin', 'flutter'));
    Directory.current = tempDir;

    for (final path in [
      '',
      'dart',
      p.join('bin', 'cache', 'dart-sdk', 'bin', 'dart'),
    ]) {
      final result = findFlutterExecutable(
        resolvedExecutable: path,
        isWindows: false,
      );

      expect(result, 'flutter', reason: 'resolvedExecutable: "$path"');
    }
  });

  test('handles paths with spaces', () {
    final flutter = createFile(p.join('my flutter sdk', 'bin', 'flutter'));
    final dart = createFile(
      p.join('my flutter sdk', 'bin', 'cache', 'dart-sdk', 'bin', 'dart'),
    );

    final result = findFlutterExecutable(
      resolvedExecutable: dart.path,
      isWindows: false,
    );

    expect(result, flutter.path);
  });

  test('falls back to bare flutter when nothing matches', () {
    final standaloneDart = createFile(p.join('standalone', 'bin', 'dart'));

    final result = findFlutterExecutable(
      resolvedExecutable: standaloneDart.path,
      isWindows: false,
    );

    expect(result, 'flutter');
  });
}
