// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:developer';
import 'dart:io' as io;
import 'dart:typed_data';
import 'package:file/file.dart';

/// A [FileSystem] that wraps another [FileSystem] and adds timeline events
/// for all file system operations.
class TracingFileSystem extends ForwardingFileSystem {
  final TimelineTask task;

  TracingFileSystem(super.delegate, this.task);

  @override
  File file(dynamic path) => TracingFile._(delegate.file(path), this);

  @override
  Directory directory(dynamic path) =>
      TracingDirectory._(delegate.directory(path), this);

  Future<T> _timeAsync<T>(
    String name,
    String? path,
    Future<T> Function() function,
  ) async {
    final arguments = path != null ? {'path': path} : null;
    task.start(name, arguments: arguments);
    try {
      return await function();
    } finally {
      task.finish();
    }
  }
}

class TracingFile extends ForwardingFileSystemEntity<File, io.File>
    with ForwardingFile {
  @override
  final io.File delegate;

  @override
  final TracingFileSystem fileSystem;

  TracingFile._(this.delegate, this.fileSystem);

  @override
  Directory wrapDirectory(io.Directory delegate) => throw UnimplementedError();

  @override
  TracingFile wrapFile(io.File delegate) => TracingFile._(delegate, fileSystem);

  @override
  Link wrapLink(io.Link delegate) => throw UnimplementedError();

  @override
  Future<bool> exists() =>
      fileSystem._timeAsync('File.exists', path, delegate.exists);

  @override
  Future<String> readAsString({Encoding encoding = utf8}) =>
      fileSystem._timeAsync(
        'File.readAsString',
        path,
        () => delegate.readAsString(encoding: encoding),
      );

  @override
  Future<Uint8List> readAsBytes() =>
      fileSystem._timeAsync('File.readAsBytes', path, delegate.readAsBytes);

  @override
  Future<TracingFile> writeAsString(
    String contents, {
    FileMode mode = FileMode.write,
    Encoding encoding = utf8,
    bool flush = false,
  }) async => fileSystem._timeAsync(
    'File.writeAsString',
    path,
    () async => TracingFile._(
      await delegate.writeAsString(
        contents,
        mode: mode,
        encoding: encoding,
        flush: flush,
      ),
      fileSystem,
    ),
  );
}

class TracingDirectory
    extends ForwardingFileSystemEntity<Directory, io.Directory>
    with ForwardingDirectory {
  @override
  final io.Directory delegate;

  @override
  final TracingFileSystem fileSystem;

  TracingDirectory._(this.delegate, this.fileSystem);

  @override
  TracingDirectory wrapDirectory(io.Directory delegate) =>
      TracingDirectory._(delegate, fileSystem);

  @override
  TracingFile wrapFile(io.File delegate) => TracingFile._(delegate, fileSystem);

  @override
  Link wrapLink(io.Link delegate) => throw UnimplementedError();

  @override
  Future<bool> exists() =>
      fileSystem._timeAsync('Directory.exists', path, delegate.exists);

  @override
  Future<TracingDirectory> create({bool recursive = false}) async =>
      fileSystem._timeAsync('Directory.create', path, () async {
        await delegate.create(recursive: recursive);
        return this;
      });

  @override
  Directory childDirectory(String basename) => throw UnimplementedError();

  @override
  File childFile(String basename) => throw UnimplementedError();

  @override
  Link childLink(String basename) => throw UnimplementedError();
}
