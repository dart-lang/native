// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: experimental_member_use

import 'dart:convert';
import 'dart:io';

import 'package:data_assets/data_assets.dart';
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
    final dataAssets = input.assets.data;
    print('Received assets: ${dataAssets.map((a) => a.id).join(', ')}.');

    final symbols = <String>{};

    // Tree-shake unused assets using calls
    for (final methodName in ['add', 'multiply']) {
      final calls = usages.constArgumentsFor(
        Definition(
          'package:${input.packageName}/src/${input.packageName}.dart',
          [const Name('MyMath'), Name(methodName)],
        ),
      );
      print('Checking calls to $methodName...');
      for (final call in calls) {
        if (call.positional case [
          IntConstant(value: final v0),
          IntConstant(value: final v1),
        ]) {
          print(
            'A call was made to "$methodName" with the arguments ($v0,$v1)',
          );
        }
        symbols.add(methodName);
      }
    }

    // Tree-shake unused assets using instances
    for (final className in ['Double', 'Square']) {
      final instances = usages.constantsOf(
        Definition(
          'package:${input.packageName}/src/${input.packageName}.dart',
          [Name(className)],
        ),
      );
      print('Checking instances of $className...');
      for (final instance in instances) {
        print('An instance of "$className" was found: $instance');
        // Map class name to asset symbol (lowercase)
        symbols.add(className.toLowerCase());
      }
    }

    final neededCodeAssets = [
      for (final asset in dataAssets)
        if (symbols.any(asset.id.endsWith)) asset,
    ];

    print('Keeping only ${neededCodeAssets.map((e) => e.id).join(', ')}.');
    output.assets.data.addAll(neededCodeAssets);

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
