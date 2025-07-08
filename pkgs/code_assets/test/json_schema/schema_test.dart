// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: avoid_dynamic_calls

import 'dart:convert';

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

Uri packageUri = findPackageRoot('code_assets');

const _codeConfigPath = ['config', 'extensions', 'code_assets'];

FieldsFunction _codeFields(AllTestData allTestData) {
  final dataUri = packageUri.resolve('test/data/build_output_macos.json');
  final assets =
      ((jsonDecode(allTestData[dataUri]!) as Map<String, Object?>)['assets']
              as List)
          .cast<Map<String, dynamic>>();
  late int dynamicLoadingBundledIndex, dynamicLoadingSystemIndex, staticIndex;
  for (var i = 0; i < assets.length; i++) {
    final asset = assets[i];
    switch (asset['encoding']['link_mode']['type']) {
      case 'dynamic_loading_bundle':
        dynamicLoadingBundledIndex = i;
      case 'dynamic_loading_system':
        dynamicLoadingSystemIndex = i;
      case 'static':
        staticIndex = i;
    }
  }

  List<(List<Object>, void Function(ValidationResults result))> codeFields({
    required InputOrOutput inputOrOutput,
    required Hook hook,
    required Party party,
  }) {
    // (expectFunction, path)
    const codeAssetFields =
        <(List<Object>, void Function(ValidationResults result))>[
          (['id'], expectRequiredFieldMissing),
          (['link_mode'], expectRequiredFieldMissing),
          (['link_mode', 'type'], expectRequiredFieldMissing),
        ];

    return <(List<Object>, void Function(ValidationResults result))>[
      if (inputOrOutput == InputOrOutput.input) ...[
        ([..._codeConfigPath, 'c_compiler'], expectOptionalFieldMissing),
        ([..._codeConfigPath, 'c_compiler', 'ar'], expectRequiredFieldMissing),
        ([..._codeConfigPath, 'c_compiler', 'cc'], expectRequiredFieldMissing),
        ([..._codeConfigPath, 'c_compiler', 'ld'], expectRequiredFieldMissing),
        ([..._codeConfigPath, 'macos'], expectRequiredFieldMissing),
        (
          [..._codeConfigPath, 'macos', 'target_version'],
          expectRequiredFieldMissing,
        ),
        if (hook == Hook.link) ...[
          for (final (field, expect) in codeAssetFields) ...[
            (['assets', 0, 'encoding', ...field], expect),
            (['assets', 1, 'encoding', ...field], expect),
          ],
        ],
      ],
      if (inputOrOutput == InputOrOutput.output) ...[
        for (final (field, expect) in codeAssetFields)
          (['assets', 0, 'encoding', ...field], expect),
        if (hook == Hook.build) ...[
          for (final (field, expect) in codeAssetFields)
            for (final path in [
              ['assets_for_build'],
              ['assets_for_linking', 'package_with_linker'],
            ])
              ([...path, 0, 'encoding', ...field], expect),
        ],
        (
          ['assets', staticIndex, 'encoding', 'file'],
          expectRequiredFieldMissing,
        ),
        (
          ['assets', dynamicLoadingBundledIndex, 'encoding', 'file'],
          expectRequiredFieldMissing,
        ),
        (
          ['assets', dynamicLoadingSystemIndex, 'encoding', 'link_mode', 'uri'],
          expectRequiredFieldMissing,
        ),
      ],
    ];
  }

  return codeFields;
}

List<(List<Object>, void Function(ValidationResults result))>
_codeFieldsWindows({
  required InputOrOutput inputOrOutput,
  required Hook hook,
  required Party party,
}) => <(List<Object>, void Function(ValidationResults result))>[
  if (inputOrOutput == InputOrOutput.input && hook == Hook.build) ...[
    ([..._codeConfigPath, 'c_compiler', 'windows'], expectRequiredFieldMissing),
    (
      [..._codeConfigPath, 'c_compiler', 'windows', 'developer_command_prompt'],
      expectOptionalFieldMissing,
    ),
    (
      [
        'config',
        'extensions',
        'code_assets',
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
        'extensions',
        'code_assets',
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
  required InputOrOutput inputOrOutput,
  required Hook hook,
  required Party party,
}) => <(List<Object>, void Function(ValidationResults result))>[
  if (inputOrOutput == InputOrOutput.input && hook == Hook.build) ...[
    ([..._codeConfigPath, 'ios'], expectRequiredFieldMissing),
    ([..._codeConfigPath, 'ios', 'target_sdk'], expectRequiredFieldMissing),
    ([..._codeConfigPath, 'ios', 'target_version'], expectRequiredFieldMissing),
  ],
];

List<(List<Object>, void Function(ValidationResults result))>
_codeFieldsAndroid({
  required InputOrOutput inputOrOutput,
  required Hook hook,
  required Party party,
}) => <(List<Object>, void Function(ValidationResults result))>[
  if (inputOrOutput == InputOrOutput.input && hook == Hook.build) ...[
    ([..._codeConfigPath, 'android'], expectRequiredFieldMissing),
    (
      [..._codeConfigPath, 'android', 'target_ndk_api'],
      expectRequiredFieldMissing,
    ),
  ],
];
