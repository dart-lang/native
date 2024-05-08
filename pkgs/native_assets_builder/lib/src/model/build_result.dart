// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:native_assets_cli/native_assets_cli_internal.dart';

/// The result of a build, executing the build.dart hooks from all packages in
/// the dependency tree of the entry point application.
abstract class BuildResult {
  List<Uri> get dependencies;

  bool get success;

  List<AssetImpl> get assets;

  Map<String, List<AssetImpl>> get assetsForLinking;
}
