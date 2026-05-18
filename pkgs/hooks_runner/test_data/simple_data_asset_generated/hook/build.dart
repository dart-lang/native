// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'package:data_assets/data_assets.dart';
import 'package:hooks/hooks.dart';

void main(List<String> args) async {
  await build(args, (input, output) async {
    final fileUri = input.packageRoot.resolve('data/generated.txt');
    final file = File.fromUri(fileUri);
    if (!await file.parent.exists()) {
      await file.parent.create(recursive: true);
    }
    await file.writeAsString('generated content');
    output.assets.data.add(
      DataAsset(
        package: input.packageName,
        name: 'data/generated.txt',
        file: fileUri,
      ),
    );
  });
}
