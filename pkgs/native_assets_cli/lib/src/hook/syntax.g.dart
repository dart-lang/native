// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// This file is generated, do not edit.

import '../utils/json.dart';

class Asset {
  final Map<String, Object?> json;

  Asset.fromJson(this.json);

  Asset({required String type}) : json = {} {
    _type = type;
    json.sortOnKey();
  }

  String get type => json.string('type');

  set _type(String value) {
    json['type'] = value;
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
    json['linking_enabled'] = value;
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
  BuildConfig get config => BuildConfig.fromJson(json.map$('config'));

  Map<String, Map<String, Object?>>? get dependencyMetadata =>
      json.optionalMap<Map<String, Object?>>('dependency_metadata');

  set _dependencyMetadata(Map<String, Map<String, Object?>>? value) {
    if (value == null) {
      json.remove('dependency_metadata');
    } else {
      json['dependency_metadata'] = value;
    }
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
    if (value == null) {
      json.remove('metadata');
    } else {
      json['metadata'] = value;
    }
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

  Config get config => Config.fromJson(json.map$('config'));
  set config(Config value) => json['config'] = value.json;

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
    if (value == null) {
      json.remove('out_file');
    } else {
      json['out_file'] = value.toFilePath();
    }
    json.sortOnKey();
  }

  String get packageName => json.string('package_name');

  set packageName(String value) {
    json['package_name'] = value;
    json.sortOnKey();
  }

  Uri get packageRoot => json.path('package_root');

  set packageRoot(Uri value) {
    json['package_root'] = value.toFilePath();
    json.sortOnKey();
  }

  String get version => json.string('version');

  set version(String value) {
    json['version'] = value;
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

  List<Asset>? get assets {
    final list_ = json.optionalList('assets')?.cast<Map<String, Object?>>();
    if (list_ == null) {
      return null;
    }
    final result = <Asset>[];
    for (final item in list_) {
      result.add(Asset.fromJson(item));
    }
    return result;
  }

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
    if (value == null) {
      json.remove('dependencies');
    } else {
      json['dependencies'] = value.toJson();
    }
    json.sortOnKey();
  }

  String get timestamp => json.string('timestamp');

  set timestamp(String value) {
    json['timestamp'] = value;
    json.sortOnKey();
  }

  String get version => json.string('version');

  set version(String value) {
    json['version'] = value;
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

  List<Asset>? get assets {
    final list_ = json.optionalList('assets')?.cast<Map<String, Object?>>();
    if (list_ == null) {
      return null;
    }
    final result = <Asset>[];
    for (final item in list_) {
      result.add(Asset.fromJson(item));
    }
    return result;
  }

  set _assets(List<Asset>? value) {
    if (value == null) {
      json.remove('assets');
    } else {
      json['assets'] = [for (final item in value) item.json];
    }
  }

  Uri? get resourceIdentifiers => json.optionalPath('resource_identifiers');

  set _resourceIdentifiers(Uri? value) {
    if (value == null) {
      json.remove('resource_identifiers');
    } else {
      json['resource_identifiers'] = value.toFilePath();
    }
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

  /// Setup all fields for [LinkOutput] that are not in
  /// [HookOutput].
  void setup() {}

  @override
  String toString() => 'LinkOutput($json)';
}
