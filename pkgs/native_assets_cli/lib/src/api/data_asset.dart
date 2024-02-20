// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of 'asset.dart';

/// Data bundled with a Dart or Flutter application.
///
/// An data asset is data which is accessible from a Dart or Flutter
/// application. To retrieve an asset at runtime, the [id] is used. This enables
/// access to the asset irrespective of how and where the application is run.
abstract final class DataAsset implements Asset {
  factory DataAsset({
    required String id,
    required Uri file,
  }) =>
      DataAssetImpl(
        id: id,
        file: file,
      );

  static const String type = 'data';
}
