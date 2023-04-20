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
  late Uri fakeAr;

  setUp(() async {
    tempUri = (await Directory.systemTemp.createTemp()).uri;
    fakeClang = tempUri.resolve('fake_clang');
    await File.fromUri(fakeClang).create();
    fakeLd = tempUri.resolve('fake_ld');
    await File.fromUri(fakeLd).create();
    fakeAr = tempUri.resolve('fake_ar');
    await File.fromUri(fakeAr).create();
  });

  tearDown(() async {
    await Directory.fromUri(tempUri).delete(recursive: true);
  });

  test('BuildConfig ==', () {
    final config1 = BuildConfig(
      outDir: tempUri.resolve('out1/'),
      packageRoot: tempUri,
      target: Target.iOSArm64,
      targetIOSSdk: IOSSdk.iPhoneOs,
      cc: fakeClang,
      ld: fakeLd,
      ar: fakeAr,
      linkModePreference: LinkModePreference.preferStatic,
    );

    final config2 = BuildConfig(
      outDir: tempUri.resolve('out2/'),
      packageRoot: tempUri,
      target: Target.androidArm64,
      linkModePreference: LinkModePreference.preferStatic,
    );

    expect(config1, equals(config1));
    expect(config1 == config2, false);
    expect(config1.outDir != config2.outDir, true);
    expect(config1.packageRoot, config2.packageRoot);
    expect(config1.target != config2.target, true);
    expect(config1.targetIOSSdk != config2.targetIOSSdk, true);
    expect(config1.cc != config2.cc, true);
    expect(config1.ld != config2.ld, true);
    expect(config1.ar != config2.ar, true);
    expect(config1.linkModePreference, config2.linkModePreference);
    expect(config1.dependencyMetadata, config2.dependencyMetadata);
  });

  test('BuildConfig fromConfig', () {
    final buildConfig2 = BuildConfig(
      outDir: tempUri.resolve('out2/'),
      packageRoot: tempUri.resolve('packageRoot/'),
      target: Target.androidArm64,
      linkModePreference: LinkModePreference.preferStatic,
    );

    final config = Config(fileParsed: {
      'out_dir': tempUri.resolve('out2/').path,
      'package_root': tempUri.resolve('packageRoot/').path,
      'target': 'android_arm64',
      'link_mode_preference': 'prefer-static',
    });

    final fromConfig = BuildConfig.fromConfig(config);
    expect(fromConfig, equals(buildConfig2));
  });

  test('BuildConfig toYaml fromConfig', () {
    final buildConfig1 = BuildConfig(
      outDir: tempUri.resolve('out1/'),
      packageRoot: tempUri.resolve('packageRoot/'),
      target: Target.iOSArm64,
      targetIOSSdk: IOSSdk.iPhoneOs,
      cc: fakeClang,
      ld: fakeLd,
      linkModePreference: LinkModePreference.preferStatic,
    );

    final configFile = buildConfig1.toYaml();
    final config = Config(fileParsed: configFile);
    final fromConfig = BuildConfig.fromConfig(config);
    expect(fromConfig, equals(buildConfig1));
  });

  test('BuildConfig == dependency metadata', () {
    final buildConfig1 = BuildConfig(
      outDir: tempUri.resolve('out1/'),
      packageRoot: tempUri,
      target: Target.androidArm64,
      linkModePreference: LinkModePreference.preferStatic,
      dependencyMetadata: {
        'bar': Metadata({
          'key': 'value',
          'foo': ['asdf', 'fdsa'],
        }),
        'foo': Metadata({
          'key': 321,
        }),
      },
    );

    final buildConfig2 = BuildConfig(
      outDir: tempUri.resolve('out1/'),
      packageRoot: tempUri,
      target: Target.androidArm64,
      linkModePreference: LinkModePreference.preferStatic,
      dependencyMetadata: {
        'bar': Metadata({
          'key': 'value',
        }),
        'foo': Metadata({
          'key': 123,
        }),
      },
    );

    expect(buildConfig1, equals(buildConfig1));
    expect(buildConfig1 == buildConfig2, false);
    expect(buildConfig1.hashCode == buildConfig2.hashCode, false);
  });

  test('BuildConfig toYaml fromYaml', () {
    final outDir = tempUri.resolve('out1/');
    final buildConfig1 = BuildConfig(
      outDir: outDir,
      packageRoot: tempUri,
      target: Target.iOSArm64,
      targetIOSSdk: IOSSdk.iPhoneOs,
      cc: fakeClang,
      ld: fakeLd,
      linkModePreference: LinkModePreference.preferStatic,
      // This map should be sorted on key for two layers.
      dependencyMetadata: {
        'foo': Metadata({
          'z': ['z', 'a'],
          'a': 321,
        }),
        'bar': Metadata({
          'key': 'value',
        }),
      },
    );
    final yamlString = buildConfig1.toYamlString();
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
link_mode_preference: prefer-static
out_dir: ${outDir.path}
package_root: ${tempUri.path}
target: ios_arm64
target_ios_sdk: iphoneos''';
    expect(yamlString, equals(expectedYamlString));

    final buildConfig2 = BuildConfig.fromConfig(
      Config.fromConfigFileContents(
        fileContents: yamlString,
      ),
    );
    expect(buildConfig2, buildConfig1);
  });

  test('BuildConfig FormatExceptions', () {
    expect(
      () => BuildConfig.fromConfig(Config(fileParsed: {})),
      throwsFormatException,
    );
    expect(
      () => BuildConfig.fromConfig(Config(fileParsed: {
        'package_root': tempUri.resolve('packageRoot/').path,
        'target': 'android_arm64',
        'link_mode_preference': 'prefer-static',
      })),
      throwsFormatException,
    );
    expect(
      () => BuildConfig.fromConfig(Config(fileParsed: {
        'out_dir': tempUri.resolve('out2/').path,
        'package_root': tempUri.resolve('packageRoot/').path,
        'target': 'android_arm64',
        'link_mode_preference': 'prefer-static',
        'dependency_metadata': {
          'bar': {'key': 'value'},
          'foo': <int>[],
        },
      })),
      throwsFormatException,
    );
  });

  test('FormatExceptions contain full stack trace of wrapped exception', () {
    try {
      BuildConfig.fromConfig(Config(fileParsed: {
        'out_dir': tempUri.resolve('out2/').path,
        'package_root': tempUri.resolve('packageRoot/').path,
        'target': [1, 2, 3, 4, 5],
        'link_mode_preference': 'prefer-static',
      }));
    } on FormatException catch (e) {
      expect(e.toString(), stringContainsInOrder(['Config.string']));
    }
  });

  test('BuildConfig toString', () {
    final config = BuildConfig(
      outDir: tempUri.resolve('out1/'),
      packageRoot: tempUri,
      target: Target.iOSArm64,
      targetIOSSdk: IOSSdk.iPhoneOs,
      cc: fakeClang,
      ld: fakeLd,
      linkModePreference: LinkModePreference.preferStatic,
    );
    config.toString();
  });

  test('BuildConfig fromArgs', () async {
    final buildConfig = BuildConfig(
      outDir: tempUri.resolve('out2/'),
      packageRoot: tempUri,
      target: Target.androidArm64,
      linkModePreference: LinkModePreference.preferStatic,
    );
    final configFileContents = buildConfig.toYamlString();
    final configUri = tempUri.resolve('config.yaml');
    final configFile = File.fromUri(configUri);
    await configFile.writeAsString(configFileContents);
    final buildConfig2 = await BuildConfig.fromArgs(
      ['--config', configUri.toFilePath()],
      environment: {}, // Don't inherit the test environment.
    );
    expect(buildConfig2, buildConfig);
  });

  test('dependency metadata via config accessor', () {
    final buildConfig1 = BuildConfig(
      outDir: tempUri.resolve('out1/'),
      packageRoot: tempUri,
      target: Target.androidArm64,
      linkModePreference: LinkModePreference.preferStatic,
      dependencyMetadata: {
        'bar': Metadata({
          'key': {'key2': 'value'},
        }),
      },
    );
    // Useful for doing `path(..., exists: true)`.
    expect(
      buildConfig1.config.string([
        BuildConfig.dependencyMetadataConfigKey,
        'bar',
        'key',
        'key2'
      ].join('.')),
      'value',
    );
  });
}
