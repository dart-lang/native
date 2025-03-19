// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Helper methods for the code generator that are added to the generated file.
///
/// This simplifies the code generator.
const helperLib = r'''
extension on Map<String, Object?> {
  T get<T extends Object?>(String key) {
    final value = this[key];
    if (value is T) return value;
    if (value == null) {
      throw FormatException('No value was provided for required key: $key');
    }
    throw FormatException(
      'Unexpected value \'$value\' for key \'.$key\'. '
      'Expected a $T.',
    );
  }

  List<T> list<T extends Object?>(String key) =>
      _castList<T>(get<List<Object?>>(key), key);

  List<T>? optionalList<T extends Object?>(String key) =>
      switch (get<List<Object?>?>(key)?.cast<T>()) {
        null => null,
        final l => _castList<T>(l, key),
      };

  /// [List.cast] but with [FormatException]s.
  static List<T> _castList<T extends Object?>(List<Object?> list, String key) {
    for (final value in list) {
      if (value is! T) {
        throw FormatException(
          'Unexpected value \'$list\' (${list.runtimeType}) for key \'.$key\'. '
          'Expected a ${List<T>}.',
        );
      }
    }
    return list.cast();
  }

  List<T>? optionalListParsed<T extends Object?>(
    String key,
    T Function(Object?) elementParser,
  ) {
    final jsonValue = optionalList(key);
    if (jsonValue == null) return null;
    return [for (final element in jsonValue) elementParser(element)];
  }

  Map<String, T> map$<T extends Object?>(String key) =>
      _castMap<T>(get<Map<String, Object?>>(key), key);

  Map<String, T>? optionalMap<T extends Object?>(String key) =>
      switch (get<Map<String, Object?>?>(key)) {
        null => null,
        final m => _castMap<T>(m, key),
      };

  /// [Map.cast] but with [FormatException]s.
  static Map<String, T> _castMap<T extends Object?>(
    Map<String, Object?> map_,
    String key,
  ) {
    for (final value in map_.values) {
      if (value is! T) {
        throw FormatException(
          'Unexpected value \'$map_\' (${map_.runtimeType}) for key \'.$key\'.'
          'Expected a ${Map<String, T>}.',
        );
      }
    }
    return map_.cast();
  }

  List<String>? optionalStringList(String key) => optionalList<String>(key);

  List<String> stringList(String key) => list<String>(key);

  Uri path(String key) => _fileSystemPathToUri(get<String>(key));

  Uri? optionalPath(String key) {
    final value = get<String?>(key);
    if (value == null) return null;
    return _fileSystemPathToUri(value);
  }

  List<Uri>? optionalPathList(String key) {
    final strings = optionalStringList(key);
    if (strings == null) {
      return null;
    }
    return [for (final string in strings) _fileSystemPathToUri(string)];
  }

  static Uri _fileSystemPathToUri(String path) {
    if (path.endsWith(Platform.pathSeparator)) {
      return Uri.directory(path);
    }
    return Uri.file(path);
  }

  void setOrRemove(String key, Object? value) {
    if (value == null) {
      remove(key);
    } else {
      this[key] = value;
    }
  }
}

extension on List<Uri> {
  List<String> toJson() => [for (final uri in this) uri.toFilePath()];
}

extension <K extends Comparable<K>, V extends Object?> on Map<K, V> {
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
''';
