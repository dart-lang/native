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
        AddDataAssetsDirectoryExtension,
        AddFoundCodeAssetsExtension,
        BuildConfig,
        BuildConfigBuilder,
        BuildInput,
        BuildOutputBuilder,
        EncodedAssetBuildOutputBuilder,
        EncodedAssetLinkOutputBuilder,
        GetLinkMode,
        HookConfig,
        HookConfigBuilder,
        HookInput,
        LinkInput,
        LinkOutputBuilder;
export 'src/encoded_asset.dart' show EncodedAsset;
export 'src/metadata.dart';
