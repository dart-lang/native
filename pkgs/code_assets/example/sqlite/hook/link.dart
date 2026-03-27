// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';
import 'package:record_use/record_use.dart';
import 'package:sqlite/src/third_party/record_use_mapping.dart';

void main(List<String> arguments) async {
  await link(arguments, (input, output) async {
    final asset = input.assets.code.single;
    final assetId = asset.id;
    final assetName = assetId.split('/').skip(1).join('/');
    final linker = CLinker.library(
      name: 'sqlite3',
      assetName: assetName,
      linkerOptions: LinkerOptions.treeshake(
        symbolsToKeep: input.usages?.calls.keys
            .cast<Method>()
            .map((e) => recordUseMapping[e.name])
            .nonNulls,
      ),
      sources: [asset.file!.toFilePath()],
    );

    await linker.run(input: input, output: output);
  });
}

extension on LinkInput {
  Recordings? get usages {
    // ignore: experimental_member_use
    final usagesFile = recordedUsagesFile;
    if (usagesFile == null) return null;
    final usagesContent = File.fromUri(usagesFile).readAsStringSync();
    final usagesJson = jsonDecode(usagesContent) as Map<String, Object?>;
    final usages = Recordings.fromJson(usagesJson);
    return usages;
  }
}
