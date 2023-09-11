// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:native_assets_builder/native_assets_builder.dart';
import 'package:test/test.dart';

import '../helpers.dart';
import 'helpers.dart';

void main() async {
  test('fromRootPackageRoot', () async {
    await inTempDir((tempUri) async {
      await copyTestProjects(targetUri: tempUri);
      final nativeAddUri = tempUri.resolve('native_add/');

      // First, run `pub get`, we need pub to resolve our dependencies.
      await runPubGet(workingDirectory: nativeAddUri, logger: logger);

      final packageLayout =
          await PackageLayout.fromRootPackageRoot(nativeAddUri);
      final packageLayout2 = PackageLayout.fromPackageConfig(
        packageLayout.packageConfig,
        packageLayout.packageConfigUri,
      );
      expect(packageLayout.rootPackageRoot, packageLayout2.rootPackageRoot);
    });
  });
}
