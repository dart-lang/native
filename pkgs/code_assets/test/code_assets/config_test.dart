// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:code_assets/src/code_assets/code_asset.dart';
import 'package:hooks/hooks.dart';
import 'package:test/test.dart';

import '../../../hooks/test/helpers.dart';

void main() async {
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
        file: Uri.file('not there'),
      ).encode(),
    ];
  });

  // Full JSON to see where the config sits in the full JSON.
  // When removing the non-hierarchical JSON, we can change this test to only
  // check the nested key.
  Map<String, Object> inputJson({
    String hookType = 'build',
    OS targetOS = OS.android,
  }) {
    final codeConfig = {
      'target_architecture': 'arm64',
      'target_os': targetOS.name,
      'link_mode_preference': 'prefer_static',
      'c_compiler': {
        'ar': fakeAr.toFilePath(),
        'ld': fakeLd.toFilePath(),
        'cc': fakeClang.toFilePath(),
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
    };
    return {
      if (hookType == 'link')
        'assets': [
          {
            'type': 'code_assets/code',
            'encoding': {
              'file': 'not there',
              'id': 'package:my_package/name',
              'link_mode': {'type': 'dynamic_loading_bundle'},
            },
          },
        ],
      'config': {
        'build_asset_types': ['code_assets/code'],
        'extensions': {'code_assets': codeConfig},
        if (hookType == 'build') 'linking_enabled': false,
      },
      'out_dir_shared': outputDirectoryShared.toFilePath(),
      'out_file': outFile.toFilePath(),
      'package_name': packageName,
      'package_root': packageRootUri.toFilePath(),
    };
  }

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
            outputDirectoryShared: outputDirectoryShared,
          )
          ..config.setupBuild(linkingEnabled: false)
          ..addExtension(
            CodeAssetExtension(
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
            ),
          );
    final input = inputBuilder.build();
    expect(input.json, inputJson());
    expectCorrectCodeConfig(input.config.code);
  });

  test('BuildInput from json ', () {
    for (final targetOS in [OS.android, OS.iOS, OS.macOS]) {
      final input = BuildInput(inputJson(targetOS: targetOS));
      expect(input.packageName, packageName);
      expect(input.packageRoot, packageRootUri);
      expect(input.outputDirectoryShared, outputDirectoryShared);
      expect(input.config.linkingEnabled, false);
      expect(input.config.buildAssetTypes, [CodeAssetType.type]);
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
            outputDirectoryShared: outputDirectoryShared,
          )
          ..setupLink(assets: assets, recordedUsesFile: null)
          ..addExtension(
            CodeAssetExtension(
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
            ),
          );
    final input = inputBuilder.build();
    expect(input.json, inputJson(hookType: 'link'));
    expectCorrectCodeConfig(input.config.code);
    expect(input.assets.encodedAssets, assets);
  });

  test('LinkInput from json', () {
    for (final targetOS in [OS.android, OS.iOS, OS.macOS]) {
      final input = LinkInput(inputJson(targetOS: targetOS, hookType: 'link'));
      expect(input.packageName, packageName);
      expect(input.packageRoot, packageRootUri);
      expect(input.outputDirectoryShared, outputDirectoryShared);
      expect(input.config.buildAssetTypes, [CodeAssetType.type]);
      expectCorrectCodeConfig(input.config.code, targetOS: targetOS);
    }
  });

  test('BuildInput.config.code: invalid architecture', () {
    final input = inputJson();
    traverseJson<Map<String, Object?>>(input, [
          'config',
          'extensions',
          'code_assets',
        ])['target_architecture'] =
        'invalid_architecture';
    expect(
      () => BuildInput(input).config.code.targetArchitecture,
      throwsFormatException,
    );
  });

  test('LinkInput.config.code: invalid os', () {
    final input = inputJson(hookType: 'link');
    traverseJson<Map<String, Object?>>(input, [
          'config',
          'extensions',
          'code_assets',
        ])['target_os'] =
        'invalid_os';
    expect(() => LinkInput(input).config.code.targetOS, throwsFormatException);
  });

  test('LinkInput.config.code.target_os invalid type', () {
    final input = inputJson(hookType: 'link');
    traverseJson<Map<String, Object?>>(input, [
          'config',
          'extensions',
          'code_assets',
        ])['target_os'] =
        123;
    expect(
      () => LinkInput(input).config.code.targetOS,
      throwsA(
        predicate(
          (e) =>
              e is FormatException &&
              e.message.contains(
                "Unexpected value '123' (int) for "
                "'config.extensions.code_assets.target_os'. "
                'Expected a String.',
              ),
        ),
      ),
    );
  });

  test('LinkInput.config.code.link_mode_preference missing', () {
    final input = inputJson(hookType: 'link');
    traverseJson<Map<String, Object?>>(input, [
      'config',
      'extensions',
      'code_assets',
    ]).remove('link_mode_preference');
    expect(
      () => LinkInput(input).config.code.linkModePreference,
      throwsA(
        predicate(
          (e) =>
              e is FormatException &&
              e.message.contains(
                'No value was provided for '
                "'config.extensions.code_assets.link_mode_preference'.",
              ),
        ),
      ),
    );
  });

  test('LinkInput.assets.0.link_mode missing', () {
    final input = inputJson(hookType: 'link');
    traverseJson<Map<String, Object?>>(input, [
      'assets',
      0,
      'encoding',
    ]).remove('link_mode');
    expect(
      () => LinkInput(input).assets.code.first.linkMode,
      throwsA(
        predicate(
          (e) =>
              e is FormatException &&
              e.message.contains(
                "No value was provided for 'assets.0.encoding.link_mode'.",
              ),
        ),
      ),
    );
  });
}
