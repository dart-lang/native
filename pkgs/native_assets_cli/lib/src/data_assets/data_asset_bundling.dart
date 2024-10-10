// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../config.dart';
import 'data_asset.dart';

extension DataAssetBuildOutput on BuildOutput {
  List<DataAsset> get dataAssets => encodedAssets
      .where((asset) => asset.type == DataAsset.type)
      .map<DataAsset>(DataAsset.fromEncoded)
      .toList();
}

extension DataAssetLinkOutput on LinkOutput {
  List<DataAsset> get dataAssets => encodedAssets
      .where((asset) => asset.type == DataAsset.type)
      .map<DataAsset>(DataAsset.fromEncoded)
      .toList();
}
