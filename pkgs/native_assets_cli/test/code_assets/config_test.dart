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
      Map<String, Object?> json, CodeConfig codeCondig) {
    <String, Object?>{
      'build_asset_types': [CodeAsset.type],
      'link_mode_preference': 'prefer-static',
    }.forEach((k, v) {
      expect(json[k], v);
    });

    expect(() => codeCondig.targetArchitecture, throwsStateError);
    expect(() => codeCondig.android.targetNdkApi, throwsStateError);
    expect(codeCondig.linkModePreference, LinkModePreference.preferStatic);
    expect(codeCondig.cCompiler, null);
  }

  void expectCorrectCodeConfig(
      Map<String, Object?> json, CodeConfig codeCondig) {
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

    expect(codeCondig.targetArchitecture, Architecture.arm64);
    expect(codeCondig.android.targetNdkApi, 30);
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
    expectCorrectCodeConfig(input.json, input.config.code);
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
    expectCorrectCodeConfig(input.json, input.config.code);
    expect(input.assets.encodedAssets, assets);
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
