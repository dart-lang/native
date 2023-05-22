// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:logging/logging.dart';

/// Runs a [Process].
///
/// If [logger] is provided, stream stdout and stderr to it.
///
/// If [captureOutput], captures stdout and stderr.
Future<RunProcessResult> runProcess({
  required Uri executable,
  List<String> arguments = const [],
  Uri? workingDirectory,
  Map<String, String>? environment,
  bool includeParentEnvironment = true,
  required Logger? logger,
  bool captureOutput = true,
  int expectedExitCode = 0,
  bool throwOnUnexpectedExitCode = false,
}) async {
  if (Platform.isWindows && !includeParentEnvironment) {
    const winEnvKeys = [
      'SYSTEMROOT',
    ];
    final newEnvironment = {
      ...{
        for (final winEnvKey in winEnvKeys)
          winEnvKey: Platform.environment[winEnvKey]!,
      },
      if (environment != null) ...environment,
    };
    environment = newEnvironment;
  }

  final printWorkingDir =
      workingDirectory != null && workingDirectory != Directory.current.uri;
  final commandString = [
    if (printWorkingDir) '(cd ${workingDirectory.toFilePath()};',
    ...?environment?.entries.map((entry) => '${entry.key}=${entry.value}'),
    executable.toFilePath(),
    ...arguments.map((a) => a.contains(' ') ? "'$a'" : a),
    if (printWorkingDir) ')',
  ].join(' ');
  logger?.info('Running `$commandString`.');

  final stdoutBuffer = StringBuffer();
  final stderrBuffer = StringBuffer();
  final stdoutCompleter = Completer<Object?>();
  final stderrCompleter = Completer<Object?>();
  final process = await Process.start(
    executable.toFilePath(),
    arguments,
    workingDirectory: workingDirectory?.toFilePath(),
    environment: environment,
    includeParentEnvironment: includeParentEnvironment,
    runInShell: Platform.isWindows && !includeParentEnvironment,
  );

  process.stdout.transform(utf8.decoder).transform(const LineSplitter()).listen(
    (s) {
      logger?.fine(s);
      if (captureOutput) stdoutBuffer.write(s);
    },
    onDone: stdoutCompleter.complete,
  );
  process.stderr.transform(utf8.decoder).transform(const LineSplitter()).listen(
    (s) {
      logger?.severe(s);
      if (captureOutput) stderrBuffer.write(s);
    },
    onDone: stderrCompleter.complete,
  );

  final exitCode = await process.exitCode;
  await stdoutCompleter.future;
  await stderrCompleter.future;
  final result = RunProcessResult(
    pid: process.pid,
    command: commandString,
    exitCode: exitCode,
    stdout: stdoutBuffer.toString(),
    stderr: stderrBuffer.toString(),
  );
  if (throwOnUnexpectedExitCode && expectedExitCode != exitCode) {
    throw ProcessException(
      executable.toFilePath(),
      arguments,
      "Full command string: '$commandString'.\n"
      "Exit code: '$exitCode'.\n"
      'For the output of the process check the logger output.',
    );
  }
  return result;
}

class RunProcessResult extends ProcessResult {
  final String command;

  final int _exitCode;

  // For some reason super.exitCode returns 0.
  @override
  int get exitCode => _exitCode;

  final String _stderrString;

  @override
  String get stderr => _stderrString;

  final String _stdoutString;

  @override
  String get stdout => _stdoutString;

  RunProcessResult({
    required int pid,
    required this.command,
    required int exitCode,
    required String stderr,
    required String stdout,
  })  : _exitCode = exitCode,
        _stderrString = stderr,
        _stdoutString = stdout,
        super(pid, exitCode, stdout, stderr);

  @override
  String toString() => '''command: $command
exitCode: $exitCode
stdout: $stdout
stderr: $stderr''';
}
