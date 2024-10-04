// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../api/build_config.dart';
import '../api/build_output.dart';
import '../api/link_config.dart';
import '../encoded_asset.dart';
import '../json_utils.dart';
import '../utils/map.dart';

/// Data bundled with a Dart or Flutter application.
///
/// A data asset is accessible in a Dart or Flutter application. To retrieve an
/// asset at runtime, the [id] is used. This enables access to the asset
/// irrespective of how and where the application is run.
///
/// An data asset must provide a [DataAsset.file]. The Dart and Flutter SDK will
/// bundle this code in the final application.
final class DataAsset {
  /// The file to be bundled with the Dart or Flutter application.
  ///
  /// The file can be omitted in the [BuildOutput] for [BuildConfig.dryRun].
  ///
  /// The file can also be omitted for asset types which refer to an asset
  /// already present on the target system or an asset already present in Dart
  /// or Flutter.
  final Uri file;

  /// The name of this asset, which must be unique for the package.
  final String name;

  /// The package which contains this asset.
  final String package;

  /// The identifier for this data asset.
  ///
  /// An [DataAsset] has a string identifier called "asset id". Dart code that
  /// uses an asset references the asset using this asset id.
  ///
  /// An asset identifier consists of two elements, the `package` and `name`,
  /// which together make a library uri `package:<package>/<name>`. The package
  /// being part of the identifer prevents name collisions between assets of
  /// different packages.
  String get id => 'package:$package/$name';

  DataAsset({
    required this.file,
    required this.name,
    required this.package,
  });

  /// Constructs a [DataAsset] from an [EncodedAsset].
  factory DataAsset.fromEncoded(EncodedAsset asset) {
    assert(asset.type == DataAsset.type);
    final jsonMap = asset.encoding;
    return DataAsset(
      name: jsonMap.string(_nameKey),
      package: jsonMap.string(_packageKey),
      file: jsonMap.path(_fileKey),
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is! DataAsset) {
      return false;
    }
    return other.package == package &&
        other.file.toFilePath() == file.toFilePath() &&
        other.name == name;
  }

  @override
  int get hashCode => Object.hash(
        package,
        name,
        file.toFilePath(),
      );

  EncodedAsset encode() => EncodedAsset(
      DataAsset.type,
      <String, Object>{
        _nameKey: name,
        _packageKey: package,
        _fileKey: file.toFilePath(),
      }..sortOnKey());

  @override
  String toString() => 'DataAsset(${encode().encoding})';

  static const String type = 'data';
}

/// Build output extension for data assets.
extension DataAssetsBuildOutput on BuildOutput {
  BuildOutputDataAssets get dataAssets => BuildOutputDataAssets(this);
}

extension type BuildOutputDataAssets(BuildOutput _output) {
  void add(DataAsset asset, {String? linkInPackage}) =>
      _output.addEncodedAsset(asset.encode(), linkInPackage: linkInPackage);

  void addAll(Iterable<DataAsset> assets, {String? linkInPackage}) {
    for (final asset in assets) {
      add(asset, linkInPackage: linkInPackage);
    }
  }

  Iterable<DataAsset> get all => _output.encodedAssets
      .where((e) => e.type == DataAsset.type)
      .map(DataAsset.fromEncoded);
}

/// Link output extension for data assets.
extension DataAssetsLinkConfig on LinkConfig {
  LinkConfigDataAssets get dataAssets => LinkConfigDataAssets(this);
}

extension type LinkConfigDataAssets(LinkConfig _config) {
  // Returns the data assets that were sent to this linker.
  //
  // NOTE: If the linker implementation depends on the contents of the files of
  // the data assets (e.g. by transforming them, merging with other files, etc)
  // then the linker script has to add those files as dependencies via
  // [LinkOutput.addDependency] to ensure the linker script will be re-run if
  // the content of the files changes.
  Iterable<DataAsset> get all => _config.encodedAssets
      .where((e) => e.type == DataAsset.type)
      .map(DataAsset.fromEncoded);
}

/// Link output extension for data assets.
extension DataAssetsLinkOutput on LinkOutput {
  LinkOutputDataAssets get dataAssets => LinkOutputDataAssets(this);
}

extension type LinkOutputDataAssets(LinkOutput _output) {
  void add(DataAsset asset) => _output.addEncodedAsset(asset.encode());

  void addAll(Iterable<DataAsset> assets) => assets.forEach(add);

  Iterable<DataAsset> get all => _output.encodedAssets
      .where((e) => e.type == DataAsset.type)
      .map(DataAsset.fromEncoded);
}

const _nameKey = 'name';
const _packageKey = 'package';
const _fileKey = 'file';
