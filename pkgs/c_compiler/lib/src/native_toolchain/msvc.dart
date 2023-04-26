// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:logging/logging.dart';
import 'package:native_assets_cli/native_assets_cli.dart';

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

/// The C/C++ Optimizing Compiler.
final Tool msvc = Tool(
  name: 'MSVC',
  defaultResolver: PathVersionResolver(
    wrappedResolver: RelativeToolResolver(
      toolName: 'MSVC',
      wrappedResolver: visualStudio.defaultResolver!,
      relativePath: Uri(path: './VC/Tools/MSVC/*/'),
    ),
  ),
);

final Tool vcvars64 = Tool(
  name: 'vcvars64.bat',
  defaultResolver: RelativeToolResolver(
    toolName: 'vcvars64.bat',
    wrappedResolver: visualStudio.defaultResolver!,
    relativePath: Uri(path: './VC/Auxiliary/Build/vcvars64.bat'),
  ),
);

final Tool vcvars32 = Tool(
  name: 'vcvars32.bat',
  defaultResolver: RelativeToolResolver(
    toolName: 'vcvars32.bat',
    wrappedResolver: visualStudio.defaultResolver!,
    relativePath: Uri(path: './VC/Auxiliary/Build/vcvars32.bat'),
  ),
);

final Tool vcvarsall = Tool(
  name: 'vcvarsall.bat',
  defaultResolver: RelativeToolResolver(
    toolName: 'vcvars32.bat',
    wrappedResolver: visualStudio.defaultResolver!,
    relativePath: Uri(path: './VC/Auxiliary/Build/vcvarsall.bat'),
  ),
);

final Tool vsDevCmd = Tool(
  name: 'VsDevCmd.bat',
  defaultResolver: RelativeToolResolver(
    toolName: 'VsDevCmd.bat',
    wrappedResolver: visualStudio.defaultResolver!,
    relativePath: Uri(path: './Common7/Tools/VsDevCmd.bat'),
  ),
);

/// The C/C++ Optimizing Compiler main executable.
///
/// For targeting x64.
final Tool cl = _msvcTool(
  name: 'cl',
  versionArguments: [],
  targetArchitecture: Architecture.x64,
  hostArchitecture: Target.current.architecture,
);

/// The C/C++ Optimizing Compiler main executable.
///
/// For targeting ia32.
final Tool clIA32 = _msvcTool(
  name: 'cl',
  versionArguments: [],
  targetArchitecture: Architecture.ia32,
  hostArchitecture: Target.current.architecture,
);

final Tool lib = _msvcTool(
  name: 'lib',
  targetArchitecture: Architecture.x64,
  hostArchitecture: Target.current.architecture,
  // https://github.com/dart-lang/native/issues/18
  resolveVersion: false,
);

final Tool libIA32 = _msvcTool(
  name: 'lib',
  targetArchitecture: Architecture.ia32,
  hostArchitecture: Target.current.architecture,
  // https://github.com/dart-lang/native/issues/18
  resolveVersion: false,
);

final Tool link = _msvcTool(
  name: 'link',
  versionArguments: ['/help'],
  versionExitCode: 1100,
  targetArchitecture: Architecture.x64,
  hostArchitecture: Target.current.architecture,
);

final Tool linkIA32 = _msvcTool(
  name: 'link',
  versionArguments: ['/help'],
  versionExitCode: 1100,
  targetArchitecture: Architecture.ia32,
  hostArchitecture: Target.current.architecture,
);

final Tool dumpbin = _msvcTool(
  name: 'dumpbin',
  targetArchitecture: Architecture.x64,
  hostArchitecture: Target.current.architecture,
);

const _msvcArchNames = {
  Architecture.ia32: 'x86',
  Architecture.x64: 'x64',
};

Tool _msvcTool({
  required String name,
  required Architecture targetArchitecture,
  required Architecture hostArchitecture,
  List<String> versionArguments = const ['--version'],
  int versionExitCode = 0,
  bool resolveVersion = true,
}) {
  final executableName = OS.windows.executableFileName(name);
  ToolResolver resolver = RelativeToolResolver(
    toolName: executableName,
    wrappedResolver: msvc.defaultResolver!,
    relativePath: Uri(
      path: 'bin/Host${_msvcArchNames[hostArchitecture]!}/'
          '${_msvcArchNames[targetArchitecture]!}/$executableName',
    ),
  );
  if (resolveVersion) {
    resolver = CliVersionResolver(
      expectedExitCode: versionExitCode,
      arguments: versionArguments,
      wrappedResolver: resolver,
    );
  }
  return Tool(
    name: executableName,
    defaultResolver: resolver,
  );
}

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
