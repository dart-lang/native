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
final class DataAsset extends Asset {
  /// The file to be bundled with the Dart or Flutter application.
  ///
  /// The file can be omitted in the [BuildOutput] for [BuildConfig.dryRun].
  ///
  /// The file can also be omitted for asset types which refer to an asset
  /// already present on the target system or an asset already present in Dart
  /// or Flutter.
  @override
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
  @override
  String get id => 'package:$package/$name';

  DataAsset({
    required this.file,
    required this.name,
    required this.package,
  });

  /// Constructs a [DataAsset] from a json representation obtained via
  /// [DataAsset.toJson].
  factory DataAsset.fromJson(Map<String, Object?> jsonMap) => DataAsset(
        name: jsonMap.string(_nameKey),
        package: jsonMap.string(_packageKey),
        file: jsonMap.path(_fileKey),
      );

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

  @override
  Map<String, Object> toJson() => {
        _nameKey: name,
        _packageKey: package,
        _fileKey: file.toFilePath(),
        _typeKey: DataAsset.type,
      }..sortOnKey();

  @override
  String toString() => 'DataAsset(${toJson()})';

  static const String type = 'data';
}
