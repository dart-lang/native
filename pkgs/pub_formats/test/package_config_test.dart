// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:pub_formats/pubspec_formats.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  test('package config', () {
    final json = loadJson('test_data/package_config_1.json');
    final parsed = PackageConfigFileSyntax.fromJson(json);
    final errors = parsed.validate();
    expect(errors, isEmpty);
    expect(parsed.configVersion, equals(2));
    expect(parsed.packages, isNotEmpty);
    expect(parsed.packages.first.name, equals('analyzer'));
    expect(
      parsed.packages.first.rootUri,
      equals(
        'file:///Users/some_user/.pub-cache/hosted/pub.dev/analyzer-7.4.5',
      ),
    );
    expect(parsed.packages.first.languageVersion, equals('3.5'));
    expect(parsed.generator, equals('pub'));
    expect(parsed.pubCache, 'file:///Users/some_user/.pub-cache');
    expect(
      parsed.flutterRoot,
      equals('file:///Users/some_user/src/flutter/flutter'),
    );
    expect(parsed.flutterVersion, equals('3.33.0-1.0.pre-1146'));
  });
}
