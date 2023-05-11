// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:native_assets_cli/src/model/build_config.dart';

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

String unparseKey(String key) => key.replaceAll('.', '__').toUpperCase();

/// Archiver provided by the environment.
final Uri? ar = Platform
    .environment[unparseKey(CCompilerConfig.arConfigKeyFull)]
    ?.asFileUri();

/// Compiler provided by the environment.
final Uri? cc = Platform
    .environment[unparseKey(CCompilerConfig.ccConfigKeyFull)]
    ?.asFileUri();

/// Linker provided by the environment.
final Uri? ld = Platform
    .environment[unparseKey(CCompilerConfig.ldConfigKeyFull)]
    ?.asFileUri();

/// Path to script that sets environment variables for [cc], [ld], and [ar].
///
/// Provided by environment.
final Uri? envScript = Platform
    .environment[unparseKey(CCompilerConfig.envScriptConfigKeyFull)]
    ?.asFileUri();

/// Arguments for [envScript] provided by environment.
final List<String>? envScriptArgs = Platform
    .environment[unparseKey(CCompilerConfig.envScriptArgsConfigKeyFull)]
    ?.split(' ');

extension on String {
  Uri asFileUri() => Uri.file(this);
}
