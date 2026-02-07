// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: experimental_member_use

import 'dart:convert';
import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:record_use/record_use.dart';

void main(List<String> arguments) async {
  await link(arguments, (input, output) async {
    final recordedUsagesFile = input.recordedUsagesFile;
    if (recordedUsagesFile == null) {
      throw ArgumentError(
        'Enable the --enable-experiment=record-use experiment'
        ' to use this app.',
      );
    }
    final usages = await recordedUsages(recordedUsagesFile);
    final codeAssets = input.assets.code;
    print('Received assets: ${codeAssets.map((a) => a.id).join(', ')}.');

    final symbols = <String>{};
    final argumentsFile = await File.fromUri(
      input.outputDirectory.resolve('arguments.txt'),
    ).create();

    final dataLines = <String>[];
    // Tree-shake unused assets using calls
    for (final methodName in ['add', 'multiply']) {
      final calls = usages.constArgumentsFor(
        Identifier(
          importUri:
              'package:drop_dylib_recording/src/drop_dylib_recording.dart',
          scope: 'MyMath',
          name: methodName,
        ),
      );
      for (final call in calls) {
        if (call.positional case [
          IntConstant(value: final v0),
          IntConstant(value: final v1),
        ]) {
          dataLines.add(
            'A call was made to "$methodName" with the arguments ($v0,$v1)',
          );
        }
        symbols.add(methodName);
      }
    }

    argumentsFile.writeAsStringSync(dataLines.join('\n'));

    // Tree-shake unused assets using instances
    for (final className in ['Double', 'Square']) {
      final instances = usages.constantsOf(
        Identifier(
          importUri:
              'package:drop_dylib_recording/src/drop_dylib_recording.dart',
          name: className,
        ),
      );
      for (final instance in instances) {
        print('An instance of "$className" was found: $instance');
        if (className == 'Double') {
          symbols.add('add');
        } else if (className == 'Square') {
          symbols.add('multiply');
        }
      }
    }

    final neededCodeAssets = [
      for (final codeAsset in codeAssets)
        if (symbols.any(codeAsset.id.endsWith)) codeAsset,
    ];

    print('Keeping only ${neededCodeAssets.map((e) => e.id).join(', ')}.');
    output.assets.code.addAll(neededCodeAssets);

    output.dependencies.add(recordedUsagesFile);
  });
}

Future<RecordedUsages> recordedUsages(Uri recordedUsagesFile) async {
  final file = File.fromUri(recordedUsagesFile);
  final string = await file.readAsString();
  final usages = RecordedUsages.fromJson(
    jsonDecode(string) as Map<String, Object?>,
  );
  return usages;
}
