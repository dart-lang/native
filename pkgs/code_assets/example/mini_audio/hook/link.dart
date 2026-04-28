// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:hooks/hooks.dart';
import 'package:mini_audio/src/c_library.dart';
import 'package:mini_audio/src/third_party/record_use_mapping.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';
import 'package:record_use/record_use.dart';

void main(List<String> arguments) async {
  await link(arguments, (input, output) async {
    await cLibrary.link(
      input: input,
      output: output,
      linkerOptions: LinkerOptions.treeshake(
        // ignore: experimental_member_use
        symbolsToKeep: input.recordedUses?.calls.keys.cast<Method>().map(
          (e) => recordUseMapping[e.name]!,
        ),
      ),
    );
  });
}
