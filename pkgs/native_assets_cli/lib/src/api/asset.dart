// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:pub_semver/pub_semver.dart';
import 'package:yaml/yaml.dart';

import '../utils/map.dart';
import '../utils/yaml.dart';
import 'architecture.dart';
import 'build_config.dart';
import 'build_output.dart';
import 'link_mode.dart';
import 'os.dart';
import 'target.dart';

part 'c_code_asset.dart';
part 'data_asset.dart';
part '../model/asset.dart';
part '../model/c_code_asset.dart';
part '../model/data_asset.dart';

/// Data or code bundled with a Dart or Flutter application.
///
/// An asset is data or code which is accessible from a Dart or Flutter
/// application. To access an asset at runtime, the asset [id] is used. This
/// enables access to the asset irrespective of how and where the application is
/// run.
abstract final class Asset {
  /// The identifier for this asset.
  ///
  /// An [Asset] must have a string identifier called "asset id". Dart code that
  /// uses an asset, references the asset using this asset id.
  ///
  /// A package must prefix all asset ids it defines with:
  /// `package:<package>/`, `<package>` being the current package's name. This
  /// ensures assets don't conflict between packages.
  ///
  /// Additionally, the convention is that an asset referenced from
  /// `lib/src/foo.dart` in `package:foo` has the asset id
  /// `'package:foo/src/foo.dart'`.
  String get id;

  /// The file to be bundled with the Dart or Flutter application.
  ///
  /// How this file is bundled depends on the subtype [Asset] and the SDK (Dart
  /// or Flutter).
  ///
  /// The file can be omitted in the [BuildOutput] for [BuildConfig.dryRun].
  ///
  /// The file can also be omitted for asset types which refer to an asset
  /// already present on the target system or an asset already present in Dart
  /// or Flutter.
  Uri? get file;
}
