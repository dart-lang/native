// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// A library that contains the argument and file formats for implementing hooks.
///
/// The main entrypoint for build hooks, implemented in `hook/build.dart`,
/// is [build]. The main entrypoint for link hooks, implemented in
/// `hook/link.dart`, is [link].
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
        BuildInput,
        BuildInputAssets,
        BuildInputBuilder,
        BuildInputMetadata,
        BuildOutput,
        BuildOutputAssets,
        BuildOutputAssetsBuilder,
        BuildOutputBuilder,
        BuildOutputMetadataBuilder,
        HookConfig,
        HookConfigBuilder,
        HookInput,
        HookInputBuilder,
        HookInputUserDefines,
        HookOutput,
        HookOutputBuilder,
        LinkConfig,
        LinkConfigBuilder,
        LinkInput,
        LinkInputAssets,
        LinkInputBuilder,
        LinkOutput,
        LinkOutputAssets,
        LinkOutputAssetsBuilder,
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
export 'src/validation.dart' show ProtocolBase;
