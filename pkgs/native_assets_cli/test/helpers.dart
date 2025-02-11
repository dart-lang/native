// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:logging/logging.dart';
import 'package:native_assets_cli/code_assets_builder.dart';
import 'package:native_assets_cli/data_assets_builder.dart';
import 'package:test/test.dart';

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

Uri packageUri = findPackageRoot('native_assets_cli');

extension on Uri {
  String get name => pathSegments.where((e) => e != '').last;
}

/// Archiver provided by the environment.
///
/// Provided on Dart CI.
final Uri? _ar =
    Platform.environment['DART_HOOK_TESTING_C_COMPILER__AR']?.asFileUri();

/// Compiler provided by the environment.
///
/// Provided on Dart CI.
final Uri? _cc =
    Platform.environment['DART_HOOK_TESTING_C_COMPILER__CC']?.asFileUri();

/// Linker provided by the environment.
///
/// Provided on Dart CI.
final Uri? _ld =
    Platform.environment['DART_HOOK_TESTING_C_COMPILER__LD']?.asFileUri();

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
        windows: WindowsCCompilerConfig(
          developerCommandPrompt: _envScript == null
              ? null
              : DeveloperCommandPrompt(
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
      if (encodedAsset.type == DataAsset.type) {
        final dataAsset = DataAsset.fromEncoded(encodedAsset);
        if (!await dataAsset.file.fileSystemEntity.exists()) {
          return false;
        }
      } else if (encodedAsset.type == CodeAsset.type) {
        final codeAsset = CodeAsset.fromEncoded(encodedAsset);
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

extension UnescapePath on String {
  String unescape() => replaceAll('\\', '/');
}

extension UriExtension on Uri {
  FileSystemEntity get fileSystemEntity {
    if (path.endsWith(Platform.pathSeparator) || path.endsWith('/')) {
      return Directory.fromUri(this);
    }
    return File.fromUri(this);
  }
}

/// Logger that outputs the full trace when a test fails.
Logger get logger => _logger ??= () {
      // A new logger is lazily created for each test so that the messages
      // captured by printOnFailure are scoped to the correct test.
      addTearDown(() => _logger = null);
      return _createTestLogger();
    }();

Logger? _logger;

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

int defaultMacOSVersion = 13;
