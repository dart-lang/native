// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

/// Provides utility extensions for file system uris.
extension UriExtension on Uri {
  /// Get the file s system entity associated with this uri.
  FileSystemEntity get fileSystemEntity {
    if (path.endsWith(Platform.pathSeparator) || path.endsWith('/')) {
      return Directory.fromUri(this);
    }
    return File.fromUri(this);
  }
}

/// Convert a file system path to a uri.
Uri fileSystemPathToUri(String path) {
  if (path.endsWith(Platform.pathSeparator) || path.endsWith('/')) {
    return Uri.directory(path);
  }
  return Uri.file(path);
}
