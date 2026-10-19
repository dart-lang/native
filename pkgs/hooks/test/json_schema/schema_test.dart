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

  _testDoctorFields(allSchemas: allSchemas, allTestData: allTestData);
}

Uri packageUri = findPackageRoot('hooks');

void _testDoctorFields({
  required AllSchemas allSchemas,
  required AllTestData allTestData,
}) {
  for (final party in Party.values) {
    for (final inputOrOutput in InputOrOutput.values) {
      final schemaName = 'doctor_${inputOrOutput.name}';
      final schemaUri = packageUri.resolve(
        'doc/schema/${party.name}/$schemaName.generated.schema.json',
      );
      final schema = allSchemas[schemaUri]!;
      final dataUri = packageUri.resolve('test/data/$schemaName.json');
      final data = allTestData[dataUri]!;
      final fields = <(List<Object>, void Function(ValidationResults result))>[
        ([r'$schema'], expectOptionalFieldMissing),
        if (inputOrOutput == InputOrOutput.input) ...[
          (['out_file'], expectRequiredFieldMissing),
          (['package_name'], expectRequiredFieldMissing),
          (['package_root'], expectRequiredFieldMissing),
        ],
        if (inputOrOutput == InputOrOutput.output) ...[
          (['validations'], expectOptionalFieldMissing),
          (['validations', 0], expectOptionalFieldMissing),
          (['validations', 0, 'title'], expectRequiredFieldMissing),
          (['validations', 0, 'type'], expectRequiredFieldMissing),
          (['validations', 0, 'status_info'], expectOptionalFieldMissing),
          (['validations', 0, 'messages'], expectOptionalFieldMissing),
          (['validations', 0, 'messages', 0], expectOptionalFieldMissing),
          (
            ['validations', 0, 'messages', 0, 'message'],
            expectRequiredFieldMissing,
          ),
          (
            ['validations', 0, 'messages', 0, 'type'],
            expectRequiredFieldMissing,
          ),
          (
            ['validations', 0, 'messages', 0, 'context_url'],
            expectOptionalFieldMissing,
          ),
          (
            ['validations', 0, 'messages', 0, 'pii_stripped_message'],
            expectOptionalFieldMissing,
          ),
        ],
      ];
      for (final (field, missingExpectations) in fields) {
        testField(
          field: field,
          schemaUri: schemaUri,
          schema: schema,
          dataUri: dataUri,
          data: data,
          missingExpectations: missingExpectations,
        );
      }
    }
  }
}

List<(List<Object>, void Function(ValidationResults result))>
_metadataAssetFields({
  required InputOrOutput inputOrOutput,
  required Hook hook,
  required Party party,
}) => <(List<Object>, void Function(ValidationResults result))>[
  for (final path in [
    if (inputOrOutput == InputOrOutput.input && hook == Hook.link) ...[
      ['assets'],
      ['assets_from_linking'],
    ],
    if (inputOrOutput == InputOrOutput.output)
      ['assets_for_linking', 'package_with_linker'],
    if (inputOrOutput == InputOrOutput.output && hook == Hook.build)
      ['assets_for_build'],
  ]) ...[
    ([...path, 1], expectOptionalFieldMissing),
    ([...path, 1, 'type'], expectRequiredFieldMissing),
    ([...path, 1, 'encoding'], expectRequiredFieldMissing),
    ([...path, 1, 'encoding', 'key'], expectRequiredFieldMissing),
    // Skip `encoding.value`, it's optional and may have any type.
  ],
];
