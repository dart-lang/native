// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:record_use/record_use_internal.dart';
import 'package:test/test.dart';

import 'storage_2_test.dart';

const dart2jsNotSupported = {
  // No support for instance constants.
  // https://github.com/dart-lang/native/issues/2893
  'instance_class.json',
  'instance_complex.json',
  'instance_duplicates.json',
  'instance_method.json',
  'instance_not_annotation.json',
  'nested.json',
  'record_enum.json',
  'record_instance_constant_empty.json',
  // No support for lists and map constants.
  // https://github.com/dart-lang/native/issues/2896
  'types_of_arguments.json',
  // Named arguments are converted to positional arguments.
  // https://github.com/dart-lang/native/issues/2883
  'named_and_positional.json',
  'named_both.json',
  'named_optional.json',
  'named_required.json',
  // Extension methods are broken.
  // https://github.com/dart-lang/native/issues/2926
  'extension.json',
};

// dart2js also records loadDeferredLibrary calls.
// https://github.com/dart-lang/native/issues/2892
const dart2jsDeferLoadedLibrary = {
  'loading_units_simple.json',
  'loading_units_multiple.json',
};

void main() {
  final testDataUri = packageUri.resolve('test_data/json_dart2js/');
  final expectDataUri = packageUri.resolve('test_data/json/');
  final allTestData = loadTestsData(testDataUri);

  for (final entry in allTestData.entries) {
    final dataUri = entry.key;
    final dataString = entry.value;

    final fileName = dataUri.pathSegments.last;
    if (dart2jsNotSupported.contains(fileName)) continue;
    final expectUri = expectDataUri.resolve(fileName);
    final expectFile = File.fromUri(expectUri);
    final expectString = expectFile.readAsStringSync();
    test('$dataUri $expectUri', () {
      final uses = Recordings.fromJson(
        jsonDecode(dataString) as Map<String, Object?>,
      );
      final expectedUses = Recordings.fromJson(
        jsonDecode(expectString) as Map<String, Object?>,
      );
      if (!uses.semanticEquals(
        expectedUses,
        allowMetadataMismatch: true,
        // Definition loading units are not working in dart2js backend.
        // https://github.com/dart-lang/native/issues/2890
        allowDefinitionLoadingUnitNull: true,
        allowMoreConstArguments: true,
        allowTearoffToStaticPromotion: true,
        expectedIsSubset: dart2jsDeferLoadedLibrary.contains(fileName),
        uriMapping: (String uri) =>
            uri.replaceFirst('memory:sdk/tests/web/native/', ''),
        loadingUnitMapping: (String unit) =>
            const <String, String>{
              'out': '1',
              'out_1': '2',
            }[unit] ??
            unit,
      )) {
        fail('not semantic equals');
      }
    });
  }
}
