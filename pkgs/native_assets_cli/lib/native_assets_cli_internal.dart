// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Internal API for invoking build hooks.
///
/// This library is intended for use by:
///  * `package:native_assets_builder`,
///  * `dartdev` (in the Dart SDK), and,
///  * `flutter_tools` (in the Flutter SDK).
///
/// > [!CAUTION]
/// > Unless you are building a custom SDK that embeds Dart you should
/// > not be importing this library!
///
/// @nodoc
library native_assets_cli_internal;

export 'native_assets_cli.dart' hide build, link;
export 'src/api/build_config.dart' show BuildConfigImpl;
export 'src/api/build_output.dart' show HookOutputImpl;
export 'src/api/hook_config.dart' show HookConfigImpl;
export 'src/api/link_config.dart' show LinkConfigImpl;
export 'src/code_assets/validation.dart'
    show
        validateCodeAssetBuildOutput,
        validateCodeAssetLinkOutput,
        validateCodeAssetsInApplication;
export 'src/data_assets/validation.dart'
    show validateDataAssetBuildOutput, validateDataAssetLinkOutput;
export 'src/encoded_asset.dart' show EncodedAsset;
export 'src/model/dependencies.dart';
export 'src/model/hook.dart';
export 'src/model/metadata.dart';
export 'src/model/resource_identifiers.dart';
export 'src/model/target.dart' show Target;
export 'src/validation.dart'
    show ValidationErrors, validateBuildOutput, validateLinkOutput;
