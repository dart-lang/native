// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// This file contains utils that are intended to be overridden by downstream
// clones. They're gathered into one file to make it easy to swap them out.

// This file is exclusively imported by utils.dart, so that there's only one
// line we have to patch in the downstream clones.
@Deprecated('Import config_provider/utils.dart instead')
library;

import 'dart:io';

import 'package:path/path.dart' as p;

// Replaces the path separators according to current platform.
String _replaceSeparators(String path) {
  if (Platform.isWindows) {
    return path.replaceAll(p.posix.separator, p.windows.separator);
  } else {
    return path.replaceAll(p.windows.separator, p.posix.separator);
  }
}

/// Replaces the path separators according to current platform, and normalizes .
/// and .. in the path. If a relative path is passed in, it is resolved relative
/// to the config path, and the absolute path is returned.
String normalizePath(String path, String? configFilename) {
  final resolveInConfigDir =
      (configFilename == null) || p.isAbsolute(path) || path.startsWith('**');
  return _replaceSeparators(
    p.normalize(
      resolveInConfigDir
          ? path
          : p.absolute(p.join(p.dirname(configFilename), path)),
    ),
  );
}

/// These locations are searched for clang dylibs before any others. Downstream
/// clones can use a non-null value for this path to search here first.
final libclangOverridePaths = const <String>[];

/// Returns the compiler options to use, potentially overriding the ones from
/// the config. Downstream clones can use this to add or remove flags.
List<String> overrideCompilerOpts(List<String> opts) => opts;

/// Returns the root path of the package, for use during tests.
///
/// Note that `dart test` sets the current directory to the package root.
final packagePathForTests = _findPackageRoot('ffigen').toFilePath();

/// Returns a path to a config yaml in a unit test.
String configPathForTest(String directory, String file) =>
    p.join(directory, file);

/// Test files are run in a variety of ways, find this package root in all.
///
/// Test files can be run from source from any working directory. The Dart SDK
/// `tools/test.py` runs them from the root of the SDK for example.
///
/// Test files can be run from dill from the root of package. `package:test`
/// does this.
///
/// https://github.com/dart-lang/test/issues/110
Uri _findPackageRoot(String packageName) {
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
