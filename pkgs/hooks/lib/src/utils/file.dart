// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

/// Provides utility extensions on [File] for enhanced file operations.
extension FileExtension on File {
  /// Writes [contents] to the file, creating parent directories if they don't
  /// exist.
  Future<File> writeAsStringCreateDirectory(
    String contents, {
    FileMode mode = FileMode.write,
    Encoding encoding = utf8,
    bool flush = false,
  }) async {
    if (!await parent.exists()) {
      await parent.create(recursive: true);
    }
    return await writeAsString(
      contents,
      mode: mode,
      encoding: encoding,
      flush: flush,
    );
  }
}

/// Provides utility extensions on [FileSystemEntity] for common file system
/// operations.
extension FileSystemEntityExtension on FileSystemEntity {
  /// Returns the last modified date of this file system entity.
  Future<DateTime> lastModified() async {
    final this_ = this;
    if (this_ is Link || await FileSystemEntity.isLink(this_.path)) {
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
    assert(this_ is Directory);
    this_ as Directory;
    return await this_.lastModified();
  }
}

/// Provides utility extensions on an [Iterable] of [FileSystemEntity] for
/// finding the latest modification time among them.
extension FileSystemEntityIterable on Iterable<FileSystemEntity> {
  /// Returns the latest [DateTime] among all entities in this iterable.
  Future<DateTime> lastModified() async {
    var last = DateTime.fromMillisecondsSinceEpoch(0);
    for (final entity in this) {
      final entityTimestamp = await entity.lastModified();
      if (entityTimestamp.isAfter(last)) {
        last = entityTimestamp;
      }
    }
    return last;
  }
}

/// Provides utility extensions on [Directory] for recursive last modified
/// checks.
extension DirectoryExtension on Directory {
  /// Returns the latest modification [DateTime] of this directory or any of its
  /// contents.
  Future<DateTime> lastModified() async {
    var last = DateTime.fromMillisecondsSinceEpoch(0);
    await for (final entity in list()) {
      final entityTimestamp = await entity.lastModified();
      if (entityTimestamp.isAfter(last)) {
        last = entityTimestamp;
      }
    }
    return last;
  }
}
