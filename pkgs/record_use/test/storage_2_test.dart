// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:native_test_helpers/native_test_helpers.dart';
import 'package:record_use/record_use_internal.dart';
import 'package:test/test.dart';

void main() {
  final update = Platform.environment['UPDATE'] != null;
  final testDataUri = packageUri.resolve('test_data/json/');
  final allTestData = loadTestsData(testDataUri);

  for (final entry in allTestData.entries) {
    final dataUri = entry.key;
    final dataString = entry.value;
    test('Deserialize and serialize $dataUri', () {
      printOnFailure(dataUri.toString());
      final uses = Recordings.fromJson(
        jsonDecode(dataString) as Map<String, Object?>,
      );
      const encoder = JsonEncoder.withIndent('  ');
      final serializedString = encoder.convert({
        '\$schema': '../../doc/schema/record_use.schema.json',
        ...uses.toJson(),
      });

      if (update) {
        File.fromUri(dataUri).writeAsStringSync('$serializedString\n');
      } else {
        expect(
          serializedString.replaceAll('\r\n', '\n').trim(),
          dataString.replaceAll('\r\n', '\n').trim(),
        );
      }
    });
  }
}

typedef AllTestData = Map<Uri, String>;

/// The data is modified in tests, so load but don't json decode them all.
AllTestData loadTestsData(Uri directory) {
  final allTestData = <Uri, String>{};
  for (final file in Directory.fromUri(directory).listSync()) {
    file as File;
    allTestData[file.uri] = file.readAsStringSync();
  }
  return allTestData;
}

Uri packageUri = findPackageRoot('record_use');
