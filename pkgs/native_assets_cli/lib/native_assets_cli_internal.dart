// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// This library should not be used by `build.dart` scripts.
///
/// Only `package:native_assets_builder` should use this.
library native_assets_cli_internal;

export 'src/model/asset.dart';
export 'src/model/build_config.dart';
export 'src/model/build_mode.dart';
export 'src/model/build_output.dart';
export 'src/model/dependencies.dart';
export 'src/model/ios_sdk.dart';
export 'src/model/link_mode.dart';
export 'src/model/link_mode_preference.dart';
export 'src/model/metadata.dart';
export 'src/model/target.dart';
