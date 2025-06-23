// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('Versions in pubspec.yaml and dart_generator.dart match', () {
    final pubspecVersion = RegExp(r'version: (.*)')
        .firstMatch(File('pubspec.yaml').readAsStringSync())!
        .group(1)!;
    final dartGeneratorVersion = RegExp(r"const String version = '(.*)';")
        .firstMatch(
            File('lib/src/bindings/dart_generator.dart').readAsStringSync())!
        .group(1)!;
    final pubspecVersionWithoutWip = pubspecVersion.endsWith('-wip')
        ? pubspecVersion.substring(0, pubspecVersion.length - '-wip'.length)
        : pubspecVersion;
    expect(pubspecVersionWithoutWip, dartGeneratorVersion);
  });
}
