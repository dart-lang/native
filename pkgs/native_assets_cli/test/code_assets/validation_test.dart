// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:native_assets_cli/code_assets_builder.dart';
import 'package:test/test.dart';

void main() {
  late Uri tempUri;
  late Uri outDirUri;
  late Uri outDirSharedUri;
  late String packageName;
  late Uri packageRootUri;

  setUp(() async {
    tempUri = (await Directory.systemTemp.createTemp()).uri;
    outDirUri = tempUri.resolve('out/');
    await Directory.fromUri(outDirUri).create();
    outDirSharedUri = tempUri.resolve('out_shared/');
    await Directory.fromUri(outDirSharedUri).create();
    packageName = 'my_package';
    packageRootUri = tempUri.resolve('$packageName/');
    await Directory.fromUri(packageRootUri).create();
  });

  tearDown(() async {
    await Directory.fromUri(tempUri).delete(recursive: true);
  });

  BuildConfigBuilder makeBuildConfigBuilder({OS os = OS.iOS}) {
    final configBuilder = BuildConfigBuilder()
      ..setupHookConfig(
        packageName: packageName,
        packageRoot: tempUri,
        targetOS: os,
        buildAssetTypes: [CodeAsset.type],
      )
      ..setupBuildConfig(
        linkingEnabled: false,
        dryRun: false,
      )
      ..setupBuildRunConfig(
        outputDirectory: outDirUri,
        outputDirectoryShared: outDirSharedUri,
      );
    return configBuilder;
  }

  BuildConfig makeCodeBuildConfig(
      {LinkModePreference linkModePreference = LinkModePreference.dynamic}) {
    final builder = makeBuildConfigBuilder()
      ..setupCodeConfig(
        targetArchitecture: Architecture.arm64,
        targetIOSSdk: IOSSdk.iPhoneOS,
        linkModePreference: linkModePreference,
        buildMode: BuildMode.release,
      );
    return BuildConfig(builder.json);
  }

  test('file not set', () async {
    final config = makeCodeBuildConfig();
    final outputBuilder = BuildOutputBuilder();
    outputBuilder.codeAssets.add(CodeAsset(
      package: config.packageName,
      name: 'foo.dylib',
      architecture: config.codeConfig.targetArchitecture,
      os: config.targetOS,
      linkMode: DynamicLoadingBundled(),
    ));
    final errors = await validateCodeAssetBuildOutput(
        config, BuildOutput(outputBuilder.json));
    expect(
      errors,
      contains(contains('has no file')),
    );
  });

  for (final (linkModePreference, linkMode) in [
    (LinkModePreference.static, DynamicLoadingBundled()),
    (LinkModePreference.dynamic, StaticLinking()),
  ]) {
    test('native code asset wrong linking $linkModePreference', () async {
      final config =
          makeCodeBuildConfig(linkModePreference: linkModePreference);
      final outputBuilder = BuildOutputBuilder();
      final assetFile = File.fromUri(outDirUri.resolve('foo.dylib'));
      await assetFile.writeAsBytes([1, 2, 3]);
      outputBuilder.codeAssets.add(
        CodeAsset(
          package: config.packageName,
          name: 'foo.dart',
          file: assetFile.uri,
          linkMode: linkMode,
          os: config.targetOS,
          architecture: config.codeConfig.targetArchitecture,
        ),
      );
      final errors = await validateCodeAssetBuildOutput(
          config, BuildOutput(outputBuilder.json));
      expect(
        errors,
        contains(contains(
          'which is not allowed by by the config link mode preference',
        )),
      );
    });
  }

  test('native code wrong architecture', () async {
    final config = makeCodeBuildConfig();
    final outputBuilder = BuildOutputBuilder();
    final assetFile = File.fromUri(outDirUri.resolve('foo.dylib'));
    await assetFile.writeAsBytes([1, 2, 3]);
    outputBuilder.codeAssets.add(
      CodeAsset(
        package: config.packageName,
        name: 'foo.dart',
        file: assetFile.uri,
        linkMode: DynamicLoadingBundled(),
        os: config.targetOS,
        architecture: Architecture.x64,
      ),
    );
    final errors = await validateCodeAssetBuildOutput(
        config, BuildOutput(outputBuilder.json));
    expect(
      errors,
      contains(contains(
        'which is not the target architecture',
      )),
    );
  });

  test('native code no architecture', () async {
    final config = makeCodeBuildConfig();
    final outputBuilder = BuildOutputBuilder();
    final assetFile = File.fromUri(outDirUri.resolve('foo.dylib'));
    await assetFile.writeAsBytes([1, 2, 3]);
    outputBuilder.codeAssets.add(
      CodeAsset(
        package: config.packageName,
        name: 'foo.dart',
        file: assetFile.uri,
        linkMode: DynamicLoadingBundled(),
        os: config.targetOS,
      ),
    );
    final errors = await validateCodeAssetBuildOutput(
        config, BuildOutput(outputBuilder.json));
    expect(
      errors,
      contains(contains(
        'has no architecture',
      )),
    );
  });

  test('native code asset wrong os', () async {
    final config = makeCodeBuildConfig();
    final outputBuilder = BuildOutputBuilder();
    final assetFile = File.fromUri(outDirUri.resolve('foo.dylib'));
    await assetFile.writeAsBytes([1, 2, 3]);
    outputBuilder.codeAssets.add(
      CodeAsset(
        package: config.packageName,
        name: 'foo.dart',
        file: assetFile.uri,
        linkMode: DynamicLoadingBundled(),
        os: OS.windows,
        architecture: config.codeConfig.targetArchitecture,
      ),
    );
    final errors = await validateCodeAssetBuildOutput(
        config, BuildOutput(outputBuilder.json));
    expect(
      errors,
      contains(contains(
        'which is not the target os',
      )),
    );
  });

  test('duplicate dylib name', () async {
    final config = makeCodeBuildConfig();
    final outputBuilder = BuildOutputBuilder();
    final fileName = config.targetOS.dylibFileName('foo');
    final assetFile = File.fromUri(outDirUri.resolve(fileName));
    await assetFile.writeAsBytes([1, 2, 3]);
    outputBuilder.codeAssets.addAll([
      CodeAsset(
        package: config.packageName,
        name: 'src/foo.dart',
        file: assetFile.uri,
        linkMode: DynamicLoadingBundled(),
        os: config.targetOS,
        architecture: config.codeConfig.targetArchitecture,
      ),
      CodeAsset(
        package: config.packageName,
        name: 'src/bar.dart',
        file: assetFile.uri,
        linkMode: DynamicLoadingBundled(),
        os: config.targetOS,
        architecture: config.codeConfig.targetArchitecture,
      ),
    ]);
    final errors = await validateCodeAssetBuildOutput(
        config, BuildOutput(outputBuilder.json));
    expect(
      errors,
      contains(contains('Duplicate dynamic library file name')),
    );
  });

  group('BuildConfig.codeConfig validation', () {
    test('Missing targetIOSVersion', () async {
      final builder = makeBuildConfigBuilder(os: OS.iOS)
        ..setupCodeConfig(
          targetArchitecture: Architecture.arm64,
          linkModePreference: LinkModePreference.dynamic,
          buildMode: BuildMode.release,
        );
      final errors =
          await validateCodeAssetBuildConfig(BuildConfig(builder.json));
      expect(
          errors,
          contains(
              contains('BuildConfig.codeConfig.targetIOSVersion was missing')));
      expect(
          errors,
          contains(
              contains('BuildConfig.codeConfig.targetIOSSdk was missing')));
    });
    test('Missing targetAndroidNdkApi', () async {
      final builder = makeBuildConfigBuilder(os: OS.android)
        ..setupCodeConfig(
          targetArchitecture: Architecture.arm64,
          linkModePreference: LinkModePreference.dynamic,
          buildMode: BuildMode.release,
        );
      expect(
          await validateCodeAssetBuildConfig(BuildConfig(builder.json)),
          contains(contains(
              'BuildConfig.codeConfig.targetAndroidNdkApi was missing')));
    });
    test('Missing targetMacOSVersion', () async {
      final builder = makeBuildConfigBuilder(os: OS.macOS)
        ..setupCodeConfig(
          targetArchitecture: Architecture.arm64,
          linkModePreference: LinkModePreference.dynamic,
          buildMode: BuildMode.release,
        );
      expect(
          await validateCodeAssetBuildConfig(BuildConfig(builder.json)),
          contains(contains(
              'BuildConfig.codeConfig.targetMacOSVersion was missing')));
    });
    test('Nonexisting compiler/archiver/linker/envScript', () async {
      final nonExistent = outDirUri.resolve('foo baz');
      final builder = makeBuildConfigBuilder(os: OS.linux)
        ..setupCodeConfig(
          targetArchitecture: Architecture.arm64,
          linkModePreference: LinkModePreference.dynamic,
          cCompilerConfig: CCompilerConfig(
            compiler: nonExistent,
            linker: nonExistent,
            archiver: nonExistent,
            envScript: nonExistent,
          ),
          buildMode: BuildMode.release,
        );
      final errors =
          await validateCodeAssetBuildConfig(BuildConfig(builder.json));

      bool matches(String error, String field) =>
          RegExp('BuildConfig.codeConfig.$field (.*foo baz).* does not exist.')
              .hasMatch(error);

      expect(errors.any((e) => matches(e, 'compiler')), true);
      expect(errors.any((e) => matches(e, 'linker')), true);
      expect(errors.any((e) => matches(e, 'archiver')), true);
      expect(errors.any((e) => matches(e, 'envScript')), true);
    });
  });
}
