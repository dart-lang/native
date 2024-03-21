// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:pub_semver/pub_semver.dart';

import '../model/target.dart';
import '../utils/json.dart';
import '../utils/map.dart';
import 'architecture.dart';
import 'build_config.dart';
import 'build_output.dart';
import 'os.dart';

part '../model/asset.dart';
part '../model/data_asset.dart';
part '../model/native_code_asset.dart';
part 'data_asset.dart';
part 'native_code_asset.dart';

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
  /// `'package:foo/src/foo.dart'`. For example a [NativeCodeAsset] can be accessed
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
}
