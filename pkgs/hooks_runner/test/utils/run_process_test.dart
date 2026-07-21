// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Regression test for running commands whose executable path or arguments
// contain a space (e.g. the default pub cache under a Windows user name with
// a space, `C:\Users\First Last\AppData\Local\Pub\Cache\...`).
//
// On Windows, `runProcess` only runs through `cmd.exe` (`runInShell`) when
// strictly necessary: bare command names (resolved via `PATHEXT`) and
// `.bat`/`.cmd` shims. For `.exe`/`.com` binaries it uses `CreateProcess`
// directly so command lines with multiple quoted tokens are not mangled by
// `cmd.exe`'s `/c` quote-stripping rule.

import 'dart:io';

import 'package:test/test.dart';

import '../helpers.dart';

void main() {
  late Uri scriptUri;

  setUpAll(() async {
    final scriptDir = await tempDirForTest();
    scriptUri = scriptDir.resolve('echo_args.dart');
    await File.fromUri(scriptUri).writeAsString('''
void main(List<String> args) {
  print('ARGC:\${args.length}');
  print('ARGV:\${args.join('|')}');
}
''');
  });

  test(
    'runProcess handles an executable path containing a space',
    timeout: const Timeout.factor(5),
    () async {
      final outDir = await tempDirForTest();
      final exeUri = outDir.resolve(
        'echo args${Platform.isWindows ? '.exe' : ''}',
      );
      final compileResult = await Process.run(Platform.resolvedExecutable, [
        'compile',
        'exe',
        scriptUri.toFilePath(),
        '-o',
        exeUri.toFilePath(),
      ]);
      expect(compileResult.exitCode, 0, reason: '${compileResult.stderr}');

      final workingDir = await tempDirForTest();
      final result = await runProcess(
        executable: exeUri,
        arguments: ['an argument with spaces'],
        workingDirectory: workingDir,
        logger: logger,
      );

      expect(result.exitCode, 0);
      expect(result.stdout, contains('ARGC:1'));
      expect(result.stdout, contains('ARGV:an argument with spaces'));
    },
  );

  test('runProcess handles arguments containing a space', () async {
    final workingDir = await tempDirForTest();
    final result = await runProcess(
      executable: Uri.file(Platform.resolvedExecutable),
      arguments: [scriptUri.toFilePath(), 'first arg', 'second arg'],
      workingDirectory: workingDir,
      logger: logger,
    );

    expect(result.exitCode, 0);
    expect(result.stdout, contains('ARGC:2'));
    expect(result.stdout, contains('ARGV:first arg|second arg'));
  });

  test(
    'runProcess runs bare .bat shim from working directory on Windows',
    () async {
      if (!Platform.isWindows) return;

      final binDir = await tempDirForTest();
      final batUri = binDir.resolve('test shim.bat');
      await File.fromUri(batUri).writeAsString(
        '@echo off\r\necho SHIM_OK %*\r\n',
      );

      final result = await runProcess(
        executable: Uri.parse('test shim'),
        arguments: ['--help'],
        workingDirectory: binDir,
        logger: logger,
      );

      expect(result.exitCode, 0);
      expect(result.stdout, contains('SHIM_OK'));
      expect(result.stdout, contains('--help'));
    },
  );

  test(
    'runProcess runs bare .bat shim from PATH on Windows',
    () async {
      if (!Platform.isWindows) return;

      final binDir = await tempDirForTest();
      final batUri = binDir.resolve('test shim.bat');
      await File.fromUri(batUri).writeAsString(
        '@echo off\r\necho SHIM_OK %*\r\n',
      );

      final originalPath = Platform.environment['PATH'] ?? '';
      final result = await runProcess(
        executable: Uri.parse('test shim'),
        arguments: ['--help'],
        environment: {'PATH': '${binDir.toFilePath()};$originalPath'},
        logger: logger,
      );

      expect(result.exitCode, 0);
      expect(result.stdout, contains('SHIM_OK'));
      expect(result.stdout, contains('--help'));
    },
  );

  test('runProcess handles arguments containing a space and quotes', () async {
    final workingDir = await tempDirForTest();
    final result = await runProcess(
      executable: Uri.file(Platform.resolvedExecutable),
      arguments: [scriptUri.toFilePath(), 'fir"st arg', 'sec\'ond arg'],
      workingDirectory: workingDir,
      logger: logger,
    );

    expect(result.exitCode, 0);
    expect(result.stdout, contains('ARGC:2'));
    expect(result.stdout, contains('ARGV:fir"st arg|sec\'ond arg'));
  });
}
