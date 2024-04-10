// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of '../api/linkable_asset.dart';

sealed class LinkableAssetImpl implements LinkableAsset {
  AssetImpl get asset;

  @override
  Uri? get file => asset.file;

  @override
  String get id => asset.id;
}

class LinkableDataAssetImpl extends LinkableAssetImpl
    implements LinkableDataAsset {
  @override
  final DataAssetImpl asset;

  @override
  String get name => asset.name;

  LinkableDataAssetImpl(this.asset);

  @override
  LinkableDataAsset withFile(Uri file) => LinkableDataAssetImpl(DataAssetImpl(
        package: asset.package,
        name: asset.name,
        file: file,
      ));
}

class LinkableCodeAssetImpl extends LinkableAssetImpl
    implements LinkableCodeAsset {
  @override
  final NativeCodeAssetImpl asset;

  LinkableCodeAssetImpl(this.asset);

  @override
  LinkableCodeAsset withFile(Uri file) =>
      LinkableCodeAssetImpl(NativeCodeAssetImpl(
        id: asset.id,
        linkMode: asset.linkMode,
        os: asset.os,
        architecture: asset.architecture,
        file: file,
      ));
}
