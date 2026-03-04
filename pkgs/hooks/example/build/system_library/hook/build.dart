// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';

void main(List<String> arguments) async {
  await build(arguments, (input, output) async {
    final targetOS = input.config.code.targetOS;
    output.assets.code.add(
      CodeAsset(
        package: input.packageName,
        name: 'memory.dart',
        linkMode: DynamicLoadingSystem(
          Uri.file(switch (targetOS) {
            .android => 'libc.so.6',
            .iOS => 'libc.dylib',
            .linux => 'libc.so.6',
            .macOS => 'libc.dylib',
            .windows => 'ole32.dll',
            _ => throw UnsupportedError('Unknown operating system: $targetOS'),
          }),
        ),
      ),
    );
  });
}
