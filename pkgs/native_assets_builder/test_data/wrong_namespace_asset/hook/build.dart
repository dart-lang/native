// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:native_assets_cli/code_assets.dart';

void main(List<String> arguments) async {
  await build(arguments, (input, output) async {
    final assetUri = input.outputDirectory.resolve(
      OS.current.dylibFileName('foo'),
    );

    await File.fromUri(assetUri).writeAsBytes([1, 2, 3]);

    output.codeAssets.add(
      CodeAsset(
        package: 'other_package',
        name: 'foo',
        file: assetUri,
        linkMode: DynamicLoadingBundled(),
        os: OS.current,
        architecture: Architecture.current,
      ),
    );
  });
}
