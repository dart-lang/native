// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:logging/logging.dart';

import '../tool/tool.dart';
import '../tool/tool_instance.dart';
import '../tool/tool_resolver.dart';
import '../utils/run_process.dart';

final wsl = Tool(
  name: 'WSL',
  defaultResolver: PathToolResolver(
    toolName: 'WSL',
    executableName: 'wsl',
  ),
);

/// Resolves a tool that lives inside WSL (Windows -> Linux cross builds).
///
/// Runs `wsl which <executableName>` and records `wsl` as the
/// [ToolInstance.launcher], so it's later invoked as `wsl <uri> <args>`.
class WslToolResolver implements ToolResolver {
  WslToolResolver({required this.toolName, required this.executableName});

  final String toolName;
  final String executableName;

  @override
  Future<List<ToolInstance>> resolve(ToolResolvingContext context) async {
    if (!Platform.isWindows) return [];
    final wslToolInstances = await wsl.defaultResolver!.resolve(context);
    return [
      for (final wslInstance in wslToolInstances)
        ...await _tryResolve(wslInstance, context.logger),
    ];
  }

  Future<List<ToolInstance>> _tryResolve(
    ToolInstance wslToolInstance,
    Logger? logger,
  ) async {
    final result = await runProcess(
      executable: wslToolInstance.uri,
      arguments: ['which', executableName],
      logger: logger,
    );
    if (result.exitCode != 0) return [];
    final uri = Uri.file(result.stdout.trim(), windows: false);
    logger?.fine('Found $executableName in WSL at ${uri.toFilePath()}');
    return [
      ToolInstance(
        tool: Tool(name: toolName),
        uri: uri,
        launcher: wslToolInstance,
      ),
    ];
  }
}
