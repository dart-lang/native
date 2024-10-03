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
export 'src/code_assets/code_asset_bundling.dart'
    show CodeAssetBuildConfigBuilder, CodeAssetBuildOutput, CodeAssetLinkOutput;
export 'src/code_assets/validation.dart'
    show
        validateCodeAssetBuildOutput,
        validateCodeAssetLinkOutput,
        validateCodeAssetsInApplication;
export 'src/config.dart' show BuildConfigBuilder, LinkConfigBuilder;
export 'src/config.dart' show BuildOutputBuilder, LinkOutputBuilder;
export 'src/config.dart' show HookConfigBuilder, HookOutput;
export 'src/data_assets/data_asset_bundling.dart'
    show DataAssetBuildOutput, DataAssetLinkOutput;
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
