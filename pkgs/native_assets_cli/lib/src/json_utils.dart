// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:core';
import 'dart:core' as core;
import 'dart:io';

extension MapJsonUtils on Map<String, Object?> {
  String string(String key, {Iterable<String>? validValues}) {
    final value = get<String>(key);
    if (validValues != null && !validValues.contains(value)) {
      throw FormatException('Json "$key" had value $value but expected one of '
          '${validValues.join(',')}');
    }
    return value;
  }

  String? optionalString(String key) => getOptional<String>(key);

  bool? optionalBool(String key) => getOptional<bool>(key);
  core.int int(String key) => get<core.int>(key);
  core.int? optionalInt(String key) => getOptional<core.int>(key);

  Uri path(String key, {bool mustExist = false}) =>
      _fileSystemPathToUri(get<String>(key));

  Uri? optionalPath(String key, {bool mustExist = false}) {
    final value = getOptional<String>(key);
    if (value == null) return null;
    final uri = _fileSystemPathToUri(value);
    if (mustExist) {
      _throwIfNotExists(key, uri);
    }
    return uri;
  }

  List<String>? optionalStringList(String key) {
    final value = getOptional<List<Object?>>(key);
    if (value == null) return null;
    return value.cast<String>();
  }

  List<Object?> list(String key) => get<List<Object?>>(key);
  List<Object?>? optionalList(String key) => getOptional<List<Object?>>(key);
  Map<String, Object?> object(String key) => get<Map<String, Object?>>(key);
  Map<String, Object?>? optionalObject(String key) =>
      getOptional<Map<String, Object?>>(key);

  T get<T extends Object>(String key) {
    final value = this[key];
    if (value == null) {
      throw FormatException('No value was provided for required key: $key');
    }
    if (value is T) return value;
    throw FormatException(
        'Unexpected value \'$value\' for key \'.$key\' in config file. '
        'Expected a $T.');
  }

  T? getOptional<T extends Object>(String key) {
    final value = this[key];
    if (value is T?) return value;
    throw FormatException(
        'Unexpected value \'$value\' for key \'.$key\' in config file. '
        'Expected a $T?.');
  }
}

extension ListJsonUtils on List<Object?> {
  T get<T extends Object>(int index) {
    final value = this[index];
    if (value == null) {
      throw FormatException('No value was provided for index: $index');
    }
    if (value is T) return value;
    throw FormatException(
        'Unexpected value \'$value\' for index \'.$index\' in config file. '
        'Expected a $T.');
  }

  Map<String, Object?> getObject(int index) => get<Map<String, Object?>>(index);
}

void _throwIfNotExists(String key, Uri value) {
  final fileSystemEntity = value.fileSystemEntity;
  if (!fileSystemEntity.existsSync()) {
    throw FormatException("Path '$value' for key '$key' doesn't exist.");
  }
}

extension on Uri {
  FileSystemEntity get fileSystemEntity {
    if (path.endsWith(Platform.pathSeparator) || path.endsWith('/')) {
      return Directory.fromUri(this);
    }
    return File.fromUri(this);
  }
}

Uri _fileSystemPathToUri(String path) {
  if (path.endsWith(Platform.pathSeparator)) {
    return Uri.directory(path);
  }
  return Uri.file(path);
}
