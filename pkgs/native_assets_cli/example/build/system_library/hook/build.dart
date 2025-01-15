// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:native_assets_cli/code_assets.dart';

void main(List<String> arguments) async {
  await build(arguments, (input, output) async {
    final targetOS = input.config.code.targetOS;
    output.assets.code.add(CodeAsset(
      package: input.packageName,
      name: 'memory.dart',
      linkMode: DynamicLoadingSystem(
        Uri.file(
          switch (targetOS) {
            OS.android => 'libc.so.6',
            OS.iOS => 'libc.dylib',
            OS.linux => 'libc.so.6',
            OS.macOS => 'libc.dylib',
            OS.windows => 'ole32.dll',
            _ => throw UnsupportedError('Unknown operating system: $targetOS'),
          },
        ),
      ),
      os: targetOS,
      architecture: input.config.code.targetArchitecture,
    ));
  });
}
