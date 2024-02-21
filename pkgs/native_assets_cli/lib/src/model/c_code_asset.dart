// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of '../api/asset.dart';

abstract final class DynamicLoadingImpl implements DynamicLoading {
  factory DynamicLoadingImpl(String type, Uri? uri) {
    switch (type) {
      case BundledDylibImpl._typeValueV1_0_0:
      // For backwards compatibility.
      case BundledDylibImpl._typeValue:
        return BundledDylibImpl();
      case SystemDylibImpl._typeValue:
        return SystemDylibImpl(uri!);
      case LookupInExecutableImpl._typeValue:
        return LookupInExecutableImpl();
      case LookupInProcessImpl._typeValue:
        return LookupInProcessImpl();
    }
    throw FormatException('Unknown type: $type.');
  }

  factory DynamicLoadingImpl.fromYaml(YamlMap yamlMap) {
    final type = as<String>(yamlMap[_typeKey] ?? yamlMap[_pathTypeKey]);
    final uriString = as<String?>(yamlMap[_uriKey]);
    final uri = uriString != null ? Uri(path: uriString) : null;
    return DynamicLoadingImpl(type, uri);
  }

  Map<String, Object> toYaml(Version version, Uri? file);

  static const _pathTypeKey = 'path_type';
  static const _typeKey = 'type';
  static const _uriKey = 'uri';
}

final class BundledDylibImpl implements DynamicLoadingImpl, BundledDylib {
  BundledDylibImpl._();

  static final BundledDylibImpl _singleton = BundledDylibImpl._();

  factory BundledDylibImpl() => _singleton;

  static const _typeValueV1_0_0 = 'absolute';
  static const _typeValue = 'bundle';

  @override
  Map<String, Object> toYaml(Version version, Uri? file) => {
        if (version == Version(1, 0, 0)) ...{
          DynamicLoadingImpl._pathTypeKey: _typeValueV1_0_0,
          DynamicLoadingImpl._uriKey: file!.toFilePath(),
        } else
          DynamicLoadingImpl._typeKey: _typeValue,
      };
}

final class SystemDylibImpl implements DynamicLoadingImpl, SystemDylib {
  @override
  final Uri uri;

  SystemDylibImpl(this.uri);

  static const _typeValue = 'system';

  @override
  Map<String, Object> toYaml(Version version, Uri? file) => {
        if (version == Version(1, 0, 0))
          DynamicLoadingImpl._pathTypeKey: _typeValue
        else
          DynamicLoadingImpl._typeKey: _typeValue,
        DynamicLoadingImpl._uriKey: uri.toFilePath(),
      };

  @override
  int get hashCode => Object.hash(uri, 133723);

  @override
  bool operator ==(Object other) {
    if (other is! SystemDylibImpl) {
      return false;
    }
    return uri == other.uri;
  }
}

final class LookupInProcessImpl implements DynamicLoadingImpl, LookupInProcess {
  LookupInProcessImpl._();

  static final LookupInProcessImpl _singleton = LookupInProcessImpl._();

  factory LookupInProcessImpl() => _singleton;

  static const _typeValue = 'process';

  @override
  Map<String, Object> toYaml(Version version, Uri? file) => {
        if (version == Version(1, 0, 0))
          DynamicLoadingImpl._pathTypeKey: _typeValue
        else
          DynamicLoadingImpl._typeKey: _typeValue,
      };
}

final class LookupInExecutableImpl
    implements DynamicLoadingImpl, LookupInExecutable {
  LookupInExecutableImpl._();

  static final LookupInExecutableImpl _singleton = LookupInExecutableImpl._();

  factory LookupInExecutableImpl() => _singleton;

  static const _typeValue = 'executable';

  @override
  Map<String, Object> toYaml(Version version, Uri? file) => {
        if (version == Version(1, 0, 0))
          DynamicLoadingImpl._pathTypeKey: _typeValue
        else
          DynamicLoadingImpl._typeKey: _typeValue,
      };
}

final class CCodeAssetImpl implements CCodeAsset, AssetImpl {
  @override
  final Uri? file;

  @override
  final LinkModeImpl linkMode;

  @override
  final String id;

  @override
  final DynamicLoadingImpl dynamicLoading;

  @override
  final OSImpl os;

  @override
  final ArchitectureImpl? architecture;

  CCodeAssetImpl({
    this.file,
    required this.id,
    required this.linkMode,
    required this.os,
    required this.dynamicLoading,
    this.architecture,
  });

  factory CCodeAssetImpl.fromYaml(YamlMap yamlMap) {
    final dynamicLoading = DynamicLoadingImpl.fromYaml(
      as<YamlMap>(yamlMap[_dynamicLoadingKey] ?? yamlMap[_pathKey]),
    );
    final fileString = as<String?>(yamlMap[_fileKey]);
    final Uri? file;
    if (fileString != null) {
      file = Uri(path: fileString);
    } else if (dynamicLoading is BundledDylibImpl &&
        yamlMap[_pathKey] != null) {
      // Compatibility with v1.0.0.
      final oldPath = as<String?>(
          (yamlMap[_pathKey] as YamlMap)[DynamicLoadingImpl._uriKey]);
      file = oldPath != null ? Uri(path: oldPath) : null;
    } else {
      file = null;
    }
    final targetString = as<String?>(yamlMap[_targetKey]);
    final ArchitectureImpl? architecture;
    final OSImpl os;
    if (targetString != null) {
      // Compatibility with v1.0.0.
      final target = Target.fromString(targetString);
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
      dynamicLoading: dynamicLoading,
      os: os,
      architecture: architecture,
      linkMode: LinkModeImpl.fromName(as<String>(yamlMap[_linkModeKey])),
      file: file,
    );
  }

  CCodeAssetImpl copyWith({
    LinkModeImpl? linkMode,
    String? id,
    OSImpl? os,
    ArchitectureImpl? architecture,
    DynamicLoadingImpl? dynamicLoading,
    Uri? file,
  }) =>
      CCodeAssetImpl(
        id: id ?? this.id,
        linkMode: linkMode ?? this.linkMode,
        os: os ?? this.os,
        architecture: this.architecture ?? architecture,
        dynamicLoading: dynamicLoading ?? this.dynamicLoading,
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
        other.dynamicLoading == dynamicLoading &&
        other.file == file;
  }

  @override
  int get hashCode => Object.hash(
        id,
        linkMode,
        architecture,
        os,
        dynamicLoading,
        file,
      );

  @override
  Map<String, Object> toYaml(Version version) {
    if (version == Version(1, 0, 0)) {
      return {
        _idKey: id,
        _linkModeKey: linkMode.name,
        _pathKey: dynamicLoading.toYaml(version, file),
        _targetKey: Target.fromArchitectureAndOS(architecture!, os).toString(),
      }..sortOnKey();
    }
    return {
      if (architecture != null) _architectureKey: architecture.toString(),
      _dynamicLoadingKey: dynamicLoading.toYaml(version, file),
      if (file != null) _fileKey: file!.toFilePath(),
      _idKey: id,
      _linkModeKey: linkMode.name,
      _osKey: os.toString(),
      typeKey: CCodeAsset.type,
    }..sortOnKey();
  }

  static const typeKey = 'type';
  static const _idKey = 'id';
  static const _linkModeKey = 'link_mode';
  static const _pathKey = 'path';
  static const _dynamicLoadingKey = 'dynamic_loading';
  static const _targetKey = 'target';
  static const _fileKey = 'file';
  static const _osKey = 'os';
  static const _architectureKey = 'architecture';

  @override
  String toString() => 'CCodeAsset(${toYaml(BuildOutputImpl.latestVersion)})';
}
