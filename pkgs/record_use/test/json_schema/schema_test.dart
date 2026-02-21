// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:json_schema/json_schema.dart';
import 'package:native_test_helpers/native_test_helpers.dart';
import 'package:test/test.dart';

void main() {
  final schemaUri = packageUri.resolve('doc/schema/record_use.schema.json');
  final schemaJson =
      jsonDecode(File.fromUri(schemaUri).readAsStringSync())
          as Map<String, Object?>;
  final schema = JsonSchema.create(schemaJson);

  final testDataUri = packageUri.resolve('test_data/json/');
  final allTestData = loadTestsData(testDataUri);

  testAllTestData(allTestData, schemaUri, schema);

  final dataUri = testDataUri.resolve('recorded_uses.json');

  for (final field in recordUseFields) {
    testField(
      schemaUri: schemaUri,
      dataUri: dataUri,
      schema: schema,
      data: allTestData[dataUri]!,
      field: field.$1,
      missingExpectations: field.$2,
    );
  }

  final constructorInvocationDataUri = testDataUri.resolve(
    'constructor_invocation.json',
  );
  for (final field in constructorInvocationFields) {
    testField(
      schemaUri: schemaUri,
      dataUri: constructorInvocationDataUri,
      schema: schema,
      data: allTestData[constructorInvocationDataUri]!,
      field: field.$1,
      missingExpectations: field.$2,
    );
  }
}

const constNullIndex = 4;
const constNonConstantIndex = 5;
const constInstanceIndex = 7;
const constMapIndex = 3;
const constUnsupportedIndex = 9;
typedef SchemaTestField = (
  List<Object> path,
  void Function(ValidationResults result) missingExpectations,
);

List<SchemaTestField> recordUseFields = [
  (['constants'], expectOptionalFieldMissing),
  for (var index = 0; index < 10; index++) ...[
    (['constants', index, 'type'], expectRequiredFieldMissing),
    if (index != constNullIndex &&
        index != constNonConstantIndex &&
        index != constInstanceIndex &&
        index != constUnsupportedIndex)
      (['constants', index, 'value'], expectRequiredFieldMissing),
    if (index == constInstanceIndex)
      (['constants', index, 'value'], expectOptionalFieldMissing),
    if (index == constMapIndex) ...[
      (['constants', index, 'value', 0, 'key'], expectRequiredFieldMissing),
      (['constants', index, 'value', 0, 'value'], expectRequiredFieldMissing),
    ],
    if (index == constUnsupportedIndex)
      (['constants', index, 'message'], expectRequiredFieldMissing),
    // Note the value for 'Instance' is optional because an empty map is
    // omitted. Also, Null and NonConstant have no value field.
  ],
  (['definitions'], expectOptionalFieldMissing),
  (['definitions', 0, 'uri'], expectRequiredFieldMissing),
  (['definitions', 0, 'path'], expectRequiredFieldMissing),
  (['definitions', 0, 'path', 0], expectOptionalFieldMissing),
  (
    ['definitions', 0, 'path', 0, 'name'],
    expectRequiredFieldMissing,
  ),
  (
    ['definitions', 0, 'path', 0, 'kind'],
    expectOptionalFieldMissing,
  ),
  (
    [
      'definitions',
      0,
      'path',
      0,
      'disambiguators',
    ],
    expectOptionalFieldMissing,
  ),
  (['loading_units'], expectOptionalFieldMissing),
  (['loading_units', 0, 'name'], expectRequiredFieldMissing),
  (['uses'], expectOptionalFieldMissing),
  (['uses', 'static_calls'], expectOptionalFieldMissing),
  (['uses', 'static_calls', 0, 'definition_index'], expectRequiredFieldMissing),

  (['uses', 'static_calls', 0, 'uses'], expectRequiredFieldMissing),
  (['uses', 'static_calls', 0, 'uses', 0, 'type'], expectRequiredFieldMissing),
  (
    ['uses', 'static_calls', 0, 'uses', 0, 'named'],
    expectOptionalFieldMissing,
  ),
  (
    ['uses', 'static_calls', 0, 'uses', 0, 'named', 'a'],
    expectOptionalFieldMissing,
  ),
  (
    ['uses', 'static_calls', 0, 'uses', 0, 'named', 'd'],
    expectOptionalFieldMissing,
  ),
  (
    ['uses', 'static_calls', 0, 'uses', 0, 'positional'],
    expectOptionalFieldMissing,
  ),
  (
    ['uses', 'static_calls', 0, 'uses', 0, 'positional', 0],
    expectOptionalFieldMissing,
  ),
  (
    ['uses', 'static_calls', 0, 'uses', 0, 'positional', 3],
    expectOptionalFieldMissing,
  ),
  (
    ['uses', 'static_calls', 0, 'uses', 0, 'loading_unit_indices'],
    expectRequiredFieldMissing,
  ),
  (['uses', 'instances'], expectOptionalFieldMissing),
  (['uses', 'instances', 0, 'uses'], expectRequiredFieldMissing),
  (
    ['uses', 'instances', 0, 'uses', 0, 'type'],
    expectRequiredFieldMissing,
  ),
  (
    ['uses', 'instances', 0, 'uses', 0, 'constant_index'],
    expectRequiredFieldMissing,
  ),
  (
    ['uses', 'instances', 0, 'uses', 0, 'loading_unit_indices'],
    expectRequiredFieldMissing,
  ),
];

List<SchemaTestField> constructorInvocationFields = [
  (
    ['uses', 'instances', 0, 'uses', 0, 'loading_unit_indices'],
    expectRequiredFieldMissing,
  ),
  (
    ['uses', 'instances', 0, 'uses', 0, 'type'],
    expectRequiredFieldMissing,
  ),
  (
    ['uses', 'instances', 0, 'uses', 0, 'positional'],
    expectOptionalFieldMissing,
  ),
  (
    ['uses', 'instances', 0, 'uses', 0, 'named', 'param'],
    expectOptionalFieldMissing,
  ),
  (
    ['uses', 'instances', 0, 'uses', 0, 'named', 'other'],
    expectOptionalFieldMissing,
  ),
];

void testAllTestData(
  AllTestData allTestData,
  Uri schemaUri,
  JsonSchema schema,
) {
  for (final entry in allTestData.entries) {
    final dataUri = entry.key;
    final dataString = entry.value;
    test('Validate $dataUri against $schemaUri', () {
      printOnFailure(dataUri.toString());
      printOnFailure(schemaUri.toString());
      final result = schema.validate(jsonDecode(dataString));
      for (final e in result.errors) {
        printOnFailure(e.toString());
      }
      expect(result.isValid, isTrue);
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

/// Test removing a field or modifying it.
///
/// Removing a field can be valid, the expectations must be passed in
/// [missingExpectations].
void testField({
  required Uri schemaUri,
  required Uri dataUri,
  required JsonSchema schema,
  required String data,
  required List<Object> field,
  required void Function(ValidationResults result) missingExpectations,
}) {
  final fieldPath = field.join('.');
  test('$schemaUri $dataUri $fieldPath missing', () {
    final dataDecoded = jsonDecode(data);
    final dataToModify = _traverseJson(
      dataDecoded,
      field.sublist(0, field.length - 1),
    );
    if (dataToModify is List) {
      final index = field.last as int;
      dataToModify.removeAt(index);
    } else {
      (dataToModify as Map).remove(field.last);
    }

    final result = schema.validate(dataDecoded);
    printOnFailure(result.toString());
    missingExpectations(result);
  });

  test('$schemaUri $fieldPath wrong type', () {
    final dataDecoded = jsonDecode(data);
    final dataToModify = _traverseJson(
      dataDecoded,
      field.sublist(0, field.length - 1),
    );
    final Object? originalValue;
    if (dataToModify is List) {
      originalValue = dataToModify[field.last as int];
    } else {
      originalValue = (dataToModify as Map)[field.last];
    }
    final wrongTypeValue = originalValue is int ? '123' : 123;
    if (originalValue == null) {
      // If the field allows null, it likely also allows int. So use a string
      // to ensure it's invalid.
      if (dataToModify is List) {
        dataToModify[field.last as int] = 'invalid';
      } else {
        (dataToModify as Map)[field.last] = 'invalid';
      }
    } else {
      if (dataToModify is List) {
        dataToModify[field.last as int] = wrongTypeValue;
      } else {
        (dataToModify as Map)[field.last] = wrongTypeValue;
      }
    }

    final result = schema.validate(dataDecoded);
    expect(result.isValid, isFalse);
  });
}

void expectRequiredFieldMissing(ValidationResults result) {
  expect(result.isValid, isFalse);
}

void expectOptionalFieldMissing(ValidationResults result) {
  expect(result.isValid, isTrue);
}

dynamic _traverseJson(dynamic json, List<Object> path) {
  while (path.isNotEmpty) {
    final key = path.removeAt(0);
    switch (key) {
      case final int i:
        json = (json as List)[i] as Object;
        break;
      case final String s:
        json = (json as Map)[s] as Object;
        break;
      default:
        throw UnsupportedError(key.toString());
    }
  }
  return json;
}
