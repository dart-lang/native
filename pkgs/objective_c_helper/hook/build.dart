// Copyright 2025 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:hooks/hooks.dart';
import 'package:logging/logging.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';

void main(List<String> args) async {
  await build(args, (input, output) async {
    final logger = Logger('')
      ..level = Level.ALL
      ..onRecord.listen((record) {
        print('${record.level.name}: ${record.time}: ${record.message}');
      });

    final builder = CBuilder.library(
      name: 'objective_c_helper',
      assetName: 'objective_c_helper.dylib',
      sources: ['lib/src/util.c'],
    );

    await builder.run(input: input, output: output, logger: logger);
  });
}
