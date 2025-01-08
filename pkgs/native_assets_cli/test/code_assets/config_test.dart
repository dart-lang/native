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
    expect(() => codeConfig.android.targetNdkApi, throwsStateError);
    expect(codeConfig.linkModePreference, LinkModePreference.preferStatic);
    expect(codeConfig.cCompiler, null);
  }

  // Full JSON to see where the config sits in the full JSON.
  // When removing the non-hierarchical JSON, we can change this test to only
  // check the nested key.
  Map<String, Object> inputJson({
    String hookType = 'build',
    bool includeDeprecated = true,
    OS targetOS = OS.android,
  }) =>
      {
        if (hookType == 'link')
          'assets': [
            {
              'architecture': 'riscv64',
              'file': 'not there',
              'id': 'package:my_package/name',
              'link_mode': {'type': 'dynamic_loading_bundle'},
              'os': 'android',
              'type': 'native_code'
            }
          ],
        if (includeDeprecated) 'build_asset_types': [CodeAsset.type],
        if (includeDeprecated) 'build_mode': 'release',
        'config': {
          'build_asset_types': ['native_code'],
          if (hookType == 'build') 'linking_enabled': false,
          'code': {
            'target_architecture': 'arm64',
            'target_os': targetOS.name,
            'link_mode_preference': 'prefer-static',
            'c_compiler': {
              'ar': fakeAr.toFilePath(),
              'ld': fakeLd.toFilePath(),
              'cc': fakeClang.toFilePath(),
              'env_script': fakeVcVars.toFilePath(),
              'env_script_arguments': ['arg0', 'arg1'],
            },
            if (targetOS == OS.android) 'android': {'target_ndk_api': 30},
            if (targetOS == OS.macOS) 'macos': {'target_version': 13},
            if (targetOS == OS.iOS)
              'ios': {
                'target_sdk': 'iphoneos',
                'target_version': 13,
              },
          },
        },
        'c_compiler': {
          'ar': fakeAr.toFilePath(),
          'ld': fakeLd.toFilePath(),
          'cc': fakeClang.toFilePath(),
          'env_script': fakeVcVars.toFilePath(),
          'env_script_arguments': ['arg0', 'arg1'],
        },
        if (hookType == 'build' && includeDeprecated) 'dry_run': false,
        if (hookType == 'build' && includeDeprecated) 'linking_enabled': false,
        if (includeDeprecated) 'link_mode_preference': 'prefer-static',
        'out_dir_shared': outputDirectoryShared.toFilePath(),
        'out_dir': outDirUri.toFilePath(),
        'package_name': packageName,
        'package_root': packageRootUri.toFilePath(),
        if (includeDeprecated) 'supported_asset_types': [CodeAsset.type],
        if (includeDeprecated && targetOS == OS.android)
          'target_android_ndk_api': 30,
        if (includeDeprecated) 'target_architecture': 'arm64',
        if (includeDeprecated) 'target_os': targetOS.name,
        'version': '1.7.0',
      };

  void expectCorrectCodeConfig(
    CodeConfig codeCondig, {
    OS targetOS = OS.android,
  }) {
    expect(codeCondig.targetArchitecture, Architecture.arm64);
    if (targetOS == OS.android) {
      expect(codeCondig.android.targetNdkApi, 30);
    }
    if (targetOS == OS.macOS) {
      expect(codeCondig.macOS.targetVersion, 13);
    }
    if (targetOS == OS.iOS) {
      expect(codeCondig.iOS.targetVersion, 13);
      expect(codeCondig.iOS.targetSdk, IOSSdk.iPhoneOS);
    }
    expect(codeCondig.linkModePreference, LinkModePreference.preferStatic);
    expect(codeCondig.cCompiler?.compiler, fakeClang);
    expect(codeCondig.cCompiler?.linker, fakeLd);
    expect(codeCondig.cCompiler?.archiver, fakeAr);
  }

  test('BuildInput.config.code (dry-run)', () {
    final inputBuilder = BuildInputBuilder()
      ..setupShared(
        packageName: packageName,
        packageRoot: packageRootUri,
        outputDirectory: outDirUri,
        outputDirectoryShared: outputDirectoryShared,
      )
      ..config.setupBuild(
        linkingEnabled: true,
        dryRun: true,
      )
      ..config.setupShared(buildAssetTypes: [CodeAsset.type])
      ..config.setupCode(
        targetOS: OS.android,
        android: null, // not available in dry run
        targetArchitecture: null, // not available in dry run
        cCompiler: null, // not available in dry run
        linkModePreference: LinkModePreference.preferStatic,
      );
    final input = BuildInput(inputBuilder.json);
    expectCorrectCodeConfigDryRun(input.json, input.config.code);
  });

  test('BuildInput.config.code', () {
    final inputBuilder = BuildInputBuilder()
      ..setupShared(
        packageName: packageName,
        packageRoot: packageRootUri,
        outputDirectory: outDirUri,
        outputDirectoryShared: outputDirectoryShared,
      )
      ..config.setupBuild(
        linkingEnabled: false,
        dryRun: false,
      )
      ..config.setupShared(buildAssetTypes: [CodeAsset.type])
      ..config.setupCode(
        targetOS: OS.android,
        targetArchitecture: Architecture.arm64,
        android: AndroidConfig(targetNdkApi: 30),
        linkModePreference: LinkModePreference.preferStatic,
        cCompiler: CCompilerConfig(
          compiler: fakeClang,
          linker: fakeLd,
          archiver: fakeAr,
          envScript: fakeVcVars,
          envScriptArgs: ['arg0', 'arg1'],
        ),
      );
    final input = BuildInput(inputBuilder.json);
    expect(input.json, inputJson());
    expectCorrectCodeConfig(input.config.code);
  });

  test('BuildInput from json without deprecated keys', () {
    for (final targetOS in [OS.android, OS.iOS, OS.macOS]) {
      final input = BuildInput(inputJson(
        includeDeprecated: false,
        targetOS: targetOS,
      ));
      expect(input.packageName, packageName);
      expect(input.packageRoot, packageRootUri);
      expect(input.outputDirectory, outDirUri);
      expect(input.outputDirectoryShared, outputDirectoryShared);
      expect(input.config.linkingEnabled, false);
      // ignore: deprecated_member_use_from_same_package
      expect(input.config.dryRun, false);
      expect(input.config.buildAssetTypes, [CodeAsset.type]);
      expectCorrectCodeConfig(input.config.code, targetOS: targetOS);
    }
  });

  test('LinkInput.{code,codeAssets}', () {
    final inputBuilder = LinkInputBuilder()
      ..setupShared(
        packageName: packageName,
        packageRoot: packageRootUri,
        outputDirectory: outDirUri,
        outputDirectoryShared: outputDirectoryShared,
      )
      ..setupLink(
        assets: assets,
        recordedUsesFile: null,
      )
      ..config.setupShared(buildAssetTypes: [CodeAsset.type])
      ..config.setupCode(
        targetOS: OS.android,
        targetArchitecture: Architecture.arm64,
        android: AndroidConfig(targetNdkApi: 30),
        linkModePreference: LinkModePreference.preferStatic,
        cCompiler: CCompilerConfig(
          compiler: fakeClang,
          linker: fakeLd,
          archiver: fakeAr,
          envScript: fakeVcVars,
          envScriptArgs: ['arg0', 'arg1'],
        ),
      );
    final input = LinkInput(inputBuilder.json);
    expect(input.json, inputJson(hookType: 'link'));
    expectCorrectCodeConfig(input.config.code);
    expect(input.assets.encodedAssets, assets);
  });

  test('LinkInput from json without deprecated keys', () {
    for (final targetOS in [OS.android, OS.iOS, OS.macOS]) {
      final input = LinkInput(inputJson(
        includeDeprecated: false,
        targetOS: targetOS,
        hookType: 'link',
      ));
      expect(input.packageName, packageName);
      expect(input.packageRoot, packageRootUri);
      expect(input.outputDirectory, outDirUri);
      expect(input.outputDirectoryShared, outputDirectoryShared);
      expect(input.config.buildAssetTypes, [CodeAsset.type]);
      expectCorrectCodeConfig(input.config.code, targetOS: targetOS);
    }
  });

  test('BuildInput.config.code: invalid architecture', () {
    final input = {
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
      () => BuildInput(input).config.code,
      throwsFormatException,
    );
  });

  test('LinkInput.config.code: invalid architecture', () {
    final input = {
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
      () => LinkInput(input).config.code,
      throwsFormatException,
    );
  });
}
