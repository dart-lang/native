// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

extension FileSystemEntityExtension on FileSystemEntity {
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

extension FileSystemEntityIterable on Iterable<FileSystemEntity> {
  Future<DateTime> lastModified() async {
    var last = DateTime.fromMillisecondsSinceEpoch(0);
    for (final entity in this) {
      final entityTimestamp = await entity.lastModified();
      if (entityTimestamp.isAfter(last)) {
        // print([entity, entityTimestamp]);
        last = entityTimestamp;
      }
    }
    return last;
  }
}

extension DirectoryExtension on Directory {
  Future<DateTime> lastModified() async {
    var last = DateTime.fromMillisecondsSinceEpoch(0);
    await for (final entity in list()) {
      final entityTimestamp = await entity.lastModified();
      if (entityTimestamp.isAfter(last)) {
        // print([this, entityTimestamp]);
        last = entityTimestamp;
      }
    }
    return last;
  }

  /// Run [callback] with this Dart process having exclusive access to this
  /// [Directory].
  ///
  /// Note multiple isolates and isolate groups in the same Dart process share
  /// locks, so these will be able to enter the exclusive section simultanously.
  ///
  /// The required [timeout] parameter determines how long to retry before
  /// giving up. If the [timeout] is exceeded a [TimeoutException] is thrown.
  // TODO(dacoharkes): Can we also make it in-process safe?
  // TODO(dacoharkes): Where do we place this code so hook writers can reuse it?
  // I don't really want to add it to package:native_assets_cli. A new package
  // in dart-lang/tools?
  Future<T> exclusive<T>(
    Future<T> Function() callback, {
    required Duration timeout,
  }) async {
    final timeoutCompleter = Completer<void>();
    final timeoutTimer = Timer(timeout, timeoutCompleter.complete);
    const lockFileName = '.lock';
    final lockFile = File.fromUri(uri.resolve(lockFileName));
    final fileSystemExceptions = <FileSystemException>[];
    while (true) {
      try {
        if (!await lockFile.exists()) {
          await lockFile.create(recursive: true);
        }
        final randomAccessFile = await lockFile.open(mode: FileMode.write);
        await lockFile.writeAsString(
          'Last acquired by ${Platform.resolvedExecutable} '
          'running ${Platform.script} on ${DateTime.now()}.',
        );
        final fileLockCompleter =
            _completer(randomAccessFile.lock(FileLock.blockingExclusive));
        await Future.any([
          fileLockCompleter.future,
          timeoutCompleter.future,
        ]);
        if (timeoutCompleter.isCompleted) {
          var message = 'Could not acquire the lock to ${lockFile.path}.';
          for (final e in fileSystemExceptions) {
            message += '\n${e.message}';
          }
          throw TimeoutException(message, timeout);
        }
        assert(fileLockCompleter.isCompleted);
        timeoutTimer.cancel();
        final lock = await fileLockCompleter.future;
        try {
          return await callback();
        } finally {
          await lock.unlock();
        }
      } on FileSystemException catch (e) {
        fileSystemExceptions.add(e);
        continue;
      }
    }
  }
}

Completer<T> _completer<T>(Future<T> future) {
  final completer = Completer<T>();
  future.then<void>(completer.complete).catchError(completer.completeError);
  return completer;
}
