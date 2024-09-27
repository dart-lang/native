// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of '../api/asset.dart';

final class NativeCodeAssetImpl implements NativeCodeAsset, AssetImpl {
  @override
  final Uri? file;

  @override
  final LinkMode linkMode;

  @override
  final String id;

  @override
  final OS os;

  @override
  final Architecture? architecture;

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
    final linkMode = LinkMode.fromJson(as<Map<String, Object?>>(linkModeJson));
    final fileString = get<String?>(jsonMap, _fileKey);
    final Uri? file;
    if (fileString != null) {
      file = Uri(path: fileString);
    } else {
      file = null;
    }
    final Architecture? architecture;
    final os = OS.fromString(get<String>(jsonMap, _osKey));
    final architectureString = get<String?>(jsonMap, _architectureKey);
    if (architectureString != null) {
      architecture = Architecture.fromString(architectureString);
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
    LinkMode? linkMode,
    String? id,
    OS? os,
    Architecture? architecture,
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
