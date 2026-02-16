// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: experimental_member_use
// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'dart:io';

import 'package:hooks/hooks.dart';
import 'package:record_use/record_use_internal.dart';

const methodId = Definition(
  'package:pirate_speak/pirate_speak.dart',
  [
    Name('PirateTranslator'),
    Name(''),
  ],
);

const classId = Definition(
  'package:pirate_technology/pirate_technology.dart',
  [
    Name(
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
    final uses = RecordedUsages.fromJson(
      jsonDecode(usesJson) as Map<String, Object?>,
    );

    // snippet-start#static-call
    final args = uses.constArgumentsFor(methodId);
    for (final arg in args) {
      if (arg.positional[0] case StringConstant(value: final english)) {
        print('Translating to pirate: $english');
        // Shrink a translations file based on all the different translation
        // keys.
      }
    }
    // snippet-end#static-call

    // snippet-start#const-instance
    final ships = uses.constantsOf(classId);
    for (final ship in ships) {
      if (ship.fields['name'] case StringConstant(value: final name)) {
        print('Pirate ship found: $name');
        // Include the 3d model for this ship in the application but not
        // bundle the other ships.
      }
    }
    // snippet-end#const-instance
  });
}

// snippet-end#link
