// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:native_assets_cli/code_assets_builder.dart';
import 'package:native_assets_cli/src/code_assets/code_asset.dart';
import 'package:test/test.dart';

import '../helpers.dart';

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
  late Uri fileUri;

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
    fileUri = Uri.file('/not there.txt');

    assets = [
      CodeAsset(
        package: packageName,
        name: 'name',
        linkMode: DynamicLoadingBundled(),
        os: OS.android,
        file: fileUri,
        architecture: Architecture.riscv64,
      ).encode(),
    ];
  });

  // Full JSON to see where the config sits in the full JSON.
  // When removing the non-hierarchical JSON, we can change this test to only
  // check the nested key.
  Map<String, Object> inputJson({
    String hookType = 'build',
    bool includeDeprecated = false,
    OS targetOS = OS.android,
  }) {
    // TODO(https://github.com/dart-lang/native/issues/2040): Change to
    // toString if we change to json schema format uri.
    String uriSerializer(Uri u) => u.toFilePath();

    final codeConfig = {
      'target_architecture': 'arm64',
      'target_os': targetOS.name,
      'link_mode_preference': 'prefer_static',
      'c_compiler': {
        'ar': uriSerializer(fakeAr),
        'ld': uriSerializer(fakeLd),
        'cc': uriSerializer(fakeClang),
        if (includeDeprecated) 'env_script': uriSerializer(fakeVcVars),
        if (includeDeprecated) 'env_script_arguments': ['arg0', 'arg1'],
        'windows': {
          'developer_command_prompt': {
            'arguments': ['arg0', 'arg1'],
            'script': uriSerializer(fakeVcVars),
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
            'architecture': 'riscv64',
            'file': uriSerializer(fileUri),
            'id': 'package:my_package/name',
            'link_mode': {'type': 'dynamic_loading_bundle'},
            'os': 'android',
            'type': 'native_code',
            'encoding': {
              'architecture': 'riscv64',
              'file': uriSerializer(fileUri),
              'id': 'package:my_package/name',
              'link_mode': {'type': 'dynamic_loading_bundle'},
              'os': 'android',
            },
          },
        ],
      'config': {
        'code': codeConfig,
        'build_asset_types': ['code_assets/code', 'native_code'],
        'extensions': {'code_assets': codeConfig},
        if (hookType == 'build') 'linking_enabled': false,
      },
      'out_dir_shared': uriSerializer(outputDirectoryShared),
      'out_dir': uriSerializer(outDirUri),
      'out_file': uriSerializer(outFile),
      'package_name': packageName,
      'package_root': uriSerializer(packageRootUri),
      'version': '1.9.0',
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
            outputDirectory: outDirUri,
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
    final input = BuildInput(inputBuilder.json);
    expect(input.json, inputJson(includeDeprecated: true));
    expectCorrectCodeConfig(input.config.code);
  });

  test('BuildInput from json without deprecated keys', () {
    for (final targetOS in [OS.android, OS.iOS, OS.macOS]) {
      final input = BuildInput(inputJson(targetOS: targetOS));
      expect(input.packageName, packageName);
      expect(input.packageRoot, packageRootUri);
      expect(input.outputDirectoryShared, outputDirectoryShared);
      expect(input.config.linkingEnabled, false);
      expect(
        input.config.buildAssetTypes,
        CodeAssetType.typesForBuildAssetTypes,
      );
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
    final input = LinkInput(inputBuilder.json);
    expect(input.json, inputJson(hookType: 'link', includeDeprecated: true));
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
      expect(input.outputDirectoryShared, outputDirectoryShared);
      expect(
        input.config.buildAssetTypes,
        CodeAssetType.typesForBuildAssetTypes,
      );
      expectCorrectCodeConfig(input.config.code, targetOS: targetOS);
    }
  });

  test('BuildInput.config.code: invalid architecture', () {
    final input = inputJson();
    traverseJson<Map<String, Object?>>(input, [
          'config',
          'code',
        ])['target_architecture'] =
        'invalid_architecture';
    expect(
      () => BuildInput(input).config.code.targetArchitecture,
      throwsFormatException,
    );
  });

  test('LinkInput.config.code: invalid os', () {
    final input = inputJson(hookType: 'link');
    traverseJson<Map<String, Object?>>(input, ['config', 'code'])['target_os'] =
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

    traverseJson<Map<String, Object?>>(input, ['config']).remove('extensions');
    traverseJson<Map<String, Object?>>(input, ['config', 'code'])['target_os'] =
        123;
    expect(
      () => LinkInput(input).config.code.targetOS,
      throwsA(
        predicate(
          (e) =>
              e is FormatException &&
              e.message.contains(
                "Unexpected value '123' (int) for 'config.code.target_os'. "
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

    traverseJson<Map<String, Object?>>(input, ['config']).remove('extensions');
    traverseJson<Map<String, Object?>>(input, [
      'config',
      'code',
    ]).remove('link_mode_preference');
    expect(
      () => LinkInput(input).config.code.linkModePreference,
      throwsA(
        predicate(
          (e) =>
              e is FormatException &&
              e.message.contains(
                "No value was provided for 'config.code.link_mode_preference'.",
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
