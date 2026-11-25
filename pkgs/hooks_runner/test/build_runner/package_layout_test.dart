// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: experimental_member_use

import 'package:file/local.dart';
import 'package:file/memory.dart';
import 'package:hooks_runner/hooks_runner.dart';
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
        includeDevDependencies: false,
      );
      final packageLayout2 = PackageLayout.fromPackageConfig(
        fileSystem,
        packageLayout.packageConfig,
        packageLayout.packageConfigUri,
        'native_add',
        includeDevDependencies: false,
      );
      expect(packageLayout.packageConfigUri, packageLayout2.packageConfigUri);
    });
  });

  test(
    'forDoctorFromWorkingDirectory returns null when not in a project',
    () async {
      final fileSystem = MemoryFileSystem.test();
      final dir = fileSystem.directory('/some/empty/dir')
        ..createSync(recursive: true);

      expect(
        await PackageLayout.forDoctorFromWorkingDirectory(fileSystem, dir.uri),
        isNull,
      );

      // A stray package_config.json without a sibling package_graph.json should
      // also return null.
      final dotDartTool = fileSystem.directory('/some/.dart_tool')
        ..createSync(recursive: true);
      dotDartTool
          .childFile('package_config.json')
          .writeAsStringSync('{"configVersion": 2, "packages": []}');
      expect(
        await PackageLayout.forDoctorFromWorkingDirectory(fileSystem, dir.uri),
        isNull,
      );

      // Once package_graph.json is present as well, it returns a PackageLayout.
      dotDartTool
          .childFile('package_graph.json')
          .writeAsStringSync(
            '{"configVersion": 1, "packages": [], "roots": []}',
          );
      final layout = await PackageLayout.forDoctorFromWorkingDirectory(
        fileSystem,
        dir.uri,
      );
      expect(layout, isNotNull);
      expect(
        layout!.packageConfigUri,
        dotDartTool.childFile('package_config.json').uri,
      );
    },
  );

  test(
    'forDoctorFromWorkingDirectory returns null when not in a project',
    () async {
      final fileSystem = MemoryFileSystem.test();
      final dir = fileSystem.directory('/some/empty/dir')
        ..createSync(recursive: true);

      expect(
        await PackageLayout.forDoctorFromWorkingDirectory(fileSystem, dir.uri),
        isNull,
      );

      // A stray package_config.json without a sibling package_graph.json should
      // also return null.
      final dotDartTool = fileSystem.directory('/some/.dart_tool')
        ..createSync(recursive: true);
      dotDartTool
          .childFile('package_config.json')
          .writeAsStringSync('{"configVersion": 2, "packages": []}');
      expect(
        await PackageLayout.forDoctorFromWorkingDirectory(fileSystem, dir.uri),
        isNull,
      );

      // Once package_graph.json is present as well, it returns a PackageLayout.
      dotDartTool
          .childFile('package_graph.json')
          .writeAsStringSync(
            '{"configVersion": 1, "packages": [], "roots": []}',
          );
      final layout = await PackageLayout.forDoctorFromWorkingDirectory(
        fileSystem,
        dir.uri,
      );
      expect(layout, isNotNull);
      expect(
        layout!.packageConfigUri,
        dotDartTool.childFile('package_config.json').uri,
      );
    },
  );
}
