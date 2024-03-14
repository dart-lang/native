// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:native_assets_cli/native_assets_cli.dart';
import 'package:native_toolchain_c/src/native_toolchain/apple_clang.dart';
import 'package:native_toolchain_c/src/native_toolchain/clang.dart';
import 'package:native_toolchain_c/src/native_toolchain/msvc.dart';
import 'package:native_toolchain_c/src/tool/tool.dart';
import 'package:native_toolchain_c/src/tool/tool_error.dart';
import 'package:native_toolchain_c/src/tool/tool_instance.dart';
import 'package:native_toolchain_c/src/tool/tool_resolver.dart';
import 'package:test/test.dart';

import '../helpers.dart';

void main() {
  test('CliVersionResolver.executableVersion', () async {
    final toolInstances = [
      ...await appleClang.defaultResolver!.resolve(logger: logger),
      ...await clang.defaultResolver!.resolve(logger: logger),
      ...await cl.defaultResolver!.resolve(logger: logger),
    ];
    expect(toolInstances.isNotEmpty, true);
    final toolInstance = toolInstances.first;
    final versionArguments = [
      if (toolInstance.tool != cl) '--version',
    ];
    final version = await CliVersionResolver.executableVersion(
      toolInstance.uri,
      arguments: versionArguments,
      logger: logger,
    );
    expect(version.major > 5, true);
    expect(
      () => CliVersionResolver.executableVersion(
        toolInstances.first.uri,
        arguments: versionArguments,
        expectedExitCode: 9999,
        logger: logger,
      ),
      throwsA(isA<ToolError>()),
    );

    try {
      await CliVersionResolver.executableVersion(
        toolInstances.first.uri,
        arguments: versionArguments,
        expectedExitCode: 9999,
        logger: logger,
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
      paths: [barExeUri.toFilePath().replaceAll('\\', '/')],
    );
    final bazResolver = RelativeToolResolver(
      toolName: 'baz',
      wrappedResolver: barResolver,
      relativePath: Uri.file(bazExeName),
    );
    final resolvedBarInstances = await barResolver.resolve(logger: logger);
    expect(
      resolvedBarInstances,
      [ToolInstance(tool: Tool(name: 'bar'), uri: barExeUri)],
    );
    final resolvedBazInstances = await bazResolver.resolve(logger: logger);
    expect(
      resolvedBazInstances,
      [ToolInstance(tool: Tool(name: 'baz'), uri: bazExeUri)],
    );
  });

  test('logger', () async {
    final tempUri = await tempDirForTest();
    final barExeUri = tempUri.resolve(OS.current.executableFileName('bar'));
    final bazExeName = OS.current.executableFileName('baz');
    final bazExeUri = tempUri.resolve(bazExeName);
    await File.fromUri(barExeUri).writeAsString('dummy');
    final barResolver = InstallLocationResolver(
        toolName: 'bar', paths: [barExeUri.toFilePath().replaceAll('\\', '/')]);
    final bazResolver = InstallLocationResolver(
        toolName: 'baz', paths: [bazExeUri.toFilePath().replaceAll('\\', '/')]);
    final barLogs = <String>[];
    final bazLogs = <String>[];
    await barResolver.resolve(logger: createCapturingLogger(barLogs));
    await bazResolver.resolve(logger: createCapturingLogger(bazLogs));
    expect(barLogs.join('\n'), contains('Found [ToolInstance(bar'));
    expect(bazLogs.join('\n'), contains('Found no baz'));
  });
}
