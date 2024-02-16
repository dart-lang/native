// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// This library should not be used by `build.dart` scripts.
///
/// Only `package:native_assets_builder` should use this.
/// @nodoc
library native_assets_cli_internal;

export 'src/api/asset.dart'
    show
        AssetAbsolutePathImpl,
        CCodeAssetImpl,
        AssetInExecutableImpl,
        AssetInProcessImpl,
        AssetSystemPathImpl;
export 'src/api/build_config.dart' show BuildConfigImpl, CCompilerConfigImpl;
export 'src/api/build_mode.dart' show BuildModeImpl;
export 'src/api/build_output.dart' show BuildOutputImpl;
export 'src/api/ios_sdk.dart' show IOSSdkImpl;
export 'src/api/link_mode.dart' show LinkModeImpl;
export 'src/api/link_mode_preference.dart' show LinkModePreferenceImpl;
export 'src/api/target.dart' show ArchitectureImpl, OSImpl, TargetImpl;
export 'src/model/dependencies.dart';
export 'src/model/metadata.dart';
