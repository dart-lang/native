// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: deprecated_member_use_from_same_package

import 'dart:io';

import 'package:native_assets_cli/native_assets_cli.dart';
import 'package:native_assets_cli/src/api/build_config.dart';
import 'package:test/test.dart';

void main() async {
  late Uri tempUri;
  late Uri outDirUri;
  late Uri outDir2Uri;
  late Uri outputDirectoryShared;
  late Uri outputDirectoryShared2;
  late String packageName;
  late Uri packageRootUri;
  late Uri fakeClang;
  late Uri fakeLd;
  late Uri fakeAr;
  late Uri fakeCl;
  late Uri fakeVcVars;

  setUp(() async {
    tempUri = (await Directory.systemTemp.createTemp()).uri;
    outDirUri = tempUri.resolve('out1/');
    await Directory.fromUri(outDirUri).create();
    outDir2Uri = tempUri.resolve('out2/');
    await Directory.fromUri(outDir2Uri).create();
    outputDirectoryShared = tempUri.resolve('out_shared1/');
    await Directory.fromUri(outputDirectoryShared).create();
    outputDirectoryShared2 = tempUri.resolve('out_shared2/');
    await Directory.fromUri(outputDirectoryShared2).create();
    packageName = 'my_package';
    packageRootUri = tempUri.resolve('$packageName/');
    await Directory.fromUri(packageRootUri).create();
    fakeClang = tempUri.resolve('fake_clang');
    await File.fromUri(fakeClang).create();
    fakeLd = tempUri.resolve('fake_ld');
    await File.fromUri(fakeLd).create();
    fakeAr = tempUri.resolve('fake_ar');
    await File.fromUri(fakeAr).create();
    fakeCl = tempUri.resolve('cl.exe');
    await File.fromUri(fakeCl).create();
    fakeVcVars = tempUri.resolve('vcvarsall.bat');
    await File.fromUri(fakeVcVars).create();
  });

  tearDown(() async {
    await Directory.fromUri(tempUri).delete(recursive: true);
  });

  test('BuildConfig ==', () {
    final config1 = BuildConfig.build(
      outputDirectory: outDirUri,
      outputDirectoryShared: outputDirectoryShared,
      packageName: packageName,
      packageRoot: tempUri,
      targetArchitecture: Architecture.arm64,
      targetOS: OS.iOS,
      targetIOSSdk: IOSSdk.iPhoneOS,
      cCompiler: CCompilerConfig(
        compiler: fakeClang,
        linker: fakeLd,
        archiver: fakeAr,
      ),
      buildMode: BuildMode.release,
      linkModePreference: LinkModePreference.preferStatic,
      supportedAssetTypes: [CodeAsset.type],
      linkingEnabled: false,
    );

    final config2 = BuildConfig.build(
      outputDirectory: outDir2Uri,
      outputDirectoryShared: outputDirectoryShared,
      packageName: packageName,
      packageRoot: tempUri,
      targetArchitecture: Architecture.arm64,
      targetOS: OS.android,
      targetAndroidNdkApi: 30,
      buildMode: BuildMode.release,
      linkModePreference: LinkModePreference.preferStatic,
      supportedAssetTypes: [CodeAsset.type],
      linkingEnabled: false,
    );

    expect(config1, equals(config1));
    expect(config1 == config2, false);
    expect(config1.outputDirectory != config2.outputDirectory, true);
    expect(config1.packageRoot, config2.packageRoot);
    expect(config1.targetArchitecture == config2.targetArchitecture, true);
    expect(config1.targetOS != config2.targetOS, true);
    expect(config1.targetIOSSdk, IOSSdk.iPhoneOS);
    expect(() => config2.targetIOSSdk, throwsStateError);
    expect(config1.cCompiler.compiler != config2.cCompiler.compiler, true);
    expect(config1.cCompiler.linker != config2.cCompiler.linker, true);
    expect(config1.cCompiler.archiver != config2.cCompiler.archiver, true);
    expect(config1.cCompiler.envScript == config2.cCompiler.envScript, true);
    expect(config1.cCompiler.envScriptArgs == config2.cCompiler.envScriptArgs,
        true);
    expect(config1.cCompiler != config2.cCompiler, true);
    expect(config1.linkModePreference, config2.linkModePreference);
    expect(config1.supportedAssetTypes, config2.supportedAssetTypes);
    expect(config1.linkingEnabled, config2.linkingEnabled);
  });

  test('BuildConfig fromConfig', () {
    final buildConfig2 = BuildConfig.build(
      outputDirectory: outDirUri,
      outputDirectoryShared: outputDirectoryShared,
      packageName: packageName,
      packageRoot: packageRootUri,
      targetArchitecture: Architecture.arm64,
      targetOS: OS.android,
      targetAndroidNdkApi: 30,
      buildMode: BuildMode.release,
      linkModePreference: LinkModePreference.preferStatic,
      linkingEnabled: false,
    );

    final config = {
      'build_mode': 'release',
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
      'version': BuildOutput.latestVersion.toString(),
    };

    final fromConfig = BuildConfigImpl.fromJson(config);
    expect(fromConfig, equals(buildConfig2));
  });

  test('BuildConfig.dryRun', () {
    final buildConfig2 = BuildConfig.dryRun(
      outputDirectory: outDirUri,
      outputDirectoryShared: outputDirectoryShared,
      packageName: packageName,
      packageRoot: packageRootUri,
      targetOS: OS.android,
      linkModePreference: LinkModePreference.preferStatic,
      supportedAssetTypes: [CodeAsset.type],
      linkingEnabled: true,
    );

    final config = {
      'dry_run': true,
      'linking_enabled': true,
      'link_mode_preference': 'prefer-static',
      'out_dir': outDirUri.toFilePath(),
      'out_dir_shared': outputDirectoryShared.toFilePath(),
      'package_name': packageName,
      'package_root': packageRootUri.toFilePath(),
      'target_os': 'android',
      'version': BuildOutput.latestVersion.toString(),
    };

    final fromConfig = BuildConfigImpl.fromJson(config);
    expect(fromConfig, equals(buildConfig2));
  });

  test('BuildConfig == dependency metadata', () {
    final buildConfig1 = BuildConfig.build(
      outputDirectory: outDirUri,
      outputDirectoryShared: outputDirectoryShared,
      packageName: packageName,
      packageRoot: tempUri,
      targetArchitecture: Architecture.arm64,
      targetOS: OS.android,
      targetAndroidNdkApi: 30,
      buildMode: BuildMode.release,
      linkModePreference: LinkModePreference.preferStatic,
      dependencyMetadata: {
        'bar': {
          'key': 'value',
          'foo': ['asdf', 'fdsa'],
        },
        'foo': {
          'key': 321,
        },
      },
      linkingEnabled: false,
    );

    final buildConfig2 = BuildConfig.build(
      outputDirectory: outDirUri,
      outputDirectoryShared: outputDirectoryShared,
      packageName: packageName,
      packageRoot: tempUri,
      targetArchitecture: Architecture.arm64,
      targetOS: OS.android,
      targetAndroidNdkApi: 30,
      buildMode: BuildMode.release,
      linkModePreference: LinkModePreference.preferStatic,
      dependencyMetadata: {
        'bar': {
          'key': 'value',
        },
        'foo': {
          'key': 123,
        },
      },
      linkingEnabled: false,
    );

    expect(buildConfig1, equals(buildConfig1));
    expect(buildConfig1 == buildConfig2, false);
    expect(buildConfig1.hashCode == buildConfig2.hashCode, false);

    expect(buildConfig1.metadatum('bar', 'key'), 'value');
  });

  test('BuildConfig == hasLinkConfig', () {
    final buildConfig1 = BuildConfig.build(
      outputDirectory: outDirUri,
      outputDirectoryShared: outputDirectoryShared,
      packageName: packageName,
      packageRoot: tempUri,
      targetArchitecture: Architecture.x64,
      targetOS: OS.windows,
      buildMode: BuildMode.release,
      linkModePreference: LinkModePreference.preferStatic,
      linkingEnabled: true,
    );

    final buildConfig2 = BuildConfig.build(
      outputDirectory: outDirUri,
      outputDirectoryShared: outputDirectoryShared,
      packageName: packageName,
      packageRoot: tempUri,
      targetArchitecture: Architecture.x64,
      targetOS: OS.windows,
      buildMode: BuildMode.release,
      linkModePreference: LinkModePreference.preferStatic,
      linkingEnabled: false,
    );

    expect(buildConfig1, equals(buildConfig1));
    expect(buildConfig1.hashCode, isNot(buildConfig2.hashCode));
    expect(buildConfig1, isNot(buildConfig2));
  });

  test('BuildConfig fromArgs', () async {
    final buildConfig = BuildConfig.build(
      outputDirectory: outDirUri,
      outputDirectoryShared: outputDirectoryShared,
      packageName: packageName,
      packageRoot: tempUri,
      targetArchitecture: Architecture.arm64,
      targetOS: OS.android,
      targetAndroidNdkApi: 30,
      buildMode: BuildMode.release,
      linkModePreference: LinkModePreference.preferStatic,
      linkingEnabled: false,
    );
    final configFileContents = (buildConfig as BuildConfigImpl).toJsonString();
    final configUri = tempUri.resolve('config.json');
    final configFile = File.fromUri(configUri);
    await configFile.writeAsString(configFileContents);
    final buildConfigFromArgs = BuildConfig(
      ['--config', configUri.toFilePath()],
      environment: {}, // Don't inherit the test environment.
    );
    expect(buildConfigFromArgs, buildConfig);
  });

  test('BuildConfig.version', () {
    BuildConfig.latestVersion.toString();
  });
}
