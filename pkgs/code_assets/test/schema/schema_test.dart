// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: avoid_dynamic_calls

import 'dart:convert';

import 'package:json_schema/json_schema.dart';

import 'helpers.dart';

void main() {
  final schemasUri = packageUri.resolve('doc/schema/');
  final hookSchemasUri = packageUri.resolve('../hook/doc/schema/');
  final allSchemas = loadSchemas([schemasUri, hookSchemasUri]);

  final testDataUri = packageUri.resolve('test/data/');
  final allTestData = loadTestsData(testDataUri);

  testAllTestData(allSchemas, allTestData);

  const dataSuffix = '_macos';
  testFieldsHook(
    allSchemas: allSchemas,
    allTestData: allTestData,
    packageUri: packageUri,
    dataSuffix: dataSuffix,
  );

  testFields(
    allSchemas: allSchemas,
    allTestData: allTestData,
    packageUri: packageUri,
    dataSuffix: dataSuffix,
    fields: _codeFields(allTestData),
  );

  testFields(
    allSchemas: allSchemas,
    allTestData: allTestData,
    packageUri: packageUri,
    dataSuffix: '_windows',
    fields: _codeFieldsWindows,
  );

  testFields(
    allSchemas: allSchemas,
    allTestData: allTestData,
    packageUri: packageUri,
    dataSuffix: '_ios',
    fields: _codeFieldsIOS,
  );

  testFields(
    allSchemas: allSchemas,
    allTestData: allTestData,
    packageUri: packageUri,
    dataSuffix: '_android',
    fields: _codeFieldsAndroid,
  );
}

FieldsFunction _codeFields(AllTestData allTestData) {
  final dataUri = packageUri.resolve('test/data/build_output_macos.json');
  final assets =
      ((jsonDecode(allTestData[dataUri]!) as Map<String, Object?>)['assets']
              as List)
          .cast<Map<String, dynamic>>();
  late int dynamicLoadingBundledIndex, dynamicLoadingSystemIndex, staticIndex;
  for (var i = 0; i < assets.length; i++) {
    final asset = assets[i];
    switch (asset['link_mode']['type']) {
      case 'dynamic_loading_bundle':
        dynamicLoadingBundledIndex = i;
      case 'dynamic_loading_system':
        dynamicLoadingSystemIndex = i;
      case 'static':
        staticIndex = i;
    }
  }

  List<(List<Object>, void Function(ValidationResults result))> codeFields({
    required String inputOrOutput,
    required String hook,
    required String party,
  }) {
    const requiredCodeAssetFields = [
      // TODO(https://github.com/dart-lang/native/issues/2039): Make required.
      // ['architecture'],
      ['os'],
      ['id'],
      ['link_mode'],
      ['link_mode', 'type'],
    ];

    return <(List<Object>, void Function(ValidationResults result))>[
      if (inputOrOutput == 'input') ...[
        (['config', 'code', 'c_compiler'], expectOptionalFieldMissing),
        (['config', 'code', 'c_compiler', 'ar'], expectRequiredFieldMissing),
        (['config', 'code', 'c_compiler', 'cc'], expectRequiredFieldMissing),
        (['config', 'code', 'c_compiler', 'ld'], expectRequiredFieldMissing),
        (['config', 'code', 'macos'], expectRequiredFieldMissing),
        (
          ['config', 'code', 'macos', 'target_version'],
          // TODO(https://github.com/dart-lang/native/issues/2039): Make required.
          expectOptionalFieldMissing,
        ),
        if (hook == 'link') ...[
          for (final field in requiredCodeAssetFields)
            (['assets', 0, ...field], expectRequiredFieldMissing),
          // TODO(https://github.com/dart-lang/native/issues/2039): Make required.
          (['assets', 0, 'architecture'], expectOptionalFieldMissing),
        ],
      ],
      if (inputOrOutput == 'output') ...[
        for (final field in requiredCodeAssetFields)
          (['assets', 0, ...field], expectRequiredFieldMissing),
        // TODO(https://github.com/dart-lang/native/issues/2039): Make required.
        (['assets', 0, 'architecture'], expectOptionalFieldMissing),
        if (hook == 'build') ...[
          for (final field in requiredCodeAssetFields)
            (
              ['assetsForLinking', 'package_with_linker', 0, ...field],
              expectRequiredFieldMissing,
            ),
          // TODO(https://github.com/dart-lang/native/issues/2039): Make required.
          (
            ['assetsForLinking', 'package_with_linker', 0, 'architecture'],
            expectOptionalFieldMissing,
          ),
        ],
        (['assets', staticIndex, 'file'], expectRequiredFieldMissing),
        (
          ['assets', dynamicLoadingBundledIndex, 'file'],
          expectRequiredFieldMissing,
        ),
        (
          ['assets', dynamicLoadingSystemIndex, 'link_mode', 'uri'],
          expectRequiredFieldMissing,
        ),
      ],
    ];
  }

  return codeFields;
}

List<(List<Object>, void Function(ValidationResults result))>
_codeFieldsWindows({
  required String inputOrOutput,
  required String hook,
  required String party,
}) => <(List<Object>, void Function(ValidationResults result))>[
  if (inputOrOutput == 'input' && hook == 'build') ...[
    (
      ['config', 'code', 'c_compiler', 'env_script'],
      expectOptionalFieldMissing,
    ),
    (
      ['config', 'code', 'c_compiler', 'env_script_arguments'],
      expectOptionalFieldMissing,
    ),
    (['config', 'code', 'c_compiler', 'windows'], expectRequiredFieldMissing),
    (
      ['config', 'code', 'c_compiler', 'windows', 'developer_command_prompt'],
      expectOptionalFieldMissing,
    ),
    (
      [
        'config',
        'code',
        'c_compiler',
        'windows',
        'developer_command_prompt',
        'script',
      ],
      expectRequiredFieldMissing,
    ),
    (
      [
        'config',
        'code',
        'c_compiler',
        'windows',
        'developer_command_prompt',
        'arguments',
      ],
      expectRequiredFieldMissing,
    ),
  ],
];

List<(List<Object>, void Function(ValidationResults result))> _codeFieldsIOS({
  required String inputOrOutput,
  required String hook,
  required String party,
}) => <(List<Object>, void Function(ValidationResults result))>[
  if (inputOrOutput == 'input' && hook == 'build') ...[
    (['config', 'code', 'ios'], expectRequiredFieldMissing),
    (
      ['config', 'code', 'ios', 'target_sdk'],
      // TODO(https://github.com/dart-lang/native/issues/2039): Make required.
      expectOptionalFieldMissing,
    ),
    (
      ['config', 'code', 'ios', 'target_version'],
      // TODO(https://github.com/dart-lang/native/issues/2039): Make required.
      expectOptionalFieldMissing,
    ),
  ],
];

List<(List<Object>, void Function(ValidationResults result))>
_codeFieldsAndroid({
  required String inputOrOutput,
  required String hook,
  required String party,
}) => <(List<Object>, void Function(ValidationResults result))>[
  if (inputOrOutput == 'input' && hook == 'build') ...[
    (['config', 'code', 'android'], expectRequiredFieldMissing),
    (
      ['config', 'code', 'android', 'target_ndk_api'],
      // TODO(https://github.com/dart-lang/native/issues/2039): Make required.
      expectOptionalFieldMissing,
    ),
  ],
];
