// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:native_assets_cli/native_assets_cli_internal.dart';

import '../build_runner/build_runner.dart';
import 'build_result.dart';

/// Similar to a [BuildResult], but for `link.dart` hooks instead of
/// `build.dart` hooks.
abstract interface class LinkResult {
  /// The native assets produced by the hooks, which should be bundled.
  List<AssetImpl> get assets;

  /// The files used by the hooks.
  List<Uri> get dependencies;

  /// Whether all hooks completed without errors.
  ///
  /// All error messages are streamed to [NativeAssetsBuildRunner.logger].
  bool get success;
}
