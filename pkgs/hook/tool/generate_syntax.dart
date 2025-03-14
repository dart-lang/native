// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: prefer_expression_function_bodies

import 'dart:io';

import 'package:json_syntax_generator/json_syntax_generator.dart';

import '../test/schema/helpers.dart';

const generateFor = ['hook', 'code_assets', 'data_assets'];

final rootSchemas = loadSchemas([
  packageUri.resolve('doc/schema/'),
  packageUri.resolve('../code_assets/doc/schema/'),
  packageUri.resolve('../data_assets/doc/schema/'),
]);

void main() {
  for (final packageName in generateFor) {
    const schemaName = 'shared';
    final schemaUri = packageUri.resolve(
      '../$packageName/doc/schema/$schemaName/shared_definitions.schema.json',
    );
    final schema = rootSchemas[schemaUri]!;
    final analyzedSchema =
        SchemaAnalyzer(
          schema,
          capitalizationOverrides: {
            'ios': 'iOS',
            'Ios': 'IOS',
            'macos': 'macOS',
            'Macos': 'MacOS',
          },
          publicSetters: [
            'BuildOutput',
            'Config',
            'HookInput',
            'HookOutput',
            'LinkOutput',
          ],
          classSorting:
              packageName == 'code_assets'
                  ? [
                    'AndroidCodeConfig',
                    'Architecture',
                    'Asset',
                    'NativeCodeAsset',
                    'CCompilerConfig',
                    'Windows',
                    'DeveloperCommandPrompt',
                    'CodeConfig',
                    'Config',
                    'IOSCodeConfig',
                    'LinkMode',
                    'DynamicLoadingBundleLinkMode',
                    'DynamicLoadingExecutableLinkMode',
                    'DynamicLoadingProcessLinkMode',
                    'DynamicLoadingSystemLinkMode',
                    'StaticLinkMode',
                    'LinkModePreference',
                    'MacOSCodeConfig',
                    'OS',
                  ]
                  : null,
        ).analyze();
    final output = SyntaxGenerator(analyzedSchema).generate();
    final outputUri = packageUri.resolve(
      '../native_assets_cli/lib/src/$packageName/syntax.g.dart',
    );
    File.fromUri(outputUri).writeAsStringSync(output);
    Process.runSync(Platform.executable, ['format', outputUri.toFilePath()]);
    print('Generated $outputUri');
  }
}

Uri packageUri = findPackageRoot('hook');
