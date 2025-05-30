// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:developer';
import 'dart:io'
    show Platform, Process, ProcessException, ProcessResult, systemEncoding;

import 'package:file/file.dart';
import 'package:logging/logging.dart';

/// Runs a [Process].
///
/// If [logger] is provided, stream stdout and stderr to it.
///
/// If [captureOutput], captures stdout and stderr.
// TODO(dacoharkes): Share between package:native_toolchain_c and here.
Future<RunProcessResult> runProcess({
  required FileSystem filesystem,
  required Uri executable,
  List<String> arguments = const [],
  Uri? workingDirectory,
  Map<String, String>? environment,
  bool includeParentEnvironment = true,
  required Logger? logger,
  bool captureOutput = true,
  int expectedExitCode = 0,
  bool throwOnUnexpectedExitCode = false,
  TimelineTask? task,
}) async {
  final printWorkingDir =
      workingDirectory != null &&
      workingDirectory != filesystem.currentDirectory.uri;
  final commandString = [
    if (printWorkingDir) '(cd ${workingDirectory.toFilePath()};',
    ...?environment?.entries.map((entry) => '${entry.key}=${entry.value}'),
    executable.toFilePath(),
    ...arguments.map((a) => a.contains(' ') ? "'$a'" : a),
    if (printWorkingDir) ')',
  ].join(' ');
  logger?.info('Running `$commandString`.');
  task?.start(
    'Process.run',
    arguments: {
      'executable': executable.toFilePath(),
      'arguments': arguments,
      if (workingDirectory != null)
        'workingDirectory': workingDirectory.toFilePath(),
      if (environment != null) 'environment': environment,
    },
  );
  try {
    final stdoutBuffer = StringBuffer();
    final stderrBuffer = StringBuffer();
    final process = await Process.start(
      executable.toFilePath(),
      arguments,
      workingDirectory: workingDirectory?.toFilePath(),
      environment: environment,
      includeParentEnvironment: includeParentEnvironment,
      runInShell:
          Platform.isWindows &&
          (!includeParentEnvironment || workingDirectory != null),
    );

    final stdoutSub = process.stdout.listen((List<int> data) {
      try {
        final decoded = systemEncoding.decode(data);
        logger?.fine(decoded);
        if (captureOutput) {
          stdoutBuffer.write(decoded);
        }
      } catch (e) {
        logger?.warning('Failed to decode stdout: $e');
        stdoutBuffer.write('Failed to decode stdout: $e');
      }
    });
    final stderrSub = process.stderr.listen((List<int> data) {
      try {
        final decoded = systemEncoding.decode(data);
        logger?.severe(decoded);
        if (captureOutput) {
          stderrBuffer.write(decoded);
        }
      } catch (e) {
        logger?.severe('Failed to decode stderr: $e');
        stderrBuffer.write('Failed to decode stderr: $e');
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
  } finally {
    task?.finish();
  }
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
