// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Data asset support for hook authors.
library;

export 'native_assets_cli.dart'
    hide
        EncodedAsset,
        EncodedAssetBuildOutputBuilder,
        EncodedAssetLinkOutputBuilder;
export 'src/data_assets/config.dart'
    show
        DataAssetBuildOutput,
        DataAssetBuildOutput2,
        DataAssetBuildOutputBuilder,
        DataAssetBuildOutputBuilderAdd,
        DataAssetLinkConfig,
        DataAssetLinkOutput,
        DataAssetLinkOutput2,
        DataAssetLinkOutputBuilder,
        DataAssetLinkOutputBuilderAdd;
export 'src/data_assets/data_asset.dart' show DataAsset;
