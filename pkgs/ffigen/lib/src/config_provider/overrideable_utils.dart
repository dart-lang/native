// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// This file contains utils that are intended to be overridden by downstream
// clones. They're gathered into one file to make it easy to swap them out.

import 'package:path/path.dart' as p;

/// Replaces the path separators according to current platform, and normalizes .
/// and .. in the path. If a relative path is passed in, it is resolved relative
/// to the config path, and the absolute path is returned.
String normalizePath(String path, String? configFilename) {
  final resolveInConfigDir =
      (configFilename == null) || p.isAbsolute(path) || path.startsWith('**');
  return _replaceSeparators(p.normalize(resolveInConfigDir
      ? path
      : p.absolute(p.join(p.dirname(configFilename), path))));
}

/// This is the first location searched for the clang dylib. Downstream clones
/// can use a non-null value for this path to search here first.
final String? libclangOverridablePath = null;

/// Returns the root path of the package, for use during tests.
///
/// Note that `dart test` sets the current directory to the package root.
final String packagePathForTests = p.current;
