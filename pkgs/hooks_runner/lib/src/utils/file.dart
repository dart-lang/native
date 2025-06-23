// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:file/file.dart';

extension FileSystemEntityExtension on FileSystemEntity {
  Future<DateTime> lastModified(FileSystem fileSystem) async {
    final this_ = this;

    if (this_ is Link || await fileSystem.isLink(this_.path)) {
      // Don't follow links.
      return DateTime.fromMicrosecondsSinceEpoch(0);
    }
    if (this_ is File) {
      if (!await this_.exists()) {
        // If the file was deleted, regard it is modified recently.
        return DateTime.now();
      }
      return await this_.lastModified();
    }
    return await (this_ as Directory).lastModified(fileSystem);
  }
}

extension FileSystemEntityIterable on Iterable<FileSystemEntity> {
  Future<DateTime> lastModified(FileSystem fileSystem) async {
    var last = DateTime.fromMillisecondsSinceEpoch(0);
    for (final entity in this) {
      final entityTimestamp = await entity.lastModified(fileSystem);
      if (entityTimestamp.isAfter(last)) {
        last = entityTimestamp;
      }
    }
    return last;
  }
}

extension DirectoryExtension on Directory {
  Future<DateTime> lastModified(FileSystem fileSystem) async {
    var last = DateTime.fromMillisecondsSinceEpoch(0);
    await for (final entity in list()) {
      final entityTimestamp = await entity.lastModified(fileSystem);
      if (entityTimestamp.isAfter(last)) {
        last = entityTimestamp;
      }
    }
    return last;
  }
}
