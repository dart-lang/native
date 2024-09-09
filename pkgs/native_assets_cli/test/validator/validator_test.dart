// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:native_assets_cli/native_assets_cli.dart';
import 'package:native_assets_cli/src/validator/validator.dart';
import 'package:test/test.dart';

void main() {
  late Uri tempUri;
  late Uri outDirUri;
  late Uri outDir2Uri;
  late String packageName;
  late Uri packageRootUri;

  setUp(() async {
    tempUri = (await Directory.systemTemp.createTemp()).uri;
    outDirUri = tempUri.resolve('out1/');
    await Directory.fromUri(outDirUri).create();
    outDir2Uri = tempUri.resolve('out2/');
    packageName = 'my_package';
    await Directory.fromUri(outDir2Uri).create();
    packageRootUri = tempUri.resolve('$packageName/');
    await Directory.fromUri(packageRootUri).create();
  });

  tearDown(() async {
    await Directory.fromUri(tempUri).delete(recursive: true);
  });

  test('linking not enabled', () async {
    final config = BuildConfig.build(
      outputDirectory: outDirUri,
      packageName: packageName,
      packageRoot: tempUri,
      targetArchitecture: Architecture.arm64,
      targetOS: OS.iOS,
      targetIOSSdk: IOSSdk.iPhoneOS,
      buildMode: BuildMode.release,
      linkModePreference: LinkModePreference.dynamic,
      supportedAssetTypes: [NativeCodeAsset.type],
      linkingEnabled: false,
    );
    final output = BuildOutput();
    final assetFile = File.fromUri(outDirUri.resolve('foo.dylib'));
    await assetFile.writeAsBytes([1, 2, 3]);
    output.addAsset(
      NativeCodeAsset(
        id: AssetId(config.packageName, 'foo.dart'),
        file: assetFile.uri,
        linkMode: DynamicLoadingBundled(),
        os: config.targetOS,
        architecture: config.targetArchitecture,
      ),
      linkInPackage: 'bar',
    );
    final result = await validateBuild(config, output);
    expect(result.success, isFalse);
    expect(
      result.errors,
      contains(contains('linkingEnabled is false')),
    );
  });

  test('supported asset type', () async {
    final config = BuildConfig.build(
      outputDirectory: outDirUri,
      packageName: packageName,
      packageRoot: tempUri,
      targetArchitecture: Architecture.arm64,
      targetOS: OS.iOS,
      targetIOSSdk: IOSSdk.iPhoneOS,
      buildMode: BuildMode.release,
      linkModePreference: LinkModePreference.dynamic,
      supportedAssetTypes: [NativeCodeAsset.type],
      linkingEnabled: false,
    );
    final output = BuildOutput();
    final assetFile = File.fromUri(outDirUri.resolve('foo.dylib'));
    await assetFile.writeAsBytes([1, 2, 3]);
    output.addAsset(DataAsset(
      id: AssetId(config.packageName, 'foo.txt'),
      file: assetFile.uri,
    ));
    final result = await validateBuild(config, output);
    expect(result.success, isFalse);
    expect(
      result.errors,
      contains(contains('which is not in supportedAssetTypes')),
    );
  });

  test('file exists', () async {
    final config = BuildConfig.build(
      outputDirectory: outDirUri,
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
    output.addAsset(DataAsset(
      id: AssetId(config.packageName, 'foo.txt'),
      file: assetFile.uri,
    ));
    final result = await validateBuild(config, output);
    expect(result.success, isFalse);
    expect(
      result.errors,
      contains(contains('which does not exist')),
    );
  });

  test('file not set', () async {
    final config = BuildConfig.build(
      outputDirectory: outDirUri,
      packageName: packageName,
      packageRoot: tempUri,
      targetArchitecture: Architecture.arm64,
      targetOS: OS.iOS,
      targetIOSSdk: IOSSdk.iPhoneOS,
      buildMode: BuildMode.release,
      linkModePreference: LinkModePreference.dynamic,
      supportedAssetTypes: [NativeCodeAsset.type],
      linkingEnabled: false,
    );
    final output = BuildOutput();
    output.addAsset(NativeCodeAsset(
      id: AssetId(config.packageName, 'foo.dylib'),
      architecture: config.targetArchitecture,
      os: config.targetOS,
      linkMode: DynamicLoadingBundled(),
    ));
    final result = await validateBuild(config, output);
    expect(result.success, isFalse);
    expect(
      result.errors,
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
        packageName: packageName,
        packageRoot: tempUri,
        targetArchitecture: Architecture.arm64,
        targetOS: OS.iOS,
        targetIOSSdk: IOSSdk.iPhoneOS,
        buildMode: BuildMode.release,
        linkModePreference: linkModePreference,
        supportedAssetTypes: [NativeCodeAsset.type],
        linkingEnabled: false,
      );
      final output = BuildOutput();
      final assetFile = File.fromUri(outDirUri.resolve('foo.dylib'));
      await assetFile.writeAsBytes([1, 2, 3]);
      output.addAsset(
        NativeCodeAsset(
          id: AssetId(config.packageName, 'foo.dart'),
          file: assetFile.uri,
          linkMode: linkMode,
          os: config.targetOS,
          architecture: config.targetArchitecture,
        ),
      );
      final result = await validateBuild(config, output);
      expect(result.success, isFalse);
      expect(
        result.errors,
        contains(contains(
          'which is not allowed by by the config link mode preference',
        )),
      );
    });
  }

  test('native code wrong architecture', () async {
    final config = BuildConfig.build(
      outputDirectory: outDirUri,
      packageName: packageName,
      packageRoot: tempUri,
      targetArchitecture: Architecture.arm64,
      targetOS: OS.iOS,
      targetIOSSdk: IOSSdk.iPhoneOS,
      buildMode: BuildMode.release,
      linkModePreference: LinkModePreference.dynamic,
      supportedAssetTypes: [NativeCodeAsset.type],
      linkingEnabled: false,
    );
    final output = BuildOutput();
    final assetFile = File.fromUri(outDirUri.resolve('foo.dylib'));
    await assetFile.writeAsBytes([1, 2, 3]);
    output.addAsset(
      NativeCodeAsset(
        id: AssetId(config.packageName, 'foo.dart'),
        file: assetFile.uri,
        linkMode: DynamicLoadingBundled(),
        os: config.targetOS,
        architecture: Architecture.x64,
      ),
    );
    final result = await validateBuild(config, output);
    expect(result.success, isFalse);
    expect(
      result.errors,
      contains(contains(
        'which is not the target architecture',
      )),
    );
  });

  test('native code no architecture', () async {
    final config = BuildConfig.build(
      outputDirectory: outDirUri,
      packageName: packageName,
      packageRoot: tempUri,
      targetArchitecture: Architecture.arm64,
      targetOS: OS.iOS,
      targetIOSSdk: IOSSdk.iPhoneOS,
      buildMode: BuildMode.release,
      linkModePreference: LinkModePreference.dynamic,
      supportedAssetTypes: [NativeCodeAsset.type],
      linkingEnabled: false,
    );
    final output = BuildOutput();
    final assetFile = File.fromUri(outDirUri.resolve('foo.dylib'));
    await assetFile.writeAsBytes([1, 2, 3]);
    output.addAsset(
      NativeCodeAsset(
        id: AssetId(config.packageName, 'foo.dart'),
        file: assetFile.uri,
        linkMode: DynamicLoadingBundled(),
        os: config.targetOS,
      ),
    );
    final result = await validateBuild(config, output);
    expect(result.success, isFalse);
    expect(
      result.errors,
      contains(contains(
        'has no architecture',
      )),
    );
  });

  test('native code asset wrong os', () async {
    final config = BuildConfig.build(
      outputDirectory: outDirUri,
      packageName: packageName,
      packageRoot: tempUri,
      targetArchitecture: Architecture.arm64,
      targetOS: OS.iOS,
      targetIOSSdk: IOSSdk.iPhoneOS,
      buildMode: BuildMode.release,
      linkModePreference: LinkModePreference.dynamic,
      supportedAssetTypes: [NativeCodeAsset.type],
      linkingEnabled: false,
    );
    final output = BuildOutput();
    final assetFile = File.fromUri(outDirUri.resolve('foo.dylib'));
    await assetFile.writeAsBytes([1, 2, 3]);
    output.addAsset(
      NativeCodeAsset(
        id: AssetId(config.packageName, 'foo.dart'),
        file: assetFile.uri,
        linkMode: DynamicLoadingBundled(),
        os: OS.windows,
        architecture: config.targetArchitecture,
      ),
    );
    final result = await validateBuild(config, output);
    expect(result.success, isFalse);
    expect(
      result.errors,
      contains(contains(
        'which is not the target os',
      )),
    );
  });

  test('asset id in wrong package', () async {
    final config = BuildConfig.build(
      outputDirectory: outDirUri,
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
    output.addAsset(DataAsset(
      id: AssetId('different_package', 'foo.txt'),
      file: assetFile.uri,
    ));
    final result = await validateBuild(config, output);
    expect(result.success, isFalse);
    expect(
      result.errors,
      contains(contains('does not start with')),
    );
  });

  test('duplicate asset id', () async {
    final config = BuildConfig.build(
      outputDirectory: outDirUri,
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
    output.addAssets([
      DataAsset(
        id: AssetId(config.packageName, 'foo.txt'),
        file: assetFile.uri,
      ),
      DataAsset(
        id: AssetId(config.packageName, 'foo.txt'),
        file: assetFile.uri,
      ),
    ]);
    final result = await validateBuild(config, output);
    expect(result.success, isFalse);
    expect(
      result.errors,
      contains(contains('Duplicate asset id')),
    );
  });

  test('link hook validation', () async {
    final config = LinkConfig.build(
      outputDirectory: outDirUri,
      packageName: packageName,
      packageRoot: tempUri,
      targetArchitecture: Architecture.arm64,
      targetOS: OS.iOS,
      targetIOSSdk: IOSSdk.iPhoneOS,
      buildMode: BuildMode.release,
      linkModePreference: LinkModePreference.dynamic,
      supportedAssetTypes: [NativeCodeAsset.type],
      assets: [],
    );
    final output = LinkOutput();
    final assetFile = File.fromUri(outDirUri.resolve('foo.dylib'));
    await assetFile.writeAsBytes([1, 2, 3]);
    output.addAsset(DataAsset(
      id: AssetId(config.packageName, 'foo.txt'),
      file: assetFile.uri,
    ));
    final result = await validateLink(config, output);
    expect(result.success, isFalse);
    expect(
      result.errors,
      contains(contains('which is not in supportedAssetTypes')),
    );
  });

  test('duplicate dylib name', () async {
    final config = BuildConfig.build(
      outputDirectory: outDirUri,
      packageName: packageName,
      packageRoot: tempUri,
      targetArchitecture: Architecture.arm64,
      targetOS: OS.iOS,
      targetIOSSdk: IOSSdk.iPhoneOS,
      buildMode: BuildMode.release,
      linkModePreference: LinkModePreference.dynamic,
      supportedAssetTypes: [NativeCodeAsset.type],
      linkingEnabled: false,
    );
    final output = BuildOutput();
    final fileName = config.targetOS.dylibFileName('foo');
    final assetFile = File.fromUri(outDirUri.resolve(fileName));
    await assetFile.writeAsBytes([1, 2, 3]);
    output.addAssets([
      NativeCodeAsset(
        id: AssetId(config.packageName, 'src/foo.dart'),
        file: assetFile.uri,
        linkMode: DynamicLoadingBundled(),
        os: config.targetOS,
        architecture: config.targetArchitecture,
      ),
      NativeCodeAsset(
        id: AssetId(config.packageName, 'src/bar.dart'),
        file: assetFile.uri,
        linkMode: DynamicLoadingBundled(),
        os: config.targetOS,
        architecture: config.targetArchitecture,
      ),
    ]);
    final result = await validateBuild(config, output);
    expect(result.success, isFalse);
    expect(
      result.errors,
      contains(contains('Duplicate dynamic library file name')),
    );
  });
}
