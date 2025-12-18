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
}

List<(List<Object>, void Function(ValidationResults result))>
recordUseFields = [
  (['constants'], expectOptionalFieldMissing),
  for (var index = 0; index < 7; index++) ...[
    (['constants', index, 'type'], expectRequiredFieldMissing),
    if (index < 5) (['constants', index, 'value'], expectRequiredFieldMissing),
    // Note the value for 'Instance' is optional because an empty map is
    // omitted. Also, Null has no value field.
  ],
  (['locations'], expectOptionalFieldMissing),
  (['locations', 0, 'uri'], expectRequiredFieldMissing),
  (['locations', 0, 'line'], expectOptionalFieldMissing),
  (['locations', 0, 'column'], expectOptionalFieldMissing),
  (['recordings'], expectOptionalFieldMissing),
  (['recordings', 0, 'definition'], expectRequiredFieldMissing),
  (['recordings', 0, 'definition', 'identifier'], expectRequiredFieldMissing),
  (
    ['recordings', 0, 'definition', 'identifier', 'uri'],
    expectRequiredFieldMissing,
  ),
  // TODO(https://github.com/dart-lang/native/issues/1093): Potentially split
  // out the concept of a class definition (which should never have a scope),
  // and static method definition, which optionally have a scope. And the scope
  // is always an enclosing class.
  (
    ['recordings', 0, 'definition', 'identifier', 'scope'],
    expectOptionalFieldMissing,
  ),
  (
    ['recordings', 0, 'definition', 'identifier', 'name'],
    expectRequiredFieldMissing,
  ),
  // TODO: Why is this optional in the package test data?
  (['recordings', 0, 'definition', 'loading_unit'], expectOptionalFieldMissing),

  // TODO(https://github.com/dart-lang/native/issues/1093): Whether calls or
  // instances is required depends on whether the definition is a class or
  // method. This should be cleaned up.
  (['recordings', 0, 'calls'], expectOptionalFieldMissing),
  (['recordings', 0, 'calls', 0, 'type'], expectRequiredFieldMissing),
  (['recordings', 0, 'calls', 0, 'named'], expectOptionalFieldMissing),
  (['recordings', 0, 'calls', 0, 'named', 'a'], expectOptionalFieldMissing),
  (['recordings', 0, 'calls', 0, 'positional'], expectOptionalFieldMissing),
  (['recordings', 0, 'calls', 0, 'positional', 0], expectOptionalFieldMissing),
  (['recordings', 0, 'calls', 0, 'loading_unit'], expectRequiredFieldMissing),
  (['recordings', 0, 'calls', 0, '@'], expectOptionalFieldMissing),
  (['recordings', 1, 'instances'], expectOptionalFieldMissing),
  (
    ['recordings', 1, 'instances', 0, 'constant_index'],
    expectRequiredFieldMissing,
  ),
  (
    ['recordings', 1, 'instances', 0, 'loading_unit'],
    expectRequiredFieldMissing,
  ),
  (['recordings', 1, 'instances', 0, '@'], expectOptionalFieldMissing),

  // TODO: Locations are not always provided by dart2js for const values. So we
  // need to make it optional.
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
/// Changing a field to a wrong type is always expected to fail.
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
      // ignore: avoid_dynamic_calls
      dataToModify.remove(field.last);
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
    // ignore: avoid_dynamic_calls
    final originalValue = dataToModify[field.last];
    final wrongTypeValue = originalValue is int ? '123' : 123;
    // ignore: avoid_dynamic_calls
    dataToModify[field.last] = wrongTypeValue;

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
