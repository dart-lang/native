// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:yaml/yaml.dart';

import '../utils/uri.dart';
import '../utils/yaml.dart';
import 'link_mode.dart';
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
    throw FormatException('Unknown pathType: $pathType.');
  }

  factory AssetPath.fromYaml(YamlMap yamlMap) {
    final pathType = yamlMap[_pathTypeKey] as String;
    final uriString = yamlMap[_uriKey] as String?;
    final uri = uriString != null ? Uri(path: uriString) : null;
    return AssetPath(pathType, uri);
  }

  Map<String, Object> toYaml();
  List<String> toDartConst();

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
  Map<String, Object> toYaml() => {
        AssetPath._pathTypeKey: _pathTypeValue,
        AssetPath._uriKey: uri.toFilePath(),
      };

  @override
  List<String> toDartConst() => [_pathTypeValue, uri.toFilePath()];

  @override
  int get hashCode => Object.hash(uri, 133711);

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
/// If [LinkMode] of an [Asset] is [LinkMode.dynamic],
/// `Platform.script.resolve(uri)` will be used to load the asset at runtime.
class AssetRelativePath implements AssetPath {
  final Uri uri;

  AssetRelativePath(this.uri);

  static const _pathTypeValue = 'relative';

  @override
  Map<String, Object> toYaml() => {
        AssetPath._pathTypeKey: _pathTypeValue,
        AssetPath._uriKey: uri.toFilePath(),
      };

  @override
  List<String> toDartConst() => [_pathTypeValue, uri.toFilePath()];

  @override
  int get hashCode => Object.hash(uri, 133717);

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
  Map<String, Object> toYaml() => {
        AssetPath._pathTypeKey: _pathTypeValue,
        AssetPath._uriKey: uri.toFilePath(),
      };

  @override
  List<String> toDartConst() => [_pathTypeValue, uri.toFilePath()];

  @override
  int get hashCode => Object.hash(uri, 133723);

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
  Map<String, Object> toYaml() => {
        AssetPath._pathTypeKey: _pathTypeValue,
      };

  @override
  List<String> toDartConst() => [_pathTypeValue];

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
  Map<String, Object> toYaml() => {
        AssetPath._pathTypeKey: _pathTypeValue,
      };

  @override
  List<String> toDartConst() => [_pathTypeValue];

  @override
  Future<bool> exists() => Future.value(true);
}

class Asset {
  final LinkMode linkMode;
  final String name;
  final Target target;
  final AssetPath path;

  Asset({
    required this.name,
    required this.linkMode,
    required this.target,
    required this.path,
  });

  factory Asset.fromYaml(YamlMap yamlMap) => Asset(
        name: yamlMap[_nameKey] as String,
        path: AssetPath.fromYaml(yamlMap[_pathKey] as YamlMap),
        target: Target.fromString(yamlMap[_targetKey] as String),
        linkMode: LinkMode.fromName(yamlMap[_linkModeKey] as String),
      );

  static List<Asset> listFromYamlString(String yaml) {
    final yamlObject = loadYaml(yaml);
    if (yamlObject == null) {
      return [];
    }
    return [
      for (final yamlElement in yamlObject as YamlList)
        Asset.fromYaml(yamlElement as YamlMap),
    ];
  }

  static List<Asset> listFromYamlList(YamlList yamlList) => [
        for (final yamlElement in yamlList)
          Asset.fromYaml(yamlElement as YamlMap),
      ];

  Asset copyWith({
    LinkMode? linkMode,
    String? name,
    Target? target,
    AssetPath? path,
  }) =>
      Asset(
        name: name ?? this.name,
        linkMode: linkMode ?? this.linkMode,
        target: target ?? this.target,
        path: path ?? this.path,
      );

  @override
  bool operator ==(Object other) {
    if (other is! Asset) {
      return false;
    }
    return other.name == name &&
        other.linkMode == linkMode &&
        other.target == target &&
        other.path == path;
  }

  @override
  int get hashCode => Object.hash(name, linkMode, target, path);

  Map<String, Object> toYaml() => {
        _nameKey: name,
        _linkModeKey: linkMode.name,
        _pathKey: path.toYaml(),
        _targetKey: target.toString(),
      };

  Map<String, List<String>> toDartConst() => {
        name: path.toDartConst(),
      };

  String toYamlString() => yamlEncode(toYaml());

  static const _nameKey = 'name';
  static const _linkModeKey = 'link_mode';
  static const _pathKey = 'path';
  static const _targetKey = 'target';

  Future<bool> exists() => path.exists();

  @override
  String toString() => 'Asset(${toYaml()})';
}

extension AssetIterable on Iterable<Asset> {
  List<Object> toYaml() => [for (final item in this) item.toYaml()];

  String toYamlString() => yamlEncode(toYaml());

  Iterable<Asset> whereLinkMode(LinkMode linkMode) =>
      where((e) => e.linkMode == linkMode);

  Map<Target, List<Asset>> get assetsPerTarget {
    final result = <Target, List<Asset>>{};
    for (final asset in this) {
      final assets = result[asset.target] ?? [];
      assets.add(asset);
      result[asset.target] = assets;
    }
    return result;
  }

  Map<String, Map<String, List<String>>> toDartConst() => {
        for (final entry in assetsPerTarget.entries)
          entry.key.toString():
              _combineMaps(entry.value.map((e) => e.toDartConst()).toList())
      };

  Map<Object, Object> toNativeAssetsFileEncoding() => {
        'format-version': [1, 0, 0],
        'native-assets': toDartConst(),
      };

  String toNativeAssetsFile() => yamlEncode(toNativeAssetsFileEncoding());

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
