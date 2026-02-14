// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:data_assets/data_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:logging/logging.dart';
import 'package:native_test_helpers/native_test_helpers.dart';
import 'package:test/test.dart';

const keepTempKey = 'KEEP_TEMPORARY_DIRECTORIES';

Future<void> inTempDir(
  Future<void> Function(Uri tempUri) fun, {
  String? prefix,
  bool keepTemp = false,
}) async {
  final tempDir = await Directory.systemTemp.createTemp('${prefix ?? ''} ');
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

Uri packageUri = findPackageRoot('hooks');

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
}) => Logger.detached('')
  ..level = level
  ..onRecord.listen((record) {
    printOnFailure('${record.level.name}: ${record.time}: ${record.message}');
    capturedMessages?.add(record.message);
  });

final dartExecutable = File(Platform.resolvedExecutable).uri;

int defaultMacOSVersion = 13;

T traverseJson<T extends Object?>(Object json, List<Object> path) {
  while (path.isNotEmpty) {
    final key = path.removeAt(0);
    switch (key) {
      case final int i:
        json = (json as List)[i] as Object;
        break;
      case final String s:
        json = (json as Map)[s] as Object;
        break;
      default:
        throw UnsupportedError(key.toString());
    }
  }
  return json as T;
}
