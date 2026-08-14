// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:developer';
import 'dart:io' show Platform;
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:file/file.dart';

import '../utils/file.dart';
import '../utils/uri.dart';

class DependenciesHashFile {
  DependenciesHashFile(
    this._fileSystem, {
    required this.fileUri,
    TimelineTask? task,
  }) : _task = task ?? TimelineTask();

  final FileSystem _fileSystem;
  final Uri fileUri;
  final TimelineTask _task;
  FileSystemHashes _hashes = FileSystemHashes();

  List<Uri> get fileSystemEntities => _hashes.files.map((e) => e.path).toList();

  Future<bool> exists() async => await _fileSystem.file(fileUri).exists();
  Future<void> delete() async => await _fileSystem.file(fileUri).delete();

  Future<void> _readFile() async {
    final file = _fileSystem.file(fileUri);
    if (!await file.exists()) {
      _hashes = FileSystemHashes();
      return;
    }
    final jsonObject =
        (json.decode(utf8.decode(await file.readAsBytes())) as Map)
            .cast<String, Object>();
    _hashes = FileSystemHashes.fromJson(jsonObject);
  }

  void _reset() => _hashes = FileSystemHashes();

  /// Populate the hashes and persist file with entries from
  /// [fileSystemEntities], [outputFiles], and [environment].
  ///
  /// Any file system entities that were modified after
  /// [fileSystemValidBeforeLastModified] will get a dummy hash so that they
  /// will show up as outdated. If any such entity exists, its uri will be
  /// returned.
  Future<Uri?> updateHashes(
    List<Uri> fileSystemEntities,
    DateTime fileSystemValidBeforeLastModified,
    Map<String, String> environment, {
    List<Uri> outputFiles = const [],
  }) => _timeAsync('DependenciesHashFile.updateHashes', () async {
    _reset();

    Uri? modifiedAfterTimeStamp;
    for (final uri in fileSystemEntities) {
      int hash;
      int? size;
      DateTime? lastModified;
      if ((await _fileSystem.fileSystemEntity(uri).lastModified(_fileSystem))
          .isAfter(fileSystemValidBeforeLastModified)) {
        hash = _hashLastModifiedAfterCutoff;
        modifiedAfterTimeStamp = uri;
      } else {
        if (_isDirectoryPath(uri.path)) {
          hash = await _hashDirectory(uri);
        } else {
          final file = _fileSystem.file(uri);
          final stat = await file.stat();
          if (stat.type == FileSystemEntityType.file) {
            size = stat.size;
            lastModified = stat.modified;
          }
          hash = await _hashFile(uri);
        }
      }
      _hashes.files.add(
        FilesystemEntityHash(
          uri,
          hash,
          size: size,
          lastModified: lastModified,
        ),
      );
    }
    for (final uri in outputFiles) {
      int hash;
      int? size;
      DateTime? lastModified;
      if (_isDirectoryPath(uri.path)) {
        hash = await _hashDirectory(uri);
      } else {
        final file = _fileSystem.file(uri);
        final stat = await file.stat();
        if (stat.type == FileSystemEntityType.file) {
          size = stat.size;
          lastModified = stat.modified;
        }
        hash = await _hashFile(uri);
      }
      _hashes.files.add(
        FilesystemEntityHash(
          uri,
          hash,
          size: size,
          lastModified: lastModified,
        ),
      );
    }
    for (final entry in environment.entries) {
      _hashes.environment.add(
        EnvironmentVariableHash(entry.key, _hashEnvironmentValue(entry.value)),
      );
    }
    await _persist();
    return modifiedAfterTimeStamp;
  });

  Future<void> _persist() =>
      _fileSystem.file(fileUri).writeAsString(json.encode(_hashes.toJson()));

  /// Reads the file with hashes and reports if there is an outdated file,
  /// directory or environment variable.
  Future<String?> findOutdatedDependency(Map<String, String> environment) =>
      _timeAsync('DependenciesHashFile.findOutdatedDependency', () async {
        await _readFile();

        for (final savedHash in _hashes.files) {
          final uri = savedHash.path;
          if (_isDirectoryPath(uri.path)) {
            if (await _directoryContentsChanged(savedHash)) {
              return 'Directory contents changed: ${uri.toFilePath()}.';
            }
          } else {
            if (await _fileContentsChanged(savedHash)) {
              return 'File contents changed: ${uri.toFilePath()}.';
            }
          }
        }

        // Check if env vars changed or were removed.
        for (final savedHash in _hashes.environment) {
          final hashValue = _hashEnvironmentValue(environment[savedHash.key]);
          if (savedHash.hash != hashValue) {
            return 'Environment variable changed: ${savedHash.key}.';
          }
        }

        // Check if env vars were added.
        final savedEnvKeys = _hashes.environment.map((e) => e.key).toSet();
        for (final envKey in environment.keys) {
          if (!savedEnvKeys.contains(envKey)) {
            return 'Environment variable changed: $envKey.';
          }
        }

        return null;
      });

  /// Checks whether the contents of the file described by [savedHash] have
  /// changed.
  ///
  /// Fast path: if the file had a valid recorded size and modification time,
  /// and they still match, content hashing is skipped to avoid reading files
  /// from disk.
  ///
  /// Fallback: if the size or modification time changed (or was not recorded),
  /// the file is hashed to verify whether its contents actually changed.
  Future<bool> _fileContentsChanged(FilesystemEntityHash savedHash) async {
    final size = savedHash.size;
    final lastModified = savedHash.lastModified;
    if (size != null &&
        lastModified != null &&
        savedHash.hash != _hashLastModifiedAfterCutoff &&
        savedHash.hash != _hashNotExists) {
      final stat = await _fileSystem.file(savedHash.path).stat();
      if (stat.type == FileSystemEntityType.file &&
          stat.size == size &&
          stat.modified.isAtSameMomentAs(lastModified)) {
        return false;
      }
    }

    final hashValue = await _hashFile(savedHash.path);
    return savedHash.hash != hashValue;
  }

  Future<bool> _directoryContentsChanged(FilesystemEntityHash savedHash) async {
    final hashValue = await _hashDirectory(savedHash.path);
    return savedHash.hash != hashValue;
  }

  // A 64 bit hash from an md5 hash.
  int _md5int64(Uint8List bytes) {
    final md5bytes = md5.convert(bytes);
    final md5ints = (md5bytes.bytes as Uint8List).buffer.asUint64List();
    return md5ints[0];
  }

  Future<int> _hashFile(Uri uri) async =>
      _timeAsync('_hashFile', arguments: {'uri': uri.toFilePath()}, () async {
        final file = _fileSystem.file(uri);
        if (!await file.exists()) {
          return _hashNotExists;
        }
        return _md5int64(await file.readAsBytes());
      });

  Future<int> _hashDirectory(Uri uri) async {
    final directory = _fileSystem.directory(uri);
    if (!await directory.exists()) {
      return _hashNotExists;
    }
    final children = directory.listSync(followLinks: true, recursive: false);
    final childrenNames = children.map((e) => _pathBaseName(e.path)).toList()
      ..sort();
    return _md5int64(utf8.encode(childrenNames.join(';')));
  }

  int _hashEnvironmentValue(String? value) {
    if (value == null) return _hashNotExists;
    return _md5int64(utf8.encode(value));
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

  Future<T> _timeAsync<T>(
    String name,
    Future<T> Function() function, {
    Map<String, Object>? arguments,
  }) async {
    _task.start(name, arguments: arguments);
    try {
      return await function();
    } finally {
      _task.finish();
    }
  }
}

/// Storage format for file system entity hashes.
///
/// [File] hashes are a hash of the file.
///
/// [Directory] hashes are a hash of the names of the direct children.
class FileSystemHashes {
  FileSystemHashes({
    List<FilesystemEntityHash>? files,
    List<EnvironmentVariableHash>? environment,
  }) : files = files ?? [],
       environment = environment ?? [];

  factory FileSystemHashes.fromJson(Map<String, Object> json) {
    final rawFilesystemEntries =
        (json[_filesystemKey] as List?)?.cast<Object>() ?? [];
    final files = <FilesystemEntityHash>[
      for (final rawEntry in rawFilesystemEntries)
        FilesystemEntityHash._fromJson((rawEntry as Map).cast()),
    ];
    final rawEnvironmentEntries =
        (json[_environmentKey] as List?)?.cast<Object>() ?? [];
    final environment = <EnvironmentVariableHash>[
      for (final rawEntry in rawEnvironmentEntries)
        EnvironmentVariableHash._fromJson((rawEntry as Map).cast()),
    ];
    return FileSystemHashes(files: files, environment: environment);
  }

  final List<FilesystemEntityHash> files;
  final List<EnvironmentVariableHash> environment;

  static const _filesystemKey = 'file_system';

  static const _environmentKey = 'environment';

  Map<String, Object> toJson() => <String, Object>{
    _filesystemKey: <Object>[
      for (final FilesystemEntityHash file in files) file.toJson(),
    ],
    _environmentKey: <Object>[
      for (final EnvironmentVariableHash env in environment) env.toJson(),
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
    this.hash, {
    this.size,
    this.lastModified,
  });

  factory FilesystemEntityHash._fromJson(Map<String, Object> json) =>
      FilesystemEntityHash(
        _fileSystemPathToUri(json[_pathKey] as String),
        json[_hashKey] as int,
        size: json[_sizeKey] as int?,
        lastModified: switch (json[_lastModifiedKey]) {
          final int us => DateTime.fromMicrosecondsSinceEpoch(us),
          _ => null,
        },
      );

  static const _pathKey = 'path';
  static const _hashKey = 'hash';
  static const _sizeKey = 'size';
  static const _lastModifiedKey = 'last_modified';

  final Uri path;

  /// A 64 bit hash.
  final int hash;

  /// File size in bytes, or null if not applicable or not recorded.
  final int? size;

  /// Last modification timestamp, or null if not applicable or not recorded.
  final DateTime? lastModified;

  Object toJson() => <String, Object>{
    _pathKey: path.toFilePath(),
    _hashKey: hash,
    _sizeKey: ?size,
    _lastModifiedKey: ?lastModified?.microsecondsSinceEpoch,
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FilesystemEntityHash) return false;
    if (other.path != path) return false;
    if (other.hash != hash) return false;
    if (other.size != size) return false;
    if (other.lastModified == null || lastModified == null) {
      return other.lastModified == lastModified;
    }
    return other.lastModified!.isAtSameMomentAs(lastModified!);
  }

  @override
  int get hashCode => Object.hash(
    path,
    hash,
    size,
    lastModified?.microsecondsSinceEpoch,
  );
}

class EnvironmentVariableHash {
  EnvironmentVariableHash(this.key, this.hash);

  factory EnvironmentVariableHash._fromJson(Map<String, Object> json) =>
      EnvironmentVariableHash(json[_keyKey] as String, json[_hashKey] as int);

  static const _keyKey = 'key';
  static const _hashKey = 'hash';

  final String key;

  /// A 64 bit hash.
  final int hash;

  Object toJson() => <String, Object>{_keyKey: key, _hashKey: hash};
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
