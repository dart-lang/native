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
/// application.
abstract final class Asset {
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
