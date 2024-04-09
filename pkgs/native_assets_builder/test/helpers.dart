// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:native_assets_builder/src/utils/run_process.dart'
    as run_process;
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

extension UriExtension on Uri {
  Uri get parent => File(toFilePath()).parent.uri;
}

const keepTempKey = 'KEEP_TEMPORARY_DIRECTORIES';

Future<void> inTempDir(
  Future<void> Function(Uri tempUri) fun, {
  String? prefix,
  bool keepTemp = false,
}) async {
  final tempDir = await Directory.systemTemp.createTemp(prefix);
  // Deal with Windows temp folder aliases.
  final tempUri =
      Directory(await tempDir.resolveSymbolicLinks()).uri.normalizePath();
  try {
    await fun(tempUri);
  } finally {
    if ((!Platform.environment.containsKey(keepTempKey) ||
            Platform.environment[keepTempKey]!.isEmpty) &&
        !keepTemp) {
      await tempDir.delete(recursive: true);
    }
  }
}

/// Runs a [Process].
///
/// If [logger] is provided, stream stdout and stderr to it.
///
/// If [captureOutput], captures stdout and stderr.
Future<run_process.RunProcessResult> runProcess({
  required Uri executable,
  List<String> arguments = const [],
  Uri? workingDirectory,
  Map<String, String>? environment,
  bool includeParentEnvironment = true,
  required Logger? logger,
  bool captureOutput = true,
  int expectedExitCode = 0,
  bool throwOnUnexpectedExitCode = false,
}) =>
    run_process.runProcess(
      executable: executable,
      arguments: arguments,
      workingDirectory: workingDirectory,
      environment: environment,
      includeParentEnvironment: includeParentEnvironment,
      logger: logger,
      captureOutput: captureOutput,
      expectedExitCode: expectedExitCode,
      throwOnUnexpectedExitCode: throwOnUnexpectedExitCode,
    );

/// Test files are run in a variety of ways, find this package root in all.
///
/// Test files can be run from source from any working directory. The Dart SDK
/// `tools/test.py` runs them from the root of the SDK for example.
///
/// Test files can be run from dill from the root of package. `package:test`
/// does this.
///
/// https://github.com/dart-lang/test/issues/110
Uri findPackageRoot(String packageName) {
  final script = Platform.script;
  final fileName = script.name;
  if (fileName.endsWith('_test.dart')) {
    // We're likely running from source.
    var directory = script.resolve('.');
    while (true) {
      final dirName = directory.name;
      if (dirName == packageName) {
        return directory;
      }
      final parent = directory.resolve('..');
      if (parent == directory) break;
      directory = parent;
    }
  } else if (fileName.endsWith('.dill')) {
    final cwd = Directory.current.uri;
    final dirName = cwd.name;
    if (dirName == packageName) {
      return cwd;
    }
  }
  throw StateError("Could not find package root for package '$packageName'. "
      'Tried finding the package root via Platform.script '
      "'${Platform.script.toFilePath()}' and Directory.current "
      "'${Directory.current.uri.toFilePath()}'.");
}

final pkgNativeAssetsBuilderUri = findPackageRoot('native_assets_builder');

final testDataUri = pkgNativeAssetsBuilderUri.resolve('test_data/');

extension on Uri {
  String get name => pathSegments.where((e) => e != '').last;
}

Future<void> copyTestProjects({
  Uri? sourceUri,
  required Uri targetUri,
}) async {
  sourceUri ??= testDataUri;
  final manifestUri = sourceUri.resolve('manifest.yaml');
  final manifestFile = File.fromUri(manifestUri);
  final manifestString = await manifestFile.readAsString();
  final manifestYaml = loadYamlDocument(manifestString);
  final manifest = [
    for (final path in manifestYaml.contents as List<Object?>)
      Uri(path: path as String)
  ];
  final filesToCopy = manifest
      .where((e) => !(e.pathSegments.last.startsWith('pubspec') &&
          e.pathSegments.last.endsWith('.yaml')))
      .toList();
  final filesToModify = manifest
      .where((e) =>
          e.pathSegments.last.startsWith('pubspec') &&
          e.pathSegments.last.endsWith('.yaml'))
      .toList();

  for (final pathToCopy in filesToCopy) {
    final sourceFile = File.fromUri(sourceUri.resolveUri(pathToCopy));
    final targetFileUri = targetUri.resolveUri(pathToCopy);
    final targetDirUri = targetFileUri.parent;
    final targetDir = Directory.fromUri(targetDirUri);
    if (!(await targetDir.exists())) {
      await targetDir.create(recursive: true);
    }

    // Copying files on MacOS and Windows preserves the source timestamps.
    // The builder will use the cached build if the timestamps are equal.
    // So just write the file instead.
    final targetFile = File.fromUri(targetFileUri);
    await targetFile.writeAsBytes(await sourceFile.readAsBytes());
  }
  for (final pathToModify in filesToModify) {
    final sourceFile = File.fromUri(sourceUri.resolveUri(pathToModify));
    final targetFileUri = targetUri.resolveUri(pathToModify);
    final sourceString = await sourceFile.readAsString();
    final modifiedString = sourceString.replaceAll(
      'path: ../../',
      'path: ${pkgNativeAssetsBuilderUri.toFilePath().unescape()}',
    );
    await File.fromUri(targetFileUri)
        .writeAsString(modifiedString, flush: true);
  }
}

extension UnescapePath on String {
  /// Remove double encoding of slashes on windows, for string comparison with
  /// Unix-style encoded strings.
  String unescape() => replaceAll('\\', '/');
}

/// Logger that outputs the full trace when a test fails.
Logger get logger => _logger ??= () {
      // A new logger is lazily created for each test so that the messages
      // captured by printOnFailure are scoped to the correct test.
      addTearDown(() => _logger = null);
      return _createTestLogger();
    }();

Logger? _logger;

Logger createCapturingLogger(
  List<String> capturedMessages, {
  Level level = Level.ALL,
}) =>
    _createTestLogger(capturedMessages: capturedMessages, level: level);

Logger _createTestLogger({
  List<String>? capturedMessages,
  Level level = Level.ALL,
}) =>
    Logger.detached('')
      ..level = level
      ..onRecord.listen((record) {
        printOnFailure(
          '${record.level.name}: ${record.time}: ${record.message}',
        );
        capturedMessages?.add(record.message);
      });

final dartExecutable = File(Platform.resolvedExecutable).uri;
