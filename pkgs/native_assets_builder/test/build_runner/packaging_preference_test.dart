// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:native_assets_cli/native_assets_cli.dart';
import 'package:test/test.dart';

import '../helpers.dart';
import 'helpers.dart';

const Timeout longTimeout = Timeout(Duration(minutes: 5));

void main() async {
  test('link mode preference', timeout: longTimeout, () async {
    await inTempDir((tempUri) async {
      await copyTestProjects(targetUri: tempUri);
      final packageUri = tempUri.resolve('native_add/');

      // First, run `pub get`, we need pub to resolve our dependencies.
      await runPubGet(
        workingDirectory: packageUri,
        logger: logger,
      );

      final assetsDynamic = (await build(
        packageUri,
        logger,
        dartExecutable,
        linkModePreference: LinkModePreference.dynamic,
      ))
          .assets;

      final assetsPreferDynamic = (await build(
        packageUri,
        logger,
        dartExecutable,
        linkModePreference: LinkModePreference.preferDynamic,
      ))
          .assets;

      final assetsStatic = (await build(
        packageUri,
        logger,
        dartExecutable,
        linkModePreference: LinkModePreference.static,
      ))
          .assets;

      final assetsPreferStatic = (await build(
        packageUri,
        logger,
        dartExecutable,
        linkModePreference: LinkModePreference.preferStatic,
      ))
          .assets;

      // This package honors preferences.
      expect(assetsDynamic.single.linkMode, LinkMode.dynamic);
      expect(assetsPreferDynamic.single.linkMode, LinkMode.dynamic);
      expect(assetsStatic.single.linkMode, LinkMode.static);
      expect(assetsPreferStatic.single.linkMode, LinkMode.static);
    });
  });
}
