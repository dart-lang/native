// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:logging/logging.dart';
import 'package:pub_semver/pub_semver.dart';

import '../utils/run_process.dart';
import '../utils/sem_version.dart';
import 'tool.dart';
import 'tool_error.dart';
import 'tool_instance.dart';

abstract class ToolResolver {
  /// Resolves tools on the host system.
  Future<List<ToolInstance>> resolve(ToolResolvingContext context);
}

/// A context passed to [ToolResolver.resolve].
///
/// To keep resolvers testable, [ToolResolver.resolve] should ideally not access
/// global state not available in this context. Not all resolvers adhere to that
/// though, since some need to run subprocesses to resolve tools.
final class ToolResolvingContext {
  // TODO: Expose package:file and package:process environments here and use
  // them in resolvers to consistently mock external state.

  final Logger? logger;
  final Map<String, String> environment;

  ToolResolvingContext({required this.logger, Map<String, String>? environment})
    : environment = environment ?? Platform.environment;
}

/// Tries to resolve a tool on the `PATH`.
///
/// Uses `which` (`where` on Windows) to resolve a tool.
class PathToolResolver extends ToolResolver {
  /// The [Tool.name] of the [Tool] to find on the `PATH`.
  final String toolName;

  final String executableName;

  PathToolResolver({required this.toolName, String? executableName})
    : executableName =
          executableName ??
          OS.current.executableFileName(toolName.toLowerCase());

  @override
  Future<List<ToolInstance>> resolve(ToolResolvingContext context) async {
    final logger = context.logger;
    logger?.finer('Looking for $toolName on PATH.');
    final uri = await runWhich(context);
    if (uri == null) {
      logger?.fine('Did not find  $toolName on PATH.');
      return [];
    }
    final toolInstances = [
      ToolInstance(
        tool: Tool(name: toolName),
        uri: uri,
      ),
    ];
    logger?.fine('Found ${toolInstances.single}.');
    return toolInstances;
  }

  static Uri get which => Uri.file(Platform.isWindows ? 'where' : 'which');

  Future<Uri?> runWhich(ToolResolvingContext context) async {
    final process = await runProcess(
      executable: which,
      arguments: [executableName],
      logger: context.logger,
    );
    if (process.exitCode == 0) {
      final file = File(LineSplitter.split(process.stdout).first);
      final uri = File(await file.resolveSymbolicLinks()).uri;
      if (uri.pathSegments.last == 'llvm') {
        // https://github.com/dart-lang/native/issues/136
        return file.uri;
      }
      return uri;
    }
    // The exit code for executable not being on the `PATH`.
    assert(process.exitCode == 1);
    return null;
  }
}

class CliVersionResolver implements ToolResolver {
  final ToolResolver wrappedResolver;
  final List<String> arguments;
  final int expectedExitCode;

  CliVersionResolver({
    required this.wrappedResolver,
    this.arguments = const ['--version'],
    this.expectedExitCode = 0,
  });

  @override
  Future<List<ToolInstance>> resolve(ToolResolvingContext context) async {
    final toolInstances = await wrappedResolver.resolve(context);
    return [
      for (final toolInstance in toolInstances)
        await lookupVersion(
          toolInstance,
          arguments: arguments,
          expectedExitCode: expectedExitCode,
          logger: context.logger,
        ),
    ];
  }

  static Future<ToolInstance> lookupVersion(
    ToolInstance toolInstance, {
    List<String> arguments = const ['--version'],
    int expectedExitCode = 0,
    required Logger? logger,
  }) async {
    if (toolInstance.version != null) return toolInstance;
    logger?.finer('Looking up version with --version for $toolInstance.');
    final version = await executableVersion(
      toolInstance.uri,
      arguments: arguments,
      expectedExitCode: expectedExitCode,
      logger: logger,
    );
    final result = toolInstance.copyWith(version: version);
    logger?.fine('Found version for $result.');
    return result;
  }

  static Future<Version> executableVersion(
    Uri executable, {
    List<String> arguments = const ['--version'],
    int expectedExitCode = 0,
    required Logger? logger,
  }) async {
    final process = await runProcess(
      executable: executable,
      arguments: arguments,
      logger: logger,
    );
    if (process.exitCode != expectedExitCode) {
      final executablePath = executable.toFilePath();
      throw ToolError(
        '`$executablePath ${arguments.join(' ')}` returned unexpected exit'
        ' code: ${process.exitCode}.',
      );
    }
    return versionFromString(process.stderr) ??
        versionFromString(process.stdout)!;
  }
}

/// Wraps a [ToolResolver] to attach the version number of found tools if they
/// have not been found by [wrappedResolver] directly.
class PathVersionResolver implements ToolResolver {
  ToolResolver wrappedResolver;

  PathVersionResolver({required this.wrappedResolver});

  @override
  Future<List<ToolInstance>> resolve(ToolResolvingContext context) async {
    final toolInstances = await wrappedResolver.resolve(context);

    return [
      for (final toolInstance in toolInstances) lookupVersion(toolInstance),
    ];
  }

  static ToolInstance lookupVersion(ToolInstance toolInstance) {
    if (toolInstance.version != null) {
      return toolInstance;
    }
    return toolInstance.copyWith(version: version(toolInstance.uri));
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
  Future<List<ToolInstance>> resolve(ToolResolvingContext context) async => [
    for (final resolver in resolvers) ...await resolver.resolve(context),
  ];
}

/// A tool resolver that looks for tools in a glob of [paths] if they exist.
class InstallLocationResolver implements ToolResolver {
  final String toolName;
  final List<String> paths;

  InstallLocationResolver({required this.toolName, required this.paths});

  static const home = '\$HOME';

  @override
  Future<List<ToolInstance>> resolve(ToolResolvingContext context) async {
    final logger = context.logger;
    logger?.finer('Looking for $toolName in $paths.');
    final resolvedPaths = [
      for (final path in paths) ...await tryResolvePath(path),
    ];
    final toolInstances = [
      for (final uri in resolvedPaths)
        ToolInstance(
          tool: Tool(name: toolName),
          uri: uri,
        ),
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
      if (homeDir_ == null) return [];
      path = path.replaceAll(
        '$home/',
        homeDir!.toFilePath().replaceAll('\\', '/'),
      );
    }

    final result = <Uri>[];
    final fileSystemEntities = await Glob(path).list().toList();
    for (final fileSystemEntity in fileSystemEntities) {
      if (!await fileSystemEntity.exists()) {
        continue;
      }
      if (fileSystemEntity is! Directory && path.endsWith('/')) {
        continue;
      }
      result.add(fileSystemEntity.uri);
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

/// A tool resolver considering environment variables such as `ANDROID_HOME`.
class EnvironmentVariableResolver implements ToolResolver {
  final String toolName;

  /// Considered environment variables, mapped to a [Glob] identifying paths in
  /// the variable to consider.
  ///
  /// For instance, `{'ANDROID_HOME': Glob('ndk/*/')}` would report one tool
  /// instance per sub-directory of `$ANDROID_HOME/ndk/` if that environment
  /// variable is set.
  ///
  /// A null value would consider the key itself as a directory.
  final Map<String, Glob?> keys;

  EnvironmentVariableResolver({required this.toolName, required this.keys});

  @override
  Future<List<ToolInstance>> resolve(ToolResolvingContext context) async {
    final logger = context.logger;
    final foundTools = <ToolInstance>[];
    for (final MapEntry(:key, value: glob) in keys.entries) {
      logger?.fine('Looking for $toolName in environment variable $key');
      if (context.environment[key] case final found?) {
        final fileSystemEntities = switch (glob) {
          null => [Directory(found)],
          final glob =>
            await glob
                .list(root: found)
                .where(
                  // If the path ends in /, only consider directories
                  (entity) =>
                      entity is Directory || !glob.pattern.endsWith('/'),
                )
                .toList(),
        };

        for (final fileSystemEntity in fileSystemEntities) {
          if (!await fileSystemEntity.exists()) {
            continue;
          }

          foundTools.add(
            ToolInstance(
              tool: Tool(name: toolName),
              uri: fileSystemEntity.uri,
            ),
          );
        }
      }
    }

    return foundTools;
  }
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
  Future<List<ToolInstance>> resolve(ToolResolvingContext context) async {
    final logger = context.logger;
    final otherToolInstances = await wrappedResolver.resolve(context);

    logger?.finer(
      'Looking for $toolName relative to $otherToolInstances '
      'with $relativePath.',
    );
    final globs = [
      for (final toolInstance in otherToolInstances)
        Glob(
          [
            Glob.quote(
              toolInstance.uri.resolve('.').toFilePath().replaceAll('\\', '/'),
            ),
            relativePath.path,
          ].join(),
        ),
    ];
    final fileSystemEntities = [
      for (final glob in globs) ...await glob.list().toList(),
    ];

    final result = [
      for (final fileSystemEntity in fileSystemEntities)
        ToolInstance(
          tool: Tool(name: toolName),
          uri: fileSystemEntity.uri,
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

class CliFilter implements ToolResolver {
  final ToolResolver wrappedResolver;
  final List<String> cliArguments;
  final bool Function({required String stdout}) keepIf;

  CliFilter({
    required this.wrappedResolver,
    required this.cliArguments,
    required this.keepIf,
  });

  @override
  Future<List<ToolInstance>> resolve(ToolResolvingContext context) async {
    final toolInstances = await wrappedResolver.resolve(context);
    return [
      for (final toolInstance in toolInstances)
        await filter(toolInstance, logger: context.logger),
    ].whereType<ToolInstance>().toList();
  }

  Future<ToolInstance?> filter(
    ToolInstance toolInstance, {
    required Logger? logger,
  }) async {
    if (toolInstance.version != null) return toolInstance;
    logger?.finer('Checking if $toolInstance satisfies CLI filter.');
    final stdout = await executeCli(
      toolInstance.uri,
      arguments: cliArguments,
      logger: logger,
    );
    final doKeep = keepIf(stdout: stdout);
    if (doKeep) {
      logger?.fine('$toolInstance satisfies CLI filter.');
      return toolInstance;
    }
    logger?.fine('$toolInstance does not satisfy CLI filter.');
    return null;
  }

  static Future<String> executeCli(
    Uri executable, {
    required List<String> arguments,
    int expectedExitCode = 0,
    required Logger? logger,
  }) async {
    final process = await runProcess(
      executable: executable,
      arguments: arguments,
      logger: logger,
    );
    final exitCode = process.exitCode;
    assert(exitCode == expectedExitCode);
    return process.stdout;
  }
}
