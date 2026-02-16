// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// This hook is a test that checks that library URIs are as expected inside
// the link hook.
// This test is run on CI by executing `dart build cli` in this package.

import 'dart:convert';
import 'dart:io';

import 'package:hooks/hooks.dart';
import 'package:record_use/record_use_internal.dart';

void main(List<String> arguments) async {
  await link(
    arguments,
    (input, output) async {
      // ignore: experimental_member_use
      final recordedUsagesFile = input.recordedUsagesFile;
      if (recordedUsagesFile == null) {
        throw UnsupportedError('Run with --enable-experiment=record-use.');
      }
      final recordings = await readUsagesFile(recordedUsagesFile);

      // This package.
      final myMethodDefinition = recordings.calls.keys.firstWhere(
        (i) => i.path.last.name == 'myMethod',
      );
      expect(
        myMethodDefinition.library,
        'package:library_uris/src/definition.dart',
      );

      // The helper package.
      final helperMethodDefinition = recordings.calls.keys.firstWhere(
        (i) => i.path.last.name == 'methodInHelper',
      );
      expect(
        helperMethodDefinition.library,
        'package:library_uris_helper/src/helper_definition.dart',
      );

      // Outside the lib dir, no package: uri.
      final methodInBinDefinition = recordings.calls.keys.firstWhere(
        (i) => i.path.last.name == 'methodInBin',
      );
      expect(
        methodInBinDefinition.library,
        // TODO(https://github.com/dart-lang/native/issues/2891): What should
        // this be? We don't have library uris for bin.
        'package:library_uris/../bin/my_bin.dart',
      );
    },
  );
}

void expect(String actual, String expected) {
  if (actual != expected) {
    throw ArgumentError(
      'Expected "$expected" got "$actual"',
    );
  }
}

Future<Recordings> readUsagesFile(Uri recordedUsagesFile) async {
  final file = File.fromUri(recordedUsagesFile);
  final string = await file.readAsString();
  final usages = Recordings.fromJson(
    jsonDecode(string) as Map<String, Object?>,
  );
  return usages;
}
