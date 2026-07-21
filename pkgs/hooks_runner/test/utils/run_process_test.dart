// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Regression test for running commands whose executable path or arguments
// contain a space (e.g. the default pub cache under a Windows user name with
// a space, `C:\Users\First Last\AppData\Local\Pub\Cache\...`).
//
// `runProcess` never runs through a shell. Absolute paths (with a file
// extension on Windows) are required; relative paths and PATHEXT are not
// supported. Spaces in the executable path and arguments are handled by
// passing them as separate CreateProcess / exec arguments.

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

  test('runProcess rejects a relative executable path', () async {
    await expectLater(
      runProcess(
        executable: Uri(path: 'dart'),
        logger: logger,
      ),
      throwsA(
        isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          contains('absolute'),
        ),
      ),
    );
  });

  test(
    'runProcess rejects a Windows executable without a file extension',
    () async {
      if (!Platform.isWindows) return;

      await expectLater(
        runProcess(
          executable: Uri.file(r'C:\path\to\dart'),
          logger: logger,
        ),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('PATHEXT'),
          ),
        ),
      );
    },
  );
}
