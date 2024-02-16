// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of '../api/asset.dart';

abstract final class AssetPathImpl implements AssetPath {
  factory AssetPathImpl(String pathType, Uri? uri) {
    switch (pathType) {
      case AssetAbsolutePathImpl._pathTypeValue:
        return AssetAbsolutePathImpl(uri!);
      case AssetSystemPathImpl._pathTypeValue:
        return AssetSystemPathImpl(uri!);
      case AssetInExecutableImpl._pathTypeValue:
        return AssetInExecutableImpl();
      case AssetInProcessImpl._pathTypeValue:
        return AssetInProcessImpl();
    }
    throw FormatException('Unknown pathType: $pathType.');
  }

  factory AssetPathImpl.fromYaml(YamlMap yamlMap) {
    final pathType = as<String>(yamlMap[_pathTypeKey]);
    final uriString = as<String?>(yamlMap[_uriKey]);
    final uri = uriString != null ? Uri(path: uriString) : null;
    return AssetPathImpl(pathType, uri);
  }

  Map<String, Object> toYaml();

  static const _pathTypeKey = 'path_type';
  static const _uriKey = 'uri';
}

/// Asset at absolute path [uri].
final class AssetAbsolutePathImpl implements AssetPathImpl, AssetAbsolutePath {
  @override
  final Uri uri;

  AssetAbsolutePathImpl(this.uri);

  static const _pathTypeValue = 'absolute';

  @override
  Map<String, Object> toYaml() => {
        AssetPathImpl._pathTypeKey: _pathTypeValue,
        AssetPathImpl._uriKey: uri.toFilePath(),
      };

  @override
  int get hashCode => Object.hash(uri, 133711);

  @override
  bool operator ==(Object other) {
    if (other is! AssetAbsolutePathImpl) {
      return false;
    }
    return uri == other.uri;
  }
}

/// Asset is avaliable on the system `PATH`.
///
/// [uri] only contains a file name.
final class AssetSystemPathImpl implements AssetPathImpl, AssetSystemPath {
  @override
  final Uri uri;

  AssetSystemPathImpl(this.uri);

  static const _pathTypeValue = 'system';

  @override
  Map<String, Object> toYaml() => {
        AssetPathImpl._pathTypeKey: _pathTypeValue,
        AssetPathImpl._uriKey: uri.toFilePath(),
      };

  @override
  int get hashCode => Object.hash(uri, 133723);

  @override
  bool operator ==(Object other) {
    if (other is! AssetSystemPathImpl) {
      return false;
    }
    return uri == other.uri;
  }
}

/// Asset is loaded in the process and symbols are available through
/// `DynamicLibrary.process()`.
final class AssetInProcessImpl implements AssetPathImpl, AssetInProcess {
  AssetInProcessImpl._();

  static final AssetInProcessImpl _singleton = AssetInProcessImpl._();

  factory AssetInProcessImpl() => _singleton;

  static const _pathTypeValue = 'process';

  @override
  Map<String, Object> toYaml() => {
        AssetPathImpl._pathTypeKey: _pathTypeValue,
      };
}

/// Asset is embedded in executable and symbols are available through
/// `DynamicLibrary.executable()`.
final class AssetInExecutableImpl implements AssetPathImpl, AssetInExecutable {
  AssetInExecutableImpl._();

  static final AssetInExecutableImpl _singleton = AssetInExecutableImpl._();

  factory AssetInExecutableImpl() => _singleton;

  static const _pathTypeValue = 'executable';

  @override
  Map<String, Object> toYaml() => {
        AssetPathImpl._pathTypeKey: _pathTypeValue,
      };
}

final class AssetImpl implements Asset {
  @override
  final LinkModeImpl linkMode;
  @override
  final String id;
  @override
  final Target target;
  @override
  final AssetPathImpl path;

  AssetImpl({
    required this.id,
    required this.linkMode,
    required this.target,
    required this.path,
  });

  factory AssetImpl.fromYaml(YamlMap yamlMap) => AssetImpl(
        id: as<String>(yamlMap[_idKey]),
        path: AssetPathImpl.fromYaml(as<YamlMap>(yamlMap[_pathKey])),
        target: TargetImpl.fromString(as<String>(yamlMap[_targetKey])),
        linkMode: LinkModeImpl.fromName(as<String>(yamlMap[_linkModeKey])),
      );

  static List<AssetImpl> listFromYamlString(String yaml) {
    final yamlObject = loadYaml(yaml);
    if (yamlObject == null) {
      return [];
    }
    return [
      for (final yamlElement in as<YamlList>(yamlObject))
        AssetImpl.fromYaml(as<YamlMap>(yamlElement)),
    ];
  }

  static List<AssetImpl> listFromYamlList(YamlList yamlList) => [
        for (final yamlElement in yamlList)
          AssetImpl.fromYaml(as<YamlMap>(yamlElement)),
      ];

  AssetImpl copyWith({
    LinkModeImpl? linkMode,
    String? id,
    Target? target,
    AssetPathImpl? path,
  }) =>
      AssetImpl(
        id: id ?? this.id,
        linkMode: linkMode ?? this.linkMode,
        target: target ?? this.target,
        path: path ?? this.path,
      );

  @override
  bool operator ==(Object other) {
    if (other is! AssetImpl) {
      return false;
    }
    return other.id == id &&
        other.linkMode == linkMode &&
        other.target == target &&
        other.path == path;
  }

  @override
  int get hashCode => Object.hash(id, linkMode, target, path);

  Map<String, Object> toYaml() => {
        _idKey: id,
        _linkModeKey: linkMode.name,
        _pathKey: path.toYaml(),
        _targetKey: target.toString(),
      };

  static const _idKey = 'id';
  static const _linkModeKey = 'link_mode';
  static const _pathKey = 'path';
  static const _targetKey = 'target';

  // Future<bool> exists() => path.exists();

  @override
  String toString() => 'Asset(${toYaml()})';
}

extension AssetIterable on Iterable<AssetImpl> {
  List<Object> toYaml() => [for (final item in this) item.toYaml()];

  String toYamlString() => yamlEncode(toYaml());
}
