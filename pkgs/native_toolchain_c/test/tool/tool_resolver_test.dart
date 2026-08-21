// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:file/memory.dart';
import 'package:native_toolchain_c/src/native_toolchain/apple_clang.dart';
import 'package:native_toolchain_c/src/native_toolchain/clang.dart';
import 'package:native_toolchain_c/src/native_toolchain/msvc.dart';
import 'package:native_toolchain_c/src/tool/tool.dart';
import 'package:native_toolchain_c/src/tool/tool_error.dart';
import 'package:native_toolchain_c/src/tool/tool_instance.dart';
import 'package:native_toolchain_c/src/tool/tool_resolver.dart';
import 'package:process/process.dart';
import 'package:test/test.dart';

import '../helpers.dart';
import '../utils/fake_process_manager.dart';

void main() {
  test('CliVersionResolver.executableVersion', () async {
    final toolInstances = [
      ...await appleClang.defaultResolver!.resolve(systemContext),
      ...await clang.defaultResolver!.resolve(systemContext),
      ...await cl.defaultResolver!.resolve(systemContext),
    ];
    expect(toolInstances.isNotEmpty, true);
    final toolInstance = toolInstances.first;
    final versionArguments = [if (toolInstance.tool != cl) '--version'];
    final version = await CliVersionResolver.executableVersion(
      toolInstance.uri,
      arguments: versionArguments,
      logger: logger,
      processManager: const LocalProcessManager(),
    );
    expect(version.major > 5, true);
    expect(
      () => CliVersionResolver.executableVersion(
        toolInstances.first.uri,
        arguments: versionArguments,
        expectedExitCode: 9999,
        logger: logger,
        processManager: const LocalProcessManager(),
      ),
      throwsA(isA<ToolError>()),
    );

    try {
      await CliVersionResolver.executableVersion(
        toolInstances.first.uri,
        arguments: versionArguments,
        expectedExitCode: 9999,
        logger: logger,
        processManager: const LocalProcessManager(),
      );
      // ignore: avoid_catching_errors
    } on ToolError catch (e) {
      expect(e.toString(), contains('returned unexpected exit code'));
    }
  });

  test('RelativeToolResolver', () async {
    final tempUri = await tempDirForTest();
    final barExeUri = tempUri.resolve(OS.current.executableFileName('bar'));
    final bazExeName = OS.current.executableFileName('baz');
    final bazExeUri = tempUri.resolve(bazExeName);
    await File.fromUri(barExeUri).writeAsString('dummy');
    await File.fromUri(bazExeUri).writeAsString('dummy');
    expect(await File.fromUri(barExeUri).exists(), true);
    expect(await File.fromUri(bazExeUri).exists(), true);
    final barResolver = InstallLocationResolver(
      toolName: 'bar',
      paths: [barExeUri.toFilePath().unescape()],
    );
    final bazResolver = RelativeToolResolver(
      toolName: 'baz',
      wrappedResolver: barResolver,
      relativePath: Uri.file(bazExeName),
    );
    final resolvedBarInstances = await barResolver.resolve(systemContext);
    expect(resolvedBarInstances, [
      ToolInstance(
        tool: Tool(name: 'bar'),
        uri: barExeUri,
      ),
    ]);
    final resolvedBazInstances = await bazResolver.resolve(systemContext);
    expect(resolvedBazInstances, [
      ToolInstance(
        tool: Tool(name: 'baz'),
        uri: bazExeUri,
      ),
    ]);
  });

  test('logger', () async {
    final tempUri = await tempDirForTest();
    final barExeUri = tempUri.resolve(OS.current.executableFileName('bar'));
    final bazExeName = OS.current.executableFileName('baz');
    final bazExeUri = tempUri.resolve(bazExeName);
    await File.fromUri(barExeUri).writeAsString('dummy');
    final barResolver = InstallLocationResolver(
      toolName: 'bar',
      paths: [barExeUri.toFilePath().unescape()],
    );
    final bazResolver = InstallLocationResolver(
      toolName: 'baz',
      paths: [bazExeUri.toFilePath().unescape()],
    );
    final barLogs = <String>[];
    final bazLogs = <String>[];
    await barResolver.resolve(
      ToolResolvingContext(logger: createCapturingLogger(barLogs)),
    );
    await bazResolver.resolve(
      ToolResolvingContext(logger: createCapturingLogger(bazLogs)),
    );
    expect(barLogs.join('\n'), contains('Found [ToolInstance(bar'));
    expect(bazLogs.join('\n'), contains('Found no baz'));
  });

  test('PathToolResolver with memory file system', () async {
    final fileSystem = MemoryFileSystem(
      style: Platform.isWindows
          ? FileSystemStyle.windows
          : FileSystemStyle.posix,
    );
    // A tool laid out in the memory file system, found via a scripted `which`
    // (`where.exe` on Windows) invocation.
    final dir = fileSystem.systemTempDirectory.createTempSync();
    final toolFile = dir.childFile(OS.current.executableFileName('mytool'))
      ..createSync();

    final executableName = OS.current.executableFileName('mytool');
    final fakeProcessManager = FakeProcessManager([
      FakeCommand(
        command: [PathToolResolver.which.toFilePath(), executableName],
        stdout: '${toolFile.path}\n',
      ),
    ]);
    final context = ToolResolvingContext(
      logger: logger,
      processManager: fakeProcessManager,
      fileSystem: fileSystem,
    );

    final resolved = await PathToolResolver(
      toolName: 'mytool',
    ).resolve(context);
    expect(fakeProcessManager.allCommandsConsumed, true);
    expect(resolved.single.uri, toolFile.uri);
  });

  test('InstallLocationResolver with memory file system', () async {
    if (Platform.isWindows) {
      // A fake file system cannot be globbed on Windows: `package:glob`
      // refuses to list a glob whose style differs from the host platform's,
      // and a Windows style memory file system does not resolve the `C:/`
      // root that a glob pattern produces, since glob patterns must use
      // forward slashes.
      return;
    }
    // A POSIX fake keeps this test identical on the hosts where it runs.
    final fileSystem = MemoryFileSystem();
    // A tool laid out in the memory file system, found by globbing.
    final dir = fileSystem.systemTempDirectory.createTempSync();
    final barFile = dir.childFile('bar')..createSync();
    final context = ToolResolvingContext(
      logger: logger,
      fileSystem: fileSystem,
    );

    final resolver = InstallLocationResolver(
      toolName: 'bar',
      paths: [barFile.path],
    );
    final resolved = await resolver.resolve(context);
    expect(resolved.single.uri, barFile.uri);
  });
}
