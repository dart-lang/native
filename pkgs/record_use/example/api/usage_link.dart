// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: experimental_member_use
// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'dart:io';

import 'package:hooks/hooks.dart';
import 'package:record_use/record_use_internal.dart';

final methodId = Definition(
  'package:pirate_speak/pirate_speak.dart',
  [
    const Name(
      kind: DefinitionKind.classKind,
      'PirateTranslator',
    ),
    Name(
      kind: DefinitionKind.methodKind,
      'speak',
      disambiguators: {
        DefinitionDisambiguator.staticDisambiguator,
      },
    ),
  ],
);

const classId = Definition(
  'package:pirate_technology/pirate_technology.dart',
  [
    Name(
      kind: DefinitionKind.classKind,
      'PirateShip',
    ),
  ],
);

// snippet-start#link
void main(List<String> arguments) {
  link(arguments, (input, output) async {
    final usesUri = input.recordedUsagesFile;
    if (usesUri == null) return;
    final usesJson = await File.fromUri(usesUri).readAsString();
    final uses = Recordings.fromJson(
      jsonDecode(usesJson) as Map<String, Object?>,
    );

    // snippet-start#static-call
    final calls = uses.calls[methodId] ?? [];
    for (final call in calls) {
      switch (call) {
        case CallWithArguments(
          positionalArguments: [StringConstant(value: final english), ...],
        ):
          // Shrink a translations file based on all the different translation
          // keys.
          print('Translating to pirate: $english');
        case _:
          print('Cannot determine which translations are used.');
      }
    }
    // snippet-end#static-call

    // snippet-start#const-instance
    final ships = uses.instances[classId] ?? [];
    for (final ship in ships) {
      switch (ship) {
        case InstanceConstantReference(
          instanceConstant: InstanceConstant(
            fields: {'name': StringConstant(value: final name)},
          ),
        ):
          // Include the 3d model for this ship in the application but not
          // bundle the other ships.
          print('Pirate ship found: $name');
        case _:
          print('Cannot determine which ships are used.');
      }
    }
    // snippet-end#const-instance
  });
}

// snippet-end#link
