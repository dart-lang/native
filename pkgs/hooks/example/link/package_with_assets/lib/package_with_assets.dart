// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:meta/meta.dart';

//TODO: Actually use the assets, needs the AssetBundle interface for Dart. See
//also https://github.com/dart-lang/sdk/issues/54003.
@AssetUsed('assets/used_asset.json')
String someMethod() => 'Using used_asset';

@AssetUsed('assets/unused_asset.json')
String someOtherMethod() => 'Using unused_asset';

@RecordUse()
class AssetUsed {
  final String assetName;

  const AssetUsed(this.assetName);
}
