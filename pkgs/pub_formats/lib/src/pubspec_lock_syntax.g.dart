// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// This file is generated, do not edit.
// File generated by pkgs/pub_formats/tool/generate.dart.
// Must be rerun when pkgs/pub_formats/doc/schema/ is modified.

// ignore_for_file: unused_element, public_member_api_docs

import 'dart:io';

class DependencyTypeSyntax {
  final String name;

  const DependencyTypeSyntax._(this.name);

  static const directMain = DependencyTypeSyntax._('direct main');

  static const transitive = DependencyTypeSyntax._('transitive');

  static const List<DependencyTypeSyntax> values = [directMain, transitive];

  static final Map<String, DependencyTypeSyntax> _byName = {
    for (final value in values) value.name: value,
  };

  DependencyTypeSyntax.unknown(this.name)
    : assert(!_byName.keys.contains(name));

  factory DependencyTypeSyntax.fromJson(String name) {
    final knownValue = _byName[name];
    if (knownValue != null) {
      return knownValue;
    }
    return DependencyTypeSyntax.unknown(name);
  }

  bool get isKnown => _byName[name] != null;

  @override
  String toString() => name;
}

class GitPackageDescriptionSyntax extends PackageDescriptionSyntax {
  GitPackageDescriptionSyntax.fromJson(super.json, {super.path})
    : super.fromJson();

  GitPackageDescriptionSyntax({
    required String path$,
    required String ref,
    required String resolvedRef,
    required String url,
    super.path = const [],
  }) : super() {
    _path$ = path$;
    _ref = ref;
    _resolvedRef = resolvedRef;
    _url = url;
    json.sortOnKey();
  }

  /// Setup all fields for [GitPackageDescriptionSyntax] that are not in
  /// [PackageDescriptionSyntax].
  void setup({
    required String path$,
    required String ref,
    required String resolvedRef,
    required String url,
  }) {
    _path$ = path$;
    _ref = ref;
    _resolvedRef = resolvedRef;
    _url = url;
    json.sortOnKey();
  }

  String get path$ => _reader.get<String>('path');

  set _path$(String value) {
    json.setOrRemove('path', value);
  }

  List<String> _validatePath$() => _reader.validate<String>('path');

  String get ref => _reader.get<String>('ref');

  set _ref(String value) {
    json.setOrRemove('ref', value);
  }

  List<String> _validateRef() => _reader.validate<String>('ref');

  static final _resolvedRefPattern = RegExp(r'^[a-f0-9]{40}$');

  String get resolvedRef => _reader.string('resolved-ref', _resolvedRefPattern);

  set _resolvedRef(String value) {
    if (!_resolvedRefPattern.hasMatch(value)) {
      throw ArgumentError.value(
        value,
        'value',
        'Value does not satisify pattern: ${_resolvedRefPattern.pattern}.',
      );
    }
    json.setOrRemove('resolved-ref', value);
  }

  List<String> _validateResolvedRef() =>
      _reader.validateString('resolved-ref', _resolvedRefPattern);

  String get url => _reader.get<String>('url');

  set _url(String value) {
    json.setOrRemove('url', value);
  }

  List<String> _validateUrl() => _reader.validate<String>('url');

  @override
  List<String> validate() => [
    ...super.validate(),
    ..._validatePath$(),
    ..._validateRef(),
    ..._validateResolvedRef(),
    ..._validateUrl(),
  ];

  @override
  String toString() => 'GitPackageDescriptionSyntax($json)';
}

class HostedPackageDescriptionSyntax extends PackageDescriptionSyntax {
  HostedPackageDescriptionSyntax.fromJson(super.json, {super.path})
    : super.fromJson();

  HostedPackageDescriptionSyntax({
    required String name,
    required String sha256,
    required String url,
    super.path = const [],
  }) : super() {
    _name = name;
    _sha256 = sha256;
    _url = url;
    json.sortOnKey();
  }

  /// Setup all fields for [HostedPackageDescriptionSyntax] that are not in
  /// [PackageDescriptionSyntax].
  void setup({
    required String name,
    required String sha256,
    required String url,
  }) {
    _name = name;
    _sha256 = sha256;
    _url = url;
    json.sortOnKey();
  }

  static final _namePattern = RegExp(r'^[a-zA-Z_]\w*$');

  String get name => _reader.string('name', _namePattern);

  set _name(String value) {
    if (!_namePattern.hasMatch(value)) {
      throw ArgumentError.value(
        value,
        'value',
        'Value does not satisify pattern: ${_namePattern.pattern}.',
      );
    }
    json.setOrRemove('name', value);
  }

  List<String> _validateName() => _reader.validateString('name', _namePattern);

  static final _sha256Pattern = RegExp(r'^[a-f0-9]{64}$');

  String get sha256 => _reader.string('sha256', _sha256Pattern);

  set _sha256(String value) {
    if (!_sha256Pattern.hasMatch(value)) {
      throw ArgumentError.value(
        value,
        'value',
        'Value does not satisify pattern: ${_sha256Pattern.pattern}.',
      );
    }
    json.setOrRemove('sha256', value);
  }

  List<String> _validateSha256() =>
      _reader.validateString('sha256', _sha256Pattern);

  String get url => _reader.get<String>('url');

  set _url(String value) {
    json.setOrRemove('url', value);
  }

  List<String> _validateUrl() => _reader.validate<String>('url');

  @override
  List<String> validate() => [
    ...super.validate(),
    ..._validateName(),
    ..._validateSha256(),
    ..._validateUrl(),
  ];

  @override
  String toString() => 'HostedPackageDescriptionSyntax($json)';
}

class PackageSyntax extends JsonObjectSyntax {
  PackageSyntax.fromJson(super.json, {super.path = const []})
    : super.fromJson();

  PackageSyntax({
    required DependencyTypeSyntax dependency,
    required PackageDescriptionSyntax description,
    required PackageSourceSyntax source,
    required String version,
    super.path = const [],
  }) : super() {
    _dependency = dependency;
    _description = description;
    _source = source;
    _version = version;
    json.sortOnKey();
  }

  DependencyTypeSyntax get dependency {
    final jsonValue = _reader.get<String>('dependency');
    return DependencyTypeSyntax.fromJson(jsonValue);
  }

  set _dependency(DependencyTypeSyntax value) {
    json['dependency'] = value.name;
  }

  List<String> _validateDependency() => _reader.validate<String>('dependency');

  PackageDescriptionSyntax get description {
    final jsonValue = _reader.map$('description');
    return PackageDescriptionSyntax.fromJson(
      jsonValue,
      path: [...path, 'description'],
    );
  }

  set _description(PackageDescriptionSyntax value) {
    json['description'] = value.json;
  }

  List<String> _validateDescription() {
    final mapErrors = _reader.validate<Map<String, Object?>>('description');
    if (mapErrors.isNotEmpty) {
      return mapErrors;
    }
    return description.validate();
  }

  PackageSourceSyntax get source {
    final jsonValue = _reader.get<String>('source');
    return PackageSourceSyntax.fromJson(jsonValue);
  }

  set _source(PackageSourceSyntax value) {
    json['source'] = value.name;
  }

  List<String> _validateSource() => _reader.validate<String>('source');

  static final _versionPattern = RegExp(
    r'^[0-9]+\.[0-9]+\.[0-9]+(?:-[a-zA-Z0-9.]+)?$',
  );

  String get version => _reader.string('version', _versionPattern);

  set _version(String value) {
    if (!_versionPattern.hasMatch(value)) {
      throw ArgumentError.value(
        value,
        'value',
        'Value does not satisify pattern: ${_versionPattern.pattern}.',
      );
    }
    json.setOrRemove('version', value);
  }

  List<String> _validateVersion() =>
      _reader.validateString('version', _versionPattern);

  @override
  List<String> validate() => [
    ...super.validate(),
    ..._validateDependency(),
    ..._validateDescription(),
    ..._validateSource(),
    ..._validateVersion(),
  ];

  @override
  String toString() => 'PackageSyntax($json)';
}

class PackageDescriptionSyntax extends JsonObjectSyntax {
  PackageDescriptionSyntax.fromJson(super.json, {super.path = const []})
    : super.fromJson();

  PackageDescriptionSyntax({super.path = const []}) : super();

  @override
  List<String> validate() => [...super.validate()];

  @override
  String toString() => 'PackageDescriptionSyntax($json)';
}

class PackageSourceSyntax {
  final String name;

  const PackageSourceSyntax._(this.name);

  static const git = PackageSourceSyntax._('git');

  static const hosted = PackageSourceSyntax._('hosted');

  static const path$ = PackageSourceSyntax._('path');

  static const List<PackageSourceSyntax> values = [git, hosted, path$];

  static final Map<String, PackageSourceSyntax> _byName = {
    for (final value in values) value.name: value,
  };

  PackageSourceSyntax.unknown(this.name) : assert(!_byName.keys.contains(name));

  factory PackageSourceSyntax.fromJson(String name) {
    final knownValue = _byName[name];
    if (knownValue != null) {
      return knownValue;
    }
    return PackageSourceSyntax.unknown(name);
  }

  bool get isKnown => _byName[name] != null;

  @override
  String toString() => name;
}

class PathPackageDescriptionSyntax extends PackageDescriptionSyntax {
  PathPackageDescriptionSyntax.fromJson(super.json, {super.path})
    : super.fromJson();

  PathPackageDescriptionSyntax({
    required String path$,
    required bool relative,
    super.path = const [],
  }) : super() {
    _path$ = path$;
    _relative = relative;
    json.sortOnKey();
  }

  /// Setup all fields for [PathPackageDescriptionSyntax] that are not in
  /// [PackageDescriptionSyntax].
  void setup({required String path$, required bool relative}) {
    _path$ = path$;
    _relative = relative;
    json.sortOnKey();
  }

  String get path$ => _reader.get<String>('path');

  set _path$(String value) {
    json.setOrRemove('path', value);
  }

  List<String> _validatePath$() => _reader.validate<String>('path');

  bool get relative => _reader.get<bool>('relative');

  set _relative(bool value) {
    json.setOrRemove('relative', value);
  }

  List<String> _validateRelative() => _reader.validate<bool>('relative');

  @override
  List<String> validate() => [
    ...super.validate(),
    ..._validatePath$(),
    ..._validateRelative(),
  ];

  @override
  String toString() => 'PathPackageDescriptionSyntax($json)';
}

class PubspecLockFileSyntax extends JsonObjectSyntax {
  PubspecLockFileSyntax.fromJson(super.json, {super.path = const []})
    : super.fromJson();

  PubspecLockFileSyntax({
    Map<String, PackageSyntax>? packages,
    required SDKsSyntax sdks,
    super.path = const [],
  }) : super() {
    _packages = packages;
    _sdks = sdks;
    json.sortOnKey();
  }

  static final _packagesKeyPattern = RegExp(r'^[a-zA-Z_]\w*$');

  Map<String, PackageSyntax>? get packages {
    final jsonValue = _reader.optionalMap(
      'packages',
      keyPattern: _packagesKeyPattern,
    );
    if (jsonValue == null) {
      return null;
    }
    return {
      for (final MapEntry(:key, :value) in jsonValue.entries)
        key: PackageSyntax.fromJson(
          value as Map<String, Object?>,
          path: [...path, key],
        ),
    };
  }

  set _packages(Map<String, PackageSyntax>? value) {
    _checkArgumentMapKeys(value, keyPattern: _packagesKeyPattern);
    if (value == null) {
      json.remove('packages');
    } else {
      json['packages'] = {
        for (final MapEntry(:key, :value) in value.entries) key: value.json,
      };
    }
  }

  List<String> _validatePackages() {
    final mapErrors = _reader.validateOptionalMap(
      'packages',
      keyPattern: _packagesKeyPattern,
    );
    if (mapErrors.isNotEmpty) {
      return mapErrors;
    }
    final jsonValue = _reader.optionalMap('packages');
    if (jsonValue == null) {
      return [];
    }
    final result = <String>[];
    for (final value in packages!.values) {
      result.addAll(value.validate());
    }
    return result;
  }

  SDKsSyntax get sdks {
    final jsonValue = _reader.map$('sdks');
    return SDKsSyntax.fromJson(jsonValue, path: [...path, 'sdks']);
  }

  set _sdks(SDKsSyntax value) {
    json['sdks'] = value.json;
  }

  List<String> _validateSdks() {
    final mapErrors = _reader.validate<Map<String, Object?>>('sdks');
    if (mapErrors.isNotEmpty) {
      return mapErrors;
    }
    return sdks.validate();
  }

  @override
  List<String> validate() => [
    ...super.validate(),
    ..._validatePackages(),
    ..._validateSdks(),
  ];

  @override
  String toString() => 'PubspecLockFileSyntax($json)';
}

class SDKsSyntax extends JsonObjectSyntax {
  SDKsSyntax.fromJson(super.json, {super.path = const []}) : super.fromJson();

  SDKsSyntax({required String dart, super.path = const []}) : super() {
    _dart = dart;
    json.sortOnKey();
  }

  String get dart => _reader.get<String>('dart');

  set _dart(String value) {
    json.setOrRemove('dart', value);
  }

  List<String> _validateDart() => _reader.validate<String>('dart');

  @override
  List<String> validate() => [...super.validate(), ..._validateDart()];

  @override
  String toString() => 'SDKsSyntax($json)';
}

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
