// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// A library that contains the argument and file formats for implementing a
/// build hook (`hook/build.dart`).
library;

export 'src/api/build.dart' show build;
export 'src/api/builder.dart' show Builder;
export 'src/api/link.dart' show link;
export 'src/api/linker.dart' show Linker;
export 'src/config.dart'
    show
        AssetRouting,
        BuildConfig,
        BuildConfigBuilder,
        BuildConfigBuilderSetup,
        BuildInput,
        BuildInputBuilder,
        BuildOutput,
        BuildOutputBuilder,
        EncodedAssetBuildOutputBuilder,
        EncodedAssetLinkOutputBuilder,
        HookConfig,
        HookConfigBuilder,
        HookInput,
        HookInputBuilder,
        HookOutput,
        HookOutputBuilder,
        LinkConfig,
        LinkConfigBuilder,
        LinkInput,
        LinkInputBuilder,
        LinkOutput,
        LinkOutputBuilder,
        PackageMetadata,
        ToAppBundle,
        ToBuildHooks,
        ToLinkHook;
export 'src/encoded_asset.dart' show EncodedAsset;
export 'src/extension.dart';
export 'src/test.dart';
export 'src/user_defines.dart'
    show PackageUserDefines, PackageUserDefinesSource;
export 'src/validation.dart'
    show
        validateBuildInput,
        validateBuildOutput,
        validateLinkInput,
        validateLinkOutput;
