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

      final identifier = recordings.calls.keys.single;
      expect(identifier.importUri, 'package:library_uris/src/definition.dart');

      final calls = recordings.calls[identifier]!;

      final callFromFooDotDart = calls.firstWhere(
        (c) => c.location!.uri.endsWith('foo.dart'),
      );
      expect(
        callFromFooDotDart.location!.uri,
        'package:library_uris/src/foo.dart',
      );

      final callFromBarDotDart = calls.firstWhere(
        (c) => c.location!.uri.endsWith('bar.dart'),
      );
      expect(
        callFromBarDotDart.location!.uri,
        'package:library_uris/bin/bar.dart',
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
