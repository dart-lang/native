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
  final envPackageRoot = Platform.environment['PACKAGE_ROOT'];
  if (envPackageRoot != null) return Uri.directory(envPackageRoot);

  final script = Platform.script;
  final fileName = script.name;
  if (fileName.endsWith('.dart')) {
    // We're likely running from source in the package somewhere.
    var directory = script.resolve('.');
    while (true) {
      if (_isPackageRoot(directory, packageName)) {
        return directory;
      }
      final parent = directory.resolve('..');
      if (parent == directory) break;
      directory = parent;
    }
  }

  // Running via `dart test` (JIT or CLI) or from within the package or
  // workspace.
  var directory = Directory.current.uri;
  while (true) {
    if (_isPackageRoot(directory, packageName)) {
      return directory;
    }
    final candidate = directory.resolve('pkgs/$packageName/');
    if (Directory.fromUri(candidate).existsSync()) {
      return candidate;
    }
    final parent = directory.resolve('..');
    if (parent == directory) break;
    directory = parent;
  }

  throw StateError(
    "Could not find package root for package '$packageName'. "
    'Tried finding the package root via Platform.script '
    "'${Platform.script.toFilePath()}' and Directory.current "
    "'${Directory.current.uri.toFilePath()}'.",
  );
}

bool _isPackageRoot(Uri uri, String packageName) {
  if (uri.name == packageName) {
    return true;
  }
  final pubspec = File.fromUri(uri.resolve('pubspec.yaml'));
  if (pubspec.existsSync()) {
    try {
      final lines = pubspec.readAsLinesSync();
      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.startsWith('name:')) {
          final name = trimmed.substring('name:'.length).trim();
          return name == packageName;
        }
      }
    } catch (_) {}
  }
  return false;
}

extension on Uri {
  String get name {
    final segments = pathSegments.where((e) => e != '');
    return segments.isEmpty ? '' : segments.last;
  }
}
