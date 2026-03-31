// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:test/test.dart';

String _pubspecVersion(String path) {
  final v = RegExp(r'version: (.*)')
      .firstMatch(File(path).readAsStringSync())!
      .group(1)!;
  return v.endsWith('-wip') ? v.substring(0, v.length - '-wip'.length) : v;
}

String _dartGeneratorVersion(String varName) {
  return RegExp("const String $varName = '(.*)';")
      .firstMatch(
          File('lib/src/bindings/dart_generator.dart').readAsStringSync())!
      .group(1)!;
}

void main() {
  test('JNIgen version in pubspec.yaml and dart_generator.dart match', () {
    final pubspecVersion = _pubspecVersion('pubspec.yaml');
    final dartGeneratorVersion = _dartGeneratorVersion('version');
    expect(pubspecVersion, dartGeneratorVersion);
  });

  test('JNI versions in pubspec.yaml and dart_generator.dart match', () {
    final pubspecVersion = _pubspecVersion('../jni/pubspec.yaml');
    final pubspecVersionNoPatch =
        pubspecVersion.substring(0, pubspecVersion.lastIndexOf('.'));
    final dartGeneratorMajorVersion = _dartGeneratorVersion('jniMajorVersion');
    final dartGeneratorMinorVersion = _dartGeneratorVersion('jniMinorVersion');
    expect(pubspecVersionNoPatch,
        '$dartGeneratorMajorVersion.$dartGeneratorMinorVersion');
  });
}
