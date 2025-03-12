// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: avoid_dynamic_calls

import 'dart:convert';
import 'dart:io';

import 'package:json_schema/json_schema.dart';
import 'package:test/test.dart';

/// Test files are run in a variety of ways, find this package root in all.
///
/// Test files can be run from source from any working directory. The Dart SDK
/// `tools/test.py` runs them from the root of the SDK for example.
///
/// Test files can be run from dill from the root of package. `package:test`
/// does this.
///
/// https://github.com/dart-lang/test/issues/110
Uri findPackageRoot(String packageName) {
  final script = Platform.script;
  final fileName = script.name;
  if (fileName.endsWith('.dart')) {
    // We're likely running from source.
    var directory = script.resolve('.');
    while (true) {
      final dirName = directory.name;
      if (dirName == packageName) {
        return directory;
      }
      final parent = directory.resolve('..');
      if (parent == directory) break;
      directory = parent;
    }
  } else if (fileName.endsWith('.dill')) {
    final cwd = Directory.current.uri;
    final dirName = cwd.name;
    if (dirName == packageName) {
      return cwd;
    }
  }
  throw StateError(
    "Could not find package root for package '$packageName'. "
    'Tried finding the package root via Platform.script '
    "'${Platform.script.toFilePath()}' and Directory.current "
    "'${Directory.current.uri.toFilePath()}'.",
  );
}

extension on Uri {
  String get name => pathSegments.where((e) => e != '').last;
}

typedef AllSchemas = Map<Uri, JsonSchema>;

/// The schemas are reused in tests, so load and parse them all.
AllSchemas loadSchemas(List<Uri> directories) {
  final allSchemaJsons = <Uri, Map<String, dynamic>>{};
  for (final dirUri in directories) {
    Directory.fromUri(dirUri).listSync(recursive: true).forEach((file) {
      if (file is File && file.path.endsWith('.schema.json')) {
        final json =
            jsonDecode(file.readAsStringSync()) as Map<String, Object?>;
        allSchemaJsons[file.uri] = json;
      }
    });
  }
  final allSchemas = <Uri, JsonSchema>{};
  for (final entry in allSchemaJsons.entries) {
    final schema = JsonSchema.create(
      entry.value,
      refProvider: RefProvider.sync((String originalRef) {
        if (originalRef.startsWith(
          'https://json-schema.org/draft/2020-12/schema#',
        )) {
          throw UnsupportedError('This is not supported in json_schema.');
        }
        // Unmangle refs
        var ref = originalRef;
        // https://github.com/Workiva/json_schema/issues/202
        if (ref.startsWith('/')) {
          ref = ref.substring(1);
        }
        if (ref.startsWith('hook/doc/schema/')) {
          ref = '../../../../$ref';
        } else if (ref.startsWith('shared/')) {
          ref = '../$ref';
        } else if (ref.startsWith('../../../hook/doc/schema/')) {
          ref = '../$ref';
        }
        final x = entry.key.resolve(ref);
        return allSchemaJsons[x]!;
      }),
    );
    allSchemas[entry.key] = schema;
  }
  return allSchemas;
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

/// Test all [allTestData] against the schemas referred to.
void testAllTestData(AllSchemas allSchemas, AllTestData allTestData) {
  for (final dataUri in allTestData.keys) {
    final data = jsonDecode(allTestData[dataUri]!);
    final schemaRef = data[r'$schema'] as String;

    final schemaRefs = [
      schemaRef,
      // The schema should have the most restrictive one, try the other one as
      // well.
      if (schemaRef.contains('sdk')) schemaRef.replaceAll('sdk', 'hook'),
      if (schemaRef.contains('hook')) schemaRef.replaceAll('hook', 'sdk'),
    ];

    for (final schemaRef in schemaRefs) {
      final schemaUri = dataUri.resolve(schemaRef);
      test('Validate $dataUri against $schemaUri', () {
        printOnFailure(dataUri.toString());
        printOnFailure(schemaUri.toString());
        final schema = allSchemas[schemaUri]!;
        final result = schema.validate(data);
        for (final e in result.errors) {
          printOnFailure(e.toString());
        }
        expect(result.isValid, isTrue);
      });
    }
  }
}

/// Test removing a field or modifying it.
///
/// Changing a field to a wrong type is always expected to fail.
///
/// Removing a field can be valid, the expectations must be passed in
/// [missingExpectations].
void testField({
  required Uri schemaUri,
  required JsonSchema schema,
  required String data,
  required List<Object> field,
  required void Function(ValidationResults result) missingExpectations,
}) {
  final fieldPath = field.join('.');
  test('$schemaUri $fieldPath missing', () {
    final dataDecoded = jsonDecode(data);
    final dataToModify = _traverseJson(
      dataDecoded,
      field.sublist(0, field.length - 1),
    );
    if (dataToModify is List) {
      final index = field.last as int;
      dataToModify.removeAt(index);
    } else {
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
    final originalValue = dataToModify[field.last];
    final wrongTypeValue = originalValue is int ? '123' : 123;
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

typedef FieldsReturn =
    List<(List<Object>, void Function(ValidationResults result))>;
typedef FieldsFunction =
    FieldsReturn Function({
      required InputOrOutput inputOrOutput,
      required Hook hook,
      required Party party,
    });

enum InputOrOutput { input, output }

enum Hook { build, link }

enum Party { sdk, hook }

void testFields({
  required AllSchemas allSchemas,
  required AllTestData allTestData,
  required Uri packageUri,
  String dataSuffix = '',
  required FieldsFunction fields,
}) {
  for (final hook in Hook.values) {
    for (final party in Party.values) {
      for (final inputOrOutput in InputOrOutput.values) {
        final fields_ = fields(
          hook: hook,
          inputOrOutput: inputOrOutput,
          party: party,
        );
        if (fields_.isEmpty) {
          continue;
        }

        final schemaName = '${hook.name}_${inputOrOutput.name}';
        final schemaUri = packageUri.resolve(
          'doc/schema/${party.name}/$schemaName.generated.schema.json',
        );
        final schema = allSchemas[schemaUri]!;
        final dataName = '${hook.name}_${inputOrOutput.name}$dataSuffix';
        final dataUri = packageUri.resolve('test/data/$dataName.json');
        final data = allTestData[dataUri]!;

        for (final (field, missingExpectations) in fields_) {
          testField(
            field: field,
            schemaUri: schemaUri,
            schema: schema,
            data: data,
            missingExpectations: missingExpectations,
          );
        }
      }
    }
  }
}

/// Test all base hook expectations against the hook schemas.
///
/// This has been put in a reusable location, to be able to run it on protocol
/// extensions.
void testFieldsHook({
  required AllSchemas allSchemas,
  required AllTestData allTestData,
  required Uri packageUri,
  String dataSuffix = '',
}) {
  testFields(
    allSchemas: allSchemas,
    allTestData: allTestData,
    packageUri: packageUri,
    dataSuffix: dataSuffix,
    fields: _hookFields,
  );
}

FieldsReturn _hookFields({
  required InputOrOutput inputOrOutput,
  required Hook hook,
  required Party party,
}) {
  void versionMissingExpectation(ValidationResults result) {
    if ((party == Party.sdk && inputOrOutput == InputOrOutput.input) ||
        (party == Party.hook && inputOrOutput == InputOrOutput.output)) {
      // The writer must output this field. SDK must support older hooks reading
      // it.
      expect(result.isValid, isFalse);
    } else {
      // Newer hooks must support future SDKs not outputting a this field.
      // TODO: Stop requiring version in the reader.
      // expect(result.isValid, isTrue);
      expect(result.isValid, isFalse);
    }
  }

  void outFileMissingExpectation(ValidationResults result) {
    if (party == Party.sdk) {
      // It's a new field, newer hooks will try to use it. SDKs must write it.
      expect(result.isValid, isFalse);
    } else {
      // Older SDKs don't output the field. So, the reader must be okay not
      // reading it.
      expect(result.isValid, isTrue);
    }
  }

  return <(List<Object>, void Function(ValidationResults result))>[
    ([r'$schema'], expectOptionalFieldMissing),
    (['version'], versionMissingExpectation),
    if (inputOrOutput == InputOrOutput.input) ...[
      (['out_dir_shared'], expectRequiredFieldMissing),
      (['out_dir'], expectRequiredFieldMissing),
      (['package_name'], expectRequiredFieldMissing),
      (['package_root'], expectRequiredFieldMissing),
      (['config', 'build_asset_types'], expectRequiredFieldMissing),
      if (hook == Hook.build) ...[
        (['config', 'linking_enabled'], expectRequiredFieldMissing),
        (['dependency_metadata'], expectOptionalFieldMissing),
        (['dependency_metadata', 'some_package'], expectOptionalFieldMissing),
      ],
      if (hook == Hook.link) ...[
        (['assets'], expectOptionalFieldMissing),
        (['assets', 0], expectOptionalFieldMissing),
        (['assets', 0, 'type'], expectRequiredFieldMissing),
      ],
      (['out_file'], outFileMissingExpectation),
    ],
    if (inputOrOutput == InputOrOutput.output) ...[
      (['timestamp'], expectRequiredFieldMissing),
      (['dependencies'], expectOptionalFieldMissing),
      (['dependencies', 0], expectOptionalFieldMissing),
      (['assets'], expectOptionalFieldMissing),
      (['assets', 0], expectOptionalFieldMissing),
      (['assets', 0, 'type'], expectRequiredFieldMissing),
      if (hook == Hook.build) ...[
        (['metadata'], expectOptionalFieldMissing),
        (['assetsForLinking'], expectOptionalFieldMissing),
        (
          ['assetsForLinking', 'package_with_linker', 0],
          expectOptionalFieldMissing,
        ),
        (['assetsForLinking'], expectOptionalFieldMissing),
        (
          ['assetsForLinking', 'package_with_linker', 0, 'type'],
          expectRequiredFieldMissing,
        ),
      ],
    ],
  ];
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
