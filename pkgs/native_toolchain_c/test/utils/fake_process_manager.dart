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

/// The scripted output of a faked process.
class ScriptedResult {
  final String stdout;
  final String stderr;
  final int exitCode;

  const ScriptedResult({
    this.stdout = '',
    this.stderr = '',
    this.exitCode = 0,
  });
}

/// A [ProcessManager] that never spawns a real process.
///
/// It records every invocation in [invocations] and hands back the scripted
/// [result] for both [start] and [run], so tests can assert on how processes
/// were invoked without depending on the host machine.
class FakeProcessManager implements ProcessManager {
  FakeProcessManager({this.result = const ScriptedResult()});

  final ScriptedResult result;

  final List<RecordedInvocation> invocations = [];

  @override
  Future<Process> start(
    List<Object> command, {
    String? workingDirectory,
    Map<String, String>? environment,
    bool includeParentEnvironment = true,
    bool runInShell = false,
    ProcessStartMode mode = ProcessStartMode.normal,
  }) async {
    invocations.add(
      RecordedInvocation(
        command: command.map((e) => '$e').toList(),
        workingDirectory: workingDirectory,
        environment: environment,
      ),
    );
    return _FakeProcess(result);
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
    invocations.add(
      RecordedInvocation(
        command: command.map((e) => '$e').toList(),
        workingDirectory: workingDirectory,
        environment: environment,
      ),
    );
    return ProcessResult(
      _fakePid,
      result.exitCode,
      result.stdout,
      result.stderr,
    );
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

const _fakePid = 1234;

class _FakeProcess implements Process {
  _FakeProcess(this._result);

  final ScriptedResult _result;

  @override
  int get pid => _fakePid;

  @override
  Future<int> get exitCode async => _result.exitCode;

  @override
  Stream<List<int>> get stdout =>
      Stream.value(systemEncoding.encode(_result.stdout));

  @override
  Stream<List<int>> get stderr =>
      Stream.value(systemEncoding.encode(_result.stderr));

  @override
  IOSink get stdin =>
      throw UnimplementedError('stdin is not used by native_toolchain_c.');

  @override
  bool kill([ProcessSignal signal = ProcessSignal.sigterm]) => true;
}
