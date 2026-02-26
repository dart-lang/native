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
      final calls =
          usages.calls[Definition(
            'package:${input.packageName}/src/${input.packageName}.dart',
            [
              const Name(kind: DefinitionKind.classKind, 'MyMath'),
              Name(methodName),
            ],
          )] ??
          const [];
      print('Checking calls to $methodName...');
      for (final call in calls) {
        switch (call) {
          case CallWithArguments(
            positionalArguments: [
              IntConstant(value: final v0),
              IntConstant(value: final v1),
            ],
          ):
            print(
              'A call was made to "$methodName" with the arguments ($v0,$v1)',
            );
          case _:
            throw UnsupportedError(
              'Cannot determine math operations for "$methodName".',
            );
        }
        symbols.add(methodName);
      }
    }

    const classNameToSymbol = {
      'Double': 'double',
      'Square': 'square',
    };

    // Tree-shake unused assets using instances
    for (final className in classNameToSymbol.keys) {
      final instances =
          usages.instances[Definition(
            'package:${input.packageName}/src/${input.packageName}.dart',
            [Name(kind: DefinitionKind.classKind, className)],
          )] ??
          const [];
      print('Checking instances of $className...');
      for (final instance in instances) {
        switch (instance) {
          case InstanceConstantReference(:final instanceConstant):
            print('An instance of "$className" was found: $instanceConstant');
            // Map class name to asset symbol
            symbols.add(classNameToSymbol[className]!);
          case _:
            throw UnsupportedError(
              'Cannot determine math classes for "$className".',
            );
        }
      }
    }

    final neededCodeAssets = [
      for (final asset in dataAssets)
        if (symbols.any(asset.id.endsWith)) asset,
    ];

    print('Keeping only ${neededCodeAssets.map((e) => e.id).join(', ')}.');
    output.assets.data.addAll(neededCodeAssets);
  });
}

Future<Recordings> recordedUsages(Uri recordedUsagesFile) async {
  final file = File.fromUri(recordedUsagesFile);
  final string = await file.readAsString();
  final usages = Recordings.fromJson(
    jsonDecode(string) as Map<String, Object?>,
  );
  return usages;
}
