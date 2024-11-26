// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:xxh3/xxh3.dart';

import '../utils/file.dart';
import '../utils/uri.dart';

class FileSystemCache {
  FileSystemCache({
    required File cacheFile,
  }) : _cacheFile = cacheFile;

  final File _cacheFile;
  FileSystemHashes _hashes = FileSystemHashes();

  Future<void> readCacheFile() async {
    if (!await _cacheFile.exists()) {
      _hashes = FileSystemHashes();
      return;
    }
    final jsonObject =
        (json.decode(utf8.decode(await _cacheFile.readAsBytes())) as Map)
            .cast<String, dynamic>();
    _hashes = FileSystemHashes.fromJson(jsonObject);
  }

  void reset() => _hashes = FileSystemHashes();

  /// Populate the cache with entries from [fileSystemEntities].
  ///
  /// If [validBeforeLastModified] is provided, any entities that were modified
  /// after [validBeforeLastModified] will get a dummy hash so that they will
  /// show up as outdated. If any such entity exists, its uri will be returned.
  Future<Uri?> hashFiles(
    List<Uri> fileSystemEntities, {
    DateTime? validBeforeLastModified,
  }) async {
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
    return modifiedAfterTimeStamp;
  }

  Future<void> persist() =>
      _cacheFile.writeAsString(json.encode(_hashes.toJson()));

  /// Find an outdated file or directory.
  ///
  /// If all
  Future<Uri?> findOutdatedFileSystemEntity() async {
    for (final cachedHash in _hashes.files) {
      final uri = cachedHash.path;
      final cachedHashValue = cachedHash.hash;
      final int hashValue;
      if (_isDirectoryPath(uri.path)) {
        hashValue = await _hashDirectory(uri);
      } else {
        hashValue = await _hashFile(uri);
      }
      if (cachedHashValue != hashValue) {
        return uri;
      }
    }
    return null;
  }

  Future<int> _hashFile(Uri uri) async {
    final file = File.fromUri(uri);
    if (!await file.exists()) {
      return _hashNotExists;
    }
    return xxh3(await file.readAsBytes());
  }

  Future<int> _hashDirectory(Uri uri) async {
    final directory = Directory.fromUri(uri);
    if (!await directory.exists()) {
      return _hashNotExists;
    }
    final children = directory.listSync(followLinks: true, recursive: false);
    final childrenNames = children.map((e) => _pathBaseName(e.path)).join(';');
    return xxh3(utf8.encode(childrenNames));
  }

  /// Predefined hash for files and directories that do not exist.
  ///
  /// There are two predefined hash values. The chance that a predefined hash
  /// collides with a real hash is 2/2^64.
  static const _hashNotExists = 0;

  /// Predefined hash for files and directories that were modified after the
  /// time that the cache was created.
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
    this.version = 1,
    List<FilesystemEntityHash>? files,
  }) : files = files ?? [];

  factory FileSystemHashes.fromJson(Map<String, dynamic> json) {
    final version = json[_versionKey] as int;
    final rawCachedFiles =
        (json[_entitiesKey] as List<dynamic>).cast<Map<String, dynamic>>();
    final files = <FilesystemEntityHash>[
      for (final Map<String, dynamic> rawFile in rawCachedFiles)
        FilesystemEntityHash._fromJson(rawFile),
    ];
    return FileSystemHashes(
      version: version,
      files: files,
    );
  }

  final int version;
  final List<FilesystemEntityHash> files;

  static const _versionKey = 'version';
  static const _entitiesKey = 'entities';

  Map<String, Object> toJson() => <String, Object>{
        _versionKey: version,
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

  factory FilesystemEntityHash._fromJson(Map<String, dynamic> json) =>
      FilesystemEntityHash(
        _fileSystemPathToUri(json[_pathKey] as String),
        json[_hashKey] as int,
      );

  static const _pathKey = 'path';
  static const _hashKey = 'hash';

  final Uri path;

  /// A 64 bit hash.
  ///
  /// Typically xxh3.
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
