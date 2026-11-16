// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:native_toolchain_c/src/utils/run_process.dart';
import 'package:process/process.dart';
import 'package:test/test.dart';

import '../helpers.dart';
import 'fake_process_manager.dart';

void main() {
  final whichUri = Uri.file(Platform.isWindows ? 'where' : 'which');

  test('log contains working dir', () async {
    final tempUri = await tempDirForTest();
    final messages = <String>[];
    await runProcess(
      executable: whichUri,
      workingDirectory: tempUri,
      logger: createCapturingLogger(messages),
      processManager: const LocalProcessManager(),
    );
    expect(messages.join('\n'), contains('cd'));
  });

  test('log contains env', () async {
    final messages = <String>[];
    await runProcess(
      executable: whichUri,
      environment: {'FOO': 'BAR'},
      logger: createCapturingLogger(messages),
      processManager: const LocalProcessManager(),
    );
    expect(messages.join('\n'), contains('FOO=BAR'));
  });

  test('stderr', () async {
    final messages = <String>[];
    const filePath = 'a/dart/file/which/does/not/exist.dart';
    final result = await runProcess(
      executable: Uri.file(Platform.resolvedExecutable),
      arguments: [filePath],
      logger: createCapturingLogger(messages),
      processManager: const LocalProcessManager(),
    );
    expect(result.stderr, contains(filePath));
    expect(result.toString(), contains(filePath));
  });

  group('with a fake process manager', () {
    final executableUri = Uri.file('/bin/echo');

    for (final capture in [false, true]) {
      test('streams explicit encodings (capture: $capture)', () async {
        const stdoutText = '你好 😀';
        const stderrText = 'café';
        final processManager = FakeProcessManager([
          FakeCommand(
            stdoutChunks: utf8.encode(stdoutText).map((b) => [b]).toList(),
            stderrChunks: latin1.encode(stderrText).map((b) => [b]).toList(),
            exitCode: 3,
          ),
        ]);
        final processLogger = Logger.detached('encoding')..level = Level.ALL;
        final records = <LogRecord>[];
        final subscription = processLogger.onRecord.listen(records.add);
        addTearDown(subscription.cancel);
        final result = await runProcess(
          executable: executableUri,
          logger: processLogger,
          processManager: processManager,
          captureOutput: capture,
          stdoutEncoding: utf8,
          stderrEncoding: latin1,
        );
        expect(result.stdout, capture ? stdoutText : isEmpty);
        expect(result.stderr, capture ? stderrText : isEmpty);
        expect(result.exitCode, 3);
        expect(
          records
              .where((r) => r.level == Level.FINE)
              .map((r) => r.message)
              .join(),
          stdoutText,
        );
        expect(
          records
              .where((r) => r.level == Level.SEVERE)
              .map((r) => r.message)
              .join(),
          stderrText,
        );
      });
    }

    test('defaults to system encoding', () async {
      final bytes = utf8.encode('中文');
      final result = await runProcess(
        executable: executableUri,
        logger: null,
        processManager: FakeProcessManager([
          FakeCommand(stdoutChunks: [bytes], stderrChunks: [bytes]),
        ]),
      );
      expect(result.stdout, systemEncoding.decode(bytes));
      expect(result.stderr, systemEncoding.decode(bytes));
    });

    test('captures stdout and stderr and passes the command through', () async {
      final processManager = FakeProcessManager([
        const FakeCommand(
          stdout: 'the standard output',
          stderr: 'the standard error',
        ),
      ]);
      final result = await runProcess(
        executable: executableUri,
        arguments: ['hello', 'world'],
        logger: null,
        processManager: processManager,
      );
      expect(result.exitCode, 0);
      expect(result.stdout, 'the standard output');
      expect(result.stderr, 'the standard error');
      // The command list is passed through verbatim, with the executable path
      // as the first element.
      expect(processManager.invocations.single.command, [
        executableUri.toFilePath(),
        'hello',
        'world',
      ]);
    });

    test(
      'a non-zero exit code is returned without throwing by default',
      () async {
        final processManager = FakeProcessManager([
          const FakeCommand(exitCode: 3, stderr: 'boom'),
        ]);
        // By default a non-zero exit code is returned, not thrown.
        final result = await runProcess(
          executable: executableUri,
          logger: null,
          processManager: processManager,
        );
        expect(result.exitCode, 3);
        expect(result.stderr, 'boom');
      },
    );

    test(
      'throwOnUnexpectedExitCode throws on a mismatching exit code',
      () async {
        final processManager = FakeProcessManager([
          const FakeCommand(exitCode: 3),
        ]);
        await expectLater(
          runProcess(
            executable: executableUri,
            logger: null,
            processManager: processManager,
            throwOnUnexpectedExitCode: true,
          ),
          throwsA(isA<ProcessException>()),
        );
      },
    );

    test('forwards the environment and working directory', () async {
      final processManager = FakeProcessManager([const FakeCommand()]);
      final workingDirectory = Uri.directory('/tmp/work');
      await runProcess(
        executable: executableUri,
        workingDirectory: workingDirectory,
        environment: {'FOO': 'BAR'},
        logger: null,
        processManager: processManager,
      );
      final invocation = processManager.invocations.single;
      expect(invocation.environment, {'FOO': 'BAR'});
      expect(invocation.workingDirectory, workingDirectory.toFilePath());
    });

    test('a matching command is accepted', () async {
      final processManager = FakeProcessManager([
        FakeCommand(command: [executableUri.toFilePath(), 'hello']),
      ]);
      final result = await runProcess(
        executable: executableUri,
        arguments: ['hello'],
        logger: null,
        processManager: processManager,
      );
      expect(result.exitCode, 0);
      expect(processManager.allCommandsConsumed, true);
    });

    test('allCommandsConsumed is false while commands remain', () async {
      final processManager = FakeProcessManager([
        const FakeCommand(),
        const FakeCommand(),
      ]);
      await runProcess(
        executable: executableUri,
        logger: null,
        processManager: processManager,
      );
      expect(processManager.allCommandsConsumed, false);
    });

    test('onRun is invoked with the actual command', () async {
      List<String>? seen;
      final processManager = FakeProcessManager([
        FakeCommand(onRun: (command) => seen = command),
      ]);
      await runProcess(
        executable: executableUri,
        arguments: ['hello', 'world'],
        logger: null,
        processManager: processManager,
      );
      expect(seen, [executableUri.toFilePath(), 'hello', 'world']);
    });

    test('an exhausted command list throws a StateError', () async {
      final processManager = FakeProcessManager([]);
      await expectLater(
        runProcess(
          executable: executableUri,
          logger: null,
          processManager: processManager,
        ),
        throwsA(isA<StateError>()),
      );
    });
  });
}
