// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of 'asset.dart';

/// Data bundled with a Dart or Flutter application.
///
/// A data asset is accessible in a Dart or Flutter application. To retrieve an
/// asset at runtime, the [id] is used. This enables access to the asset
/// irrespective of how and where the application is run.
///
/// An data asset must provide a [Asset.file]. The Dart and Flutter SDK will
/// bundle this code in the final application.
abstract final class DataAsset implements Asset {
  /// Constructs a data asset.
  ///
  /// The unique [id] of this asset is a uri `package:<package>/<name>` from
  /// [package] and [name].
  factory DataAsset({
    required String package,
    required String name,
    required Uri file,
  }) =>
      DataAssetImpl(
        name: name,
        package: package,
        file: file,
      );

  /// The package which contains this asset.
  String get package;

  /// The name of this asset, which must be unique for the package.
  String get name;

  static const String type = 'data';
}
