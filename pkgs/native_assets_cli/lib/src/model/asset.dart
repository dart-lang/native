// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:yaml/yaml.dart';

import '../utils/uri.dart';
import '../utils/yaml.dart';
import 'packaging.dart';
import 'target.dart';

abstract class AssetPath {
  factory AssetPath(String pathType, Uri? uri) {
    switch (pathType) {
      case AssetAbsolutePath._pathTypeValue:
        return AssetAbsolutePath(uri!);
      case AssetRelativePath._pathTypeValue:
        return AssetRelativePath(uri!);
      case AssetSystemPath._pathTypeValue:
        return AssetSystemPath(uri!);
      case AssetInExecutable._pathTypeValue:
        return AssetInExecutable();
      case AssetInProcess._pathTypeValue:
        return AssetInProcess();
    }
    throw FormatException('Unknown pathType');
  }

  factory AssetPath.fromYamlMap(YamlMap yamlMap) {
    final pathType = yamlMap[_pathTypeKey] as String;
    final uriString = yamlMap[_uriKey] as String?;
    final uri = uriString != null ? Uri(path: uriString) : null;
    return AssetPath(pathType, uri);
  }

  Map<String, Object> toYamlEncoding();
  List<String> toDartConstEncoding();

  static const _pathTypeKey = 'path_type';
  static const _uriKey = 'uri';

  Future<bool> exists();
}

/// Asset at absolute path [uri].
class AssetAbsolutePath implements AssetPath {
  final Uri uri;

  AssetAbsolutePath(this.uri);

  static const _pathTypeValue = 'absolute';

  @override
  Map<String, Object> toYamlEncoding() => {
        AssetPath._pathTypeKey: _pathTypeValue,
        AssetPath._uriKey: uri.toFilePath(),
      };

  @override
  List<String> toDartConstEncoding() => [_pathTypeValue, uri.toFilePath()];

  @override
  int get hashCode => uri.hashCode ^ 5;

  @override
  bool operator ==(Object other) {
    if (other is! AssetAbsolutePath) {
      return false;
    }
    return uri == other.uri;
  }

  @override
  Future<bool> exists() => uri.fileSystemEntity.exists();
}

/// Asset is avaliable on a relative path.
///
/// If [Packaging] of an [Asset] is [Packaging.dynamic],
/// `Platform.script.resolve(uri)` will be used to load the asset at runtime.
class AssetRelativePath implements AssetPath {
  final Uri uri;

  AssetRelativePath(this.uri);

  static const _pathTypeValue = 'relative';

  @override
  Map<String, Object> toYamlEncoding() => {
        AssetPath._pathTypeKey: _pathTypeValue,
        AssetPath._uriKey: uri.toFilePath(),
      };

  @override
  List<String> toDartConstEncoding() => [_pathTypeValue, uri.toFilePath()];

  @override
  int get hashCode => uri.hashCode ^ 39;

  @override
  bool operator ==(Object other) {
    if (other is! AssetRelativePath) {
      return false;
    }
    return uri == other.uri;
  }

  @override
  Future<bool> exists() => uri.fileSystemEntity.exists();
}

/// Asset is avaliable on the system `PATH`.
///
/// [uri] only contains a file name.
class AssetSystemPath implements AssetPath {
  final Uri uri;

  AssetSystemPath(this.uri);

  static const _pathTypeValue = 'system';

  @override
  Map<String, Object> toYamlEncoding() => {
        AssetPath._pathTypeKey: _pathTypeValue,
        AssetPath._uriKey: uri.toFilePath(),
      };

  @override
  List<String> toDartConstEncoding() => [_pathTypeValue, uri.toFilePath()];

  @override
  int get hashCode => uri.hashCode ^ 13;

  @override
  bool operator ==(Object other) {
    if (other is! AssetSystemPath) {
      return false;
    }
    return uri == other.uri;
  }

  @override
  Future<bool> exists() => Future.value(true);
}

/// Asset is loaded in the process and symbols are available through
/// `DynamicLibrary.process()`.
class AssetInProcess implements AssetPath {
  AssetInProcess._();

  static final AssetInProcess _singleton = AssetInProcess._();

  factory AssetInProcess() => _singleton;

  static const _pathTypeValue = 'process';

  @override
  Map<String, Object> toYamlEncoding() => {
        AssetPath._pathTypeKey: _pathTypeValue,
      };

  @override
  List<String> toDartConstEncoding() => [_pathTypeValue];

  @override
  Future<bool> exists() => Future.value(true);
}

/// Asset is embedded in executable and symbols are available through
/// `DynamicLibrary.executable()`.
class AssetInExecutable implements AssetPath {
  AssetInExecutable._();

  static final AssetInExecutable _singleton = AssetInExecutable._();

  factory AssetInExecutable() => _singleton;

  static const _pathTypeValue = 'executable';

  @override
  Map<String, Object> toYamlEncoding() => {
        AssetPath._pathTypeKey: _pathTypeValue,
      };

  @override
  List<String> toDartConstEncoding() => [_pathTypeValue];

  @override
  Future<bool> exists() => Future.value(true);
}

class Asset {
  final Packaging packaging;
  final String name;
  final Target target;
  final AssetPath path;

  Asset({
    required this.name,
    required this.packaging,
    required this.target,
    required this.path,
  });

  factory Asset.copy(
    Asset from, {
    Packaging? packaging,
    String? name,
    Target? target,
    AssetPath? path,
  }) =>
      Asset(
        name: name ?? from.name,
        packaging: packaging ?? from.packaging,
        target: target ?? from.target,
        path: path ?? from.path,
      );

  factory Asset.fromYamlMap(YamlMap yamlMap) => Asset(
        name: yamlMap[_nameKey] as String,
        path: AssetPath.fromYamlMap(yamlMap[_pathKey] as YamlMap),
        target: Target.fromString(yamlMap[_targetKey] as String),
        packaging: Packaging.fromName(yamlMap[_packagingKey] as String),
      );

  static List<Asset> listFromYamlString(String yaml) {
    final yamlObject = loadYaml(yaml);
    if (yamlObject == null) {
      return [];
    }
    return [
      for (final yamlElement in yamlObject as YamlList)
        Asset.fromYamlMap(yamlElement as YamlMap),
    ];
  }

  static List<Asset> listFromYamlList(YamlList yamlList) => [
        for (final yamlElement in yamlList)
          Asset.fromYamlMap(yamlElement as YamlMap),
      ];

  @override
  bool operator ==(Object other) {
    if (other is! Asset) {
      return false;
    }
    return other.name == name &&
        other.packaging == packaging &&
        other.target == target &&
        other.path == path;
  }

  @override
  int get hashCode =>
      name.hashCode ^ packaging.hashCode ^ target.hashCode ^ path.hashCode;

  Map<String, Object> toYamlEncoding() => {
        _nameKey: name,
        _packagingKey: packaging.name,
        _pathKey: path.toYamlEncoding(),
        _targetKey: target.toString(),
      };

  Map<String, List<String>> toDartConstEncoding() => {
        name: path.toDartConstEncoding(),
      };

  String toYaml() => toYamlString(toYamlEncoding());

  static const _nameKey = 'name';
  static const _packagingKey = 'packaging';
  static const _pathKey = 'path';
  static const _targetKey = 'target';

  Future<bool> exists() => path.exists();

  @override
  String toString() => 'Asset(${toYamlEncoding()})';
}

extension AssetIterable on Iterable<Asset> {
  List<Object> toYamlEncoding() =>
      [for (final item in this) item.toYamlEncoding()];

  String toYaml() => toYamlString(toYamlEncoding());

  Iterable<Asset> wherePackaging(Packaging packaging) =>
      where((e) => e.packaging == packaging);

  Map<Target, List<Asset>> get assetsPerTarget {
    final result = <Target, List<Asset>>{};
    for (final asset in this) {
      final assets = result[asset.target] ?? [];
      assets.add(asset);
      result[asset.target] = assets;
    }
    return result;
  }

  Map<String, Map<String, List<String>>> toDartConstEncoding() => {
        for (final entry in assetsPerTarget.entries)
          entry.key.toString(): _combineMaps(
              entry.value.map((e) => e.toDartConstEncoding()).toList())
      };

  Map<Object, Object> toNativeAssetsFileEncoding() => {
        'format-version': [1, 0, 0],
        'native-assets': toDartConstEncoding(),
      };

  String toNativeAssetsFile() => toYamlString(toNativeAssetsFileEncoding());

  Future<bool> allExist() async {
    final allResults = await Future.wait(map((e) => e.exists()));
    final missing = allResults.contains(false);
    return !missing;
  }
}

Map<X, Y> _combineMaps<X, Y>(Iterable<Map<X, Y>> maps) {
  final result = <X, Y>{};
  for (final map in maps) {
    result.addAll(map);
  }
  return result;
}
