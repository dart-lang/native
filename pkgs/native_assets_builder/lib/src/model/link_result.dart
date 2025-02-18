// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:native_assets_cli/native_assets_cli_internal.dart';

/// The result of executing the link hooks from all packages in the dependency
/// tree of the entry point application.
abstract interface class LinkResult {
  /// All assets (produced by the build & link hooks) that have to be bundled
  /// with the app.
  List<EncodedAsset> get encodedAssets;

  /// The files used by the hooks.
  List<Uri> get dependencies;
}
