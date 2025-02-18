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
  late Uri outFile;
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
    outFile = tempUri.resolve('output.json');
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

  // Full JSON to see where the config sits in the full JSON.
  // When removing the non-hierarchical JSON, we can change this test to only
  // check the nested key.
  Map<String, Object> inputJson({
    String hookType = 'build',
    bool includeDeprecated = true,
    OS targetOS = OS.android,
  }) => {
    if (hookType == 'link')
      'assets': [
        {
          'architecture': 'riscv64',
          'file': 'not there',
          'id': 'package:my_package/name',
          'link_mode': {'type': 'dynamic_loading_bundle'},
          'os': 'android',
          'type': 'native_code',
        },
      ],
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
          if (includeDeprecated) 'env_script': fakeVcVars.toFilePath(),
          if (includeDeprecated) 'env_script_arguments': ['arg0', 'arg1'],
          'windows': {
            'developer_command_prompt': {
              'arguments': ['arg0', 'arg1'],
              'script': fakeVcVars.toFilePath(),
            },
          },
        },
        if (targetOS == OS.android) 'android': {'target_ndk_api': 30},
        if (targetOS == OS.macOS) 'macos': {'target_version': 13},
        if (targetOS == OS.iOS)
          'ios': {'target_sdk': 'iphoneos', 'target_version': 13},
      },
    },

    if (hookType == 'build' && includeDeprecated) 'linking_enabled': false,
    if (includeDeprecated) 'link_mode_preference': 'prefer-static',
    'out_dir_shared': outputDirectoryShared.toFilePath(),
    'out_dir': outDirUri.toFilePath(),
    'out_file': outFile.toFilePath(),
    'package_name': packageName,
    'package_root': packageRootUri.toFilePath(),
    if (includeDeprecated && targetOS == OS.android)
      'target_android_ndk_api': 30,
    if (includeDeprecated) 'target_architecture': 'arm64',
    if (includeDeprecated) 'target_os': targetOS.name,
    'version': '1.9.0',
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

  test('BuildInput.config.code', () {
    final inputBuilder =
        BuildInputBuilder()
          ..setupShared(
            packageName: packageName,
            packageRoot: packageRootUri,
            outputFile: outFile,
            outputDirectory: outDirUri,
            outputDirectoryShared: outputDirectoryShared,
          )
          ..config.setupBuild(linkingEnabled: false)
          ..config.setupShared(buildAssetTypes: [CodeAsset.type])
          ..config.setupCode(
            targetOS: OS.android,
            targetArchitecture: Architecture.arm64,
            android: AndroidCodeConfig(targetNdkApi: 30),
            linkModePreference: LinkModePreference.preferStatic,
            cCompiler: CCompilerConfig(
              compiler: fakeClang,
              linker: fakeLd,
              archiver: fakeAr,
              windows: WindowsCCompilerConfig(
                developerCommandPrompt: DeveloperCommandPrompt(
                  script: fakeVcVars,
                  arguments: ['arg0', 'arg1'],
                ),
              ),
            ),
          );
    final input = BuildInput(inputBuilder.json);
    expect(input.json, inputJson());
    expectCorrectCodeConfig(input.config.code);
  });

  test('BuildInput from json without deprecated keys', () {
    for (final targetOS in [OS.android, OS.iOS, OS.macOS]) {
      final input = BuildInput(
        inputJson(includeDeprecated: false, targetOS: targetOS),
      );
      expect(input.packageName, packageName);
      expect(input.packageRoot, packageRootUri);
      expect(input.outputDirectory, outDirUri);
      expect(input.outputDirectoryShared, outputDirectoryShared);
      expect(input.config.linkingEnabled, false);
      expect(input.config.buildAssetTypes, [CodeAsset.type]);
      expectCorrectCodeConfig(input.config.code, targetOS: targetOS);
    }
  });

  test('LinkInput.{code,codeAssets}', () {
    final inputBuilder =
        LinkInputBuilder()
          ..setupShared(
            packageName: packageName,
            packageRoot: packageRootUri,
            outputFile: outFile,
            outputDirectory: outDirUri,
            outputDirectoryShared: outputDirectoryShared,
          )
          ..setupLink(assets: assets, recordedUsesFile: null)
          ..config.setupShared(buildAssetTypes: [CodeAsset.type])
          ..config.setupCode(
            targetOS: OS.android,
            targetArchitecture: Architecture.arm64,
            android: AndroidCodeConfig(targetNdkApi: 30),
            linkModePreference: LinkModePreference.preferStatic,
            cCompiler: CCompilerConfig(
              compiler: fakeClang,
              linker: fakeLd,
              archiver: fakeAr,
              windows: WindowsCCompilerConfig(
                developerCommandPrompt: DeveloperCommandPrompt(
                  script: fakeVcVars,
                  arguments: ['arg0', 'arg1'],
                ),
              ),
            ),
          );
    final input = LinkInput(inputBuilder.json);
    expect(input.json, inputJson(hookType: 'link'));
    expectCorrectCodeConfig(input.config.code);
    expect(input.assets.encodedAssets, assets);
  });

  test('LinkInput from json without deprecated keys', () {
    for (final targetOS in [OS.android, OS.iOS, OS.macOS]) {
      final input = LinkInput(
        inputJson(
          includeDeprecated: false,
          targetOS: targetOS,
          hookType: 'link',
        ),
      );
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
      'linking_enabled': false,
      'link_mode_preference': 'prefer-static',
      'out_dir': outDirUri.toFilePath(),
      'out_dir_shared': outputDirectoryShared.toFilePath(),
      'out_file': outFile.toFilePath(),
      'package_name': packageName,
      'package_root': packageRootUri.toFilePath(),
      'target_android_ndk_api': 30,
      'target_architecture': 'invalid_architecture',
      'target_os': 'android',
      'version': latestVersion.toString(),
    };
    expect(() => BuildInput(input).config.code, throwsFormatException);
  });

  test('LinkInput.config.code: invalid architecture', () {
    final input = {
      'link_mode_preference': 'prefer-static',
      'out_dir': outDirUri.toFilePath(),
      'out_dir_shared': outputDirectoryShared.toFilePath(),
      'out_file': outFile.toFilePath(),
      'package_name': packageName,
      'package_root': packageRootUri.toFilePath(),
      'target_android_ndk_api': 30,
      'target_architecture': 'invalid_architecture',
      'target_os': 'android',
      'version': latestVersion.toString(),
    };
    expect(() => LinkInput(input).config.code, throwsFormatException);
  });
}
