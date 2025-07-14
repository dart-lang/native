// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

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
  if (fileName.endsWith('.dart')) {
    // We're likely running from source in the package somewhere.
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
    // Probably from the package root.
    final cwd = Directory.current.uri;
    final dirName = cwd.name;
    if (dirName == packageName) {
      return cwd;
    }
  }
  // Or the workspace root.
  final cwd = Directory.current.uri;
  final candidate = cwd.resolve('pkgs/$packageName/');
  if (Directory.fromUri(candidate).existsSync()) {
    return candidate;
  }
  throw StateError(
    "Could not find package root for package '$packageName'. "
    'Tried finding the package root via Platform.script '
    "'${Platform.script.toFilePath()}' and Directory.current "
    "'${Directory.current.uri.toFilePath()}'.",
  );
}

extension on Uri {
  String get name => pathSegments.where((e) => e != '').last;
}
