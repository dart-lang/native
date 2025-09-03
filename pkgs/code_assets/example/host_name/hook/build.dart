// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';

void main(List<String> args) async {
  await build(args, (input, output) async {
    if (input.config.buildCodeAssets) {
      final targetOS = input.config.code.targetOS;
      switch (targetOS) {
        case OS.android || OS.iOS || OS.linux || OS.macOS:
          output.assets.code.add(
            CodeAsset(
              package: 'host_name',
              name: 'src/third_party/unix.dart',
              linkMode: LookupInProcess(),
            ),
          );
        case OS.windows:
          output.assets.code.add(
            CodeAsset(
              package: 'host_name',
              name: 'src/third_party/windows.dart',
              linkMode: DynamicLoadingSystem(Uri.file('ws2_32.dll')),
            ),
          );
        default:
          throw UnsupportedError('Unsupported OS: ${targetOS.name}.');
      }
    }
  });
}
