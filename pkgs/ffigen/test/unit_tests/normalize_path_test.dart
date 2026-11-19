// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:cli_util/cli_util.dart' as cli_util;
import 'package:ffigen/src/code_generator/utils.dart';
import 'package:ffigen/src/config_provider/utils.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  final abs = Platform.isWindows ? r'C:\' : '/';
  final config = p.joinAll([abs, 'foo', 'package', 'ffigen.yaml']);

  group('normalizePath', () {
    test('All separators replaced with platform separators', () {
      // Unix style.
      expect(
        normalizePath('relative/header.h', null),
        p.joinAll(['relative', 'header.h']),
      );

      // Windows style.
      expect(
        normalizePath(r'relative\header.h', null),
        p.joinAll(['relative', 'header.h']),
      );
    });

    test('Relative path normalized and resolved relative to config', () {
      expect(
        normalizePath('relative/src/header.h', config),
        p.joinAll([abs, 'foo', 'package', 'relative', 'src', 'header.h']),
      );
      expect(
        normalizePath('../src/header.h', config),
        p.joinAll([abs, 'foo', 'src', 'header.h']),
      );
      expect(
        normalizePath('./././src/header.h', config),
        p.joinAll([abs, 'foo', 'package', 'src', 'header.h']),
      );
      expect(
        normalizePath('.././src/.././header.h', config),
        p.joinAll([abs, 'foo', 'header.h']),
      );
    });

    test('Absolute path normalized but not resolved', () {
      expect(
        normalizePath(p.joinAll([abs, 'absolute/src/header.h']), config),
        p.joinAll([abs, 'absolute', 'src', 'header.h']),
      );
      expect(
        normalizePath(p.joinAll([abs, './src/.././header.h']), config),
        p.joinAll([abs, 'header.h']),
      );
    });

    test('Glob path normalized but not resolved', () {
      expect(
        normalizePath('**/glob/*/header.h', config),
        p.joinAll(['**', 'glob', '*', 'header.h']),
      );
      expect(
        normalizePath('**/glob/./*/../header.h', config),
        p.joinAll(['**', 'glob', 'header.h']),
      );
    });

    test('Null configFilename normalized but not resolved', () {
      expect(
        normalizePath(p.joinAll(['relative/src/header.h']), null),
        p.joinAll(['relative', 'src', 'header.h']),
      );
      expect(
        normalizePath(p.joinAll(['./src/.././header.h']), null),
        p.joinAll(['header.h']),
      );
    });
  });

  group('dartExecutable', () {
    test('resolves dart via cli_util when running as an AOT binary', () {
      final nonSdkBinary = p.join(abs, 'nonexistent', 'bin', 'ffigen');
      final dartPath = runZoned(
        () => dartExecutable,
        zoneValues: {
          cli_util.environmentOverridesKey: {
            ...Platform.environment,
            '_DART_RESOLVED_EXECUTABLE': nonSdkBinary,
          },
        },
      );
      expect(p.basenameWithoutExtension(dartPath), 'dart');
      expect(File(dartPath).existsSync(), isTrue);
    });
  });

  group('findPackageRoot', () {
    test('resolves from currentDirUri when scriptUri is an AOT binary', () {
      final aotScript = Uri.file(p.join(abs, 'tmp', 'ffigen_test'));
      final pkgDir = Uri.directory(p.join(abs, 'work', 'pkgs', 'ffigen'));
      expect(
        findPackageRoot('ffigen', scriptUri: aotScript, currentDirUri: pkgDir),
        pkgDir,
      );
    });

    test('resolves from scriptUri when inside package', () {
      final script = Uri.file(
        p.join(abs, 'work', 'pkgs', 'ffigen', 'test', 'some_test.dart'),
      );
      final cwd = Uri.directory(p.join(abs, 'tmp'));
      expect(
        findPackageRoot('ffigen', scriptUri: script, currentDirUri: cwd),
        Uri.directory(p.join(abs, 'work', 'pkgs', 'ffigen')),
      );
    });

    test('throws StateError cleanly when not in package or workspace', () {
      final script = Uri.file(p.join(abs, 'tmp', 'other_binary'));
      final cwd = Uri.directory(p.join(abs, 'tmp'));
      expect(
        () => findPackageRoot('ffigen', scriptUri: script, currentDirUri: cwd),
        throwsStateError,
      );
    });
  });
}
