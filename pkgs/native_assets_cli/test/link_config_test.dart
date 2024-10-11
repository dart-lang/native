// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:native_assets_cli/native_assets_cli_internal.dart';
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

  setUp(() async {
    final tempUri = Directory.systemTemp.uri;
    outDirUri = tempUri.resolve('out1/');
    outputDirectoryShared = tempUri.resolve('out_shared1/');
    packageName = 'my_package';
    packageRootUri = tempUri.resolve('$packageName/');
    fakeClang = tempUri.resolve('fake_clang');
    fakeLd = tempUri.resolve('fake_ld');
    fakeAr = tempUri.resolve('fake_ar');

    assets = [
      DataAsset(
        package: packageName,
        name: 'name',
        file: Uri.file('nonexistent'),
      ).encode(),
      CodeAsset(
        package: packageName,
        name: 'name2',
        linkMode: DynamicLoadingBundled(),
        os: OS.android,
        file: Uri.file('not there'),
        architecture: Architecture.riscv64,
      ).encode(),
    ];
  });

  test('LinkConfigBuilder->JSON->LinkConfig', () {
    final configBuilder = LinkConfigBuilder()
      ..setupHookConfig(
        packageName: packageName,
        packageRoot: packageRootUri,
        targetOS: OS.android,
        buildMode: BuildMode.release,
        supportedAssetTypes: [CodeAsset.type],
      )
      ..setupLinkConfig(assets: assets)
      ..setupLinkRunConfig(
        outputDirectory: outDirUri,
        outputDirectoryShared: outputDirectoryShared,
        recordedUsesFile: null,
      )
      ..setupCodeConfig(
        targetArchitecture: Architecture.arm64,
        targetAndroidNdkApi: 30,
        linkModePreference: LinkModePreference.preferStatic,
        cCompilerConfig: CCompilerConfig(
          compiler: fakeClang,
          linker: fakeLd,
          archiver: fakeAr,
        ),
      );
    final config = LinkConfig(configBuilder.json);

    final expectedConfigJson = {
      'build_mode': 'release',
      'supported_asset_types': [CodeAsset.type],
      'link_mode_preference': 'prefer-static',
      'out_dir': outDirUri.toFilePath(),
      'out_dir_shared': outputDirectoryShared.toFilePath(),
      'package_name': packageName,
      'package_root': packageRootUri.toFilePath(),
      'target_android_ndk_api': 30,
      'target_architecture': 'arm64',
      'target_os': 'android',
      'version': latestVersion.toString(),
      'c_compiler.ar': fakeAr.toFilePath(),
      'c_compiler.ld': fakeLd.toFilePath(),
      'c_compiler.cc': fakeClang.toFilePath(),
      'assets': [for (final asset in assets) asset.toJson()],
    };
    expect(config.json, expectedConfigJson);
    expect(json.decode(config.toString()), expectedConfigJson);

    expect(config.outputDirectory, outDirUri);
    expect(config.outputDirectoryShared, outputDirectoryShared);

    expect(config.packageName, packageName);
    expect(config.packageRoot, packageRootUri);
    expect(config.targetOS, OS.android);
    expect(config.buildMode, BuildMode.release);
    expect(config.supportedAssetTypes, [CodeAsset.type]);
    expect(config.encodedAssets, assets);

    final codeConfig = config.codeConfig;
    expect(codeConfig.targetArchitecture, Architecture.arm64);
    expect(codeConfig.targetAndroidNdkApi, 30);
    expect(codeConfig.linkModePreference, LinkModePreference.preferStatic);
    expect(codeConfig.cCompiler.compiler, fakeClang);
    expect(codeConfig.cCompiler.linker, fakeLd);
    expect(codeConfig.cCompiler.archiver, fakeAr);
  });

  group('LinkConfig FormatExceptions', () {
    for (final version in ['9001.0.0', '0.0.1']) {
      test('LinkConfig version $version', () {
        final outDir = outDirUri;
        final config = {
          'link_mode_preference': 'prefer-static',
          'out_dir': outDir.toFilePath(),
          'out_dir_shared': outputDirectoryShared.toFilePath(),
          'package_root': packageRootUri.toFilePath(),
          'target_os': 'linux',
          'version': version,
          'package_name': packageName,
          'supported_asset_types': [CodeAsset.type],
          'dry_run': true,
        };
        expect(
          () => LinkConfig(config),
          throwsA(predicate(
            (e) =>
                e is FormatException &&
                e.message.contains(version) &&
                e.message.contains(latestVersion.toString()),
          )),
        );
      });
    }

    test('invalid architecture', () {
      final config = {
        'supported_asset_types': [CodeAsset.type],
        'build_mode': 'release',
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

    test('LinkConfig FormatExceptions', () {
      expect(
        () => LinkConfig({}),
        throwsA(predicate(
          (e) =>
              e is FormatException &&
              e.message.contains('No value was provided for required key: '),
        )),
      );
      expect(
        () => LinkConfig({
          'version': latestVersion.toString(),
          'supported_asset_types': [CodeAsset.type],
          'package_name': packageName,
          'package_root': packageRootUri.toFilePath(),
          'target_architecture': 'arm64',
          'target_os': 'android',
          'target_android_ndk_api': 30,
          'assets': <String>[],
        }),
        throwsA(predicate(
          (e) =>
              e is FormatException &&
              e.message.contains(
                'No value was provided for required key: out_dir',
              ),
        )),
      );
      expect(
        () => LinkConfig({
          'version': latestVersion.toString(),
          'supported_asset_types': [CodeAsset.type],
          'out_dir': outDirUri.toFilePath(),
          'out_dir_shared': outputDirectoryShared.toFilePath(),
          'package_name': packageName,
          'package_root': packageRootUri.toFilePath(),
          'target_architecture': 'arm64',
          'target_os': 'android',
          'target_android_ndk_api': 30,
          'build_mode': BuildMode.release.name,
          'assets': 'astring',
          'link_mode_preference': LinkModePreference.preferStatic.name,
        }),
        throwsA(predicate(
          (e) =>
              e is FormatException &&
              e.message.contains(
                "Unexpected value 'astring' for key '.assets' in config file. "
                'Expected a List<Object?>?.',
              ),
        )),
      );
    });
  });
}
