// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:native_assets_cli/code_assets_builder.dart';
import 'package:native_assets_cli/src/config.dart' show latestVersion;
import 'package:test/test.dart';

void main() async {
  late Uri outDirUri;
  late Uri outputDirectoryShared;
  late String packageName;
  late Uri packageRootUri;
  late Uri fakeClang;
  late Uri fakeLd;
  late Uri fakeAr;
  late List<EncodedAsset> assets;
  late Uri fakeVcVars;

  setUp(() async {
    final tempUri = Directory.systemTemp.uri;
    outDirUri = tempUri.resolve('out1/');
    outputDirectoryShared = tempUri.resolve('out_shared1/');
    packageName = 'my_package';
    packageRootUri = tempUri.resolve('$packageName/');
    fakeClang = tempUri.resolve('fake_clang');
    fakeLd = tempUri.resolve('fake_ld');
    fakeAr = tempUri.resolve('fake_ar');
    fakeVcVars = tempUri.resolve('vcvarsall.bat');

    assets = [
      CodeAsset(
        package: packageName,
        name: 'name',
        linkMode: DynamicLoadingBundled(),
        os: OS.android,
        file: Uri.file('not there'),
        architecture: Architecture.riscv64,
      ).encode(),
    ];
  });

  // Tests JSON encoding & accessors of code-asset configuration.
  void expectCorrectCodeConfigDryRun(
      Map<String, Object?> json, CodeConfig codeConfig) {
    <String, Object?>{
      'build_asset_types': [CodeAsset.type],
      'link_mode_preference': 'prefer-static',
    }.forEach((k, v) {
      expect(json[k], v);
    });

    expect(() => codeConfig.targetArchitecture, throwsStateError);
    expect(codeConfig.targetAndroidNdkApi, null);
    expect(codeConfig.linkModePreference, LinkModePreference.preferStatic);
    expect(codeConfig.cCompiler.compiler, null);
    expect(codeConfig.cCompiler.linker, null);
    expect(codeConfig.cCompiler.archiver, null);
  }

  void expectCorrectCodeConfig(
      Map<String, Object?> json, CodeConfig codeConfig) {
    <String, Object?>{
      'build_asset_types': [CodeAsset.type],
      'link_mode_preference': 'prefer-static',
      'target_android_ndk_api': 30,
      'target_architecture': 'arm64',
      'c_compiler': {
        'ar': fakeAr.toFilePath(),
        'ld': fakeLd.toFilePath(),
        'cc': fakeClang.toFilePath(),
        'env_script': fakeVcVars.toFilePath(),
        'env_script_arguments': ['arg0', 'arg1'],
      },
    }.forEach((k, v) {
      expect(json[k], v);
    });

    expect(codeConfig.targetArchitecture, Architecture.arm64);
    expect(codeConfig.targetAndroidNdkApi, 30);
    expect(codeConfig.linkModePreference, LinkModePreference.preferStatic);
    expect(codeConfig.cCompiler.compiler, fakeClang);
    expect(codeConfig.cCompiler.linker, fakeLd);
    expect(codeConfig.cCompiler.archiver, fakeAr);
  }

  test('BuildConfig.codeConfig (dry-run)', () {
    final configBuilder = BuildConfigBuilder()
      ..setupHookConfig(
        packageName: packageName,
        packageRoot: packageRootUri,
        buildAssetTypes: [CodeAsset.type],
      )
      ..setupBuildConfig(
        linkingEnabled: true,
        dryRun: true,
      )
      ..setupBuildRunConfig(
        outputDirectory: outDirUri,
        outputDirectoryShared: outputDirectoryShared,
      )
      ..setupCodeConfig(
        targetOS: OS.android,
        targetArchitecture: null, // not available in dry run
        cCompilerConfig: null, // not available in dry run
        linkModePreference: LinkModePreference.preferStatic,
      );
    final config = BuildConfig(configBuilder.json);
    expectCorrectCodeConfigDryRun(config.json, config.codeConfig);
  });

  test('BuildConfig.codeConfig', () {
    final configBuilder = BuildConfigBuilder()
      ..setupHookConfig(
        packageName: packageName,
        packageRoot: packageRootUri,
        buildAssetTypes: [CodeAsset.type],
      )
      ..setupBuildConfig(
        linkingEnabled: false,
        dryRun: false,
      )
      ..setupBuildRunConfig(
        outputDirectory: outDirUri,
        outputDirectoryShared: outputDirectoryShared,
      )
      ..setupCodeConfig(
        targetOS: OS.android,
        targetArchitecture: Architecture.arm64,
        targetAndroidNdkApi: 30,
        linkModePreference: LinkModePreference.preferStatic,
        cCompilerConfig: CCompilerConfig(
          compiler: fakeClang,
          linker: fakeLd,
          archiver: fakeAr,
          envScript: fakeVcVars,
          envScriptArgs: ['arg0', 'arg1'],
        ),
      );
    final config = BuildConfig(configBuilder.json);
    expectCorrectCodeConfig(config.json, config.codeConfig);
  });

  test('LinkConfig.{codeConfig,codeAssets}', () {
    final configBuilder = LinkConfigBuilder()
      ..setupHookConfig(
        packageName: packageName,
        packageRoot: packageRootUri,
        buildAssetTypes: [CodeAsset.type],
      )
      ..setupLinkConfig(assets: assets)
      ..setupLinkRunConfig(
        outputDirectory: outDirUri,
        outputDirectoryShared: outputDirectoryShared,
        recordedUsesFile: null,
      )
      ..setupCodeConfig(
        targetOS: OS.android,
        targetArchitecture: Architecture.arm64,
        targetAndroidNdkApi: 30,
        linkModePreference: LinkModePreference.preferStatic,
        cCompilerConfig: CCompilerConfig(
          compiler: fakeClang,
          linker: fakeLd,
          archiver: fakeAr,
          envScript: fakeVcVars,
          envScriptArgs: ['arg0', 'arg1'],
        ),
      );
    final config = LinkConfig(configBuilder.json);
    expectCorrectCodeConfig(config.json, config.codeConfig);
    expect(config.encodedAssets, assets);
  });

  test('BuildConfig.codeConfig: invalid architecture', () {
    final config = {
      'dry_run': false,
      'linking_enabled': false,
      'link_mode_preference': 'prefer-static',
      'out_dir': outDirUri.toFilePath(),
      'out_dir_shared': outputDirectoryShared.toFilePath(),
      'package_name': packageName,
      'package_root': packageRootUri.toFilePath(),
      'target_android_ndk_api': 30,
      'target_architecture': 'invalid_architecture',
      'target_os': 'android',
      'build_asset_types': ['my-asset-type'],
      'version': latestVersion.toString(),
    };
    expect(
      () => BuildConfig(config).codeConfig,
      throwsFormatException,
    );
  });

  test('LinkConfig.codeConfig: invalid architecture', () {
    final config = {
      'build_asset_types': [CodeAsset.type],
      'dry_run': false,
      'link_mode_preference': 'prefer-static',
      'out_dir': outDirUri.toFilePath(),
      'out_dir_shared': outputDirectoryShared.toFilePath(),
      'package_name': packageName,
      'package_root': packageRootUri.toFilePath(),
      'target_android_ndk_api': 30,
      'target_architecture': 'invalid_architecture',
      'target_os': 'android',
      'version': latestVersion.toString(),
    };
    expect(
      () => LinkConfig(config).codeConfig,
      throwsFormatException,
    );
  });
}
