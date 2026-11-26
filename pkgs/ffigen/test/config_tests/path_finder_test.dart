// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:ffigen/src/config_provider/path_finder.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  final logger = Logger('path_finder_test');

  Directory createTempDir() {
    final dir = Directory.systemTemp.createTempSync('ffigen_path_finder_test_');
    addTearDown(() {
      if (dir.existsSync()) {
        dir.deleteSync(recursive: true);
      }
    });
    return dir;
  }

  group('findClangResourceDir', () {
    test('finds resource dir in Unix lib/ layout', () {
      final tmp = createTempDir();
      final dylib = File(p.join(tmp.path, 'lib', 'libclang.dylib'))
        ..createSync(recursive: true);
      final resourceDir = Directory(
        p.join(tmp.path, 'lib', 'clang', '18', 'include'),
      )..createSync(recursive: true);

      final result = findClangResourceDir(logger, dylib.path);
      expect(result, p.dirname(resourceDir.path));
    });

    test('finds resource dir in Windows bin/ layout', () {
      final tmp = createTempDir();
      final dylib = File(p.join(tmp.path, 'bin', 'libclang.dll'))
        ..createSync(recursive: true);
      final resourceDir = Directory(
        p.join(tmp.path, 'lib', 'clang', '19.1.0', 'include'),
      )..createSync(recursive: true);

      final result = findClangResourceDir(logger, dylib.path);
      expect(result, p.dirname(resourceDir.path));
    });

    test('ignores subdirectories without include/ directory', () {
      final tmp = createTempDir();
      final dylib = File(p.join(tmp.path, 'lib', 'libclang.dylib'))
        ..createSync(recursive: true);
      // Subdirectories without include/ must be ignored.
      Directory(
        p.join(tmp.path, 'lib', 'clang', '17'),
      ).createSync(recursive: true);
      Directory(
        p.join(tmp.path, 'lib', 'clang', '20'),
      ).createSync(recursive: true);
      final expectedDir = p.join(tmp.path, 'lib', 'clang', '19');
      Directory(p.join(expectedDir, 'include')).createSync(recursive: true);

      final result = findClangResourceDir(logger, dylib.path);
      expect(result, expectedDir);
    });

    test('resolves symlinked dylib to find resource dir', () {
      final tmp = createTempDir();
      final targetDylib = File(p.join(tmp.path, 'llvm', 'lib', 'libclang.so'))
        ..createSync(recursive: true);
      final resourceDir = Directory(
        p.join(tmp.path, 'llvm', 'lib', 'clang', '18', 'include'),
      )..createSync(recursive: true);

      final symlinkDir = Directory(p.join(tmp.path, 'multiarch'))
        ..createSync(recursive: true);
      final symlinkDylib = Link(p.join(symlinkDir.path, 'libclang.so'))
        ..createSync(targetDylib.path);

      final result = findClangResourceDir(logger, symlinkDylib.path);
      expect(result, p.dirname(resourceDir.resolveSymbolicLinksSync()));
    }, skip: Platform.isWindows);

    test('returns null when no sibling clang/ directory exists', () {
      final tmp = createTempDir();
      final dylib = File(p.join(tmp.path, 'lib', 'libclang.dylib'))
        ..createSync(recursive: true);

      expect(findClangResourceDir(logger, dylib.path), isNull);
    });
  });
}
