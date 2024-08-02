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
    const lockFileName = '.lock';
    final lockFile = File.fromUri(uri.resolve(lockFileName));
    final fileSystemExceptions = <FileSystemException>[];
    await _ensureLockfileExists(lockFile, fileSystemExceptions);

    final timeoutCompleter = Completer<void>();
    var timedOut = false;
    final timeoutTimer = Timer(timeout, () {
      timedOut = true;
      timeoutCompleter.complete();
    });

    final randomAccessFile = await lockFile.open(mode: FileMode.write);
    await lockFile.writeAsString(
      'Last acquired by ${Platform.resolvedExecutable} '
      'running ${Platform.script} on ${DateTime.now()}.',
    );
    var ranCallback = false;
    T? result;
    final lockAndCallbackFuture =
        randomAccessFile.lock(FileLock.blockingExclusive).then((lock) async {
      if (!timedOut) {
        // Lock was acquired before timeout.
        // Cancel timer, otherwise the Dart process doesn't exit.
        timeoutTimer.cancel();
        try {
          result = await callback();
          ranCallback = true;
        } finally {
          await lock.unlock();
        }
      } else {
        // Timed out, but lock was acquired.
        await lock.unlock();
        // TODO(dacoharkes): The current approach probably prevents the Dart
        // process from exiting while waiting on the file lock after the timer
        // has already timed out.
        // The alternative would be to repeatedly try locking with
        // `FileLock.exclusive` with an exponential back off. But the downside
        // of that is more latency due to polling.
        // Why don't we have a cancallable blocking locking API?
      }
    });

    await Future.any([
      lockAndCallbackFuture,
      timeoutCompleter.future,
    ]);
    if (ranCallback) {
      return result!;
    }

    assert(timedOut);
    var message = 'Could not acquire the lock to ${lockFile.path}.';
    for (final e in fileSystemExceptions) {
      message += '\n${e.message}';
    }
    throw TimeoutException(message, timeout);
  }
}

Future<void> _ensureLockfileExists(
  File lockFile,
  List<FileSystemException> fileSystemExceptions,
) async {
  while (true) {
    try {
      if (!await lockFile.exists()) {
        // This code could race with itself in another process.
        await lockFile.create(recursive: true, exclusive: true);
      }
    } on FileSystemException catch (e) {
      fileSystemExceptions.add(e);
      // If it did race, log the exception and keep retrying.
      continue;
    }
    return;
  }
}
