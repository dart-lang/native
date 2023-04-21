// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:logging/logging.dart';

import '../tool/tool.dart';
import '../tool/tool_instance.dart';
import '../tool/tool_resolver.dart';
import '../utils/run_process.dart';
import '../utils/sem_version.dart';

/// The Visual Studio Locator.
///
/// https://github.com/microsoft/vswhere
final Tool vswhere = Tool(
  name: 'Visual Studio Locator',
  defaultResolver: CliVersionResolver(
    arguments: [],
    wrappedResolver: ToolResolvers(
      [
        PathToolResolver(
          toolName: 'Visual Studio Locator',
          executableName: 'vswhere.exe',
        ),
        InstallLocationResolver(
          toolName: 'Visual Studio Locator',
          paths: [
            'C:/Program Files \\(x86\\)/Microsoft Visual Studio/Installer/vswhere.exe',
            'C:/Program Files/Microsoft Visual Studio/Installer/vswhere.exe',
          ],
        ),
      ],
    ),
  ),
);

/// Visual Studio.
///
/// https://visualstudio.microsoft.com/
final Tool visualStudio = Tool(
  name: 'Visual Studio',
  defaultResolver: VisualStudioResolver(),
);

class VisualStudioResolver implements ToolResolver {
  @override
  Future<List<ToolInstance>> resolve({Logger? logger}) async {
    final vswhereInstances =
        await vswhere.defaultResolver!.resolve(logger: logger);

    final result = <ToolInstance>[];
    for (final vswhereInstance in vswhereInstances.take(1)) {
      final vswhereResult = await runProcess(
        executable: vswhereInstance.uri,
        logger: logger,
      );
      final toolInfos = vswhereResult.stdout.split(_newLine * 2).skip(1);
      for (final toolInfo in toolInfos) {
        final toolInfoParsed = parseToolInfo(toolInfo);
        final dir = Directory(toolInfoParsed['installationPath']!);
        assert(await dir.exists());
        final uri = dir.uri;
        final version = versionFromString(toolInfoParsed['installationName']!);
        final instance =
            ToolInstance(tool: visualStudio, uri: uri, version: version);
        logger?.fine('Found $instance.');
        result.add(instance);
      }
    }
    return result;
  }

  static Map<String, String> parseToolInfo(String toolInfo) {
    final result = <String, String>{};
    final lines = toolInfo.split(_newLine);
    for (final line in lines) {
      final splitLine = line.split(': ');
      final key = splitLine.first;
      final value = splitLine.skip(1).join(': ');
      result[key] = value;
    }
    return result;
  }
}

const _newLine = '\r\n';
