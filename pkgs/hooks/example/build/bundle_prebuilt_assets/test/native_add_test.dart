// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:bundle_prebuilt_assets/bundle_prebuilt_assets.dart';
import 'package:bundle_prebuilt_assets/src/hook_helpers/c_build.dart';
import 'package:code_assets/code_assets.dart';
import 'package:test/test.dart';

import '../hook/build.dart' as build_hook;
import '../tool/build.dart';

void main() {
  test('invoke native function', () {
    expect(add(24, 18), 42);
  });

  test(
    'build hook uses prebuilt asset from assets/ directory and pub publish includes it',
    () async {
      final prebuiltFile = await buildPrebuiltAsset(
        OS.current,
        Architecture.current,
        null,
      );
      final packageRoot = prebuiltFile.parent.parent;
      final tempDir = await Directory.systemTemp.createTemp(
        'bundle_prebuilt_assets_test_',
      );
      addTearDown(() async {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
        if (await prebuiltFile.exists()) {
          await prebuiltFile.delete();
        }
        final assetsDir = prebuiltFile.parent;
        if (await assetsDir.exists() && await assetsDir.list().isEmpty) {
          await assetsDir.delete();
        }
      });

      await testCodeBuildHook(
        mainMethod: build_hook.main,
        check: (input, output) {
          final fileName = targetFileName(
            OS.current,
            Architecture.current,
            null,
          );
          final expectedUri = input.packageRoot.resolve('assets/$fileName');
          expect(output.assets.code, hasLength(1));
          expect(output.assets.code.single.file, expectedUri);
          expect(output.dependencies, contains(expectedUri));
        },
      );

      // Copy the package to a standalone directory (outside the monorepo's
      // `pkgs/hooks/.pubignore` which ignores `example/*/*`) and verify
      // `dart pub publish --dry-run` bundles the prebuilt binary in `assets/`.
      await _copyDirectory(packageRoot, tempDir);
      final repoRoot = packageRoot.uri.resolve('../../../../../');
      final pubspecFile = File.fromUri(tempDir.uri.resolve('pubspec.yaml'));
      final pubspecContent = (await pubspecFile.readAsString())
          .replaceFirst('resolution: workspace', '')
          .replaceFirst('publish_to: none', '''
dependency_overrides:
  code_assets:
    path: ${repoRoot.resolve('pkgs/code_assets').toFilePath()}
  hooks:
    path: ${repoRoot.resolve('pkgs/hooks').toFilePath()}
  native_toolchain_c:
    path: ${repoRoot.resolve('pkgs/native_toolchain_c').toFilePath()}
  ffigen:
    path: ${repoRoot.resolve('pkgs/ffigen').toFilePath()}''');
      await pubspecFile.writeAsString(pubspecContent);

      final publishResult = await Process.run(Platform.resolvedExecutable, [
        'pub',
        'publish',
        '--dry-run',
      ], workingDirectory: tempDir.path);
      expect(
        publishResult.exitCode,
        0,
        reason: '${publishResult.stdout}\n${publishResult.stderr}',
      );
      final fileName = targetFileName(OS.current, Architecture.current, null);
      expect(publishResult.stdout as String, contains(fileName));
    },
  );
}

Future<void> _copyDirectory(Directory source, Directory destination) async {
  await for (final entity in source.list(recursive: false)) {
    final name = entity.uri.pathSegments.lastWhere((s) => s.isNotEmpty);
    if (name == '.dart_tool' || name == 'build') continue;
    if (entity is Directory) {
      final newDir = Directory.fromUri(destination.uri.resolve('$name/'));
      await newDir.create(recursive: true);
      await _copyDirectory(entity, newDir);
    } else if (entity is File) {
      await entity.copy(destination.uri.resolve(name).toFilePath());
    }
  }
}
