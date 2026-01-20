// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

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
      final myMethodIdentifier = recordings.calls.keys.firstWhere(
        (i) => i.name == 'myMethod',
      );
      expect(
        myMethodIdentifier.importUri,
        'package:library_uris/src/definition.dart',
      );

      final callsToMyMethod = recordings.calls[myMethodIdentifier]!;

      final callFromCallDotDart = callsToMyMethod.firstWhere(
        (c) => c.location!.uri.endsWith('call.dart'),
      );
      expect(
        callFromCallDotDart.location!.uri,
        'package:library_uris/src/call.dart',
      );

      final callFromBin = callsToMyMethod.firstWhere(
        (c) => c.location!.uri.endsWith('my_bin.dart'),
      );
      expect(
        callFromBin.location!.uri,
        // TODO(https://github.com/dart-lang/native/issues/2891): What should
        // this be? We don't have library uris for bin.
        'package:library_uris/bin/my_bin.dart',
      );

      // The helper package.
      final helperMethodIdentifier = recordings.calls.keys.firstWhere(
        (i) => i.name == 'methodInHelper',
      );
      expect(
        helperMethodIdentifier.importUri,
        'package:library_uris_helper/src/helper_definition.dart',
      );

      final callsToHelperMethod = recordings.calls[helperMethodIdentifier]!;

      final callFromHelperCallDotDart = callsToHelperMethod.firstWhere(
        (c) => c.location!.uri.endsWith('helper_call.dart'),
      );
      expect(
        callFromHelperCallDotDart.location!.uri,
        'package:library_uris_helper/src/helper_call.dart',
      );

      final callFromCallDotDart2 = callsToHelperMethod.firstWhere(
        (c) => c.location!.uri.endsWith('helper_call.dart'),
      );
      expect(
        callFromCallDotDart2.location!.uri,
        'package:library_uris/src/call.dart',
      );

      final callFromBin2 = callsToHelperMethod.firstWhere(
        (c) => c.location!.uri.endsWith('my_bin.dart'),
      );
      expect(
        callFromBin2.location!.uri,
        // TODO(https://github.com/dart-lang/native/issues/2891): What should
        // this be? We don't have library uris for bin.
        'package:library_uris/bin/my_bin.dart',
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
