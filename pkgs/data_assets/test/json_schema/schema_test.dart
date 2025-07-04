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
    fields: _dataFields,
  );
}

Uri packageUri = findPackageRoot('data_assets');

const _dataAssetFields = ['package', 'name', 'file'];

List<(List<Object>, void Function(ValidationResults result))> _dataFields({
  required InputOrOutput inputOrOutput,
  required Hook hook,
  required Party party,
}) => <(List<Object>, void Function(ValidationResults result))>[
  if (inputOrOutput == InputOrOutput.input) ...[
    if (hook == Hook.link) ...[
      for (final field in _dataAssetFields) ...[
        (['assets', 0, 'encoding', field], expectRequiredFieldMissing),
        (['assets', 1, 'encoding', field], expectRequiredFieldMissing),
      ],
    ],
  ],
  if (inputOrOutput == InputOrOutput.output) ...[
    for (final field in _dataAssetFields)
      (['assets', 0, 'encoding', field], expectRequiredFieldMissing),
    if (hook == Hook.build) ...[
      for (final field in _dataAssetFields)
        for (final path in [
          ['assets_for_build'],
          ['assets_for_linking', 'package_with_linker'],
        ])
          ([...path, 0, 'encoding', field], expectRequiredFieldMissing),
    ],
  ],
];
