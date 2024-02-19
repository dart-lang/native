// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of '../api/asset.dart';

abstract final class AssetPathImpl implements AssetPath {
  factory AssetPathImpl(String pathType, Uri? uri) {
    switch (pathType) {
      case AssetAbsolutePathImpl._pathTypeValue:
        return AssetAbsolutePathImpl();
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

final class AssetAbsolutePathImpl implements AssetPathImpl, AssetAbsolutePath {
  AssetAbsolutePathImpl();

  static const _pathTypeValue = 'absolute';

  @override
  Map<String, Object> toYaml() => {
        AssetPathImpl._pathTypeKey: _pathTypeValue,
      };

  @override
  int get hashCode => 133711;

  @override
  bool operator ==(Object other) {
    if (other is! AssetAbsolutePathImpl) {
      return false;
    }
    return true;
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

final class CCodeAssetImpl implements CCodeAsset {
  @override
  final Uri? file;

  @override
  final LinkModeImpl linkMode;

  @override
  final String id;

  @override
  final AssetPathImpl path;

  @override
  final OSImpl os;

  final ArchitectureImpl? _architecture;

  @override
  ArchitectureImpl get architecture => _architecture!;

  @override
  // Target get target => TargetImpl.fromArchitectureAndOs(_architecture!, os);

  CCodeAssetImpl({
    this.file,
    required this.id,
    required this.linkMode,
    required this.os,
    required this.path,
    ArchitectureImpl? architecture,
  }) : _architecture = architecture;

  factory CCodeAssetImpl.fromYaml(YamlMap yamlMap) {
    final path = AssetPathImpl.fromYaml(as<YamlMap>(yamlMap[_pathKey]));
    final fileString = as<String?>(yamlMap[_fileKey]);
    final Uri? file;
    if (fileString != null) {
      file = Uri(path: fileString);
    } else if (path is AssetAbsolutePathImpl) {
      // Compatibility with v1.0.0.
      final oldPath =
          as<String?>((yamlMap[_pathKey] as YamlMap)[AssetPathImpl._uriKey]);
      file = oldPath != null ? Uri(path: oldPath) : null;
    } else {
      file = null;
    }
    final targetString = as<String?>(yamlMap[_targetKey]);
    final ArchitectureImpl? architecture;
    final OSImpl os;
    if (targetString != null) {
      // Compatibility with v1.0.0.
      final target = TargetImpl.fromString(targetString);
      os = target.os;
      architecture = target.architecture;
    } else {
      os = OSImpl.fromString(as<String>(yamlMap[_osKey]));
      final architectureString = as<String?>(yamlMap[_architectureKey]);
      if (architectureString != null) {
        architecture = ArchitectureImpl.fromString(architectureString);
      } else {
        architecture = null;
      }
    }
    return CCodeAssetImpl(
      id: as<String>(yamlMap[_idKey]),
      path: path,
      os: os,
      architecture: architecture,
      linkMode: LinkModeImpl.fromName(as<String>(yamlMap[_linkModeKey])),
      file: file,
    );
  }

  static List<CCodeAssetImpl> listFromYamlString(String yaml) {
    final yamlObject = loadYaml(yaml);
    if (yamlObject == null) {
      return [];
    }
    return [
      for (final yamlElement in as<YamlList>(yamlObject))
        CCodeAssetImpl.fromYaml(as<YamlMap>(yamlElement)),
    ];
  }

  static List<CCodeAssetImpl> listFromYamlList(YamlList yamlList) => [
        for (final yamlElement in yamlList)
          CCodeAssetImpl.fromYaml(as<YamlMap>(yamlElement)),
      ];

  CCodeAssetImpl copyWith({
    LinkModeImpl? linkMode,
    String? id,
    OSImpl? os,
    ArchitectureImpl? architecture,
    AssetPathImpl? path,
    Uri? file,
  }) =>
      CCodeAssetImpl(
        id: id ?? this.id,
        linkMode: linkMode ?? this.linkMode,
        os: os ?? this.os,
        architecture: architecture ?? _architecture,
        path: path ?? this.path,
        file: file ?? this.file,
      );

  @override
  bool operator ==(Object other) {
    if (other is! CCodeAssetImpl) {
      return false;
    }
    return other.id == id &&
        other.linkMode == linkMode &&
        other.architecture == architecture &&
        other.os == os &&
        other.path == path &&
        other.file == file;
  }

  @override
  int get hashCode => Object.hash(
        id,
        linkMode,
        architecture,
        os,
        path,
        file,
      );

  Map<String, Object> toYaml() => {
        if (_architecture != null) _architectureKey: _architecture.toString(),
        if (file != null) _fileKey: file!.toFilePath(),
        _idKey: id,
        _linkModeKey: linkMode.name,
        _osKey: os.toString(),
        _pathKey: path.toYaml(),
        typeKey: type,
      };

  static const typeKey = 'type';
  static const type = 'c_code';
  static const _idKey = 'id';
  static const _linkModeKey = 'link_mode';
  static const _pathKey = 'path';
  static const _targetKey = 'target';
  static const _fileKey = 'file';
  static const _osKey = 'os';
  static const _architectureKey = 'architecture';

  @override
  String toString() => 'CCodeAsset(${toYaml()})';
}

extension AssetIterable on Iterable<CCodeAssetImpl> {
  List<Object> toYaml() => [for (final item in this) item.toYaml()];

  String toYamlString() => yamlEncode(toYaml());
}
