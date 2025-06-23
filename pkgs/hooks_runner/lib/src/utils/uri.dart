// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io' show Platform;

import 'package:file/file.dart';

extension UriExtension on FileSystem {
  FileSystemEntity fileSystemEntity(Uri uri) {
    if (uri.path.endsWith(Platform.pathSeparator) || uri.path.endsWith('/')) {
      return directory(uri);
    }
    return file(uri);
  }
}
