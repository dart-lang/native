// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:file/local.dart';
import 'package:native_assets_builder/native_assets_builder.dart';
import 'package:test/test.dart';

import '../helpers.dart';
import 'helpers.dart';

void main() async {
  test('fromWorkingDirectory', () async {
    await inTempDir((tempUri) async {
      await copyTestProjects(targetUri: tempUri);
      final nativeAddUri = tempUri.resolve('native_add/');

      // First, run `pub get`, we need pub to resolve our dependencies.
      await runPubGet(workingDirectory: nativeAddUri, logger: logger);

      const fileSystem = LocalFileSystem();
      final packageLayout = await PackageLayout.fromWorkingDirectory(
        fileSystem,
        nativeAddUri,
        'native_add',
      );
      final packageLayout2 = PackageLayout.fromPackageConfig(
        fileSystem,
        packageLayout.packageConfig,
        packageLayout.packageConfigUri,
        'native_add',
      );
      expect(packageLayout.packageConfigUri, packageLayout2.packageConfigUri);
    });
  });
}
