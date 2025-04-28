// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Data asset support for hook authors.
library;

export 'src/data_assets/config.dart'
    show
        BuildOutputBuilderAddDataAssetsDirectories,
        BuildOutputAssetsBuilderData,
        BuildOutputDataAssets,
        BuildOutputDataAssetsBuilder,
        HookConfigDataConfig,
        LinkInputDataAssets,
        LinkOutputAssetsBuilderData,
        LinkOutputDataAssets,
        LinkOutputDataAssetsBuilder;
export 'src/data_assets/data_asset.dart' show DataAsset, EncodedDataAsset;
export 'src/data_assets/extension.dart';
