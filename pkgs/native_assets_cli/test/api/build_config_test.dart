// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:cli_config/cli_config.dart';
import 'package:native_assets_cli/native_assets_cli.dart';
import 'package:native_assets_cli/native_assets_cli_internal.dart' as internal;
import 'package:test/test.dart';

void main() async {
  late Uri tempUri;
  late Uri outDirUri;
  late Uri outDir2Uri;
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
    packageName = 'my_package';
    await Directory.fromUri(outDir2Uri).create();
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
    final config1 = BuildConfig(
      outDir: outDirUri,
      packageName: packageName,
      packageRoot: tempUri,
      targetArchitecture: Architecture.arm64,
      targetOs: OS.iOS,
      targetIOSSdk: IOSSdk.iPhoneOs,
      cCompiler: CCompilerConfig(
        cc: fakeClang,
        ld: fakeLd,
        ar: fakeAr,
      ),
      buildMode: BuildMode.release,
      linkModePreference: LinkModePreference.preferStatic,
    );

    final config2 = BuildConfig(
      outDir: outDir2Uri,
      packageName: packageName,
      packageRoot: tempUri,
      targetArchitecture: Architecture.arm64,
      targetOs: OS.android,
      targetAndroidNdkApi: 30,
      buildMode: BuildMode.release,
      linkModePreference: LinkModePreference.preferStatic,
    );

    expect(config1, equals(config1));
    expect(config1 == config2, false);
    expect(config1.outDirectory != config2.outDirectory, true);
    expect(config1.packageRoot, config2.packageRoot);
    expect(config1.targetArchitecture == config2.targetArchitecture, true);
    expect(config1.targetOs != config2.targetOs, true);
    expect(config1.targetIOSSdk != config2.targetIOSSdk, true);
    expect(config1.cCompiler.cc != config2.cCompiler.cc, true);
    expect(config1.cCompiler.ld != config2.cCompiler.ld, true);
    expect(config1.cCompiler.ar != config2.cCompiler.ar, true);
    expect(config1.cCompiler.envScript == config2.cCompiler.envScript, true);
    expect(config1.cCompiler.envScriptArgs == config2.cCompiler.envScriptArgs,
        true);
    expect(config1.cCompiler != config2.cCompiler, true);
    expect(config1.linkModePreference, config2.linkModePreference);
    expect(config1.dependencyMetadata, config2.dependencyMetadata);
  });

  test('BuildConfig fromConfig', () {
    final buildConfig2 = BuildConfig(
      outDir: outDirUri,
      packageName: packageName,
      packageRoot: packageRootUri,
      targetArchitecture: Architecture.arm64,
      targetOs: OS.android,
      targetAndroidNdkApi: 30,
      buildMode: BuildMode.release,
      linkModePreference: LinkModePreference.preferStatic,
    );

    final config = Config(fileParsed: {
      'build_mode': 'release',
      'dry_run': false,
      'link_mode_preference': 'prefer-static',
      'out_dir': outDirUri.toFilePath(),
      'package_name': packageName,
      'package_root': packageRootUri.toFilePath(),
      'target_android_ndk_api': 30,
      'target_architecture': 'arm64',
      'target_os': 'android',
      'version': BuildOutput.version.toString(),
    });

    final fromConfig = BuildConfig.fromConfig(config);
    expect(fromConfig, equals(buildConfig2));
  });

  test('BuildConfig.dryRun', () {
    final buildConfig2 = BuildConfig.dryRun(
      outDir: outDirUri,
      packageName: packageName,
      packageRoot: packageRootUri,
      targetOs: OS.android,
      linkModePreference: LinkModePreference.preferStatic,
    );

    final config = Config(fileParsed: {
      'dry_run': true,
      'link_mode_preference': 'prefer-static',
      'out_dir': outDirUri.toFilePath(),
      'package_name': packageName,
      'package_root': packageRootUri.toFilePath(),
      'target_os': 'android',
      'version': BuildOutput.version.toString(),
    });

    final fromConfig = BuildConfig.fromConfig(config);
    expect(fromConfig, equals(buildConfig2));
  });

  test('BuildConfig == dependency metadata', () {
    final buildConfig1 = BuildConfig(
      outDir: outDirUri,
      packageName: packageName,
      packageRoot: tempUri,
      targetArchitecture: Architecture.arm64,
      targetOs: OS.android,
      targetAndroidNdkApi: 30,
      buildMode: BuildMode.release,
      linkModePreference: LinkModePreference.preferStatic,
      dependencyMetadata: {
        'bar': const Metadata({
          'key': 'value',
          'foo': ['asdf', 'fdsa'],
        }),
        'foo': const Metadata({
          'key': 321,
        }),
      },
    );

    final buildConfig2 = BuildConfig(
      outDir: outDirUri,
      packageName: packageName,
      packageRoot: tempUri,
      targetArchitecture: Architecture.arm64,
      targetOs: OS.android,
      targetAndroidNdkApi: 30,
      buildMode: BuildMode.release,
      linkModePreference: LinkModePreference.preferStatic,
      dependencyMetadata: {
        'bar': const Metadata({
          'key': 'value',
        }),
        'foo': const Metadata({
          'key': 123,
        }),
      },
    );

    expect(buildConfig1, equals(buildConfig1));
    expect(buildConfig1 == buildConfig2, false);
    expect(buildConfig1.hashCode == buildConfig2.hashCode, false);
  });

  test('BuildConfig fromArgs', () async {
    final buildConfig = BuildConfig(
      outDir: outDirUri,
      packageName: packageName,
      packageRoot: tempUri,
      targetArchitecture: Architecture.arm64,
      targetOs: OS.android,
      targetAndroidNdkApi: 30,
      buildMode: BuildMode.release,
      linkModePreference: LinkModePreference.preferStatic,
    );
    final configFileContents =
        (buildConfig as internal.BuildConfig).toYamlString();
    final configUri = tempUri.resolve('config.yaml');
    final configFile = File.fromUri(configUri);
    await configFile.writeAsString(configFileContents);
    final buildConfigFromArgs = await BuildConfig.fromArgs(
      ['--config', configUri.toFilePath()],
      environment: {}, // Don't inherit the test environment.
    );
    expect(buildConfigFromArgs, buildConfig);
  });

  test('BuildConfig.version', () {
    BuildConfig.version.toString();
  });
}
