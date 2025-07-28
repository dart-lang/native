// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:pub_formats/pubspec_formats.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  test('package graph', () {
    final json = loadJson('test_data/package_graph_1.json');
    final parsed = PackageGraphFileSyntax.fromJson(json);
    final errors = parsed.validate();
    expect(errors, isEmpty);
    expect(
      parsed.roots,
      equals(["add_asset_link", "app_with_asset_treeshaking"]),
    );
    final somePackage = parsed.packages.firstWhere(
      (e) => e.name == 'code_assets',
    );
    expect(somePackage.name, equals('code_assets'));
    expect(somePackage.dependencies, contains('hooks'));
    expect(somePackage.devDependencies, isNotEmpty);
  });
}
