// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:data_assets/data_assets.dart';
import 'package:file/local.dart' show LocalFileSystem;
import 'package:hooks/hooks.dart';
import 'package:hooks_runner/src/utils/run_process.dart' as run_process;
import 'package:logging/logging.dart';
import 'package:native_test_helpers/native_test_helpers.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

extension UriExtension on Uri {
  Uri get parent => File(toFilePath()).parent.uri;

  FileSystemEntity get fileSystemEntity {
    if (path.endsWith(Platform.pathSeparator) || path.endsWith('/')) {
      return Directory.fromUri(this);
    }
    return File.fromUri(this);
  }
}

const keepTempKey = 'KEEP_TEMPORARY_DIRECTORIES';

Future<void> inTempDir(
  Future<void> Function(Uri tempUri) fun, {
  String? prefix,
  bool keepTemp = false,
}) async {
  final tempDir = await Directory.systemTemp.createTemp(prefix);
  // Deal with Windows temp folder aliases.
  final tempUri = Directory(
    await tempDir.resolveSymbolicLinks(),
  ).uri.normalizePath();
  try {
    await fun(tempUri);
  } finally {
    if ((!Platform.environment.containsKey(keepTempKey) ||
            Platform.environment[keepTempKey]!.isEmpty) &&
        !keepTemp) {
      try {
        await tempDir.delete(recursive: true);
      } on FileSystemException {
        // On Windows, the temp dir might still be locked even though all
        // process invocations have finished.
        if (!Platform.isWindows) rethrow;
      }
    } else {
      print('$keepTempKey $tempUri');
    }
  }
}

Future<Uri> tempDirForTest({String? prefix, bool keepTemp = false}) async {
  final tempDir = await Directory.systemTemp.createTemp(prefix);
  // Deal with Windows temp folder aliases.
  final tempUri = Directory(
    await tempDir.resolveSymbolicLinks(),
  ).uri.normalizePath();
  if ((!Platform.environment.containsKey(keepTempKey) ||
          Platform.environment[keepTempKey]!.isEmpty) &&
      !keepTemp) {
    addTearDown(() async {
      try {
        await tempDir.delete(recursive: true);
      } on FileSystemException {
        // On Windows, the temp dir might still be locked even though all
        // process invocations have finished.
        if (!Platform.isWindows) rethrow;
      }
    });
  } else {
    print('$keepTempKey $tempUri');
  }
  return tempUri;
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
  required Logger? logger,
  bool captureOutput = true,
  int expectedExitCode = 0,
  bool throwOnUnexpectedExitCode = false,
}) => run_process.runProcess(
  filesystem: const LocalFileSystem(),
  executable: executable,
  arguments: arguments,
  workingDirectory: workingDirectory,
  environment: environment,
  logger: logger,
  captureOutput: captureOutput,
  expectedExitCode: expectedExitCode,
  throwOnUnexpectedExitCode: throwOnUnexpectedExitCode,
);

final pkgNativeAssetsBuilderUri = findPackageRoot('hooks_runner');

final testDataUri = pkgNativeAssetsBuilderUri.resolve('test_data/');

/// Archiver provided by the environment.
///
/// Provided on Dart CI.
final Uri? _ar = Platform.environment['DART_HOOK_TESTING_C_COMPILER__AR']
    ?.asFileUri();

/// Compiler provided by the environment.
///
/// Provided on Dart CI.
final Uri? _cc = Platform.environment['DART_HOOK_TESTING_C_COMPILER__CC']
    ?.asFileUri();

/// Linker provided by the environment.
///
/// Provided on Dart CI.
final Uri? _ld = Platform.environment['DART_HOOK_TESTING_C_COMPILER__LD']
    ?.asFileUri();

/// Path to script that sets environment variables for [_cc], [_ld], and [_ar].
///
/// Provided on Dart CI.
final Uri? _envScript = Platform
    .environment['DART_HOOK_TESTING_C_COMPILER__ENV_SCRIPT']
    ?.asFileUri();

/// Arguments for [_envScript] provided by environment.
///
/// Provided on Dart CI.
final List<String>? _envScriptArgs = Platform
    .environment['DART_HOOK_TESTING_C_COMPILER__ENV_SCRIPT_ARGUMENTS']
    ?.split(' ');

/// Configuration for the native toolchain.
///
/// Provided on Dart CI.
final cCompiler = (_cc == null || _ar == null || _ld == null)
    ? null
    : CCompilerConfig(
        compiler: _cc!,
        archiver: _ar!,
        linker: _ld!,
        windows: _envScript == null
            ? null
            : WindowsCCompilerConfig(
                developerCommandPrompt: DeveloperCommandPrompt(
                  script: _envScript!,
                  arguments: _envScriptArgs ?? [],
                ),
              ),
      );

extension on String {
  Uri asFileUri() => Uri.file(this);
}

extension AssetIterable on Iterable<EncodedAsset> {
  Future<bool> allExist() async {
    for (final encodedAsset in this) {
      if (encodedAsset.isDataAsset) {
        final dataAsset = encodedAsset.asDataAsset;
        if (!await dataAsset.file.fileSystemEntity.exists()) {
          return false;
        }
      } else if (encodedAsset.isCodeAsset) {
        final codeAsset = encodedAsset.asCodeAsset;
        if (!await (codeAsset.file?.fileSystemEntity.exists() ?? true)) {
          return false;
        }
      } else {
        throw UnimplementedError('Unknown asset type ${encodedAsset.type}');
      }
    }
    return true;
  }
}

Future<void> copyTestProjects({
  Uri? sourceUri,
  required Uri targetUri,
  bool addDependencyOverrides = true,
}) async {
  sourceUri ??= testDataUri;
  final manifestUri = sourceUri.resolve('manifest.yaml');
  final manifestFile = File.fromUri(manifestUri);
  final manifestString = await manifestFile.readAsString();
  final manifestYaml = loadYamlDocument(manifestString);
  final manifest = [
    for (final path in manifestYaml.contents as List<Object?>)
      Uri(path: path as String),
  ];
  final filesToCopy = manifest
      .where(
        (e) =>
            !(e.pathSegments.last.startsWith('pubspec') &&
                e.pathSegments.last.endsWith('.yaml')),
      )
      .toList();
  final filesToModify = manifest
      .where(
        (e) =>
            e.pathSegments.last.startsWith('pubspec') &&
            e.pathSegments.last.endsWith('.yaml'),
      )
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
    var sourceString = await sourceFile.readAsString();
    if (addDependencyOverrides &&
        !pathToModify.path.contains('native_add_version_skew')) {
      sourceString += '''

dependency_overrides:
''';
      const packagesToOverride = [
        'code_assets',
        'data_assets',
        'hooks',
        'native_toolchain_c',
        'record_use',
      ];
      for (final package in packagesToOverride) {
        sourceString +=
            '''
  $package:
    path: ${pkgNativeAssetsBuilderUri.resolve('../$package/').toFilePath()}
''';
      }
    }

    final modifiedString = sourceString.replaceAll('resolution: workspace', '');
    await File.fromUri(
      targetFileUri,
    ).writeAsString(modifiedString, flush: true);
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
}) => _createTestLogger(capturedMessages: capturedMessages, level: level);

Logger _createTestLogger({
  List<String>? capturedMessages,
  Level level = Level.ALL,
}) => Logger.detached('')
  ..level = level
  ..onRecord.listen((record) {
    printOnFailure('${record.level.name}: ${record.time}: ${record.message}');
    capturedMessages?.add(record.message);
  });

final dartExecutable = File(Platform.resolvedExecutable).uri;
