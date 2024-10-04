// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:native_assets_cli/native_assets_cli_internal.dart';
import 'package:test/test.dart';

void main() async {
  late Uri tempUri;
  late Uri outDirUri;
  late Uri outDir2Uri;
  late Uri outputDirectoryShared;
  late Uri outputDirectoryShared2;
  const packageName = 'my_package';
  late Uri packageRootUri;
  late Uri fakeClang;
  late Uri fakeLd;
  late Uri fakeAr;
  late Uri fakeCl;
  late Uri fakeVcVars;
  late Uri recordedUsagesFile;
  final assets = [
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
    recordedUsagesFile = tempUri.resolve('recorded_usages.json');
    File.fromUri(recordedUsagesFile).createSync();
  });

  tearDown(() async {
    await Directory.fromUri(tempUri).delete(recursive: true);
  });

  test('LinkConfig ==', () {
    final config1 = LinkConfigImpl(
      supportedAssetTypes: [CodeAsset.type],
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
      encodedAssets: assets,
      recordedUsagesFile: recordedUsagesFile,
      linkModePreference: LinkModePreference.preferStatic,
    );

    final config2 = LinkConfigImpl(
      supportedAssetTypes: [CodeAsset.type],
      outputDirectory: outDir2Uri,
      outputDirectoryShared: outputDirectoryShared,
      packageName: packageName,
      packageRoot: tempUri,
      targetArchitecture: Architecture.arm64,
      targetOS: OS.android,
      targetAndroidNdkApi: 30,
      buildMode: BuildMode.release,
      encodedAssets: [],
      recordedUsagesFile: null,
      linkModePreference: LinkModePreference.preferStatic,
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
    expect(config1.encodedAssets != config2.encodedAssets, true);
  });

  test('LinkConfig fromConfig', () {
    final buildConfig2 = LinkConfigImpl(
      supportedAssetTypes: [CodeAsset.type],
      outputDirectory: outDirUri,
      outputDirectoryShared: outputDirectoryShared,
      packageName: packageName,
      packageRoot: packageRootUri,
      targetArchitecture: Architecture.arm64,
      targetOS: OS.android,
      targetAndroidNdkApi: 30,
      buildMode: BuildMode.release,
      encodedAssets: assets,
      linkModePreference: LinkModePreference.preferStatic,
    );

    final config = {
      'build_mode': 'release',
      'supported_asset_types': [CodeAsset.type],
      'dry_run': false,
      'link_mode_preference': 'prefer-static',
      'out_dir': outDirUri.toFilePath(),
      'out_dir_shared': outputDirectoryShared.toFilePath(),
      'package_name': packageName,
      'package_root': packageRootUri.toFilePath(),
      'target_android_ndk_api': 30,
      'target_architecture': 'arm64',
      'target_os': 'android',
      'version': HookOutputImpl.latestVersion.toString(),
      'assets': [for (final asset in assets) asset.toJson()],
    };

    final fromConfig = LinkConfigImpl.fromJson(config);
    expect(fromConfig, equals(buildConfig2));
  });

  test('LinkConfig.dryRun', () {
    final buildConfig2 = LinkConfigImpl.dryRun(
      supportedAssetTypes: [CodeAsset.type],
      outputDirectory: outDirUri,
      outputDirectoryShared: outputDirectoryShared,
      packageName: packageName,
      packageRoot: packageRootUri,
      targetOS: OS.android,
      encodedAssets: [],
      linkModePreference: LinkModePreference.preferStatic,
    );

    final config = {
      'dry_run': true,
      'supported_asset_types': [CodeAsset.type],
      'link_mode_preference': 'prefer-static',
      'out_dir': outDirUri.toFilePath(),
      'out_dir_shared': outputDirectoryShared.toFilePath(),
      'package_name': packageName,
      'package_root': packageRootUri.toFilePath(),
      'target_os': 'android',
      'version': HookOutputImpl.latestVersion.toString(),
      'assets': <String>[],
    };

    final fromConfig = LinkConfigImpl.fromJson(config);
    expect(fromConfig, equals(buildConfig2));
  });

  test('LinkConfig toJson fromConfig', () {
    final buildConfig1 = LinkConfigImpl(
      supportedAssetTypes: [CodeAsset.type],
      outputDirectory: outDirUri,
      outputDirectoryShared: outputDirectoryShared,
      packageName: packageName,
      packageRoot: packageRootUri,
      targetArchitecture: Architecture.arm64,
      targetOS: OS.iOS,
      targetIOSSdk: IOSSdk.iPhoneOS,
      cCompiler: CCompilerConfig(
        compiler: fakeClang,
        linker: fakeLd,
      ),
      buildMode: BuildMode.release,
      encodedAssets: assets,
      linkModePreference: LinkModePreference.preferStatic,
    );

    final configFile = buildConfig1.toJson();
    final fromConfig = LinkConfigImpl.fromJson(configFile);
    expect(fromConfig, equals(buildConfig1));
  });

  test('LinkConfig toJson fromJson', () {
    final outDir = outDirUri;
    final buildConfig1 = LinkConfigImpl(
      supportedAssetTypes: [CodeAsset.type],
      outputDirectory: outDir,
      outputDirectoryShared: outputDirectoryShared,
      packageName: packageName,
      packageRoot: tempUri,
      targetArchitecture: Architecture.arm64,
      targetOS: OS.iOS,
      targetIOSSdk: IOSSdk.iPhoneOS,
      cCompiler: CCompilerConfig(
        compiler: fakeClang,
        linker: fakeLd,
      ),
      buildMode: BuildMode.release,
      encodedAssets: assets,
      linkModePreference: LinkModePreference.preferStatic,
    );

    final jsonObject = buildConfig1.toJson();
    final expectedJson = {
      'assets': [for (final asset in assets) asset.toJson()],
      'supported_asset_types': [CodeAsset.type],
      'build_mode': 'release',
      'c_compiler': {'cc': fakeClang.toFilePath(), 'ld': fakeLd.toFilePath()},
      'out_dir': outDir.toFilePath(),
      'out_dir_shared': outputDirectoryShared.toFilePath(),
      'package_name': packageName,
      'package_root': tempUri.toFilePath(),
      'target_architecture': 'arm64',
      'target_ios_sdk': 'iphoneos',
      'target_os': 'ios',
      'version': '${HookConfigImpl.latestVersion}',
      'link_mode_preference': 'prefer-static',
    };
    expect(jsonObject, equals(expectedJson));

    final buildConfig2 = LinkConfigImpl.fromJson(jsonObject);
    expect(buildConfig2, buildConfig1);
  });

  test('LinkConfig FormatExceptions', () {
    expect(
      () => LinkConfigImpl.fromJson({}),
      throwsA(predicate(
        (e) =>
            e is FormatException &&
            e.message
                .contains('No value was provided for required key: target_os'),
      )),
    );
    expect(
      () => LinkConfigImpl.fromJson({
        'version': HookConfigImpl.latestVersion.toString(),
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
      () => LinkConfigImpl.fromJson({
        'version': HookConfigImpl.latestVersion.toString(),
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
    expect(
      () => LinkConfigImpl.fromJson({
        'supported_asset_types': [CodeAsset.type],
        'out_dir': outDirUri.toFilePath(),
        'out_dir_shared': outputDirectoryShared.toFilePath(),
        'version': HookConfigImpl.latestVersion.toString(),
        'package_name': packageName,
        'package_root': packageRootUri.toFilePath(),
        'target_architecture': 'arm64',
        'target_os': 'android',
        'build_mode': BuildMode.release.name,
        'link_mode_preference': LinkModePreference.preferStatic.name,
      }),
      throwsA(predicate(
        (e) =>
            e is FormatException &&
            e.message.contains(
              'No value was provided for required key: target_android_ndk_api',
            ),
      )),
    );
  });

  test('LinkConfig toString', () {
    final config = LinkConfigImpl(
      supportedAssetTypes: [CodeAsset.type],
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
      ),
      buildMode: BuildMode.release,
      encodedAssets: assets,
      linkModePreference: LinkModePreference.preferStatic,
    );
    expect(config.toString(), isNotEmpty);
  });

  test('LinkConfig fromArgs', () async {
    final buildConfig = LinkConfigImpl(
      supportedAssetTypes: [CodeAsset.type],
      outputDirectory: outDirUri,
      outputDirectoryShared: outputDirectoryShared,
      packageName: packageName,
      packageRoot: tempUri,
      targetArchitecture: Architecture.arm64,
      targetOS: OS.android,
      targetAndroidNdkApi: 30,
      buildMode: BuildMode.release,
      encodedAssets: assets,
      recordedUsagesFile: recordedUsagesFile,
      linkModePreference: LinkModePreference.preferStatic,
    );
    final configFileContents = buildConfig.toJsonString();
    final configUri = tempUri.resolve('config.json');
    final configFile = File.fromUri(configUri);
    await configFile.writeAsString(configFileContents);
    final buildConfig2 =
        LinkConfigImpl.fromArguments(['--config', configUri.toFilePath()]);
    expect(buildConfig2, buildConfig);
  });

  for (final version in ['9001.0.0', '0.0.1']) {
    test('LinkConfig version $version', () {
      final outDir = outDirUri;
      final config = {
        'link_mode_preference': 'prefer-static',
        'out_dir': outDir.toFilePath(),
        'out_dir_shared': outputDirectoryShared.toFilePath(),
        'package_root': tempUri.toFilePath(),
        'target_os': 'linux',
        'version': version,
        'package_name': packageName,
        'dry_run': true,
      };
      expect(
        () => LinkConfigImpl.fromJson(config),
        throwsA(predicate(
          (e) =>
              e is FormatException &&
              e.message.contains(version) &&
              e.message.contains(HookConfigImpl.latestVersion.toString()),
        )),
      );
    });
  }

  test('LinkConfig invalid target os architecture combination', () {
    final outDir = outDirUri;
    final config = {
      'link_mode_preference': 'prefer-static',
      'out_dir': outDir.toFilePath(),
      'out_dir_shared': outputDirectoryShared.toFilePath(),
      'package_name': packageName,
      'package_root': tempUri.toFilePath(),
      'target_os': 'windows',
      'target_architecture': 'arm',
      'build_mode': 'debug',
      'version': HookConfigImpl.latestVersion.toString(),
    };
    expect(
      () => LinkConfigImpl.fromJson(config),
      throwsA(predicate(
        (e) => e is FormatException && e.message.contains('arm'),
      )),
    );
  });

  test('LinkConfig dry_run access invalid args', () {
    final outDir = outDirUri;
    final config = {
      'link_mode_preference': 'prefer-static',
      'out_dir': outDir.toFilePath(),
      'out_dir_shared': outputDirectoryShared.toFilePath(),
      'package_name': packageName,
      'package_root': tempUri.toFilePath(),
      'target_os': 'windows',
      'target_architecture': 'arm64',
      'build_mode': 'debug',
      'dry_run': true,
      'version': HookConfigImpl.latestVersion.toString(),
    };
    expect(
      () => LinkConfigImpl.fromJson(config),
      throwsA(predicate(
        (e) =>
            e is FormatException && e.message.contains('In Flutter projects'),
      )),
    );
  });

  test('LinkConfig dry_run access invalid args', () {
    final outDir = outDirUri;
    final config = {
      'link_mode_preference': 'prefer-static',
      'supported_asset_types': [CodeAsset.type],
      'out_dir': outDir.toFilePath(),
      'out_dir_shared': outputDirectoryShared.toFilePath(),
      'package_name': packageName,
      'package_root': tempUri.toFilePath(),
      'target_os': 'android',
      'dry_run': true,
      'version': HookConfigImpl.latestVersion.toString(),
    };
    final buildConfig = LinkConfigImpl.fromJson(config);
    expect(
      () => buildConfig.targetAndroidNdkApi,
      throwsA(predicate(
        (e) => e is StateError && e.message.contains('In Flutter projects'),
      )),
    );
  });

  test('LinkConfig dry_run target arch', () {
    final outDir = outDirUri;
    final config = {
      'supported_asset_types': [CodeAsset.type],
      'link_mode_preference': 'prefer-static',
      'out_dir': outDir.toFilePath(),
      'out_dir_shared': outputDirectoryShared.toFilePath(),
      'package_name': packageName,
      'package_root': tempUri.toFilePath(),
      'target_os': 'windows',
      'dry_run': true,
      'version': HookConfigImpl.latestVersion.toString(),
    };
    final buildConfig = LinkConfigImpl.fromJson(config);
    expect(buildConfig.targetArchitecture, isNull);
  });

  test('LinkConfig dry_run toString', () {
    final buildConfig = LinkConfigImpl.dryRun(
      supportedAssetTypes: [CodeAsset.type],
      packageName: packageName,
      outputDirectory: outDirUri,
      outputDirectoryShared: outputDirectoryShared,
      packageRoot: tempUri,
      targetOS: OS.windows,
      encodedAssets: assets,
      linkModePreference: LinkModePreference.preferStatic,
    );
    expect(buildConfig.toJsonString(), isNotEmpty);
  });

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
      'version': HookOutputImpl.latestVersion.toString(),
    };
    expect(
      () => LinkConfigImpl.fromJson(config),
      throwsFormatException,
    );
  });
}
