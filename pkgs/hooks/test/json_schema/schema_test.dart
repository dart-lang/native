// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:json_schema/json_schema.dart';
import 'package:native_test_helpers/native_test_helpers.dart';

import 'helpers.dart';

void main() {
  final schemasUri = packageUri.resolve('doc/schema/');
  final hookSchemasUri = packageUri.resolve('../hooks/doc/schema/');
  final allSchemas = loadSchemas([schemasUri, hookSchemasUri]);

  final testDataUri = packageUri.resolve('test/data/');
  final allTestData = loadTestsData(testDataUri);

  testAllTestData(allSchemas, allTestData);

  testFieldsHook(
    allSchemas: allSchemas,
    allTestData: allTestData,
    packageUri: packageUri,
  );

  testFields(
    allSchemas: allSchemas,
    allTestData: allTestData,
    packageUri: packageUri,
    fields: _metadataAssetFields,
  );
}

Uri packageUri = findPackageRoot('hooks');

List<(List<Object>, void Function(ValidationResults result))>
_metadataAssetFields({
  required InputOrOutput inputOrOutput,
  required Hook hook,
  required Party party,
}) => <(List<Object>, void Function(ValidationResults result))>[
  for (final path in [
    if (inputOrOutput == .input && hook == .link) ...[
      ['assets'],
      ['assets_from_linking'],
    ],
    if (inputOrOutput == .output) ['assets_for_linking', 'package_with_linker'],
    if (inputOrOutput == .output && hook == .build) ['assets_for_build'],
  ]) ...[
    ([...path, 1], expectOptionalFieldMissing),
    ([...path, 1, 'type'], expectRequiredFieldMissing),
    ([...path, 1, 'encoding'], expectRequiredFieldMissing),
    ([...path, 1, 'encoding', 'key'], expectRequiredFieldMissing),
    // Skip `encoding.value`, it's optional and may have any type.
  ],
];
