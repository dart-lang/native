// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: deprecated_member_use_from_same_package

import 'dart:convert';
import 'dart:io';

import 'package:native_assets_cli/native_assets_cli_internal.dart';
import 'package:native_assets_cli/src/config.dart' show latestVersion;
import 'package:test/test.dart';

//XXX TODO
//test('envScript', () {
//final buildConfig1 = BuildConfigImpl(
//outputDirectory: outDirUri,
//outputDirectoryShared: outputDirectoryShared,
//packageName: packageName,
//packageRoot: packageRootUri,
//targetArchitecture: Architecture.x64,
//targetOS: OS.windows,
//cCompiler: CCompilerConfig(
//compiler: fakeCl,
//envScript: fakeVcVars,
//envScriptArgs: ['x64'],
//),
//buildMode: BuildMode.release,
//linkModePreference: LinkModePreference.dynamic,
//linkingEnabled: false,
//supportedAssetTypes: [CodeAsset.type],
//);

//final configFile = buildConfig1.toJson();
//final fromConfig = BuildConfigImpl.fromJson(configFile);
//expect(fromConfig, equals(buildConfig1));
//});

void main() async {
  late Uri outDirUri;
  late Uri outputDirectoryShared;
  late String packageName;
  late Uri packageRootUri;
  late Uri fakeClang;
  late Uri fakeLd;
  late Uri fakeAr;
  late Map<String, Metadata> metadata;

  setUp(() async {
    final tempUri = Directory.systemTemp.uri;
    outDirUri = tempUri.resolve('out1/');
    outputDirectoryShared = tempUri.resolve('out_shared1/');
    packageName = 'my_package';
    packageRootUri = tempUri.resolve('$packageName/');
    fakeClang = tempUri.resolve('fake_clang');
    fakeLd = tempUri.resolve('fake_ld');
    fakeAr = tempUri.resolve('fake_ar');
    metadata = {
      'bar': const Metadata({
        'key': 'value',
        'foo': ['asdf', 'fdsa'],
      }),
      'foo': const Metadata({
        'key': 321,
      }),
    };
  });

  test('BuildConfigBuilder->JSON->BuildConfig', () {
    final configBuilder = BuildConfigBuilder()
      ..setupHookConfig(
        packageName: packageName,
        packageRoot: packageRootUri,
        targetOS: OS.android,
        buildMode: BuildMode.release,
        supportedAssetTypes: [CodeAsset.type],
      )
      ..setupBuildConfig(
        linkingEnabled: false,
        dryRun: false,
        metadata: metadata,
      )
      ..setupBuildRunConfig(
        outputDirectory: outDirUri,
        outputDirectoryShared: outputDirectoryShared,
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
    final config = BuildConfig(configBuilder.json);

    final expectedConfigJson = {
      'build_mode': 'release',
      'supported_asset_types': [CodeAsset.type],
      'dry_run': false,
      'linking_enabled': false,
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
      'dependency_metadata': {
        'bar': {
          'key': 'value',
          'foo': ['asdf', 'fdsa'],
        },
        'foo': {
          'key': 321,
        },
      },
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

    expect(config.linkingEnabled, false);
    expect(config.dryRun, false);
    expect(config.metadata, metadata);

    final codeConfig = config.codeConfig;
    expect(codeConfig.targetArchitecture, Architecture.arm64);
    expect(codeConfig.targetAndroidNdkApi, 30);
    expect(codeConfig.linkModePreference, LinkModePreference.preferStatic);
    expect(codeConfig.cCompiler.compiler, fakeClang);
    expect(codeConfig.cCompiler.linker, fakeLd);
    expect(codeConfig.cCompiler.archiver, fakeAr);
  });

  test('BuildConfig.dryRun', () {
    final configBuilder = BuildConfigBuilder()
      ..setupHookConfig(
        packageName: packageName,
        packageRoot: packageRootUri,
        targetOS: OS.android,
        buildMode: null, // not available in dry run
        supportedAssetTypes: [CodeAsset.type],
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
        targetArchitecture: null, // not available in dry run
        cCompilerConfig: null, // not available in dry run
        linkModePreference: LinkModePreference.preferStatic,
      );
    final config = BuildConfig(configBuilder.json);

    final expectedConfigJson = {
      'dry_run': true,
      'supported_asset_types': [CodeAsset.type],
      'linking_enabled': true,
      'link_mode_preference': 'prefer-static',
      'out_dir': outDirUri.toFilePath(),
      'out_dir_shared': outputDirectoryShared.toFilePath(),
      'package_name': packageName,
      'package_root': packageRootUri.toFilePath(),
      'target_os': 'android',
      'version': latestVersion.toString(),
    };

    expect(config.json, expectedConfigJson);
    expect(json.decode(config.toString()), expectedConfigJson);

    expect(config.outputDirectory, outDirUri);
    expect(config.outputDirectoryShared, outputDirectoryShared);

    expect(config.packageName, packageName);
    expect(config.packageRoot, packageRootUri);
    expect(config.targetOS, OS.android);
    expect(config.supportedAssetTypes, [CodeAsset.type]);
    expect(() => config.buildMode, throwsStateError);

    expect(config.linkingEnabled, true);
    expect(config.dryRun, true);
    expect(config.metadata, <String, Object?>{});

    final codeConfig = config.codeConfig;
    expect(() => codeConfig.targetArchitecture, throwsStateError);
    expect(codeConfig.targetAndroidNdkApi, null);
    expect(codeConfig.linkModePreference, LinkModePreference.preferStatic);
    expect(codeConfig.cCompiler.compiler, null);
    expect(codeConfig.cCompiler.linker, null);
    expect(codeConfig.cCompiler.archiver, null);
  });

  group('BuildConfig format issues', () {
    for (final version in ['9001.0.0', '0.0.1']) {
      test('BuildConfig version $version', () {
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
          'linking_enabled': false,
        };
        expect(
          () => BuildConfig(config),
          throwsA(predicate(
            (e) =>
                e is FormatException &&
                e.message.contains(version) &&
                e.message.contains(latestVersion.toString()),
          )),
        );
      });
    }

    test('BuildConfig FormatExceptions', () {
      expect(
        () => BuildConfig({}),
        throwsA(predicate(
          (e) =>
              e is FormatException &&
              e.message.contains(
                'No value was provided for required key: ',
              ),
        )),
      );
      expect(
        () => BuildConfig({
          'version': latestVersion.toString(),
          'package_name': packageName,
          'package_root': packageRootUri.toFilePath(),
          'target_architecture': 'arm64',
          'target_os': 'android',
          'target_android_ndk_api': 30,
          'link_mode_preference': 'prefer-static',
          'linking_enabled': true,
          'supported_asset_types': [CodeAsset.type],
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
        () => BuildConfig({
          'version': latestVersion.toString(),
          'out_dir': outDirUri.toFilePath(),
          'out_dir_shared': outputDirectoryShared.toFilePath(),
          'package_name': packageName,
          'package_root': packageRootUri.toFilePath(),
          'target_architecture': 'arm64',
          'target_os': 'android',
          'target_android_ndk_api': 30,
          'link_mode_preference': 'prefer-static',
          'linking_enabled': true,
          'build_mode': BuildMode.release.name,
          'supported_asset_types': [CodeAsset.type],
          'dependency_metadata': {
            'bar': {'key': 'value'},
            'foo': <int>[],
          },
        }),
        throwsA(predicate(
          (e) =>
              e is FormatException &&
              e.message.contains("Unexpected value '[]' ") &&
              e.message.contains('Expected a Map<String, Object?>'),
        )),
      );
    });

    test('invalid architecture', () {
      final config = {
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
        'supported_asset_types': [CodeAsset.type],
        'version': latestVersion.toString(),
      };
      expect(
        () => BuildConfig(config),
        throwsFormatException,
      );
    });
  });
}
