// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:native_assets_cli/native_assets_cli_internal.dart';
import 'package:test/test.dart';

import '../helpers.dart';

void main() {
  const packageName = 'my_package';
  test('checksum', () async {
    await inTempDir((tempUri) async {
      final nativeAddUri = tempUri.resolve('native_add/');
      final fakeClangUri = tempUri.resolve('fake_clang');
      await File.fromUri(fakeClangUri).create();

      final name1 = HookConfigImpl.checksum(
        packageName: packageName,
        packageRoot: nativeAddUri,
        targetArchitecture: Architecture.x64,
        targetOS: OS.linux,
        buildMode: BuildMode.release,
        linkModePreference: LinkModePreference.dynamic,
        supportedAssetTypes: [CodeAsset.type],
        hook: Hook.build,
        version: HookConfigImpl.latestVersion,
        linkingEnabled: true,
      );

      // Using the checksum for a build folder should be stable.
      expect(name1, '8780162e48a4539f01ea483fda6c1efc');

      // Build folder different due to metadata.
      final name2 = HookConfigImpl.checksum(
        packageName: packageName,
        packageRoot: nativeAddUri,
        targetArchitecture: Architecture.x64,
        targetOS: OS.linux,
        buildMode: BuildMode.release,
        linkModePreference: LinkModePreference.dynamic,
        supportedAssetTypes: [CodeAsset.type],
        dependencyMetadata: {
          'foo': const Metadata({'key': 'value'})
        },
        hook: Hook.build,
        version: HookConfigImpl.latestVersion,
        linkingEnabled: true,
      );
      printOnFailure([name1, name2].toString());
      expect(name1 != name2, true);

      // Build folder different due to cc.
      final name3 = HookConfigImpl.checksum(
        packageName: packageName,
        packageRoot: nativeAddUri,
        targetArchitecture: Architecture.x64,
        targetOS: OS.linux,
        buildMode: BuildMode.release,
        linkModePreference: LinkModePreference.dynamic,
        supportedAssetTypes: [CodeAsset.type],
        cCompiler: CCompilerConfig(
          compiler: fakeClangUri,
        ),
        hook: Hook.build,
        version: HookConfigImpl.latestVersion,
        linkingEnabled: true,
      );
      printOnFailure([name1, name3].toString());
      expect(name1 != name3, true);

      // Build folder different due to hook.
      final name4 = HookConfigImpl.checksum(
        packageName: packageName,
        packageRoot: nativeAddUri,
        targetArchitecture: Architecture.x64,
        targetOS: OS.linux,
        buildMode: BuildMode.release,
        linkModePreference: LinkModePreference.dynamic,
        supportedAssetTypes: [CodeAsset.type],
        cCompiler: CCompilerConfig(
          compiler: fakeClangUri,
        ),
        hook: Hook.link,
        version: HookConfigImpl.latestVersion,
        linkingEnabled: true,
      );
      printOnFailure([name1, name4].toString());
      expect(name1 != name4, true);

      // Build folder different due to haslinkPhase.
      final name5 = HookConfigImpl.checksum(
        packageName: packageName,
        packageRoot: nativeAddUri,
        targetArchitecture: Architecture.x64,
        targetOS: OS.linux,
        buildMode: BuildMode.release,
        linkModePreference: LinkModePreference.dynamic,
        supportedAssetTypes: [CodeAsset.type],
        hook: Hook.build,
        version: HookConfigImpl.latestVersion,
        linkingEnabled: false,
      );
      printOnFailure([name1, name5].toString());
      expect(name1, isNot(name5));
    });
  });
}
