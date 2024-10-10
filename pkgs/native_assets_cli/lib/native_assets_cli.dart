// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// A library that contains the argument and file formats for implementing a
/// build hook (`hook/build.dart`).
library native_assets_cli;

export 'src/api/build.dart' show build;
export 'src/api/builder.dart' show Builder;
export 'src/api/link.dart' show link;
export 'src/api/linker.dart' show Linker;
export 'src/architecture.dart' show Architecture;
export 'src/build_mode.dart' show BuildMode;
export 'src/c_compiler_config.dart' show CCompilerConfig;
export 'src/code_assets/code_asset.dart'
    show
        BuildOutputCodeAssets,
        CodeAsset,
        CodeAssetBuildConfig,
        CodeAssetsBuildOutput,
        CodeAssetsLinkConfig,
        CodeAssetsLinkOutput,
        CodeConfig,
        LinkConfigCodeAssets,
        LinkOutputCodeAssets,
        OSLibraryNaming;
export 'src/config.dart' show BuildConfig, BuildOutputBuilder;
export 'src/config.dart' show BuildOutput, LinkOutput, LinkOutputBuilder;
export 'src/config.dart' show HookConfig;
export 'src/config.dart' show LinkConfig;
export 'src/data_assets/data_asset.dart'
    show
        BuildOutputDataAssets,
        DataAsset,
        DataAssetsBuildOutput,
        DataAssetsLinkConfig,
        DataAssetsLinkOutput,
        LinkConfigDataAssets,
        LinkOutputDataAssets;
export 'src/encoded_asset.dart' show EncodedAsset;
export 'src/ios_sdk.dart' show IOSSdk;
export 'src/link_mode.dart'
    show
        DynamicLoadingBundled,
        DynamicLoadingSystem,
        LinkMode,
        LookupInExecutable,
        LookupInProcess,
        StaticLinking;
export 'src/link_mode_preference.dart' show LinkModePreference;
export 'src/os.dart' show OS;
