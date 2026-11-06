// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:process/process.dart';

/// Runs a [Process].
///
/// If [logger] is provided, stream stdout and stderr to it.
///
/// The process is spawned through [processManager], which allows the process
/// invocation to be mocked out in tests.
///
/// If [captureOutput], captures stdout and stderr.
///
/// Decodes output using [stdoutEncoding] and [stderrEncoding], which default
/// to the system encoding. Override these for tools with a known encoding.
Future<RunProcessResult> runProcess({
  Uri? launcher,
  required Uri executable,
  List<String> arguments = const [],
  Uri? workingDirectory,
  Map<String, String>? environment,
  required Logger? logger,
  required ProcessManager processManager,
  bool captureOutput = true,
  Encoding stdoutEncoding = systemEncoding,
  Encoding stderrEncoding = systemEncoding,
  Level stdoutLogLevel = .FINE,
  int expectedExitCode = 0,
  bool throwOnUnexpectedExitCode = false,
}) async {
  final printWorkingDir =
      workingDirectory != null && workingDirectory != Directory.current.uri;
  String quoteIfSpaced(String s) => s.contains(' ') ? '"$s"' : s;
  final commandString = [
    if (printWorkingDir) '(cd ${workingDirectory.toFilePath()};',
    ...?environment?.entries.map((entry) => '${entry.key}=${entry.value}'),
    quoteIfSpaced((launcher ?? executable).toFilePath()),
    // WSL is the only launcher, so the executable and any file paths in
    // [arguments] are Linux style.
    if (launcher != null) quoteIfSpaced(executable.toFilePath(windows: false)),
    ...arguments.map(quoteIfSpaced),
    if (printWorkingDir) ')',
  ].join(' ');
  logger?.info('Running `$commandString`.');

  final stdoutBuffer = StringBuffer();
  final stderrBuffer = StringBuffer();

  final resolvedArguments = [
    if (launcher != null) executable.toFilePath(windows: false),
    ...arguments,
  ];
  final process = await processManager.start(
    // The executable is the first element of the command list.
    [(launcher ?? executable).toFilePath(), ...resolvedArguments],
    workingDirectory: workingDirectory?.toFilePath(),
    environment: environment,
    // Never run through a shell. On Windows, running an executable through
    // `cmd.exe /c` mangles the command line when more than one argument is
    // quoted (cmd strips the outer quotes when the line contains more than
    // two quote characters), which breaks any invocation whose executable and
    // arguments contain spaces. A shell is also not needed for wildcard
    // arguments: on Windows, programs expand wildcards themselves; `cmd.exe`
    // performs no glob expansion.
  );

  // Decode streams so multibyte characters can span process output chunks.
  final stdoutSub = process.stdout.transform(stdoutEncoding.decoder).listen((
    decoded,
  ) {
    logger?.log(stdoutLogLevel, decoded);
    if (captureOutput) {
      stdoutBuffer.write(decoded);
    }
  });
  final stderrSub = process.stderr.transform(stderrEncoding.decoder).listen((
    decoded,
  ) {
    logger?.severe(decoded);
    if (captureOutput) {
      stderrBuffer.write(decoded);
    }
  });

  final (exitCode, _, _) = await (
    process.exitCode,
    stdoutSub.asFuture<void>(),
    stderrSub.asFuture<void>(),
  ).wait;
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

/// Drop in replacement of [ProcessResult].
class RunProcessResult {
  final int pid;

  final String command;

  final int exitCode;

  final String stderr;

  final String stdout;

  RunProcessResult({
    required this.pid,
    required this.command,
    required this.exitCode,
    required this.stderr,
    required this.stdout,
  });

  @override
  String toString() =>
      '''command: $command
exitCode: $exitCode
stdout: $stdout
stderr: $stderr''';
}
