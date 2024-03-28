// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of '../api/asset.dart';

final class DataAssetImpl implements DataAsset, AssetImpl {
  @override
  final Uri file;

  @override
  final String name;

  @override
  final String package;

  @override
  String get id => 'package:$package/$name';

  DataAssetImpl({
    required this.file,
    required this.name,
    required this.package,
  });

  factory DataAssetImpl.fromJson(Map<Object?, Object?> jsonMap) =>
      DataAssetImpl(
        name: as<String>(jsonMap[_nameKey]),
        package: as<String>(jsonMap[_packageKey]),
        file: Uri(path: as<String>(jsonMap[_fileKey])),
      );

  @override
  bool operator ==(Object other) {
    if (other is! DataAssetImpl) {
      return false;
    }
    return other.package == package && other.file == file && other.name == name;
  }

  @override
  int get hashCode => Object.hash(
        package,
        name,
        file,
      );

  @override
  Map<String, Object> toJson(Version version) => {
        _nameKey: name,
        _packageKey: package,
        _fileKey: file.toFilePath(),
        typeKey: DataAsset.type,
      }..sortOnKey();

  static const typeKey = 'type';
  static const _nameKey = 'name';
  static const _packageKey = 'package';
  static const _fileKey = 'file';

  @override
  String toString() => 'DataAsset(${toJson(BuildOutput.latestVersion)})';
}
