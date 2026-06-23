// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:hooks/hooks.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';
import 'package:record_use/record_use.dart';
import 'package:treeshaking_dylib_record_use/src/add_record_use_mapping.dart'
    as add_mapping;
import 'package:treeshaking_dylib_record_use/src/multiply_record_use_mapping.dart'
    as multiply_mapping;

void main(List<String> arguments) async {
  await link(arguments, (input, output) async {
    final addLib = CLibrary(
      name: 'add',
      assetName: 'add',
      sources: ['src/add.c'],
    );

    final multiplyLib = CLibrary(
      name: 'multiply',
      assetName: 'multiply',
      sources: ['src/multiply.c'],
    );

    // ignore: experimental_member_use
    final usages = input.recordedUses;

    final addSymbols = usages?.calls.keys
        .cast<Method>()
        .where((e) => add_mapping.recordUseMapping.containsKey(e.name))
        .map((e) => add_mapping.recordUseMapping[e.name]!);
    await addLib.link(
      input: input,
      output: output,
      linkerOptions: LinkerOptions.treeshake(symbolsToKeep: addSymbols),
    );

    final multiplySymbols = usages?.calls.keys
        .cast<Method>()
        .where((e) => multiply_mapping.recordUseMapping.containsKey(e.name))
        .map((e) => multiply_mapping.recordUseMapping[e.name]!);
    await multiplyLib.link(
      input: input,
      output: output,
      linkerOptions: LinkerOptions.treeshake(symbolsToKeep: multiplySymbols),
    );
  });
}
