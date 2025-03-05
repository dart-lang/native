// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:core';
import 'dart:core' as core;
import 'dart:io';

T as<T>(Object? object) {
  if (object is T) {
    return object;
  }
  throw FormatException(
    "Unexpected value '$object' of type ${object.runtimeType} in JSON. Expected"
    ' a $T.',
  );
}

T get<T>(Map<Object?, Object?> map, String key) {
  final object = map[key];
  if (object is T) {
    return object;
  }
  throw FormatException(
    "Unexpected value '$object' of type ${object.runtimeType} in JSON for key "
    '$key. Expected a $T.',
  );
}

extension MapCast on Map<Object?, Object?> {
  Map<K, V> formatCast<K, V>() => <K, V>{
    for (final e in entries) as<K>(e.key): as<V>(e.value),
  };
}

extension MapJsonUtils on Map<String, Object?> {
  String string(String key, {Iterable<String>? validValues}) {
    final value = get<String>(key);
    if (validValues != null && !validValues.contains(value)) {
      throw FormatException(
        'Json "$key" had value $value but expected one of '
        '${validValues.join(',')}',
      );
    }
    return value;
  }

  String? optionalString(String key, {Iterable<String>? validValues}) {
    final value = getOptional<String>(key);
    if (value == null) return null;
    if (validValues != null && !validValues.contains(value)) {
      throw FormatException(
        'Json "$key" had value $value but expected one of '
        '${validValues.join(',')}',
      );
    }
    return value;
  }

  core.bool bool(String key) => get<core.bool>(key);
  core.bool? optionalBool(String key) => getOptional<core.bool>(key);
  core.int int(String key) => get<core.int>(key);
  core.int? optionalInt(String key) => getOptional<core.int>(key);

  Uri path(String key) => _fileSystemPathToUri(get<String>(key));

  Uri? optionalPath(String key) {
    final value = getOptional<String>(key);
    if (value == null) return null;
    return _fileSystemPathToUri(value);
  }

  List<String>? optionalStringList(String key) {
    final value = getOptional<List<Object?>>(key);
    if (value == null) return null;
    return value.cast<String>();
  }

  List<String> stringList(String key) => get<List<Object?>>(key).cast<String>();

  List<Uri>? optionalPathList(String key) {
    final strings = optionalStringList(key);
    if (strings == null) {
      return null;
    }
    return [for (final string in strings) _fileSystemPathToUri(string)];
  }

  List<Object?> list(String key) => get<List<Object?>>(key);
  List<Object?>? optionalList(String key) => getOptional<List<Object?>>(key);
  Map<String, Object?> map$(String key) => get<Map<String, Object?>>(key);
  Map<String, T>? optionalMap<T extends Object?>(String key) {
    final map_ = getOptional<Map<String, Object?>>(key);
    if (map_ is Map<String, T>?) return map_;
    for (final value in map_.values) {
      if (value is! T) {
        throw FormatException(
          'Unexpected value \'$map_\' (${map_.runtimeType}) for key \'.$key\''
          ' in input file. Expected a ${Map<String, T>}?.',
        );
      }
    }
    return map_.cast();
  }

  T get<T extends Object>(String key) {
    final value = this[key];
    if (value == null) {
      throw FormatException('No value was provided for required key: $key');
    }
    if (value is T) return value;
    throw FormatException(
      'Unexpected value \'$value\' for key \'.$key\' in input file. '
      'Expected a $T.',
    );
  }

  T? getOptional<T extends Object>(String key) {
    final value = this[key];
    if (value is T?) return value;
    throw FormatException(
      'Unexpected value \'$value\' for key \'.$key\' in input file. '
      'Expected a $T?.',
    );
  }

  void setNested(List<String> nestedMapKeys, Object? value) {
    var map = this;
    for (final key in nestedMapKeys.sublist(0, nestedMapKeys.length - 1)) {
      map = (map[key] ??= <String, Object?>{}) as Map<String, Object?>;
    }
    map[nestedMapKeys.last] = value;
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
      'Unexpected value \'$value\' for index \'.$index\' in input file. '
      'Expected a $T.',
    );
  }

  Map<String, Object?> mapAt(int index) => get<Map<String, Object?>>(index);
  Uri pathAt(int index) => _fileSystemPathToUri(get<String>(index));
}

Uri _fileSystemPathToUri(String path) {
  if (path.endsWith(Platform.pathSeparator)) {
    return Uri.directory(path);
  }
  return Uri.file(path);
}

extension UriList on List<Uri> {
  List<String> toJson() => [for (final uri in this) uri.toFilePath()];
}

extension MapSorting<K extends Comparable<K>, V extends Object?> on Map<K, V> {
  void sortOnKey() {
    final result = <K, V>{};
    final keysSorted = keys.toList()..sort();
    for (final key in keysSorted) {
      result[key] = this[key] as V;
    }
    clear();
    addAll(result);
  }
}
