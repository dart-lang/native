// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:native_assets_cli/native_assets_cli_internal.dart';
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

  BuildConfig makeCodeBuildConfig(
      {LinkModePreference linkModePreference = LinkModePreference.dynamic}) {
    final configBuilder = BuildConfigBuilder()
      ..setupHookConfig(
        packageName: packageName,
        packageRoot: tempUri,
        targetOS: OS.iOS,
        buildMode: BuildMode.release,
        supportedAssetTypes: [CodeAsset.type],
      )
      ..setupBuildConfig(
        linkingEnabled: false,
        dryRun: false,
      )
      ..setupBuildRunConfig(
        outputDirectory: outDirUri,
        outputDirectoryShared: outDirSharedUri,
      )
      ..setupCodeConfig(
        targetArchitecture: Architecture.arm64,
        targetIOSSdk: IOSSdk.iPhoneOS,
        linkModePreference: linkModePreference,
      );
    return BuildConfig(configBuilder.json);
  }

  LinkConfig makeCodeLinkConfig() {
    final configBuilder = LinkConfigBuilder()
      ..setupHookConfig(
        packageName: packageName,
        packageRoot: tempUri,
        targetOS: OS.iOS,
        buildMode: BuildMode.release,
        supportedAssetTypes: [CodeAsset.type],
      )
      ..setupLinkConfig(assets: [])
      ..setupLinkRunConfig(
        outputDirectory: outDirUri,
        outputDirectoryShared: outDirSharedUri,
        recordedUsesFile: null,
      )
      ..setupCodeConfig(
        targetArchitecture: Architecture.arm64,
        targetIOSSdk: IOSSdk.iPhoneOS,
        linkModePreference: LinkModePreference.dynamic,
      );
    return LinkConfig(configBuilder.json);
  }

  BuildConfig makeDataBuildConfig() {
    final configBuilder = BuildConfigBuilder()
      ..setupHookConfig(
          packageName: packageName,
          packageRoot: tempUri,
          targetOS: OS.iOS,
          buildMode: BuildMode.release,
          supportedAssetTypes: [DataAsset.type])
      ..setupBuildConfig(
        linkingEnabled: false,
        dryRun: false,
      )
      ..setupBuildRunConfig(
        outputDirectory: outDirUri,
        outputDirectoryShared: outDirSharedUri,
      );
    return BuildConfig(configBuilder.json);
  }

  test('linking not enabled', () async {
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
        architecture: config.codeConfig.targetArchitecture,
      ),
      linkInPackage: 'bar',
    );
    final errors =
        await validateBuildOutput(config, BuildOutput(outputBuilder.json));
    expect(
      errors,
      contains(contains('linkingEnabled is false')),
    );
  });

  test('supported asset type', () async {
    final config = makeCodeBuildConfig();
    final outputBuilder = BuildOutputBuilder();
    final assetFile = File.fromUri(outDirUri.resolve('foo.dylib'));
    await assetFile.writeAsBytes([1, 2, 3]);
    outputBuilder.dataAssets.add(DataAsset(
      package: config.packageName,
      name: 'foo.txt',
      file: assetFile.uri,
    ));
    final errors =
        await validateBuildOutput(config, BuildOutput(outputBuilder.json));
    expect(
      errors,
      contains(contains('"data" is not a supported asset type')),
    );
  });

  test('file exists', () async {
    final config = makeCodeBuildConfig();
    final outputBuilder = BuildOutputBuilder();
    final assetFile = File.fromUri(outDirUri.resolve('foo.dylib'));
    outputBuilder.dataAssets.add(DataAsset(
      package: config.packageName,
      name: 'foo.txt',
      file: assetFile.uri,
    ));
    final errors = await validateDataAssetBuildOutput(
        config, BuildOutput(outputBuilder.json));
    expect(
      errors,
      contains(contains('which does not exist')),
    );
  });

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

  test('asset id in wrong package', () async {
    final config = makeDataBuildConfig();
    final outputBuilder = BuildOutputBuilder();
    final assetFile = File.fromUri(outDirUri.resolve('foo.dylib'));
    await assetFile.writeAsBytes([1, 2, 3]);
    outputBuilder.dataAssets.add(DataAsset(
      package: 'different_package',
      name: 'foo.txt',
      file: assetFile.uri,
    ));
    final errors = await validateDataAssetBuildOutput(
        config, BuildOutput(outputBuilder.json));
    expect(
      errors,
      contains(contains('Data asset must have package name my_package')),
    );
  });

  test('duplicate asset id', () async {
    final config = makeDataBuildConfig();
    final outputBuilder = BuildOutputBuilder();
    final assetFile = File.fromUri(outDirUri.resolve('foo.dylib'));
    await assetFile.writeAsBytes([1, 2, 3]);
    outputBuilder.dataAssets.addAll([
      DataAsset(
        package: config.packageName,
        name: 'foo.txt',
        file: assetFile.uri,
      ),
      DataAsset(
        package: config.packageName,
        name: 'foo.txt',
        file: assetFile.uri,
      ),
    ]);
    final errors = await validateDataAssetBuildOutput(
        config, BuildOutput(outputBuilder.json));
    expect(
      errors,
      contains(contains('More than one')),
    );
  });

  test('link hook validation', () async {
    final config = makeCodeLinkConfig();
    final outputBuilder = LinkOutputBuilder();
    final assetFile = File.fromUri(outDirUri.resolve('foo.dylib'));
    await assetFile.writeAsBytes([1, 2, 3]);
    outputBuilder.dataAssets.add(DataAsset(
      package: config.packageName,
      name: 'foo.txt',
      file: assetFile.uri,
    ));
    final errors =
        await validateLinkOutput(config, LinkOutput(outputBuilder.json));
    expect(
      errors,
      contains(contains('"data" is not a supported asset type')),
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
}
