// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:native_assets_cli/native_assets_cli_internal.dart';
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

      final resultDynamic = await build(
        packageUri,
        logger,
        dartExecutable,
        linkModePreference: LinkModePreference.dynamic,
      );

      final resultPreferDynamic = await build(
        packageUri,
        logger,
        dartExecutable,
        linkModePreference: LinkModePreference.preferDynamic,
      );

      final resultStatic = await build(
        packageUri,
        logger,
        dartExecutable,
        linkModePreference: LinkModePreference.static,
      );

      final resultPreferStatic = await build(
        packageUri,
        logger,
        dartExecutable,
        linkModePreference: LinkModePreference.preferStatic,
      );

      // This package honors preferences.
      expect(resultDynamic.assets.single.linkMode, LinkMode.dynamic);
      expect(resultPreferDynamic.assets.single.linkMode, LinkMode.dynamic);
      expect(resultStatic.assets.single.linkMode, LinkMode.static);
      expect(resultPreferStatic.assets.single.linkMode, LinkMode.static);
    });
  });
}
