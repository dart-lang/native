// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:cli_config/cli_config.dart';
import 'package:native_assets_cli/native_assets_cli.dart';
import 'package:test/test.dart';

void main() async {
  late Uri tempUri;
  late Uri fakeClang;
  late Uri fakeLd;

  setUp(() async {
    tempUri = (await Directory.systemTemp.createTemp()).uri;
    fakeClang = tempUri.resolve('fake_clang');
    await File.fromUri(fakeClang).create();
    fakeLd = tempUri.resolve('fake_ld');
    await File.fromUri(fakeLd).create();
  });

  tearDown(() async {
    await Directory.fromUri(tempUri).delete(recursive: true);
  });

  test('NativeAssetsCliConfig ==', () {
    final nativeAssetsCliConfig1 = NativeAssetsCliConfig(
      outDir: tempUri.resolve('out1/'),
      packageRoot: tempUri,
      target: Target.iOSArm64,
      targetIOSSdk: IOSSdk.iPhoneOs,
      cc: fakeClang,
      ld: fakeLd,
      packaging: PackagingPreference.preferStatic,
    );

    final nativeAssetsCliConfig2 = NativeAssetsCliConfig(
      outDir: tempUri.resolve('out2/'),
      packageRoot: tempUri,
      target: Target.androidArm64,
      packaging: PackagingPreference.preferStatic,
    );

    expect(nativeAssetsCliConfig1, equals(nativeAssetsCliConfig1));
    expect(nativeAssetsCliConfig1 == nativeAssetsCliConfig2, false);
  });

  test('NativeAssetsCliConfig fromConfig', () {
    final nativeAssetsCliConfig2 = NativeAssetsCliConfig(
      outDir: tempUri.resolve('out2/'),
      packageRoot: tempUri.resolve('packageRoot/'),
      target: Target.androidArm64,
      packaging: PackagingPreference.preferStatic,
    );

    final config = Config(fileParsed: {
      'out_dir': tempUri.resolve('out2/').path,
      'package_root': tempUri.resolve('packageRoot/').path,
      'target': 'android_arm64',
      'packaging': 'prefer-static',
    });

    final fromConfig = NativeAssetsCliConfig.fromConfig(config);
    expect(fromConfig, equals(nativeAssetsCliConfig2));
  });

  test('NativeAssetsCliConfig toYamlEncoding fromConfig', () {
    final nativeAssetsCliConfig1 = NativeAssetsCliConfig(
      outDir: tempUri.resolve('out1/'),
      packageRoot: tempUri.resolve('packageRoot/'),
      target: Target.iOSArm64,
      targetIOSSdk: IOSSdk.iPhoneOs,
      cc: fakeClang,
      ld: fakeLd,
      packaging: PackagingPreference.preferStatic,
    );

    final configFile = nativeAssetsCliConfig1.toYamlEncoding();
    final config = Config(fileParsed: configFile);
    final fromConfig = NativeAssetsCliConfig.fromConfig(config);
    expect(fromConfig, equals(nativeAssetsCliConfig1));
  });

  test('NativeAssetsCliConfig == dependency metadata', () {
    final nativeAssetsCliConfig1 = NativeAssetsCliConfig(
      outDir: tempUri.resolve('out1/'),
      packageRoot: tempUri,
      target: Target.androidArm64,
      packaging: PackagingPreference.preferStatic,
      dependencyMetadata: {
        'bar': {
          'key': 'value',
          'foo': ['asdf', 'fdsa'],
        },
        'foo': {
          'key': 321,
        },
      },
    );

    final nativeAssetsCliConfig2 = NativeAssetsCliConfig(
      outDir: tempUri.resolve('out1/'),
      packageRoot: tempUri,
      target: Target.androidArm64,
      packaging: PackagingPreference.preferStatic,
      dependencyMetadata: {
        'bar': {
          'key': 'value',
        },
        'foo': {
          'key': 123,
        },
      },
    );

    expect(nativeAssetsCliConfig1, equals(nativeAssetsCliConfig1));
    expect(nativeAssetsCliConfig1 == nativeAssetsCliConfig2, false);
  });

  test('NativeAssetsCliConfig toYaml', () {
    final outDir = tempUri.resolve('out1/');
    final nativeAssetsCliConfig1 = NativeAssetsCliConfig(
      outDir: outDir,
      packageRoot: tempUri,
      target: Target.iOSArm64,
      targetIOSSdk: IOSSdk.iPhoneOs,
      cc: fakeClang,
      ld: fakeLd,
      packaging: PackagingPreference.preferStatic,
      // This map should be sorted on key for two layers.
      dependencyMetadata: {
        'foo': {
          'z': ['z', 'a'],
          'a': 321,
        },
        'bar': {
          'key': 'value',
        },
      },
    );
    final yamlString = nativeAssetsCliConfig1.toYaml();
    final expectedYamlString = '''cc: ${fakeClang.path}
dependency_metadata:
  bar:
    key: value
  foo:
    a: 321
    z:
      - z
      - a
ld: ${fakeLd.path}
out_dir: ${outDir.path}
package_root: ${tempUri.path}
packaging: prefer-static
target: ios_arm64
target_ios_sdk: iphoneos''';
    expect(yamlString, equals(expectedYamlString));
  });
}
