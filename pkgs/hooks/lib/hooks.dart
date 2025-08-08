// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// @docImport 'src/api/build_and_link.dart';

/// A library that contains the protocol for implementing hooks.
///
/// The main entrypoint for build hooks (`hook/build.dart`) is [build]. The main
/// entrypoint for link hooks (`hook/link.dart`) is [link].
library;

export 'src/api/build_and_link.dart' show build, link;
export 'src/api/builder.dart' show Builder;
export 'src/api/linker.dart' show Linker;
export 'src/config.dart'
    show
        AssetRouting,
        BuildConfig,
        BuildConfigBuilder,
        BuildError,
        BuildInput,
        BuildInputAssets,
        BuildInputBuilder,
        BuildInputMetadata,
        BuildOutput,
        BuildOutputAssets,
        BuildOutputAssetsBuilder,
        BuildOutputBuilder,
        BuildOutputFailure,
        BuildOutputMaybeFailure,
        BuildOutputMetadataBuilder,
        FailureType,
        HookConfig,
        HookConfigBuilder,
        HookError,
        HookInput,
        HookInputBuilder,
        HookInputUserDefines,
        HookOutput,
        HookOutputBuilder,
        HookOutputFailure,
        InfraError,
        LinkAssetRouting,
        LinkConfig,
        LinkConfigBuilder,
        LinkInput,
        LinkInputAssets,
        LinkInputBuilder,
        LinkOutput,
        LinkOutputAssets,
        LinkOutputAssetsBuilder,
        LinkOutputBuilder,
        LinkOutputFailure,
        LinkOutputMaybeFailure,
        LinkOutputMetadataBuilder,
        PackageMetadata,
        ToAppBundle,
        ToBuildHooks,
        ToLinkHook;
export 'src/encoded_asset.dart' show EncodedAsset;
export 'src/extension.dart';
export 'src/test.dart';
export 'src/user_defines.dart'
    show PackageUserDefines, PackageUserDefinesSource;
export 'src/validation.dart' show ProtocolBase;
