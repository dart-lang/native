// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:native_assets_cli/data_assets.dart';
import 'package:record_use/record_use.dart';

const multiplyIdentifier = Identifier(
  importUri: 'package:package_with_assets/package_with_assets.dart',
  name: 'AssetUsed',
);

void main(List<String> args) async {
  await link(args, (config, output) async {
    final usages = config.usages;

    final usedAssets = (usages.instancesOf(multiplyIdentifier) ?? []).map((e) =>
        (e.instanceConstant.fields.values.first as StringConstant).value);

    output.data.addAssets(config.assets.data
        .where((dataAsset) => usedAssets.contains(dataAsset.name)));
  });
}

extension on LinkConfig {
  RecordedUsages get usages {
    final usagesFile = recordedUsagesFile;
    final usagesContent = File.fromUri(usagesFile!).readAsStringSync();
    final usagesJson = jsonDecode(usagesContent) as Map<String, Object?>;
    final usages = RecordedUsages.fromJson(usagesJson);
    return usages;
  }
}
