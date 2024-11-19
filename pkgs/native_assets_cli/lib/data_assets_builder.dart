// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Data asset support for hook invokers (e.g. building / bundling tools).
library;

export 'data_assets.dart' hide build, link;
export 'native_assets_cli_builder.dart'
    hide EncodedAssetBuildOutputBuilder, EncodedAssetLinkOutputBuilder;
export 'src/data_assets/config.dart'
    show DataAssetBuildOutput, DataAssetLinkOutput;
export 'src/data_assets/validation.dart'
    show
        validateDataAssetBuildConfig,
        validateDataAssetBuildOutput,
        validateDataAssetLinkConfig,
        validateDataAssetLinkOutput;
