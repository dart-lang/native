// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// This file is generated, do not edit.

// ignore_for_file: unused_element

import 'dart:io';

class Asset {
  final Map<String, Object?> json;

  Asset.fromJson(this.json);

  Asset({required String type}) : json = {} {
    _type = type;
    json.sortOnKey();
  }

  String get type => json.get<String>('type');

  set _type(String value) {
    json.setOrRemove('type', value);
  }

  @override
  String toString() => 'Asset($json)';
}

class BuildConfig extends Config {
  BuildConfig.fromJson(super.json) : super.fromJson();

  BuildConfig({required super.buildAssetTypes, required bool linkingEnabled})
    : super() {
    _linkingEnabled = linkingEnabled;
    json.sortOnKey();
  }

  /// Setup all fields for [BuildConfig] that are not in
  /// [Config].
  void setup({required bool linkingEnabled}) {
    _linkingEnabled = linkingEnabled;
    json.sortOnKey();
  }

  bool get linkingEnabled => json.get<bool>('linking_enabled');

  set _linkingEnabled(bool value) {
    json.setOrRemove('linking_enabled', value);
  }

  @override
  String toString() => 'BuildConfig($json)';
}

class BuildInput extends HookInput {
  BuildInput.fromJson(super.json) : super.fromJson();

  BuildInput({
    required super.config,
    Map<String, Map<String, Object?>>? dependencyMetadata,
    required super.outDir,
    required super.outDirShared,
    super.outFile,
    required super.packageName,
    required super.packageRoot,
    required super.version,
  }) : super() {
    _dependencyMetadata = dependencyMetadata;
    json.sortOnKey();
  }

  /// Setup all fields for [BuildInput] that are not in
  /// [HookInput].
  void setup({Map<String, Map<String, Object?>>? dependencyMetadata}) {
    _dependencyMetadata = dependencyMetadata;
    json.sortOnKey();
  }

  @override
  BuildConfig get config {
    final jsonValue = json.map$('config');
    return BuildConfig.fromJson(jsonValue);
  }

  Map<String, Map<String, Object?>>? get dependencyMetadata =>
      json.optionalMap<Map<String, Object?>>('dependency_metadata');

  set _dependencyMetadata(Map<String, Map<String, Object?>>? value) {
    json.setOrRemove('dependency_metadata', value);
  }

  @override
  String toString() => 'BuildInput($json)';
}

class BuildOutput extends HookOutput {
  BuildOutput.fromJson(super.json) : super.fromJson();

  BuildOutput({
    super.assets,
    Map<String, List<Asset>>? assetsForLinking,
    super.dependencies,
    Map<String, Object?>? metadata,
    required super.timestamp,
    required super.version,
  }) : super() {
    this.assetsForLinking = assetsForLinking;
    this.metadata = metadata;
    json.sortOnKey();
  }

  /// Setup all fields for [BuildOutput] that are not in
  /// [HookOutput].
  void setup({
    Map<String, List<Asset>>? assetsForLinking,
    Map<String, Object?>? metadata,
  }) {
    this.assetsForLinking = assetsForLinking;
    this.metadata = metadata;
    json.sortOnKey();
  }

  Map<String, List<Asset>>? get assetsForLinking {
    final map_ = json.optionalMap('assetsForLinking');
    if (map_ == null) {
      return null;
    }
    return {
      for (final MapEntry(:key, :value) in map_.entries)
        key: [
          for (final item in value as List<Object?>)
            Asset.fromJson(item as Map<String, Object?>),
        ],
    };
  }

  set assetsForLinking(Map<String, List<Asset>>? value) {
    if (value == null) {
      json.remove('assetsForLinking');
    } else {
      json['assetsForLinking'] = {
        for (final MapEntry(:key, :value) in value.entries)
          key: [for (final item in value) item.json],
      };
    }
    json.sortOnKey();
  }

  Map<String, Object?>? get metadata => json.optionalMap('metadata');

  set metadata(Map<String, Object?>? value) {
    json.setOrRemove('metadata', value);
    json.sortOnKey();
  }

  @override
  String toString() => 'BuildOutput($json)';
}

class Config {
  final Map<String, Object?> json;

  Config.fromJson(this.json);

  Config({required List<String> buildAssetTypes}) : json = {} {
    this.buildAssetTypes = buildAssetTypes;
    json.sortOnKey();
  }

  List<String> get buildAssetTypes => json.stringList('build_asset_types');

  set buildAssetTypes(List<String> value) {
    json['build_asset_types'] = value;
    json.sortOnKey();
  }

  @override
  String toString() => 'Config($json)';
}

class HookInput {
  final Map<String, Object?> json;

  HookInput.fromJson(this.json);

  HookInput({
    required Config config,
    required Uri outDir,
    required Uri outDirShared,
    Uri? outFile,
    required String packageName,
    required Uri packageRoot,
    required String version,
  }) : json = {} {
    this.config = config;
    this.outDir = outDir;
    this.outDirShared = outDirShared;
    this.outFile = outFile;
    this.packageName = packageName;
    this.packageRoot = packageRoot;
    this.version = version;
    json.sortOnKey();
  }

  Config get config {
    final jsonValue = json.map$('config');
    return Config.fromJson(jsonValue);
  }

  set config(Config value) {
    json['config'] = value.json;
    json.sortOnKey();
  }

  Uri get outDir => json.path('out_dir');

  set outDir(Uri value) {
    json['out_dir'] = value.toFilePath();
    json.sortOnKey();
  }

  Uri get outDirShared => json.path('out_dir_shared');

  set outDirShared(Uri value) {
    json['out_dir_shared'] = value.toFilePath();
    json.sortOnKey();
  }

  Uri? get outFile => json.optionalPath('out_file');

  set outFile(Uri? value) {
    json.setOrRemove('out_file', value?.toFilePath());
    json.sortOnKey();
  }

  String get packageName => json.get<String>('package_name');

  set packageName(String value) {
    json.setOrRemove('package_name', value);
    json.sortOnKey();
  }

  Uri get packageRoot => json.path('package_root');

  set packageRoot(Uri value) {
    json['package_root'] = value.toFilePath();
    json.sortOnKey();
  }

  String get version => json.get<String>('version');

  set version(String value) {
    json.setOrRemove('version', value);
    json.sortOnKey();
  }

  @override
  String toString() => 'HookInput($json)';
}

class HookOutput {
  final Map<String, Object?> json;

  HookOutput.fromJson(this.json);

  HookOutput({
    List<Asset>? assets,
    List<Uri>? dependencies,
    required String timestamp,
    required String version,
  }) : json = {} {
    this.assets = assets;
    this.dependencies = dependencies;
    this.timestamp = timestamp;
    this.version = version;
    json.sortOnKey();
  }

  List<Asset>? get assets => json.optionalListParsed(
    'assets',
    (e) => Asset.fromJson(e as Map<String, Object?>),
  );

  set assets(List<Asset>? value) {
    if (value == null) {
      json.remove('assets');
    } else {
      json['assets'] = [for (final item in value) item.json];
    }
    json.sortOnKey();
  }

  List<Uri>? get dependencies => json.optionalPathList('dependencies');

  set dependencies(List<Uri>? value) {
    json.setOrRemove('dependencies', value?.toJson());
    json.sortOnKey();
  }

  String get timestamp => json.get<String>('timestamp');

  set timestamp(String value) {
    json.setOrRemove('timestamp', value);
    json.sortOnKey();
  }

  String get version => json.get<String>('version');

  set version(String value) {
    json.setOrRemove('version', value);
    json.sortOnKey();
  }

  @override
  String toString() => 'HookOutput($json)';
}

class LinkInput extends HookInput {
  LinkInput.fromJson(super.json) : super.fromJson();

  LinkInput({
    List<Asset>? assets,
    required super.config,
    required super.outDir,
    required super.outDirShared,
    super.outFile,
    required super.packageName,
    required super.packageRoot,
    Uri? resourceIdentifiers,
    required super.version,
  }) : super() {
    _assets = assets;
    _resourceIdentifiers = resourceIdentifiers;
    json.sortOnKey();
  }

  /// Setup all fields for [LinkInput] that are not in
  /// [HookInput].
  void setup({List<Asset>? assets, Uri? resourceIdentifiers}) {
    _assets = assets;
    _resourceIdentifiers = resourceIdentifiers;
    json.sortOnKey();
  }

  List<Asset>? get assets => json.optionalListParsed(
    'assets',
    (e) => Asset.fromJson(e as Map<String, Object?>),
  );

  set _assets(List<Asset>? value) {
    if (value == null) {
      json.remove('assets');
    } else {
      json['assets'] = [for (final item in value) item.json];
    }
  }

  Uri? get resourceIdentifiers => json.optionalPath('resource_identifiers');

  set _resourceIdentifiers(Uri? value) {
    json.setOrRemove('resource_identifiers', value?.toFilePath());
  }

  @override
  String toString() => 'LinkInput($json)';
}

class LinkOutput extends HookOutput {
  LinkOutput.fromJson(super.json) : super.fromJson();

  LinkOutput({
    super.assets,
    super.dependencies,
    required super.timestamp,
    required super.version,
  }) : super();

  @override
  String toString() => 'LinkOutput($json)';
}

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
