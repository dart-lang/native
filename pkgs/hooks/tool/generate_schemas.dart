// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:native_test_helpers/native_test_helpers.dart';

import '../test/json_schema/helpers.dart';
import 'normalize.dart';

void main(List<String> args) {
  final stopwatch = Stopwatch()..start();
  final parser = ArgParser()
    ..addFlag(
      'set-exit-if-changed',
      negatable: false,
      help: 'Return a non-zero exit code if any files were changed.',
    );
  final argResults = parser.parse(args);
  final setExitIfChanged = argResults['set-exit-if-changed'] as bool;

  final counts = Counts();

  generateSharedDefinitions(counts);
  generateEntryPoints(counts);

  stopwatch.stop();
  final duration = stopwatch.elapsedMilliseconds / 1000.0;
  print(
    'Generated ${counts.generated} files (${counts.changed} changed) in '
    '${duration.toStringAsFixed(2)} seconds.',
  );
  if (setExitIfChanged && counts.changed > 0) {
    exit(1);
  }
}

class Counts {
  int generated = 0;
  int changed = 0;
}

Uri packageUri = findPackageRoot('hooks');

const jsonEncoder = JsonEncoder.withIndent('  ');

enum Party { hook, shared, sdk }

enum Hook { build, hook, link }

const packages = ['hooks', 'code_assets', 'data_assets'];

void generateSharedDefinitions(Counts counts) {
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
      'assets_for_linking': {
        'type': 'object',
        'additionalProperties': {
          'type': 'array',
          'items': {
            r'$ref': 'shared_definitions.schema.json#/definitions/Asset',
          },
        },
      },
      'assets_for_build': {
        'type': 'array',
        'items': {r'$ref': 'shared_definitions.schema.json#/definitions/Asset'},
      },
    },
  };
  const buildInputAssetOverride = {
    'properties': {
      'assets': {
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
              '../../../../hooks/doc/schema/shared/shared_definitions.schema.json#/definitions/Config',
        },
        {r'$ref': 'shared_definitions.schema.json#/definitions/Config'},
      ],
    },
  };

  for (final package in packages) {
    for (final party in Party.values) {
      if (package == 'hooks' && party == Party.shared) continue;
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
                  if (package != 'hooks')
                    {
                      r'$ref':
                          '../../../../hooks/doc/schema/${party.name}/shared_definitions${party == Party.shared ? '' : '.generated'}.schema.json#/definitions/${definitionName(hook, inputOrOutput)}',
                    },
                  if (party != Party.shared)
                    {
                      r'$ref':
                          '../shared/shared_definitions${package == 'hooks' ? '' : '.generated'}.schema.json#/definitions/${definitionName(hook, inputOrOutput)}',
                    },
                  if (package != 'data_assets' && party != Party.shared)
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
                      hook == Hook.build &&
                      inputOrOutput == InputOrOutput.input)
                    buildInputAssetOverride,
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
      var jsonString = jsonEncoder.convert(sortJson(contents, schemaUri.path));
      jsonString += '\n';
      final file = File.fromUri(schemaUri);

      var oldContent = '';
      if (file.existsSync()) {
        oldContent = file.readAsStringSync();
      }

      final newContentNormalized = jsonString.replaceAll('\r\n', '\n');
      final oldContentNormalized = oldContent.replaceAll('\r\n', '\n');
      if (newContentNormalized != oldContentNormalized) {
        file.writeAsStringSync(jsonString);
        print('Generated $schemaUri (content changed)');
        counts.changed++;
      }
      counts.generated++;
    }
  }
}

void generateEntryPoints(Counts counts) {
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

          var jsonString = jsonEncoder.convert(
            sortJson(contents, schemaUri.path),
          );
          jsonString += '\n';
          final file = File.fromUri(schemaUri);

          var oldContent = '';
          if (file.existsSync()) {
            oldContent = file.readAsStringSync();
          }

          final newContentNormalized = jsonString.replaceAll('\r\n', '\n');
          final oldContentNormalized = oldContent.replaceAll('\r\n', '\n');
          if (newContentNormalized != oldContentNormalized) {
            file.writeAsStringSync(jsonString);
            print('Generated $schemaUri (content changed)');
            counts.changed++;
          }
          counts.generated++;
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
