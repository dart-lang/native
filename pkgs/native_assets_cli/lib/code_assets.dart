// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Code asset support for hook authors.
library;

export 'native_assets_cli.dart'
    hide
        EncodedAsset,
        EncodedAssetBuildOutputBuilder,
        EncodedAssetLinkOutputBuilder;
export 'src/code_assets/architecture.dart' show Architecture;
export 'src/code_assets/c_compiler_config.dart' show CCompilerConfig;
export 'src/code_assets/code_asset.dart' show CodeAsset, OSLibraryNaming;
export 'src/code_assets/config.dart'
    show
        CodeAssetBuildConfig,
        CodeAssetBuildOutputBuilder,
        CodeAssetBuildOutputBuilderAdd,
        CodeAssetLinkConfig,
        CodeAssetLinkOutputBuilder,
        CodeAssetLinkOutputBuilderAdd,
        CodeConfig;
export 'src/code_assets/ios_sdk.dart' show IOSSdk;
export 'src/code_assets/link_mode.dart'
    show
        DynamicLoadingBundled,
        DynamicLoadingSystem,
        LinkMode,
        LookupInExecutable,
        LookupInProcess,
        StaticLinking;
export 'src/code_assets/link_mode_preference.dart' show LinkModePreference;
export 'src/code_assets/os.dart' show OS;
