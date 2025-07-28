// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Helper methods for the code generator that are added to the generated file.
///
/// This simplifies the code generator.
// TODO(https://github.com/dart-lang/native/issues/2447): At some time, move
// this to a helper package to avoid copying.
const helperLib = r'''
class JsonObjectSyntax {
  final Map<String, Object?> json;

  final List<Object> path;

  _JsonReader get _reader => _JsonReader(json, path);

  JsonObjectSyntax({this.path = const []}) : json = {};

  JsonObjectSyntax.fromJson(this.json, {this.path = const []});

  List<String> validate() => [];
}

class _JsonReader {
  /// The JSON Object this reader is reading.
  final Map<String, Object?> json;

  /// The path traversed by readers of the surrounding JSON.
  ///
  /// Contains [String] property keys and [int] indices.
  ///
  /// This is used to give more precise error messages.
  final List<Object> path;

  _JsonReader(this.json, this.path);

  T get<T extends Object?>(String key) {
    final value = json[key];
    if (value is T) return value;
    throwFormatException(value, T, [key]);
  }

  List<String> validate<T extends Object?>(String key) {
    final value = json[key];
    if (value is T) return [];
    return [
      errorString(value, T, [key]),
    ];
  }

  List<T> list<T extends Object?>(String key) =>
      _castList<T>(get<List<Object?>>(key), key);

  List<String> validateList<T extends Object?>(String key) {
    final listErrors = validate<List<Object?>>(key);
    if (listErrors.isNotEmpty) {
      return listErrors;
    }
    return _validateListElements(get<List<Object?>>(key), key);
  }

  List<T>? optionalList<T extends Object?>(String key) =>
      switch (get<List<Object?>?>(key)?.cast<T>()) {
        null => null,
        final l => _castList<T>(l, key),
      };

  List<String> validateOptionalList<T extends Object?>(String key) {
    final listErrors = validate<List<Object?>?>(key);
    if (listErrors.isNotEmpty) {
      return listErrors;
    }
    final list = get<List<Object?>?>(key);
    if (list == null) {
      return [];
    }
    return _validateListElements(list, key);
  }

  /// [List.cast] but with [FormatException]s.
  List<T> _castList<T extends Object?>(List<Object?> list, String key) {
    for (final (index, value) in list.indexed) {
      if (value is! T) {
        throwFormatException(value, T, [key, index]);
      }
    }
    return list.cast();
  }

  List<String> _validateListElements<T extends Object?>(
    List<Object?> list,
    String key,
  ) {
    final result = <String>[];
    for (final (index, value) in list.indexed) {
      if (value is! T) {
        result.add(errorString(value, T, [key, index]));
      }
    }
    return result;
  }

  Map<String, T> map$<T extends Object?>(String key, {RegExp? keyPattern}) {
    final map = get<Map<String, Object?>>(key);
    final keyErrors = _validateMapKeys(map, key, keyPattern: keyPattern);
    if (keyErrors.isNotEmpty) {
      throw FormatException(keyErrors.join('\n'));
    }
    return _castMap<T>(map, key);
  }

  List<String> validateMap<T extends Object?>(
    String key, {
    RegExp? keyPattern,
  }) {
    final mapErrors = validate<Map<String, Object?>>(key);
    if (mapErrors.isNotEmpty) {
      return mapErrors;
    }
    final map = get<Map<String, Object?>>(key);
    return [
      ..._validateMapKeys(map, key, keyPattern: keyPattern),
      ..._validateMapElements<T>(map, key),
    ];
  }

  Map<String, T>? optionalMap<T extends Object?>(
    String key, {
    RegExp? keyPattern,
  }) {
    final map = get<Map<String, Object?>?>(key);
    if (map == null) return null;
    final keyErrors = _validateMapKeys(map, key, keyPattern: keyPattern);
    if (keyErrors.isNotEmpty) {
      throw FormatException(keyErrors.join('\n'));
    }
    return _castMap<T>(map, key);
  }

  List<String> validateOptionalMap<T extends Object?>(
    String key, {
    RegExp? keyPattern,
  }) {
    final mapErrors = validate<Map<String, Object?>?>(key);
    if (mapErrors.isNotEmpty) {
      return mapErrors;
    }
    final map = get<Map<String, Object?>?>(key);
    if (map == null) {
      return [];
    }
    return [
      ..._validateMapKeys(map, key, keyPattern: keyPattern),
      ..._validateMapElements<T>(map, key),
    ];
  }

  /// [Map.cast] but with [FormatException]s.
  Map<String, T> _castMap<T extends Object?>(
    Map<String, Object?> map_,
    String parentKey,
  ) {
    for (final MapEntry(:key, :value) in map_.entries) {
      if (value is! T) {
        throwFormatException(value, T, [parentKey, key]);
      }
    }
    return map_.cast();
  }

  List<String> _validateMapKeys(
    Map<String, Object?> map_,
    String parentKey, {
    required RegExp? keyPattern,
  }) {
    if (keyPattern == null) return [];
    final result = <String>[];
    for (final key in map_.keys) {
      if (!keyPattern.hasMatch(key)) {
        result.add(
          keyErrorString(key, pattern: keyPattern, pathExtension: [parentKey]),
        );
      }
    }
    return result;
  }

  List<String> _validateMapElements<T extends Object?>(
    Map<String, Object?> map_,
    String parentKey,
  ) {
    final result = <String>[];
    for (final MapEntry(:key, :value) in map_.entries) {
      if (value is! T) {
        result.add(errorString(value, T, [parentKey, key]));
      }
    }
    return result;
  }

  List<String> validateMapStringElements<T extends Object?>(
    Map<String, String?> map_,
    String parentKey, {
    RegExp? valuePattern,
  }) {
    final result = <String>[];
    for (final MapEntry(:key, :value) in map_.entries) {
      if (value != null &&
          valuePattern != null &&
          !valuePattern.hasMatch(value)) {
        result.add(
          errorString(value, T, [parentKey, key], pattern: valuePattern),
        );
      }
    }
    return result;
  }

  String string(String key, RegExp? pattern) {
    final value = get<String>(key);
    if (pattern != null && !pattern.hasMatch(value)) {
      throwFormatException(value, String, [key], pattern: pattern);
    }
    return value;
  }

  String? optionalString(String key, RegExp? pattern) {
    final value = get<String?>(key);
    if (value == null) return null;
    if (pattern != null && !pattern.hasMatch(value)) {
      throwFormatException(value, String, [key], pattern: pattern);
    }
    return value;
  }

  List<String> validateString(String key, RegExp? pattern) {
    final errors = validate<String>(key);
    if (errors.isNotEmpty) {
      return errors;
    }
    final value = get<String>(key);
    if (pattern != null && !pattern.hasMatch(value)) {
      return [
        errorString(value, String, [key], pattern: pattern),
      ];
    }
    return [];
  }

  List<String> validateOptionalString(String key, RegExp? pattern) {
    final errors = validate<String?>(key);
    if (errors.isNotEmpty) {
      return errors;
    }
    final value = get<String?>(key);
    if (value == null) return [];
    if (pattern != null && !pattern.hasMatch(value)) {
      return [
        errorString(value, String, [key], pattern: pattern),
      ];
    }
    return [];
  }

  List<String>? optionalStringList(String key) => optionalList<String>(key);

  List<String> validateOptionalStringList(String key) =>
      validateOptionalList<String>(key);

  List<String> stringList(String key) => list<String>(key);

  List<String> validateStringList(String key) => validateList<String>(key);

  Uri path$(String key) => _fileSystemPathToUri(get<String>(key));

  List<String> validatePath(String key) => validate<String>(key);

  Uri? optionalPath(String key) {
    final value = get<String?>(key);
    if (value == null) return null;
    return _fileSystemPathToUri(value);
  }

  List<String> validateOptionalPath(String key) => validate<String?>(key);

  List<Uri>? optionalPathList(String key) {
    final strings = optionalStringList(key);
    if (strings == null) {
      return null;
    }
    return [for (final string in strings) _fileSystemPathToUri(string)];
  }

  List<String> validateOptionalPathList(String key) =>
      validateOptionalStringList(key);

  static Uri _fileSystemPathToUri(String path) {
    if (path.endsWith(Platform.pathSeparator)) {
      return Uri.directory(path);
    }
    return Uri.file(path);
  }

  String _jsonPathToString(List<Object> pathEnding) =>
      [...path, ...pathEnding].join('.');

  Never throwFormatException(
    Object? value,
    Type expectedType,
    List<Object> pathExtension, {
    RegExp? pattern,
  }) {
    throw FormatException(
      errorString(value, expectedType, pathExtension, pattern: pattern),
    );
  }

  String errorString(
    Object? value,
    Type expectedType,
    List<Object> pathExtension, {
    RegExp? pattern,
  }) {
    final pathString = _jsonPathToString(pathExtension);
    if (value == null) {
      return "No value was provided for '$pathString'."
          ' Expected a $expectedType.';
    }
    final satisfying = pattern == null ? '' : ' satisfying ${pattern.pattern}';
    return "Unexpected value '$value' (${value.runtimeType}) for '$pathString'."
        ' Expected a $expectedType$satisfying.';
  }

  String keyErrorString(
    String key, {
    required RegExp pattern,
    List<Object> pathExtension = const [],
  }) {
    final pathString = _jsonPathToString(pathExtension);
    return "Unexpected key '$key' in '$pathString'."
        ' Expected a key satisfying ${pattern.pattern}.';
  }

  /// Traverses a JSON path, returns `null` if the path cannot be traversed.
  Object? tryTraverse(List<String> path) {
    Object? json = this.json;
    for (final key in path) {
      if (json is! Map<String, Object?>) {
        return null;
      }
      json = json[key];
    }
    return json;
  }
}

extension on Map<String, Object?> {
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

extension<K extends Comparable<K>, V extends Object?> on Map<K, V> {
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

void _checkArgumentMapKeys(Map<String, Object?>? map, {RegExp? keyPattern}) {
  if (map == null) return;
  if (keyPattern == null) return;
  for (final key in map.keys) {
    if (!keyPattern.hasMatch(key)) {
      throw ArgumentError.value(
        map,
        "Unexpected key '$key'."
        ' Expected a key satisfying ${keyPattern.pattern}.',
      );
    }
  }
}

void _checkArgumentMapStringElements(
  Map<String, String?>? map, {
  RegExp? valuePattern,
}) {
  if (map == null) return;
  if (valuePattern == null) return;
  for (final entry in map.entries) {
    final value = entry.value;
    if (value != null && !valuePattern.hasMatch(value)) {
      throw ArgumentError.value(
        map,
        "Unexpected value '$value' under key '${entry.key}'."
        ' Expected a value satisfying ${valuePattern.pattern}.',
      );
    }
  }
}
''';
