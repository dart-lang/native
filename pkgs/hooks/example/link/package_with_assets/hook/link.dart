// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: experimental_member_use

import 'dart:convert';
import 'dart:io';

import 'package:data_assets/data_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:record_use/record_use.dart';

const someMethodDefinition = Definition(
  importUri: 'package:package_with_assets/package_with_assets.dart',
  name: 'someMethod',
);

const someOtherMethodDefinition = Definition(
  importUri: 'package:package_with_assets/package_with_assets.dart',
  name: 'someOtherMethod',
);

final assetMapping = {
  someMethodDefinition: 'assets/used_asset.json',
  someOtherMethodDefinition: 'assets/unused_asset.json',
};

void main(List<String> args) async {
  await link(args, (input, output) async {
    final usages = input.usages;

    final usedAssets = [
      for (final entry in assetMapping.entries)
        if (usages.constArgumentsFor(entry.key).isNotEmpty ||
            usages.hasNonConstArguments(entry.key))
          entry.value,
    ];

    output.assets.data.addAll(
      input.assets.data.where(
        (dataAsset) => usedAssets.contains(dataAsset.name),
      ),
    );
  });
}

extension on LinkInput {
  RecordedUsages get usages {
    final usagesFile = recordedUsagesFile;
    final usagesContent = File.fromUri(usagesFile!).readAsStringSync();
    final usagesJson = jsonDecode(usagesContent) as Map<String, Object?>;
    final usages = RecordedUsages.fromJson(usagesJson);
    return usages;
  }
}
