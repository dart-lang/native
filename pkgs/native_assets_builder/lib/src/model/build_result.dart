// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:native_assets_cli/native_assets_cli_internal.dart';

/// The result of executing build hooks from all packages in the dependency tree
/// of the entry point application.
abstract class BuildResult {
  /// The files used by the hooks.
  List<Uri> get dependencies;

  /// The native assets produced by the hooks, which should be bundled.
  List<EncodedAsset> get encodedAssets;

  /// The native assets produced by the hooks, which should be linked.
  Map<String, List<EncodedAsset>> get encodedAssetsForLinking;
}
