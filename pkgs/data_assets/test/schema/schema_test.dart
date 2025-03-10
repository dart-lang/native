// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:json_schema/json_schema.dart';

import 'helpers.dart';

void main() {
  final schemasUri = packageUri.resolve('doc/schema/');
  final hookSchemasUri = packageUri.resolve('../hook/doc/schema/');
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
  required String inputOrOutput,
  required String hook,
  required String party,
}) => <(List<Object>, void Function(ValidationResults result))>[
  if (inputOrOutput == 'input') ...[
    if (hook == 'link') ...[
      for (final field in _dataAssetFields)
        (['assets', 0, field], expectRequiredFieldMissing),
    ],
  ],
  if (inputOrOutput == 'output') ...[
    for (final field in _dataAssetFields)
      (['assets', 0, field], expectRequiredFieldMissing),
    if (hook == 'build') ...[
      for (final field in _dataAssetFields)
        (
          ['assetsForLinking', 'package_with_linker', 0, field],
          expectRequiredFieldMissing,
        ),
    ],
  ],
];
