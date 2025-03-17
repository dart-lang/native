// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import '../test/schema/helpers.dart';
import 'normalize.dart';

void main() {
  generateSharedDefinitions();
  generateEntryPoints();
}

Uri packageUri = findPackageRoot('hook');

const jsonEncoder = JsonEncoder.withIndent('  ');

enum Party { hook, shared, sdk }

enum Hook { build, hook, link }

const packages = ['hook', 'code_assets', 'data_assets'];

void generateSharedDefinitions() {
  const hookOutputAssetOverride = {
    'properties': {
      'assets': {
        'type': 'array',
        'items': {r'$ref': 'shared_definitions.schema.json#/definitions/Asset'},
      },
    },
  };
  const buildOutputAssetOverride = {
    'properties': {
      'assetsForLinking': {
        'type': 'object',
        'additionalProperties': {
          'type': 'array',
          'items': {
            r'$ref': 'shared_definitions.schema.json#/definitions/Asset',
          },
        },
      },
    },
  };
  const linkInputAssetOverride = {
    'properties': {
      'assets': {
        'type': 'array',
        'items': {r'$ref': 'shared_definitions.schema.json#/definitions/Asset'},
      },
    },
  };
  const hookInputCodeOverride = {
    'properties': {
      'config': {r'$ref': 'shared_definitions.schema.json#/definitions/Config'},
    },
  };
  const configOverride = {
    'Config': {
      'allOf': [
        {
          r'$ref':
              '../../../../hook/doc/schema/shared/shared_definitions.schema.json#/definitions/Config',
        },
        {r'$ref': 'shared_definitions.schema.json#/definitions/Config'},
      ],
    },
  };

  for (final package in packages) {
    for (final party in Party.values) {
      if (package == 'hook' && party == Party.shared) continue;
      final schemaUri = packageUri.resolve(
        '../$package/doc/schema/${party.name}/'
        'shared_definitions.generated.schema.json',
      );
      final contents = {
        r'$schema': 'https://json-schema.org/draft-07/schema#',
        r'$comment':
            'This schema was automatically generated. '
            'It combines various definitions into new definitions.',
        'title':
            'package:$package party:${party.name} shared definitions generated',
        'definitions': {
          for (final hook in Hook.values)
            for (final inputOrOutput in InputOrOutput.values) ...{
              definitionName(hook, inputOrOutput): {
                'allOf': [
                  // Include all definitions that together make this definition.
                  if (hook != Hook.hook)
                    {
                      r'$ref':
                          '#/definitions/${definitionName(Hook.hook, inputOrOutput)}',
                    },
                  if (package != 'hook')
                    {
                      r'$ref':
                          '../../../../hook/doc/schema/${party.name}/shared_definitions${party == Party.shared ? '' : '.generated'}.schema.json#/definitions/${definitionName(hook, inputOrOutput)}',
                    },
                  if (party != Party.shared)
                    {
                      r'$ref':
                          '../shared/shared_definitions${package == 'hook' ? '' : '.generated'}.schema.json#/definitions/${definitionName(hook, inputOrOutput)}',
                    },
                  if (package == 'hook' && party != Party.shared)
                    {
                      r'$ref':
                          'shared_definitions.schema.json#/definitions/${definitionName(hook, inputOrOutput)}',
                    },
                  // Redefine definitions if nested properties are overwritten.
                  if (party == Party.shared &&
                      hook == Hook.build &&
                      inputOrOutput == InputOrOutput.output)
                    buildOutputAssetOverride,
                  if (party == Party.shared &&
                      hook == Hook.hook &&
                      inputOrOutput == InputOrOutput.output)
                    hookOutputAssetOverride,
                  if (party == Party.shared &&
                      hook == Hook.link &&
                      inputOrOutput == InputOrOutput.input)
                    linkInputAssetOverride,
                  if (party == Party.shared &&
                      hook == Hook.hook &&
                      inputOrOutput == InputOrOutput.input &&
                      package == 'code_assets')
                    hookInputCodeOverride,
                ],
              },
              if (package == 'code_assets' &&
                  party == Party.shared &&
                  hook == Hook.hook &&
                  inputOrOutput == InputOrOutput.output)
                ...configOverride,
            },
        },
      };
      final jsonString = jsonEncoder.convert(
        sortJson(contents, schemaUri.path),
      );
      File.fromUri(schemaUri).writeAsStringSync('$jsonString\n');
      print('Generated: $schemaUri');
    }
  }
}

void generateEntryPoints() {
  for (final package in packages) {
    for (final hook in Hook.values) {
      if (hook == Hook.hook) continue;
      for (final party in Party.values) {
        if (party == Party.shared) continue;
        for (final inputOrOutput in InputOrOutput.values) {
          final schemaUri = packageUri.resolve(
            '../$package/doc/schema/${party.name}/'
            '${hook.name}_${inputOrOutput.name}.generated.schema.json',
          );
          final name = definitionName(hook, inputOrOutput);
          final contents = {
            r'$schema': 'https://json-schema.org/draft-07/schema#',
            r'$comment':
                'This schema was automatically generated. '
                'It is the schema for a json file in the build/link hook protocol.',
            'title': 'package:$package party:${party.name} $name',
            'allOf': [
              {
                r'$ref':
                    'shared_definitions.generated.schema.json#/definitions/$name',
              },
            ],
          };
          final jsonString = jsonEncoder.convert(contents);
          File.fromUri(schemaUri).writeAsStringSync('$jsonString\n');
          print('Generated: $schemaUri');
        }
      }
    }
  }
}

String definitionName(Hook hook, InputOrOutput inputOrOutput) =>
    '${ucFirst(hook.name)}${ucFirst(inputOrOutput.name)}';

String ucFirst(String str) {
  if (str.isEmpty) {
    return '';
  }
  return str[0].toUpperCase() + str.substring(1);
}
