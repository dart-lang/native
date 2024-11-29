// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import '../utils/file.dart';
import '../utils/uri.dart';

class DependenciesHashFile {
  DependenciesHashFile({
    required File file,
  }) : _file = file;

  final File _file;
  FileSystemHashes _hashes = FileSystemHashes();

  Future<void> _readFile() async {
    if (!await _file.exists()) {
      _hashes = FileSystemHashes();
      return;
    }
    final jsonObject =
        (json.decode(utf8.decode(await _file.readAsBytes())) as Map)
            .cast<String, Object>();
    _hashes = FileSystemHashes.fromJson(jsonObject);
  }

  void _reset() => _hashes = FileSystemHashes();

  /// Populate the hashes and persist file with entries from
  /// [fileSystemEntities].
  ///
  /// If [validBeforeLastModified] is provided, any entities that were modified
  /// after [validBeforeLastModified] will get a dummy hash so that they will
  /// show up as outdated. If any such entity exists, its uri will be returned.
  Future<Uri?> hashFilesAndDirectories(
    List<Uri> fileSystemEntities, {
    DateTime? validBeforeLastModified,
  }) async {
    _reset();

    Uri? modifiedAfterTimeStamp;
    for (final uri in fileSystemEntities) {
      int hash;
      if (validBeforeLastModified != null &&
          (await uri.fileSystemEntity.lastModified())
              .isAfter(validBeforeLastModified)) {
        hash = _hashLastModifiedAfterCutoff;
        modifiedAfterTimeStamp = uri;
      } else {
        if (_isDirectoryPath(uri.path)) {
          hash = await _hashDirectory(uri);
        } else {
          hash = await _hashFile(uri);
        }
      }
      _hashes.files.add(FilesystemEntityHash(uri, hash));
    }
    await _persist();
    return modifiedAfterTimeStamp;
  }

  Future<void> _persist() => _file.writeAsString(json.encode(_hashes.toJson()));

  /// Reads the file with hashes and finds an outdated file or directory if it
  /// exists.
  Future<Uri?> findOutdatedFileSystemEntity() async {
    await _readFile();

    for (final savedHash in _hashes.files) {
      final uri = savedHash.path;
      final savedHashValue = savedHash.hash;
      final int hashValue;
      if (_isDirectoryPath(uri.path)) {
        hashValue = await _hashDirectory(uri);
      } else {
        hashValue = await _hashFile(uri);
      }
      if (savedHashValue != hashValue) {
        return uri;
      }
    }
    return null;
  }

  // A 64 bit hash from an md5 hash.
  int _md5int64(Uint8List bytes) {
    final md5bytes = md5.convert(bytes);
    final md5ints = (md5bytes.bytes as Uint8List).buffer.asUint64List();
    return md5ints[0];
  }

  Future<int> _hashFile(Uri uri) async {
    final file = File.fromUri(uri);
    if (!await file.exists()) {
      return _hashNotExists;
    }
    return _md5int64(await file.readAsBytes());
  }

  Future<int> _hashDirectory(Uri uri) async {
    final directory = Directory.fromUri(uri);
    if (!await directory.exists()) {
      return _hashNotExists;
    }
    final children = directory.listSync(followLinks: true, recursive: false);
    final childrenNames = children.map((e) => _pathBaseName(e.path)).join(';');
    return _md5int64(utf8.encode(childrenNames));
  }

  /// Predefined hash for files and directories that do not exist.
  ///
  /// There are two predefined hash values. The chance that a predefined hash
  /// collides with a real hash is 2/2^64.
  static const _hashNotExists = 0;

  /// Predefined hash for files and directories that were modified after the
  /// time that the hashes file was created.
  ///
  /// There are two predefined hash values. The chance that a predefined hash
  /// collides with a real hash is 2/2^64.
  static const _hashLastModifiedAfterCutoff = 1;
}

/// Storage format for file system entity hashes.
///
/// [File] hashes are a hash of the file.
///
/// [Directory] hashes are a hash of the names of the direct children.
class FileSystemHashes {
  FileSystemHashes({
    List<FilesystemEntityHash>? files,
  }) : files = files ?? [];

  factory FileSystemHashes.fromJson(Map<String, Object> json) {
    final rawEntries = (json[_entitiesKey] as List).cast<Object>();
    final files = <FilesystemEntityHash>[
      for (final rawEntry in rawEntries)
        FilesystemEntityHash._fromJson((rawEntry as Map).cast()),
    ];
    return FileSystemHashes(
      files: files,
    );
  }

  final List<FilesystemEntityHash> files;

  static const _entitiesKey = 'entities';

  Map<String, Object> toJson() => <String, Object>{
        _entitiesKey: <Object>[
          for (final FilesystemEntityHash file in files) file.toJson(),
        ],
      };
}

/// A stored file or directory hash and path.
///
/// [File] hashes are a hash of the file.
///
/// [Directory] hashes are a hash of the names of the direct children.
class FilesystemEntityHash {
  FilesystemEntityHash(
    this.path,
    this.hash,
  );

  factory FilesystemEntityHash._fromJson(Map<String, Object> json) =>
      FilesystemEntityHash(
        _fileSystemPathToUri(json[_pathKey] as String),
        json[_hashKey] as int,
      );

  static const _pathKey = 'path';
  static const _hashKey = 'hash';

  final Uri path;

  /// A 64 bit hash.
  final int hash;

  Object toJson() => <String, Object>{
        _pathKey: path.toFilePath(),
        _hashKey: hash,
      };
}

bool _isDirectoryPath(String path) =>
    path.endsWith(Platform.pathSeparator) || path.endsWith('/');

Uri _fileSystemPathToUri(String path) {
  if (_isDirectoryPath(path)) {
    return Uri.directory(path);
  }
  return Uri.file(path);
}

String _pathBaseName(String path) =>
    path.split(Platform.pathSeparator).where((e) => e.isNotEmpty).last;
