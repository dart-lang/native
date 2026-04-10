// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:hooks/hooks.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';
import 'package:record_use/record_use.dart';
import 'package:sqlite/src/c_library.dart';
import 'package:sqlite/src/third_party/record_use_mapping.dart';

void main(List<String> arguments) async {
  await link(arguments, (input, output) async {
    await cLibrary.link(
      input: input,
      output: output,
      linkerOptions: LinkerOptions.treeshake(
        symbolsToKeep: input.usages?.calls.keys
            .cast<Method>()
            .map((e) => recordUseMapping[e.name])
            .nonNulls,
      ),
    );
  });
}

extension on LinkInput {
  Recordings? get usages {
    // ignore: experimental_member_use
    final usagesFile = recordedUsagesFile;
    if (usagesFile == null) return null;
    final usagesContent = File.fromUri(usagesFile).readAsStringSync();
    final usagesJson = jsonDecode(usagesContent) as Map<String, Object?>;
    final usages = Recordings.fromJson(usagesJson);
    return usages;
  }
}
