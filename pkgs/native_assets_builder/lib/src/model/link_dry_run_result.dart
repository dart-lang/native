// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:native_assets_cli/native_assets_cli_internal.dart';

import '../../native_assets_builder.dart';

/// The result of executing the link hooks in dry run mode from all packages in
/// the dependency tree of the entry point application.
abstract interface class LinkDryRunResult {
  /// The native assets produced by the hooks, which should be bundled.
  List<AssetImpl> get assets;

  /// Whether all hooks completed without errors.
  ///
  /// All error messages are streamed to [NativeAssetsBuildRunner.logger].
  bool get success;
}
