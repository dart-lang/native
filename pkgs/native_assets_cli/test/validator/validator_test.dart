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

  test('linking not enabled', () async {
    final config = BuildConfig.build(
      outputDirectory: outDirUri,
      outputDirectoryShared: outDirSharedUri,
      packageName: packageName,
      packageRoot: tempUri,
      targetArchitecture: Architecture.arm64,
      targetOS: OS.iOS,
      targetIOSSdk: IOSSdk.iPhoneOS,
      buildMode: BuildMode.release,
      linkModePreference: LinkModePreference.dynamic,
      supportedAssetTypes: [CodeAsset.type],
      linkingEnabled: false,
    );
    final output = BuildOutput();
    final assetFile = File.fromUri(outDirUri.resolve('foo.dylib'));
    await assetFile.writeAsBytes([1, 2, 3]);
    output.codeAssets.add(
      CodeAsset(
        package: config.packageName,
        name: 'foo.dart',
        file: assetFile.uri,
        linkMode: DynamicLoadingBundled(),
        os: config.targetOS,
        architecture: config.targetArchitecture,
      ),
      linkInPackage: 'bar',
    );
    final errors = await validateBuildOutput(config, output);
    expect(
      errors,
      contains(contains('linkingEnabled is false')),
    );
  });

  test('supported asset type', () async {
    final config = BuildConfig.build(
      outputDirectory: outDirUri,
      outputDirectoryShared: outDirSharedUri,
      packageName: packageName,
      packageRoot: tempUri,
      targetArchitecture: Architecture.arm64,
      targetOS: OS.iOS,
      targetIOSSdk: IOSSdk.iPhoneOS,
      buildMode: BuildMode.release,
      linkModePreference: LinkModePreference.dynamic,
      supportedAssetTypes: [CodeAsset.type],
      linkingEnabled: false,
    );
    final output = BuildOutput();
    final assetFile = File.fromUri(outDirUri.resolve('foo.dylib'));
    await assetFile.writeAsBytes([1, 2, 3]);
    output.dataAssets.add(DataAsset(
      package: config.packageName,
      name: 'foo.txt',
      file: assetFile.uri,
    ));
    final errors = await validateBuildOutput(config, output);
    expect(
      errors,
      contains(contains('"data" is not a supported asset type')),
    );
  });

  test('file exists', () async {
    final config = BuildConfig.build(
      outputDirectory: outDirUri,
      outputDirectoryShared: outDirSharedUri,
      packageName: packageName,
      packageRoot: tempUri,
      targetArchitecture: Architecture.arm64,
      targetOS: OS.iOS,
      targetIOSSdk: IOSSdk.iPhoneOS,
      buildMode: BuildMode.release,
      linkModePreference: LinkModePreference.dynamic,
      supportedAssetTypes: [DataAsset.type],
      linkingEnabled: false,
    );
    final output = BuildOutput();
    final assetFile = File.fromUri(outDirUri.resolve('foo.dylib'));
    output.dataAssets.add(DataAsset(
      package: config.packageName,
      name: 'foo.txt',
      file: assetFile.uri,
    ));
    final errors = await validateDataAssetBuildOutput(config, output);
    expect(
      errors,
      contains(contains('which does not exist')),
    );
  });

  test('file not set', () async {
    final config = BuildConfig.build(
      outputDirectory: outDirUri,
      outputDirectoryShared: outDirSharedUri,
      packageName: packageName,
      packageRoot: tempUri,
      targetArchitecture: Architecture.arm64,
      targetOS: OS.iOS,
      targetIOSSdk: IOSSdk.iPhoneOS,
      buildMode: BuildMode.release,
      linkModePreference: LinkModePreference.dynamic,
      supportedAssetTypes: [CodeAsset.type],
      linkingEnabled: false,
    );
    final output = BuildOutput();
    output.codeAssets.add(CodeAsset(
      package: config.packageName,
      name: 'foo.dylib',
      architecture: config.targetArchitecture,
      os: config.targetOS,
      linkMode: DynamicLoadingBundled(),
    ));
    final errors = await validateCodeAssetBuildOutput(config, output);
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
      final config = BuildConfig.build(
        outputDirectory: outDirUri,
        outputDirectoryShared: outDirSharedUri,
        packageName: packageName,
        packageRoot: tempUri,
        targetArchitecture: Architecture.arm64,
        targetOS: OS.iOS,
        targetIOSSdk: IOSSdk.iPhoneOS,
        buildMode: BuildMode.release,
        linkModePreference: linkModePreference,
        supportedAssetTypes: [CodeAsset.type],
        linkingEnabled: false,
      );
      final output = BuildOutput();
      final assetFile = File.fromUri(outDirUri.resolve('foo.dylib'));
      await assetFile.writeAsBytes([1, 2, 3]);
      output.codeAssets.add(
        CodeAsset(
          package: config.packageName,
          name: 'foo.dart',
          file: assetFile.uri,
          linkMode: linkMode,
          os: config.targetOS,
          architecture: config.targetArchitecture,
        ),
      );
      final errors = await validateCodeAssetBuildOutput(config, output);
      expect(
        errors,
        contains(contains(
          'which is not allowed by by the config link mode preference',
        )),
      );
    });
  }

  test('native code wrong architecture', () async {
    final config = BuildConfig.build(
      outputDirectory: outDirUri,
      outputDirectoryShared: outDirSharedUri,
      packageName: packageName,
      packageRoot: tempUri,
      targetArchitecture: Architecture.arm64,
      targetOS: OS.iOS,
      targetIOSSdk: IOSSdk.iPhoneOS,
      buildMode: BuildMode.release,
      linkModePreference: LinkModePreference.dynamic,
      supportedAssetTypes: [CodeAsset.type],
      linkingEnabled: false,
    );
    final output = BuildOutput();
    final assetFile = File.fromUri(outDirUri.resolve('foo.dylib'));
    await assetFile.writeAsBytes([1, 2, 3]);
    output.codeAssets.add(
      CodeAsset(
        package: config.packageName,
        name: 'foo.dart',
        file: assetFile.uri,
        linkMode: DynamicLoadingBundled(),
        os: config.targetOS,
        architecture: Architecture.x64,
      ),
    );
    final errors = await validateCodeAssetBuildOutput(config, output);
    expect(
      errors,
      contains(contains(
        'which is not the target architecture',
      )),
    );
  });

  test('native code no architecture', () async {
    final config = BuildConfig.build(
      outputDirectory: outDirUri,
      outputDirectoryShared: outDirSharedUri,
      packageName: packageName,
      packageRoot: tempUri,
      targetArchitecture: Architecture.arm64,
      targetOS: OS.iOS,
      targetIOSSdk: IOSSdk.iPhoneOS,
      buildMode: BuildMode.release,
      linkModePreference: LinkModePreference.dynamic,
      supportedAssetTypes: [CodeAsset.type],
      linkingEnabled: false,
    );
    final output = BuildOutput();
    final assetFile = File.fromUri(outDirUri.resolve('foo.dylib'));
    await assetFile.writeAsBytes([1, 2, 3]);
    output.codeAssets.add(
      CodeAsset(
        package: config.packageName,
        name: 'foo.dart',
        file: assetFile.uri,
        linkMode: DynamicLoadingBundled(),
        os: config.targetOS,
      ),
    );
    final errors = await validateCodeAssetBuildOutput(config, output);
    expect(
      errors,
      contains(contains(
        'has no architecture',
      )),
    );
  });

  test('native code asset wrong os', () async {
    final config = BuildConfig.build(
      outputDirectory: outDirUri,
      outputDirectoryShared: outDirSharedUri,
      packageName: packageName,
      packageRoot: tempUri,
      targetArchitecture: Architecture.arm64,
      targetOS: OS.iOS,
      targetIOSSdk: IOSSdk.iPhoneOS,
      buildMode: BuildMode.release,
      linkModePreference: LinkModePreference.dynamic,
      supportedAssetTypes: [CodeAsset.type],
      linkingEnabled: false,
    );
    final output = BuildOutput();
    final assetFile = File.fromUri(outDirUri.resolve('foo.dylib'));
    await assetFile.writeAsBytes([1, 2, 3]);
    output.codeAssets.add(
      CodeAsset(
        package: config.packageName,
        name: 'foo.dart',
        file: assetFile.uri,
        linkMode: DynamicLoadingBundled(),
        os: OS.windows,
        architecture: config.targetArchitecture,
      ),
    );
    final errors = await validateCodeAssetBuildOutput(config, output);
    expect(
      errors,
      contains(contains(
        'which is not the target os',
      )),
    );
  });

  test('asset id in wrong package', () async {
    final config = BuildConfig.build(
      outputDirectory: outDirUri,
      outputDirectoryShared: outDirSharedUri,
      packageName: packageName,
      packageRoot: tempUri,
      targetArchitecture: Architecture.arm64,
      targetOS: OS.iOS,
      targetIOSSdk: IOSSdk.iPhoneOS,
      buildMode: BuildMode.release,
      linkModePreference: LinkModePreference.dynamic,
      supportedAssetTypes: [DataAsset.type],
      linkingEnabled: false,
    );
    final output = BuildOutput();
    final assetFile = File.fromUri(outDirUri.resolve('foo.dylib'));
    await assetFile.writeAsBytes([1, 2, 3]);
    output.dataAssets.add(DataAsset(
      package: 'different_package',
      name: 'foo.txt',
      file: assetFile.uri,
    ));
    final errors = await validateDataAssetBuildOutput(config, output);
    expect(
      errors,
      contains(contains('Data asset must have package name my_package')),
    );
  });

  test('duplicate asset id', () async {
    final config = BuildConfig.build(
      outputDirectory: outDirUri,
      outputDirectoryShared: outDirSharedUri,
      packageName: packageName,
      packageRoot: tempUri,
      targetArchitecture: Architecture.arm64,
      targetOS: OS.iOS,
      targetIOSSdk: IOSSdk.iPhoneOS,
      buildMode: BuildMode.release,
      linkModePreference: LinkModePreference.dynamic,
      supportedAssetTypes: [DataAsset.type],
      linkingEnabled: false,
    );
    final output = BuildOutput();
    final assetFile = File.fromUri(outDirUri.resolve('foo.dylib'));
    await assetFile.writeAsBytes([1, 2, 3]);
    output.dataAssets.addAll([
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
    final errors = await validateDataAssetBuildOutput(config, output);
    expect(
      errors,
      contains(contains('More than one')),
    );
  });

  test('link hook validation', () async {
    final config = LinkConfig.build(
      outputDirectory: outDirUri,
      outputDirectoryShared: outDirSharedUri,
      packageName: packageName,
      packageRoot: tempUri,
      targetArchitecture: Architecture.arm64,
      targetOS: OS.iOS,
      targetIOSSdk: IOSSdk.iPhoneOS,
      buildMode: BuildMode.release,
      linkModePreference: LinkModePreference.dynamic,
      supportedAssetTypes: [CodeAsset.type],
      assets: [],
    );
    final output = LinkOutput();
    final assetFile = File.fromUri(outDirUri.resolve('foo.dylib'));
    await assetFile.writeAsBytes([1, 2, 3]);
    output.dataAssets.add(DataAsset(
      package: config.packageName,
      name: 'foo.txt',
      file: assetFile.uri,
    ));
    final errors = await validateLinkOutput(config, output);
    expect(
      errors,
      contains(contains('"data" is not a supported asset type')),
    );
  });

  test('duplicate dylib name', () async {
    final config = BuildConfig.build(
      outputDirectory: outDirUri,
      outputDirectoryShared: outDirSharedUri,
      packageName: packageName,
      packageRoot: tempUri,
      targetArchitecture: Architecture.arm64,
      targetOS: OS.iOS,
      targetIOSSdk: IOSSdk.iPhoneOS,
      buildMode: BuildMode.release,
      linkModePreference: LinkModePreference.dynamic,
      supportedAssetTypes: [CodeAsset.type],
      linkingEnabled: false,
    );
    final output = BuildOutput();
    final fileName = config.targetOS.dylibFileName('foo');
    final assetFile = File.fromUri(outDirUri.resolve(fileName));
    await assetFile.writeAsBytes([1, 2, 3]);
    output.codeAssets.addAll([
      CodeAsset(
        package: config.packageName,
        name: 'src/foo.dart',
        file: assetFile.uri,
        linkMode: DynamicLoadingBundled(),
        os: config.targetOS,
        architecture: config.targetArchitecture,
      ),
      CodeAsset(
        package: config.packageName,
        name: 'src/bar.dart',
        file: assetFile.uri,
        linkMode: DynamicLoadingBundled(),
        os: config.targetOS,
        architecture: config.targetArchitecture,
      ),
    ]);
    final errors = await validateCodeAssetBuildOutput(config, output);
    expect(
      errors,
      contains(contains('Duplicate dynamic library file name')),
    );
  });
}
