import 'dart:io';

import 'package:native_assets_cli/native_assets_cli_internal.dart';
import 'package:native_assets_cli/src/api/asset.dart';
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
        targetArchitecture: ArchitectureImpl.x64,
        targetOS: OSImpl.linux,
        buildMode: BuildModeImpl.release,
        linkModePreference: LinkModePreferenceImpl.dynamic,
        supportedAssetTypes: [NativeCodeAsset.type],
        hook: Hook.build,
        version: HookConfigImpl.latestVersion,
      );

      // Using the checksum for a build folder should be stable.
      expect(name1, 'b6170f6f00000d3766b01cea7637b607');

      // Build folder different due to metadata.
      final name2 = HookConfigImpl.checksum(
        packageName: packageName,
        packageRoot: nativeAddUri,
        targetArchitecture: ArchitectureImpl.x64,
        targetOS: OSImpl.linux,
        buildMode: BuildModeImpl.release,
        linkModePreference: LinkModePreferenceImpl.dynamic,
        dependencyMetadata: {
          'foo': const Metadata({'key': 'value'})
        },
        hook: Hook.build,
        version: HookConfigImpl.latestVersion,
      );
      printOnFailure([name1, name2].toString());
      expect(name1 != name2, true);

      // Build folder different due to cc.
      final name3 = HookConfigImpl.checksum(
        packageName: packageName,
        packageRoot: nativeAddUri,
        targetArchitecture: ArchitectureImpl.x64,
        targetOS: OSImpl.linux,
        buildMode: BuildModeImpl.release,
        linkModePreference: LinkModePreferenceImpl.dynamic,
        cCompiler: CCompilerConfigImpl(
          compiler: fakeClangUri,
        ),
        hook: Hook.build,
        version: HookConfigImpl.latestVersion,
      );
      printOnFailure([name1, name3].toString());
      expect(name1 != name3, true);

      // Build folder different due to hook.
      final name4 = HookConfigImpl.checksum(
        packageName: packageName,
        packageRoot: nativeAddUri,
        targetArchitecture: ArchitectureImpl.x64,
        targetOS: OSImpl.linux,
        buildMode: BuildModeImpl.release,
        linkModePreference: LinkModePreferenceImpl.dynamic,
        cCompiler: CCompilerConfigImpl(
          compiler: fakeClangUri,
        ),
        hook: Hook.link,
        version: HookConfigImpl.latestVersion,
      );
      printOnFailure([name1, name4].toString());
      expect(name1 != name4, true);
    });
  });
}
