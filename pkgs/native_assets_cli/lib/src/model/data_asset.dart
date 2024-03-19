// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of '../api/asset.dart';

final class DataAssetImpl implements DataAsset, AssetImpl {
  @override
  final Uri file;

  @override
  final String id;

  DataAssetImpl({
    required this.file,
    required this.id,
  });

  factory DataAssetImpl.fromJson(Map<Object?, Object?> jsonMap) =>
      DataAssetImpl(
        id: as<String>(jsonMap[_idKey]),
        file: Uri(path: as<String>(jsonMap[_fileKey])),
      );

  @override
  bool operator ==(Object other) {
    if (other is! DataAssetImpl) {
      return false;
    }
    return other.id == id && other.file == file;
  }

  @override
  int get hashCode => Object.hash(
        id,
        file,
      );

  @override
  Map<String, Object> toJson(Version version) => {
        _idKey: id,
        _fileKey: file.toFilePath(),
        typeKey: DataAsset.type,
      }..sortOnKey();

  static const typeKey = 'type';
  static const _idKey = 'id';
  static const _fileKey = 'file';

  @override
  String toString() => 'DataAsset(${toJson(BuildOutput.latestVersion)})';
}
