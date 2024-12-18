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

  BuildConfigBuilder makeBuildConfigBuilder() {
    final configBuilder = BuildConfigBuilder()
      ..setupHook(
        packageName: packageName,
        packageRoot: tempUri,
        buildAssetTypes: [CodeAsset.type],
      )
      ..setupBuild(
        linkingEnabled: false,
        dryRun: false,
      )
      ..setupBuildAfterChecksum(
        outputDirectory: outDirUri,
        outputDirectoryShared: outDirSharedUri,
      );
    return configBuilder;
  }

  BuildConfig makeCodeBuildConfig({
    LinkModePreference linkModePreference = LinkModePreference.dynamic,
  }) {
    final builder = makeBuildConfigBuilder()
      ..setupCode(
        targetOS: OS.linux,
        targetArchitecture: Architecture.arm64,
        linkModePreference: linkModePreference,
      );
    return BuildConfig(builder.json);
  }

  test('file not set', () async {
    final config = makeCodeBuildConfig();
    final outputBuilder = BuildOutputBuilder();
    outputBuilder.code.addAsset(CodeAsset(
      package: config.packageName,
      name: 'foo.dylib',
      architecture: config.code.targetArchitecture,
      os: config.code.targetOS,
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
      outputBuilder.code.addAsset(
        CodeAsset(
          package: config.packageName,
          name: 'foo.dart',
          file: assetFile.uri,
          linkMode: linkMode,
          os: config.code.targetOS,
          architecture: config.code.targetArchitecture,
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
    outputBuilder.code.addAsset(
      CodeAsset(
        package: config.packageName,
        name: 'foo.dart',
        file: assetFile.uri,
        linkMode: DynamicLoadingBundled(),
        os: config.code.targetOS,
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
    outputBuilder.code.addAsset(
      CodeAsset(
        package: config.packageName,
        name: 'foo.dart',
        file: assetFile.uri,
        linkMode: DynamicLoadingBundled(),
        os: config.code.targetOS,
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
    outputBuilder.code.addAsset(
      CodeAsset(
        package: config.packageName,
        name: 'foo.dart',
        file: assetFile.uri,
        linkMode: DynamicLoadingBundled(),
        os: OS.windows,
        architecture: config.code.targetArchitecture,
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
    final fileName = config.code.targetOS.dylibFileName('foo');
    final assetFile = File.fromUri(outDirUri.resolve(fileName));
    await assetFile.writeAsBytes([1, 2, 3]);
    outputBuilder.code.addAssets([
      CodeAsset(
        package: config.packageName,
        name: 'src/foo.dart',
        file: assetFile.uri,
        linkMode: DynamicLoadingBundled(),
        os: config.code.targetOS,
        architecture: config.code.targetArchitecture,
      ),
      CodeAsset(
        package: config.packageName,
        name: 'src/bar.dart',
        file: assetFile.uri,
        linkMode: DynamicLoadingBundled(),
        os: config.code.targetOS,
        architecture: config.code.targetArchitecture,
      ),
    ]);
    final errors = await validateCodeAssetBuildOutput(
        config, BuildOutput(outputBuilder.json));
    expect(
      errors,
      contains(contains('Duplicate dynamic library file name')),
    );
  });

  group('BuildConfig.code validation', () {
    test('Missing targetIOSVersion', () async {
      final builder = makeBuildConfigBuilder()
        ..setupCode(
          targetOS: OS.iOS,
          targetArchitecture: Architecture.arm64,
          linkModePreference: LinkModePreference.dynamic,
        );
      final errors =
          await validateCodeAssetBuildConfig(BuildConfig(builder.json));
      expect(errors,
          contains(contains('BuildConfig.code.iOS.targetVersion was missing')));
      expect(errors,
          contains(contains('BuildConfig.code.iOS.targetSdk was missing')));
    });
    test('Missing targetAndroidNdkApi', () async {
      final builder = makeBuildConfigBuilder()
        ..setupCode(
          targetOS: OS.android,
          targetArchitecture: Architecture.arm64,
          linkModePreference: LinkModePreference.dynamic,
        );
      expect(
        await validateCodeAssetBuildConfig(BuildConfig(builder.json)),
        contains(contains('BuildConfig.code.android.targetNdkApi was missing')),
      );
    });
    test('Missing targetMacOSVersion', () async {
      final builder = makeBuildConfigBuilder()
        ..setupCode(
          targetOS: OS.macOS,
          targetArchitecture: Architecture.arm64,
          linkModePreference: LinkModePreference.dynamic,
        );
      expect(
          await validateCodeAssetBuildConfig(BuildConfig(builder.json)),
          contains(
              contains('BuildConfig.code.macOS.targetVersion was missing')));
    });
    test('Nonexisting compiler/archiver/linker/envScript', () async {
      final nonExistent = outDirUri.resolve('foo baz');
      final builder = makeBuildConfigBuilder()
        ..setupCode(
            targetOS: OS.linux,
            targetArchitecture: Architecture.arm64,
            linkModePreference: LinkModePreference.dynamic,
            cCompiler: CCompilerConfig(
              compiler: nonExistent,
              linker: nonExistent,
              archiver: nonExistent,
              envScript: nonExistent,
            ));
      final errors =
          await validateCodeAssetBuildConfig(BuildConfig(builder.json));

      bool matches(String error, String field) =>
          RegExp('BuildConfig.code.$field (.*foo baz).* does not exist.')
              .hasMatch(error);

      expect(errors.any((e) => matches(e, 'compiler')), true);
      expect(errors.any((e) => matches(e, 'linker')), true);
      expect(errors.any((e) => matches(e, 'archiver')), true);
      expect(errors.any((e) => matches(e, 'envScript')), true);
    });
  });
}
