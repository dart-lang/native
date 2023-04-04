// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:logging/logging.dart';

/// Runs a process async and captures the exit code and standard out.
Future<RunProcessResult> runProcess({
  required String executable,
  required List<String> arguments,
  Uri? workingDirectory,
  Map<String, String>? environment,
  bool throwOnFailure = true,
}) async {
  final stdoutBuffer = <String>[];
  final stderrBuffer = <String>[];
  final stdoutCompleter = Completer<Object?>();
  final stderrCompleter = Completer<Object?>();
  final process = await Process.start(
    executable,
    arguments,
    workingDirectory: workingDirectory?.toFilePath(),
    environment: environment,
  );

  process.stdout.transform(utf8.decoder).listen(
        stdoutBuffer.add,
        onDone: stdoutCompleter.complete,
      );
  process.stderr.transform(utf8.decoder).listen(
        stderrBuffer.add,
        onDone: stderrCompleter.complete,
      );

  final exitCode = await process.exitCode;
  await stdoutCompleter.future;
  final stdout = stdoutBuffer.join();
  await stderrCompleter.future;
  final stderr = stderrBuffer.join();
  final result = RunProcessResult(
    pid: process.pid,
    command: '$executable ${arguments.join(' ')}',
    exitCode: exitCode,
    stdout: stdout,
    stderr: stderr,
  );
  if (throwOnFailure && result.exitCode != 0) {
    throw Exception(result);
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

/// A task that when run executes a process.
class RunProcess {
  final String executable;
  final List<String> arguments;
  final Uri? workingDirectory;
  final Map<String, String>? environment;
  final bool includeParentEnvironment;
  final bool throwOnFailure;

  RunProcess({
    required this.executable,
    this.arguments = const [],
    this.workingDirectory,
    this.environment,
    this.includeParentEnvironment = true,
    this.throwOnFailure = true,
  });

  String get commandString {
    final printWorkingDir =
        workingDirectory != null && workingDirectory != Directory.current.uri;
    return [
      if (printWorkingDir) '(cd ${workingDirectory!.path};',
      ...?environment?.entries.map((entry) => '${entry.key}=${entry.value}'),
      executable,
      ...arguments.map((a) => a.contains(' ') ? "'$a'" : a),
      if (printWorkingDir) ')',
    ].join(' ');
  }

  Future<void> run({Logger? logger}) async {
    final workingDirectoryString = workingDirectory?.toFilePath();

    logger?.info('Running `$commandString`.');
    final process = await Process.start(
      executable,
      arguments,
      runInShell: true,
      workingDirectory: workingDirectoryString,
      environment: environment,
      includeParentEnvironment: includeParentEnvironment,
    ).then((process) {
      process.stdout
          .transform(utf8.decoder)
          .forEach((s) => logger?.fine('  $s'));
      process.stderr
          .transform(utf8.decoder)
          .forEach((s) => logger?.severe('  $s'));
      return process;
    });
    final exitCode = await process.exitCode;
    if (exitCode != 0) {
      final message =
          'Command `$commandString` failed with exit code $exitCode.';
      logger?.severe(message);
      if (throwOnFailure) {
        throw Exception(message);
      }
    }
    logger?.fine('Command `$commandString` done.');
  }
}
