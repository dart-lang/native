// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:hooks/hooks.dart';
import 'package:logging/logging.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';
import 'package:reusable_dynamic_library/hook.dart';

void main(List<String> args) async {
  await build(args, (input, output) async {
    final logger = Logger('')
      ..level = Level.ALL
      ..onRecord.listen((record) => print(record.message));

    final addLibrary = AddLibrary(input);
    final builder = CBuilder.library(
      name: 'my_add',
      assetName: 'my_add.dart',
      sources: ['src/my_add.c'],
      libraries: [...addLibrary.libraries],
      libraryDirectories: [...addLibrary.libraryDirectories],
      includes: [...addLibrary.includes],
      buildMode: BuildMode.debug,
    );

    await builder.run(
      input: input,
      output: output,
      logger: logger,
      routing: const [ToAppBundle()],
    );
  });
}
