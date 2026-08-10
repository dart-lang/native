// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:test/test.dart';

String _pubspecVersion(String path) {
  final v = RegExp(
    r'version: (.*)',
  ).firstMatch(File(path).readAsStringSync())!.group(1)!;
  return v.endsWith('-wip') ? v.substring(0, v.length - '-wip'.length) : v;
}

String _importsVersion(String varName) {
  return RegExp('const $varName = (\\d+);')
      .firstMatch(
        File('lib/src/code_generator/imports.dart').readAsStringSync(),
      )!
      .group(1)!;
}

void main() {
  test('Objective-C versions in pubspec.yaml and imports.dart match', () {
    final pubspecVersion = _pubspecVersion('../objective_c/pubspec.yaml');
    final pubspecVersionNoPatch = pubspecVersion.substring(
      0,
      pubspecVersion.lastIndexOf('.'),
    );
    final importsMajorVersion = _importsVersion('objcMajorVersion');
    final importsMinorVersion = _importsVersion('objcMinorVersion');
    expect(pubspecVersionNoPatch, '$importsMajorVersion.$importsMinorVersion');
  });
}
