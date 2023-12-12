// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:collection/collection.dart';
import 'package:yaml/yaml.dart';

import '../utils/uri.dart';
import '../utils/yaml.dart';
import 'build_type.dart';
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
    final pathType = as<String>(yamlMap[_pathTypeKey]);
    final uriString = as<String?>(yamlMap[_uriKey]);
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
  final String id;
  final Target target;
  final AssetPath path;

  /// The step at which the asset should be written to file.
  /// * [PipelineStep.build] - The asset is written after `build.dart` has run.
  /// * [PipelineStep.build] - The asset is written after `link.dart` has run.
  ///
  /// In particular, an asset which is created by `build.dart` and then further
  /// modified by `link.dart` should be marked as [PipelineStep.link].
  final PipelineStep step;

  Asset({
    required this.id,
    required this.linkMode,
    required this.target,
    required this.path,
    this.step = PipelineStep.build,
  });

  factory Asset.fromYaml(YamlMap yamlMap) => Asset(
        id: as<String>(yamlMap[_idKey]),
        path: AssetPath.fromYaml(as<YamlMap>(yamlMap[_pathKey])),
        target: Target.fromString(as<String>(yamlMap[_targetKey])),
        linkMode: LinkMode.fromName(as<String>(yamlMap[_linkModeKey])),
        step: PipelineStep.values.firstWhereOrNull(
                (step) => step.name == as<String>(yamlMap[_step])) ??
            PipelineStep.build,
      );

  static List<Asset> listFromYamlString(String yaml) {
    final yamlObject = loadYaml(yaml);
    if (yamlObject == null) {
      return [];
    }
    return [
      for (final yamlElement in as<YamlList>(yamlObject))
        Asset.fromYaml(as<YamlMap>(yamlElement)),
    ];
  }

  static List<Asset> listFromYamlList(YamlList yamlList) => [
        for (final yamlElement in yamlList)
          Asset.fromYaml(as<YamlMap>(yamlElement)),
      ];

  Asset copyWith({
    LinkMode? linkMode,
    String? id,
    Target? target,
    AssetPath? path,
    PipelineStep? step,
  }) =>
      Asset(
        id: id ?? this.id,
        linkMode: linkMode ?? this.linkMode,
        target: target ?? this.target,
        path: path ?? this.path,
        step: step ?? this.step,
      );

  @override
  bool operator ==(Object other) {
    if (other is! Asset) {
      return false;
    }
    return other.id == id &&
        other.linkMode == linkMode &&
        other.target == target &&
        other.path == path &&
        other.step == step;
  }

  @override
  int get hashCode => Object.hash(id, linkMode, target, path, step);

  Map<String, Object> toYaml() => {
        _idKey: id,
        _linkModeKey: linkMode.name,
        _pathKey: path.toYaml(),
        _targetKey: target.toString(),
        _step: step.name,
      };

  Map<String, List<String>> toDartConst() => {
        id: path.toDartConst(),
      };

  String toYamlString() => yamlEncode(toYaml());

  static const _idKey = 'id';
  static const _linkModeKey = 'link_mode';
  static const _pathKey = 'path';
  static const _targetKey = 'target';
  static const _step = 'step';

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
        'native-assets': toYaml(),
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
