// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:process/process.dart';

/// A single recorded call to [FakeProcessManager.start] or
/// [FakeProcessManager.run].
class RecordedInvocation {
  /// The full command list as passed to the [ProcessManager], with the
  /// executable as the first element.
  final List<String> command;

  final String? workingDirectory;

  final Map<String, String>? environment;

  RecordedInvocation({
    required this.command,
    required this.workingDirectory,
    required this.environment,
  });
}

/// A single expected process invocation and its scripted output.
class FakeCommand {
  /// When set, the actual invocation must match this list exactly.
  final List<String>? command;

  final String stdout;
  final String stderr;
  final int exitCode;

  /// Called with the actual command when this invocation is consumed.
  final void Function(List<String> command)? onRun;

  const FakeCommand({
    this.command,
    this.stdout = '',
    this.stderr = '',
    this.exitCode = 0,
    this.onRun,
  });
}

/// A [ProcessManager] that never spawns a real process.
///
/// It consumes the given [FakeCommand]s in order, one per [start] or [run],
/// records every invocation in [invocations], and hands back the scripted
/// output, so tests can assert on how processes were invoked without depending
/// on the host machine.
class FakeProcessManager implements ProcessManager {
  FakeProcessManager(this._commands);

  final List<FakeCommand> _commands;
  int _nextCommand = 0;

  final List<RecordedInvocation> invocations = [];

  /// Consumes the next [FakeCommand], checking it against [command].
  FakeCommand _consume(List<String> command) {
    if (_nextCommand >= _commands.length) {
      throw StateError('Unexpected command: $command');
    }
    final fake = _commands[_nextCommand++];
    if (fake.command != null && !_listEquals(fake.command!, command)) {
      throw StateError(
        'Expected command ${fake.command} but got $command.',
      );
    }
    fake.onRun?.call(command);
    return fake;
  }

  @override
  Future<Process> start(
    List<Object> command, {
    String? workingDirectory,
    Map<String, String>? environment,
    bool includeParentEnvironment = true,
    bool runInShell = false,
    ProcessStartMode mode = ProcessStartMode.normal,
  }) async {
    final commandList = command.map((e) => '$e').toList();
    final fake = _consume(commandList);
    invocations.add(
      RecordedInvocation(
        command: commandList,
        workingDirectory: workingDirectory,
        environment: environment,
      ),
    );
    return _FakeProcess(fake);
  }

  @override
  Future<ProcessResult> run(
    List<Object> command, {
    String? workingDirectory,
    Map<String, String>? environment,
    bool includeParentEnvironment = true,
    bool runInShell = false,
    Encoding? stdoutEncoding = systemEncoding,
    Encoding? stderrEncoding = systemEncoding,
  }) async {
    final commandList = command.map((e) => '$e').toList();
    final fake = _consume(commandList);
    invocations.add(
      RecordedInvocation(
        command: commandList,
        workingDirectory: workingDirectory,
        environment: environment,
      ),
    );
    return ProcessResult(_fakePid, fake.exitCode, fake.stdout, fake.stderr);
  }

  @override
  ProcessResult runSync(
    List<Object> command, {
    String? workingDirectory,
    Map<String, String>? environment,
    bool includeParentEnvironment = true,
    bool runInShell = false,
    Encoding? stdoutEncoding = systemEncoding,
    Encoding? stderrEncoding = systemEncoding,
  }) => throw UnimplementedError('runSync is not used by native_toolchain_c.');

  @override
  bool canRun(dynamic executable, {String? workingDirectory}) => true;

  @override
  bool killPid(int pid, [ProcessSignal signal = ProcessSignal.sigterm]) => true;
}

bool _listEquals(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

const _fakePid = 1234;

class _FakeProcess implements Process {
  _FakeProcess(this._command);

  final FakeCommand _command;

  @override
  int get pid => _fakePid;

  @override
  Future<int> get exitCode async => _command.exitCode;

  @override
  Stream<List<int>> get stdout =>
      Stream.value(systemEncoding.encode(_command.stdout));

  @override
  Stream<List<int>> get stderr =>
      Stream.value(systemEncoding.encode(_command.stderr));

  @override
  IOSink get stdin =>
      throw UnimplementedError('stdin is not used by native_toolchain_c.');

  @override
  bool kill([ProcessSignal signal = ProcessSignal.sigterm]) => true;
}
