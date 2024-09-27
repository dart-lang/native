// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of '../api/asset.dart';

abstract final class LinkModeImpl implements LinkMode {
  /// Serialization of a link mode.
  ///
  /// Does not include the toplevel keys.
  ///
  /// ```
  ///   type: dynamic_loading_system
  ///   uri: ${foo3Uri.toFilePath()}
  /// ```
  Map<String, Object> toJson();

  factory LinkModeImpl(String type, Uri? uri) {
    switch (type) {
      case DynamicLoadingBundledImpl._typeValue:
        return DynamicLoadingBundledImpl();
      case DynamicLoadingSystemImpl._typeValue:
        return DynamicLoadingSystemImpl(uri!);
      case LookupInExecutableImpl._typeValue:
        return LookupInExecutableImpl();
      case LookupInProcessImpl._typeValue:
        return LookupInProcessImpl();
      case StaticLinkingImpl._typeValue:
        return StaticLinkingImpl();
    }
    throw FormatException('Unknown type: $type.');
  }

  factory LinkModeImpl.fromJson(Map<Object?, Object?> jsonMap) {
    final type = get<String>(jsonMap, _typeKey);
    final uriString = get<String?>(jsonMap, _uriKey);
    final uri = uriString != null ? Uri(path: uriString) : null;
    return LinkModeImpl(type, uri);
  }

  static const _typeKey = 'type';
  static const _uriKey = 'uri';
}

abstract final class DynamicLoadingImpl
    implements LinkModeImpl, DynamicLoading {
  static const _typeKey = 'type';
  static const _uriKey = 'uri';
}

final class DynamicLoadingBundledImpl
    implements DynamicLoadingImpl, DynamicLoadingBundled {
  DynamicLoadingBundledImpl._();

  static final DynamicLoadingBundledImpl _singleton =
      DynamicLoadingBundledImpl._();

  factory DynamicLoadingBundledImpl() => _singleton;

  static const _typeValue = 'dynamic_loading_bundle';

  @override
  Map<String, Object> toJson() => {
        DynamicLoadingImpl._typeKey: _typeValue,
      };

  @override
  String toString() => _typeValue;
}

final class DynamicLoadingSystemImpl
    implements DynamicLoadingImpl, DynamicLoadingSystem {
  @override
  final Uri uri;

  DynamicLoadingSystemImpl(this.uri);

  static const _typeValue = 'dynamic_loading_system';

  @override
  Map<String, Object> toJson() => {
        DynamicLoadingImpl._typeKey: _typeValue,
        DynamicLoadingImpl._uriKey: uri.toFilePath(),
      };

  @override
  int get hashCode => Object.hash(uri, 133723);

  @override
  bool operator ==(Object other) {
    if (other is! DynamicLoadingSystemImpl) {
      return false;
    }
    return uri == other.uri;
  }

  @override
  String toString() => _typeValue;
}

final class LookupInProcessImpl implements DynamicLoadingImpl, LookupInProcess {
  LookupInProcessImpl._();

  static final LookupInProcessImpl _singleton = LookupInProcessImpl._();

  factory LookupInProcessImpl() => _singleton;

  static const _typeValue = 'dynamic_loading_process';

  @override
  Map<String, Object> toJson() => {
        DynamicLoadingImpl._typeKey: _typeValue,
      };

  @override
  String toString() => _typeValue;
}

final class LookupInExecutableImpl
    implements DynamicLoadingImpl, LookupInExecutable {
  LookupInExecutableImpl._();

  static final LookupInExecutableImpl _singleton = LookupInExecutableImpl._();

  factory LookupInExecutableImpl() => _singleton;

  static const _typeValue = 'dynamic_loading_executable';

  @override
  Map<String, Object> toJson() => {
        DynamicLoadingImpl._typeKey: _typeValue,
      };
}

final class StaticLinkingImpl implements LinkModeImpl, StaticLinking {
  StaticLinkingImpl._();

  static final StaticLinkingImpl _singleton = StaticLinkingImpl._();

  factory StaticLinkingImpl() => _singleton;

  static const _typeValue = 'static';

  @override
  Map<String, Object> toJson() => {
        DynamicLoadingImpl._typeKey: _typeValue,
      };

  @override
  String toString() => _typeValue;
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
        linkMode is! DynamicLoadingBundled &&
        file != null) {
      throw ArgumentError.value(
        file,
        'file',
        'Must be null if dynamicLoading is not BundledDylib.',
      );
    }
  }

  factory NativeCodeAssetImpl.fromJson(Map<Object?, Object?> jsonMap) {
    final linkModeJson = jsonMap[_linkModeKey];
    final linkMode =
        LinkModeImpl.fromJson(as<Map<Object?, Object?>>(linkModeJson));

    final fileString = get<String?>(jsonMap, _fileKey);
    final Uri? file;
    if (fileString != null) {
      file = Uri(path: fileString);
    } else {
      file = null;
    }
    final ArchitectureImpl? architecture;
    final os = OSImpl.fromString(get<String>(jsonMap, _osKey));
    final architectureString = get<String?>(jsonMap, _architectureKey);
    if (architectureString != null) {
      architecture = ArchitectureImpl.fromString(architectureString);
    } else {
      architecture = null;
    }

    return NativeCodeAssetImpl(
      id: get<String>(jsonMap, _idKey),
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
  Map<String, Object> toJson(Version version) => {
        if (architecture != null) _architectureKey: architecture.toString(),
        if (file != null) _fileKey: file!.toFilePath(),
        _idKey: id,
        _linkModeKey: linkMode.toJson(),
        _osKey: os.toString(),
        typeKey: NativeCodeAsset.type,
      }..sortOnKey();

  static const typeKey = 'type';
  static const _idKey = 'id';
  static const _linkModeKey = 'link_mode';
  static const _fileKey = 'file';
  static const _osKey = 'os';
  static const _architectureKey = 'architecture';

  @override
  String toString() =>
      'NativeCodeAsset(${toJson(HookOutputImpl.latestVersion)})';
}
