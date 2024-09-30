// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'api/build_config.dart';
import 'api/build_output.dart';
import 'architecture.dart';
import 'json_utils.dart';
import 'link_mode.dart';
import 'os.dart';
import 'utils/map.dart';

part 'code_asset.dart';
part 'data_asset.dart';

/// Data or code bundled with a Dart or Flutter application.
///
/// An asset is data or code which is accessible from a Dart or Flutter
/// application. To access an asset at runtime, the asset [id] is used.
abstract final class Asset {
  /// The identifier for this asset.
  ///
  /// An [Asset] has a string identifier called "asset id". Dart code that uses
  /// an asset references the asset using this asset id.
  ///
  /// An asset identifier consists of two elements, the `package` and `name`,
  /// which together make a library uri `package:<package>/<name>`. The package
  /// being part of the identifer prevents name collisions between assets of
  /// different packages.
  ///
  /// The default asset id for an asset reference from `lib/src/foo.dart` is
  /// `'package:foo/src/foo.dart'`. For example a [CodeAsset] can be accessed
  /// via `@Native` with the `assetId` argument omitted:
  ///
  /// ```dart
  /// // file package:foo/src/foo.dart
  /// @Native<Int Function(Int, Int)>()
  /// external int add(int a, int b);
  /// ```
  ///
  /// This will be then automatically expanded to
  ///
  /// ```dart
  /// // file package:foo/src/foo.dart
  /// @Native<Int Function(Int, Int)>(assetId: 'package:foo/src/foo.dart')
  /// external int add(int a, int b);
  /// ```
  String get id;

  /// The file to be bundled with the Dart or Flutter application.
  ///
  /// How this file is bundled depends on the kind of asset, represented by a
  /// concrete subtype of [Asset], and the SDK (Dart or Flutter).
  ///
  /// The file can be omitted in the [BuildOutput] for [BuildConfig.dryRun].
  ///
  /// The file can also be omitted for asset types which refer to an asset
  /// already present on the target system or an asset already present in Dart
  /// or Flutter.
  Uri? get file;

  /// A json representation of this [Asset].
  Map<String, Object> toJson();

  static List<Asset> listFromJson(List<Object?>? list) {
    final assets = <Asset>[];
    if (list == null) return assets;
    for (var i = 0; i < list.length; ++i) {
      final jsonMap = list.getObject(i);
      final type = jsonMap[_typeKey];
      switch (type) {
        case CodeAsset.type:
          assets.add(CodeAsset.fromJson(jsonMap));
        case DataAsset.type:
          assets.add(DataAsset.fromJson(jsonMap));
        default:
        // Do nothing, some other launcher might define it's own asset types.
      }
    }
    return assets;
  }

  static List<Map<String, Object>> listToJson(Iterable<Asset> assets) => [
        for (final asset in assets) asset.toJson(),
      ];
}

const _architectureKey = 'architecture';
const _fileKey = 'file';
const _idKey = 'id';
const _linkModeKey = 'link_mode';
const _nameKey = 'name';
const _osKey = 'os';
const _packageKey = 'package';
const _typeKey = 'type';
