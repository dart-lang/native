// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:cli_config/cli_config.dart';
import 'package:native_assets_cli/native_assets_cli.dart';
import 'package:test/test.dart';

import '../helpers.dart';

void main() async {
  late Uri tempUri;
  late Uri fakeClang;
  late Uri fakeLd;
  late Uri fakeAr;
  late Uri fakeCl;
  late Uri fakeVcVars;

  setUp(() async {
    tempUri = (await Directory.systemTemp.createTemp()).uri;
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
      outDir: tempUri.resolve('out1/'),
      packageRoot: tempUri,
      target: Target.iOSArm64,
      targetIOSSdk: IOSSdk.iPhoneOs,
      cCompiler: CCompilerConfig(
        cc: fakeClang,
        ld: fakeLd,
        ar: fakeAr,
      ),
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
      outDir: tempUri.resolve('out2/'),
      packageRoot: tempUri.resolve('packageRoot/'),
      target: Target.androidArm64,
      linkModePreference: LinkModePreference.preferStatic,
    );

    final config = Config(fileParsed: {
      'out_dir': tempUri.resolve('out2/').toFilePath(),
      'package_root': tempUri.resolve('packageRoot/').toFilePath(),
      'target': 'android_arm64',
      'link_mode_preference': 'prefer-static',
      'version': BuildOutput.version.toString(),
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
      cCompiler: CCompilerConfig(
        cc: fakeClang,
        ld: fakeLd,
      ),
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
      cCompiler: CCompilerConfig(
        cc: fakeClang,
        ld: fakeLd,
      ),
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
    final expectedYamlString = '''c_compiler:
  cc: ${fakeClang.toFilePath()}
  ld: ${fakeLd.toFilePath()}
dependency_metadata:
  bar:
    key: value
  foo:
    a: 321
    z:
      - z
      - a
link_mode_preference: prefer-static
out_dir: ${outDir.toFilePath()}
package_root: ${tempUri.toFilePath()}
target: ios_arm64
target_ios_sdk: iphoneos
version: ${BuildConfig.version}''';
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
        'package_root': tempUri.resolve('packageRoot/').toFilePath(),
        'target': 'android_arm64',
        'link_mode_preference': 'prefer-static',
      })),
      throwsFormatException,
    );
    expect(
      () => BuildConfig.fromConfig(Config(fileParsed: {
        'out_dir': tempUri.resolve('out2/').toFilePath(),
        'package_root': tempUri.resolve('packageRoot/').toFilePath(),
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
        'out_dir': tempUri.resolve('out2/').toFilePath(),
        'package_root': tempUri.resolve('packageRoot/').toFilePath(),
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
      cCompiler: CCompilerConfig(
        cc: fakeClang,
        ld: fakeLd,
      ),
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

  test('envScript', () {
    final buildConfig1 = BuildConfig(
      outDir: tempUri.resolve('out1/'),
      packageRoot: tempUri.resolve('packageRoot/'),
      target: Target.windowsX64,
      cCompiler: CCompilerConfig(
        cc: fakeCl,
        envScript: fakeVcVars,
        envScriptArgs: ['x64'],
      ),
      linkModePreference: LinkModePreference.dynamic,
    );

    final configFile = buildConfig1.toYaml();
    final config = Config(fileParsed: configFile);
    final fromConfig = BuildConfig.fromConfig(config);
    expect(fromConfig, equals(buildConfig1));
  });

  for (final version in ['9001.0.0', '0.0.1']) {
    test('BuildConfig version $version', () {
      final outDir = tempUri.resolve('out1/');
      final config = Config(fileParsed: {
        'link_mode_preference': 'prefer-static',
        'out_dir': outDir.toFilePath(),
        'package_root': tempUri.toFilePath(),
        'target': 'linux_x64',
        'version': version,
      });
      expect(() => BuildConfig.fromConfig(config), throwsFormatException);
    });
  }

  test('build folder stable ', () async {
    await inTempDir((tempUri) async {
      final nativeAddUri = tempUri.resolve('native_add/');

      final outDir = BuildConfig.outDirName(
        packageRoot: nativeAddUri,
        target: Target.linuxX64,
        linkModePreference: LinkModePreference.dynamic,
      );

      // The build folder should be stable.
      expect(outDir, '96819d83ae789cb65752986a4abb4071');
    });
  });

  test('build folder different due to metadata', () async {
    await inTempDir((tempUri) async {
      final nativeAddUri = tempUri.resolve('native_add/');

      final name1 = BuildConfig.outDirName(
        packageRoot: nativeAddUri,
        target: Target.linuxX64,
        linkModePreference: LinkModePreference.dynamic,
      );

      final name2 = BuildConfig.outDirName(
        packageRoot: nativeAddUri,
        target: Target.linuxX64,
        linkModePreference: LinkModePreference.dynamic,
        dependencyMetadata: {
          'foo': Metadata({'key': 'value'})
        },
      );

      printOnFailure([name1, name2].toString());
      expect(name1 != name2, true);
    });
  });

  test('build folder different due to cc', () async {
    await inTempDir((tempUri) async {
      final nativeAddUri = tempUri.resolve('native_add/');
      final fakeClangUri = tempUri.resolve('fake_clang');
      await File.fromUri(fakeClangUri).create();

      final name1 = BuildConfig.outDirName(
        packageRoot: nativeAddUri,
        target: Target.linuxX64,
        linkModePreference: LinkModePreference.dynamic,
      );

      final name2 = BuildConfig.outDirName(
          packageRoot: nativeAddUri,
          target: Target.linuxX64,
          linkModePreference: LinkModePreference.dynamic,
          cCompiler: CCompilerConfig(
            cc: fakeClangUri,
          ));

      printOnFailure([name1, name2].toString());
      expect(name1 != name2, true);
    });
  });
}
