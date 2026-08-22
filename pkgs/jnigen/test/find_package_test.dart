// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:jnigen/src/util/find_package.dart';
import 'package:test/test.dart';

void main() {
  test('findPackage and findPackageRoot in current directory', () async {
    final pkg = await findPackage('jnigen');
    expect(pkg, isNotNull);
    expect(pkg!.name, equals('jnigen'));

    final root = await findPackageRoot('jnigen');
    expect(root, isNotNull);
    expect(root!.toFilePath(), equals(pkg.root.toFilePath()));
  });

  test('findPackage and findPackageRoot for nonexistent package', () async {
    final pkg = await findPackage('non_existent_package_12345');
    expect(pkg, isNull);

    final root = await findPackageRoot('non_existent_package_12345');
    expect(root, isNull);
  });

  test(
      'findPackage falls back to Isolate.packageConfig when directory has no '
      'package_config', () async {
    final tempDir = Directory.systemTemp.createTempSync('find_package_test_');
    try {
      // In tempDir, findPackageConfig(tempDir) returns null.
      // However, findPackage should fall back to Isolate.packageConfig.
      final pkg = await findPackage('jnigen', tempDir);
      expect(pkg, isNotNull);
      expect(pkg!.name, equals('jnigen'));

      final root = await findPackageRoot('jnigen', tempDir);
      expect(root, isNotNull);
      expect(root!.toFilePath(), equals(pkg.root.toFilePath()));
    } finally {
      tempDir.deleteSync(recursive: true);
    }
  });
}
