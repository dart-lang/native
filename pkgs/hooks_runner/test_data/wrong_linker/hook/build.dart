// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';

void main(List<String> arguments) async {
  await build(arguments, (input, output) async {
    final assetUri = input.outputDirectory.resolve(
      OS.current.dylibFileName('foo'),
    );

    await File.fromUri(assetUri).writeAsBytes([1, 2, 3]);

    output.assets.code.add(
      CodeAsset(
        package: input.packageName,
        name: 'foo',
        file: assetUri,
        linkMode: DynamicLoadingBundled(),
      ),
      routing: const ToLinkHook('a_package_that_does_not_exist'),
    );
  });
}
