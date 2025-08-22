// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';

void main(List<String> args) async {
  await build(args, (input, output) async {
    if (input.config.buildCodeAssets) {
      final linkMode = switch (input.config.code.targetOS) {
        OS.android => LookupInProcess(),
        OS.iOS => LookupInProcess(),
        OS.linux => LookupInProcess(),
        OS.macOS => LookupInProcess(),
        OS.windows => DynamicLoadingSystem(Uri.file('ws2_32.dll')),
        final os => throw UnsupportedError('Unsupported OS: ${os.name}.'),
      };
      output.assets.code.add(
        // Asset ID: "package:host_name/src/host_name.dart"
        CodeAsset(
          package: 'host_name',
          name: 'src/host_name.dart',
          linkMode: linkMode,
        ),
      );
    }
  });
}
