// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:pub_semver/pub_semver.dart';
import 'package:yaml/yaml.dart';

import '../../native_assets_cli.dart';
import '../../native_assets_cli_internal.dart';
import '../utils/map.dart';
import '../utils/yaml.dart';
import 'link_mode.dart';
import 'target.dart';

part 'c_code_asset.dart';
part '../model/c_code_asset.dart';

/// Data bundled with a Dart or Flutter application.
///
/// An asset is data or code which is accessible from a Dart or Flutter
/// application. To retrieve an asset at runtime, the [id] is used. This enables
/// access to the asset irrespective of how and where the application is run.
abstract final class Asset {
  /// The identifier for this asset.
  ///
  /// An [Asset] must have a string identifier called `assetId`. Dart code that
  /// uses an asset, references the asset using this `assetId`.
  ///
  /// A package must prefix all `assetId`s it defines with:
  /// `package:<package>/`, `<package>` being the current package's name. This
  /// ensures assets don't conflict between packages.
  ///
  /// Additionally, the convention is that an asset referenced from
  /// `lib/src/foo.dart` in `package:foo` has the `assetId`
  /// `'package:foo/src/foo.dart'`.
  String get id;

  Uri? get file;
}
