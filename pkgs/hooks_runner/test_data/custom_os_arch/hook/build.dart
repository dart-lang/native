// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';

void main(List<String> arguments) async {
  await build(arguments, (input, output) async {
    final targetOS = input.config.code.targetOS;
    final targetArch = input.config.code.targetArchitecture;
    final sanitizer = input.config.code.sanitizer;
    final linkModePreference = input.config.code.linkModePreference;

    final file = File.fromUri(input.outputDirectory.resolve('my_asset.so'));
    await file.writeAsString(
      'dummy: $targetOS, $targetArch, $sanitizer, $linkModePreference',
    );

    output.assets.code.add(
      CodeAsset(
        package: 'custom_os_arch',
        name: 'my_asset',
        linkMode: CustomLinkMode('my_custom_link_mode', {
          'type': 'my_custom_link_mode',
          'extra_data': 'some_value',
        }),
        file: file.uri,
      ),
    );
  });
}
