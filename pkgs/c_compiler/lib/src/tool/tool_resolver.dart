// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:logging/logging.dart';
import 'package:native_assets_cli/native_assets_cli.dart';
import 'package:pub_semver/pub_semver.dart';

import '../utils/run_process.dart';
import '../utils/sem_version.dart';
import 'tool.dart';
import 'tool_error.dart';
import 'tool_instance.dart';

abstract class ToolResolver {
  /// Resolves tools on the host system.
  Future<List<ToolInstance>> resolve({Logger? logger});
}

/// Tries to resolve a tool on the `PATH`.
///
/// Uses `which` (`where` on Windows) to resolve a tool.
class PathToolResolver extends ToolResolver {
  /// The [Tool.name] of the [Tool] to find on the `PATH`.
  final String toolName;

  PathToolResolver({required this.toolName});

  @override
  Future<List<ToolInstance>> resolve({Logger? logger}) async {
    logger?.finer('Looking for $toolName on PATH.');
    final uri = await runWhich();
    if (uri == null) {
      logger?.fine('Did not find  $toolName on PATH.');
      return [];
    }
    final toolInstances = [
      ToolInstance(tool: Tool(name: toolName), uri: uri),
    ];
    logger?.fine('Found ${toolInstances.single}.');
    return toolInstances;
  }

  String get executableName =>
      Target.current.os.executableFileName(toolName.toLowerCase());

  static String get which => Platform.isWindows ? 'where' : 'which';

  Future<Uri?> runWhich() async {
    final process = await runProcess(
      executable: which,
      arguments: [executableName],
      throwOnFailure: false,
    );
    if (process.exitCode == 0) {
      final file = File(LineSplitter.split(process.stdout).first);
      final uri = File(await file.resolveSymbolicLinks()).uri;
      return uri;
    }
    // The exit code for executable not being on the `PATH`.
    assert(process.exitCode == 1);
    return null;
  }
}

class CliVersionResolver implements ToolResolver {
  ToolResolver wrappedResolver;

  CliVersionResolver({required this.wrappedResolver});

  @override
  Future<List<ToolInstance>> resolve({Logger? logger}) async {
    final toolInstances = await wrappedResolver.resolve(logger: logger);
    return [
      for (final toolInstance in toolInstances)
        await lookupVersion(toolInstance, logger: logger)
    ];
  }

  static Future<ToolInstance> lookupVersion(
    ToolInstance toolInstance, {
    Logger? logger,
  }) async {
    if (toolInstance.version != null) return toolInstance;
    logger?.finer('Looking up version with --version for $toolInstance.');
    final version = await executableVersion(toolInstance.uri);
    final result = toolInstance.copyWith(version: version);
    logger?.fine('Found version for $result.');
    return result;
  }

  static Future<Version> executableVersion(
    Uri executable, {
    String argument = '--version',
    int expectedExitCode = 0,
  }) async {
    final executablePath = executable.toFilePath();
    final process = await runProcess(
      executable: executablePath,
      arguments: [argument],
      throwOnFailure: expectedExitCode == 0,
    );
    if (process.exitCode != expectedExitCode) {
      throw ToolError(
          '`$executablePath $argument` returned unexpected exit code: '
          '${process.exitCode}.');
    }
    return versionFromString(process.stdout)!;
  }
}

class PathVersionResolver implements ToolResolver {
  ToolResolver wrappedResolver;

  PathVersionResolver({required this.wrappedResolver});

  @override
  Future<List<ToolInstance>> resolve({Logger? logger}) async {
    final toolInstances = await wrappedResolver.resolve(logger: logger);

    return [
      for (final toolInstance in toolInstances) lookupVersion(toolInstance)
    ];
  }

  static ToolInstance lookupVersion(ToolInstance toolInstance) {
    if (toolInstance.version != null) {
      return toolInstance;
    }
    return toolInstance.copyWith(
      version: version(toolInstance.uri),
    );
  }

  static Version? version(Uri uri) {
    final versionString = uri.pathSegments.where((e) => e != '').last;
    final version = versionFromString(versionString);
    return version;
  }
}

/// A resolver which invokes all [resolvers] tools.
class ToolResolvers implements ToolResolver {
  final List<ToolResolver> resolvers;

  ToolResolvers(this.resolvers);

  @override
  Future<List<ToolInstance>> resolve({Logger? logger}) async => [
        for (final resolver in resolvers)
          ...await resolver.resolve(logger: logger)
      ];
}

class InstallLocationResolver implements ToolResolver {
  final String toolName;
  final List<String> paths;

  InstallLocationResolver({
    required this.toolName,
    required this.paths,
  });

  static const home = '\$HOME';

  @override
  Future<List<ToolInstance>> resolve({Logger? logger}) async {
    logger?.finer('Looking for $toolName in $paths.');
    final resolvedPaths = [
      for (final path in paths) ...await tryResolvePath(path)
    ];
    final toolInstances = [
      for (final uri in resolvedPaths)
        ToolInstance(tool: Tool(name: toolName), uri: uri),
    ];
    if (toolInstances.isNotEmpty) {
      logger?.fine('Found $toolInstances.');
    } else {
      logger?.finer('Found no $toolName in $paths.');
    }
    return toolInstances;
  }

  Future<List<Uri>> tryResolvePath(String path) async {
    if (path.startsWith(home)) {
      final homeDir_ = homeDir;
      assert(homeDir_ != null);
      path = path.replaceAll('$home/', homeDir!.path);
    }

    final result = <Uri>[];
    final fileSystemEntities = await Glob(path).list().toList();
    for (final fileSystemEntity in fileSystemEntities) {
      if (await fileSystemEntity.exists()) {
        result.add(fileSystemEntity.uri);
      }
    }
    return result;
  }

  static final Uri? homeDir = () {
    final path =
        Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
    if (path == null) return null;
    return Directory(path).uri;
  }();
}

class RelativeToolResolver implements ToolResolver {
  final String toolName;
  final ToolResolver wrappedResolver;
  final Uri relativePath;

  RelativeToolResolver({
    required this.toolName,
    required this.wrappedResolver,
    required this.relativePath,
  });

  @override
  Future<List<ToolInstance>> resolve({Logger? logger}) async {
    final otherToolInstances = await wrappedResolver.resolve(logger: logger);

    logger?.finer('Looking for $toolName relative to $otherToolInstances '
        'with $relativePath.');
    final result = [
      for (final toolInstance in otherToolInstances)
        ToolInstance(
          tool: Tool(name: toolName),
          uri: toolInstance.uri.resolveUri(relativePath),
        ),
    ];
    if (result.isNotEmpty) {
      logger?.fine('Found $result.');
    } else {
      logger?.finer('Found no $toolName relative to $otherToolInstances.');
    }
    return result;
  }
}
