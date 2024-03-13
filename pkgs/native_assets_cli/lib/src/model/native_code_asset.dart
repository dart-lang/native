// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of '../api/asset.dart';

abstract final class LinkModeImpl implements LinkMode {
  /// v1.0.0 Includes the parent keys.
  ///
  /// ```
  /// link_mode: dynamic
  /// path:
  ///   path_type: system
  ///   uri: ${foo3Uri.toFilePath()}
  /// ```
  Map<String, Object> toYamlV1_0_0(Uri? file);

  /// v1.1.0 does not include the toplevel keys.
  ///
  /// ```
  ///   type: dynamic_loading_system
  ///   uri: ${foo3Uri.toFilePath()}
  /// ```
  Map<String, Object> toYaml();

  factory LinkModeImpl(String type, Uri? uri) {
    switch (type) {
      case DynamicLoadingBundledDylibImpl._typeValueV1_0_0:
      case DynamicLoadingBundledDylibImpl._typeValue:
        return DynamicLoadingBundledDylibImpl();
      case DynamicLoadingSystemDylibImpl._typeValueV1_0_0:
      case DynamicLoadingSystemDylibImpl._typeValue:
        return DynamicLoadingSystemDylibImpl(uri!);
      case LookupInExecutableImpl._typeValueV1_0_0:
      case LookupInExecutableImpl._typeValue:
        return LookupInExecutableImpl();
      case LookupInProcessImpl._typeValueV1_0_0:
      case LookupInProcessImpl._typeValue:
        return LookupInProcessImpl();
      case StaticLinkingImpl._typeValue:
        return StaticLinkingImpl();
    }
    throw FormatException('Unknown type: $type.');
  }

  /// v1.1.0 only.
  factory LinkModeImpl.fromYaml(YamlMap yamlMap) {
    final type = as<String>(yamlMap[_typeKey]);
    final uriString = as<String?>(yamlMap[_uriKey]);
    final uri = uriString != null ? Uri(path: uriString) : null;
    return LinkModeImpl(type, uri);
  }

  static const _typeKey = 'type';
  static const _uriKey = 'uri';
}

abstract final class DynamicLoadingImpl
    implements LinkModeImpl, DynamicLoading {
  factory DynamicLoadingImpl(String type, Uri? uri) {
    switch (type) {
      case DynamicLoadingBundledDylibImpl._typeValueV1_0_0:
      // For backwards compatibility.
      case DynamicLoadingBundledDylibImpl._typeValue:
        return DynamicLoadingBundledDylibImpl();
      case DynamicLoadingSystemDylibImpl._typeValue:
        return DynamicLoadingSystemDylibImpl(uri!);
      case LookupInExecutableImpl._typeValue:
        return LookupInExecutableImpl();
      case LookupInProcessImpl._typeValue:
        return LookupInProcessImpl();
    }
    throw FormatException('Unknown type: $type.');
  }

  static const _pathTypeKeyV1_0_0 = 'path_type';
  static const _typeKey = 'type';
  static const _uriKey = 'uri';

  static const _typeValueV1_0_0 = 'dynamic';
}

final class DynamicLoadingBundledDylibImpl
    implements DynamicLoadingImpl, DynamicLoadingBundledDylib {
  DynamicLoadingBundledDylibImpl._();

  static final DynamicLoadingBundledDylibImpl _singleton =
      DynamicLoadingBundledDylibImpl._();

  factory DynamicLoadingBundledDylibImpl() => _singleton;

  static const _typeValueV1_0_0 = 'absolute';
  static const _typeValue = 'dynamic_loading_bundle';

  @override
  Map<String, Object> toYaml() => {
        DynamicLoadingImpl._typeKey: _typeValue,
      };

  @override
  Map<String, Object> toYamlV1_0_0(Uri? file) => {
        NativeCodeAssetImpl._linkModeKey: DynamicLoadingImpl._typeValueV1_0_0,
        NativeCodeAssetImpl._pathKey: {
          DynamicLoadingImpl._pathTypeKeyV1_0_0: _typeValueV1_0_0,
          DynamicLoadingImpl._uriKey: file!.toFilePath(),
        }
      };
}

final class DynamicLoadingSystemDylibImpl
    implements DynamicLoadingImpl, DynamicLoadingSystemDylib {
  @override
  final Uri uri;

  DynamicLoadingSystemDylibImpl(this.uri);

  static const _typeValue = 'dynamic_loading_system';
  static const _typeValueV1_0_0 = 'system';

  @override
  Map<String, Object> toYaml() => {
        DynamicLoadingImpl._typeKey: _typeValue,
        DynamicLoadingImpl._uriKey: uri.toFilePath(),
      };

  @override
  Map<String, Object> toYamlV1_0_0(Uri? file) => {
        NativeCodeAssetImpl._linkModeKey: DynamicLoadingImpl._typeValueV1_0_0,
        NativeCodeAssetImpl._pathKey: {
          DynamicLoadingImpl._pathTypeKeyV1_0_0: _typeValueV1_0_0,
          DynamicLoadingImpl._uriKey: uri.toFilePath(),
        }
      };

  @override
  int get hashCode => Object.hash(uri, 133723);

  @override
  bool operator ==(Object other) {
    if (other is! DynamicLoadingSystemDylibImpl) {
      return false;
    }
    return uri == other.uri;
  }
}

final class LookupInProcessImpl implements DynamicLoadingImpl, LookupInProcess {
  LookupInProcessImpl._();

  static final LookupInProcessImpl _singleton = LookupInProcessImpl._();

  factory LookupInProcessImpl() => _singleton;

  static const _typeValue = 'dynamic_loading_process';
  static const _typeValueV1_0_0 = 'process';

  @override
  Map<String, Object> toYaml() => {
        DynamicLoadingImpl._typeKey: _typeValue,
      };

  @override
  Map<String, Object> toYamlV1_0_0(Uri? file) => {
        NativeCodeAssetImpl._linkModeKey: DynamicLoadingImpl._typeValueV1_0_0,
        NativeCodeAssetImpl._pathKey: {
          DynamicLoadingImpl._pathTypeKeyV1_0_0: _typeValueV1_0_0,
        }
      };
}

final class LookupInExecutableImpl
    implements DynamicLoadingImpl, LookupInExecutable {
  LookupInExecutableImpl._();

  static final LookupInExecutableImpl _singleton = LookupInExecutableImpl._();

  factory LookupInExecutableImpl() => _singleton;

  static const _typeValue = 'dynamic_loading_executable';
  static const _typeValueV1_0_0 = 'executable';

  @override
  Map<String, Object> toYaml() => {
        DynamicLoadingImpl._typeKey: _typeValue,
      };

  @override
  Map<String, Object> toYamlV1_0_0(Uri? file) => {
        NativeCodeAssetImpl._linkModeKey: DynamicLoadingImpl._typeValueV1_0_0,
        NativeCodeAssetImpl._pathKey: {
          DynamicLoadingImpl._pathTypeKeyV1_0_0: _typeValueV1_0_0,
        }
      };
}

final class StaticLinkingImpl implements LinkModeImpl, StaticLinking {
  StaticLinkingImpl._();

  static final StaticLinkingImpl _singleton = StaticLinkingImpl._();

  factory StaticLinkingImpl() => _singleton;

  static const _typeValue = 'static';

  @override
  Map<String, Object> toYaml() => {
        DynamicLoadingImpl._typeKey: _typeValue,
      };

  @override
  Map<String, Object> toYamlV1_0_0(Uri? file) => {
        NativeCodeAssetImpl._linkModeKey: _typeValue,
      };
}

final class NativeCodeAssetImpl implements NativeCodeAsset, AssetImpl {
  @override
  final Uri? file;

  @override
  final LinkModeImpl linkMode;

  @override
  final String id;

  @override
  final OSImpl os;

  @override
  final ArchitectureImpl? architecture;

  NativeCodeAssetImpl({
    this.file,
    required this.id,
    required this.linkMode,
    required this.os,
    this.architecture,
  }) {
    if (linkMode is DynamicLoading &&
        linkMode is! DynamicLoadingBundledDylib &&
        file != null) {
      throw ArgumentError.value(
        file,
        'file',
        'Must be null if dynamicLoading is not BundledDylib.',
      );
    }
  }

  factory NativeCodeAssetImpl.fromYaml(YamlMap yamlMap) {
    final LinkModeImpl linkMode;
    final linkModeYaml = yamlMap[_linkModeKey];
    if (linkModeYaml is String) {
      // v1.0.0
      if (linkModeYaml == StaticLinkingImpl._typeValue) {
        linkMode = StaticLinkingImpl();
      } else {
        assert(linkModeYaml == DynamicLoadingImpl._typeValueV1_0_0);
        final pathYaml = as<YamlMap>(yamlMap[_pathKey]);
        final type =
            as<String>(pathYaml[DynamicLoadingImpl._pathTypeKeyV1_0_0]);
        final uriString = as<String?>(pathYaml[DynamicLoadingImpl._uriKey]);
        final uri = uriString != null ? Uri(path: uriString) : null;
        linkMode = LinkModeImpl(type, uri);
      }
    } else {
      // v1.1.0
      linkMode = LinkModeImpl.fromYaml(as<YamlMap>(linkModeYaml));
    }

    final fileString = as<String?>(yamlMap[_fileKey]);
    final Uri? file;
    if (fileString != null) {
      file = Uri(path: fileString);
    } else if ((linkMode is DynamicLoadingBundledDylibImpl ||
            linkMode is StaticLinkingImpl) &&
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

    return NativeCodeAssetImpl(
      id: as<String>(yamlMap[_idKey]),
      os: os,
      architecture: architecture,
      linkMode: linkMode,
      file: file,
    );
  }

  NativeCodeAssetImpl copyWith({
    LinkModeImpl? linkMode,
    String? id,
    OSImpl? os,
    ArchitectureImpl? architecture,
    Uri? file,
  }) =>
      NativeCodeAssetImpl(
        id: id ?? this.id,
        linkMode: linkMode ?? this.linkMode,
        os: os ?? this.os,
        architecture: this.architecture ?? architecture,
        file: file ?? this.file,
      );

  @override
  bool operator ==(Object other) {
    if (other is! NativeCodeAssetImpl) {
      return false;
    }
    return other.id == id &&
        other.linkMode == linkMode &&
        other.architecture == architecture &&
        other.os == os &&
        other.file == file;
  }

  @override
  int get hashCode => Object.hash(
        id,
        linkMode,
        architecture,
        os,
        file,
      );

  @override
  Map<String, Object> toYaml(Version version) {
    if (version == Version(1, 0, 0)) {
      return {
        _idKey: id,
        ...linkMode.toYamlV1_0_0(file),
        _targetKey: Target.fromArchitectureAndOS(architecture!, os).toString(),
      }..sortOnKey();
    }
    return {
      if (architecture != null) _architectureKey: architecture.toString(),
      if (file != null) _fileKey: file!.toFilePath(),
      _idKey: id,
      _linkModeKey: linkMode.toYaml(),
      _osKey: os.toString(),
      typeKey: NativeCodeAsset.type,
    }..sortOnKey();
  }

  static const typeKey = 'type';
  static const _idKey = 'id';
  static const _linkModeKey = 'link_mode';
  static const _pathKey = 'path';
  static const _targetKey = 'target';
  static const _fileKey = 'file';
  static const _osKey = 'os';
  static const _architectureKey = 'architecture';

  @override
  String toString() =>
      'NativeCodeAsset(${toYaml(BuildOutputImpl.latestVersion)})';
}
