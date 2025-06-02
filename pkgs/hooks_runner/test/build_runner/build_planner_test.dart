// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:file/local.dart';
import 'package:hooks_runner/hooks_runner.dart';
import 'package:hooks_runner/src/build_runner/build_planner.dart';
import 'package:test/test.dart';

import '../helpers.dart';
import 'helpers.dart';

void main() async {
  test('build dependency graph fromPackageRoot', () async {
    await inTempDir((tempUri) async {
      await copyTestProjects(targetUri: tempUri);
      final nativeAddUri = tempUri.resolve('native_add/');

      // First, run `pub get`, we need pub to resolve our dependencies.
      await runPubGet(workingDirectory: nativeAddUri, logger: logger);

      final packageLayout = await PackageLayout.fromWorkingDirectory(
        const LocalFileSystem(),
        nativeAddUri,
        'native_add',
        false,
      );
      final nativeAssetsBuildPlanner =
          await NativeAssetsBuildPlanner.fromPackageConfigUri(
            packageConfigUri: nativeAddUri.resolve(
              '.dart_tool/package_config.json',
            ),
            dartExecutable: Uri.file(Platform.resolvedExecutable),
            logger: logger,
            packageLayout: packageLayout,
            fileSystem: const LocalFileSystem(),
          );
      final packagesWithHook = await nativeAssetsBuildPlanner.packagesWithHook(
        Hook.build,
      );
      expect(packagesWithHook.length, 1);
      final buildPlan = await nativeAssetsBuildPlanner.makeBuildHookPlan();
      expect(buildPlan.success.length, 1);
      expect(buildPlan.success.single.name, 'native_add');
    });
  });

  for (final existing in [true, false]) {
    final runPackageName = existing ? 'ffigen' : 'does_not_exist';
    test('runPackageName $runPackageName', () async {
      await inTempDir((tempUri) async {
        await copyTestProjects(targetUri: tempUri);
        final nativeAddUri = tempUri.resolve('native_add/');

        // First, run `pub get`, we need pub to resolve our dependencies.
        await runPubGet(workingDirectory: nativeAddUri, logger: logger);

        final packageLayout = await PackageLayout.fromWorkingDirectory(
          const LocalFileSystem(),
          nativeAddUri,
          runPackageName,
          false,
        );
        final nativeAssetsBuildPlanner =
            await NativeAssetsBuildPlanner.fromPackageConfigUri(
              packageConfigUri: nativeAddUri.resolve(
                '.dart_tool/package_config.json',
              ),
              dartExecutable: Uri.file(Platform.resolvedExecutable),
              logger: logger,
              packageLayout: packageLayout,
              fileSystem: const LocalFileSystem(),
            );
        final buildPlan = await nativeAssetsBuildPlanner.makeBuildHookPlan();
        expect(buildPlan.success.length, 0);
      });
    });
  }

  for (final includeDevDependencies in [true, false]) {
    test('includeDevDependencies $includeDevDependencies', () async {
      const runPackageName = 'dev_dependency_with_hook';
      await inTempDir((tempUri) async {
        await copyTestProjects(targetUri: tempUri);
        final nativeAddUri = tempUri.resolve('$runPackageName/');

        // First, run `pub get`, we need pub to resolve our dependencies.
        await runPubGet(workingDirectory: nativeAddUri, logger: logger);

        final packageLayout = await PackageLayout.fromWorkingDirectory(
          const LocalFileSystem(),
          nativeAddUri,
          runPackageName,
          includeDevDependencies,
        );
        final nativeAssetsBuildPlanner =
            await NativeAssetsBuildPlanner.fromPackageConfigUri(
              packageConfigUri: nativeAddUri.resolve(
                '.dart_tool/package_config.json',
              ),
              dartExecutable: Uri.file(Platform.resolvedExecutable),
              logger: logger,
              packageLayout: packageLayout,
              fileSystem: const LocalFileSystem(),
            );
        final buildPlan = await nativeAssetsBuildPlanner.makeBuildHookPlan();
        expect(buildPlan.success.length, includeDevDependencies ? 1 : 0);
      });
    });
  }
}
