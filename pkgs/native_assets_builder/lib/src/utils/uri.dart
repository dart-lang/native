// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

extension UriExtension on Uri {
  FileSystemEntity get fileSystemEntity {
    if (path.endsWith(Platform.pathSeparator) || path.endsWith('/')) {
      return Directory.fromUri(this);
    }
    return File.fromUri(this);
  }
}
