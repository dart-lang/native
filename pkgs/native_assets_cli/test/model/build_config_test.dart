// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:cli_config/cli_config.dart';
import 'package:native_assets_cli/native_assets_cli_internal.dart';
import 'package:test/test.dart';

import '../helpers.dart';

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
    expect(config1.outDir != config2.outDir, true);
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

  test('BuildConfig toYaml fromConfig', () {
    final buildConfig1 = BuildConfig(
      outDir: outDirUri,
      packageName: packageName,
      packageRoot: packageRootUri,
      targetArchitecture: Architecture.arm64,
      targetOs: OS.iOS,
      targetIOSSdk: IOSSdk.iPhoneOs,
      cCompiler: CCompilerConfig(
        cc: fakeClang,
        ld: fakeLd,
      ),
      buildMode: BuildMode.release,
      linkModePreference: LinkModePreference.preferStatic,
    );

    final configFile = buildConfig1.toYaml();
    final config = Config(fileParsed: configFile);
    final fromConfig = BuildConfig.fromConfig(config);
    expect(fromConfig, equals(buildConfig1));
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

  test('BuildConfig toYaml fromYaml', () {
    final outDir = outDirUri;
    final buildConfig1 = BuildConfig(
      outDir: outDir,
      packageName: packageName,
      packageRoot: tempUri,
      targetArchitecture: Architecture.arm64,
      targetOs: OS.iOS,
      targetIOSSdk: IOSSdk.iPhoneOs,
      cCompiler: CCompilerConfig(
        cc: fakeClang,
        ld: fakeLd,
      ),
      buildMode: BuildMode.release,
      linkModePreference: LinkModePreference.preferStatic,
      // This map should be sorted on key for two layers.
      dependencyMetadata: {
        'foo': const Metadata({
          'z': ['z', 'a'],
          'a': 321,
        }),
        'bar': const Metadata({
          'key': 'value',
        }),
      },
    );
    final yamlString = buildConfig1.toYamlString();
    final expectedYamlString = '''build_mode: release
c_compiler:
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
package_name: $packageName
package_root: ${tempUri.toFilePath()}
target_architecture: arm64
target_ios_sdk: iphoneos
target_os: ios
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
      throwsA(predicate(
        (e) =>
            e is FormatException &&
            e.message.contains(
              'No value was provided for required key: build_mode',
            ),
      )),
    );
    expect(
      () => BuildConfig.fromConfig(Config(fileParsed: {
        'version': BuildConfig.version.toString(),
        'package_name': packageName,
        'package_root': packageRootUri.toFilePath(),
        'target_architecture': 'arm64',
        'target_os': 'android',
        'target_android_ndk_api': 30,
        'link_mode_preference': 'prefer-static',
      })),
      throwsA(predicate(
        (e) =>
            e is FormatException &&
            e.message.contains(
              'No value was provided for required key: out_dir',
            ),
      )),
    );
    expect(
      () => BuildConfig.fromConfig(Config(fileParsed: {
        'version': BuildConfig.version.toString(),
        'out_dir': outDirUri.toFilePath(),
        'package_name': packageName,
        'package_root': packageRootUri.toFilePath(),
        'target_architecture': 'arm64',
        'target_os': 'android',
        'target_android_ndk_api': 30,
        'link_mode_preference': 'prefer-static',
        'dependency_metadata': {
          'bar': {'key': 'value'},
          'foo': <int>[],
        },
      })),
      throwsA(predicate(
        (e) =>
            e is FormatException &&
            e.message.contains(
              "Unexpected value '[]' for key 'dependency_metadata.foo' in "
              'config file. Expected a Map.',
            ),
      )),
    );
    expect(
      () => BuildConfig.fromConfig(Config(fileParsed: {
        'out_dir': outDirUri.toFilePath(),
        'version': BuildConfig.version.toString(),
        'package_name': packageName,
        'package_root': packageRootUri.toFilePath(),
        'target_architecture': 'arm64',
        'target_os': 'android',
        'link_mode_preference': 'prefer-static',
      })),
      throwsA(predicate(
        (e) =>
            e is FormatException &&
            e.message.contains(
              'No value was provided for required key: target_android_ndk_api',
            ),
      )),
    );
  });

  test('FormatExceptions contain full stack trace of wrapped exception', () {
    try {
      BuildConfig.fromConfig(Config(fileParsed: {
        'out_dir': outDirUri.toFilePath(),
        'package_root': packageRootUri.toFilePath(),
        'target': [1, 2, 3, 4, 5],
        'link_mode_preference': 'prefer-static',
      }));
    } on FormatException catch (e) {
      expect(e.toString(), stringContainsInOrder(['Config.string']));
    }
  });

  test('BuildConfig toString', () {
    final config = BuildConfig(
      outDir: outDirUri,
      packageName: packageName,
      packageRoot: tempUri,
      targetArchitecture: Architecture.arm64,
      targetOs: OS.iOS,
      targetIOSSdk: IOSSdk.iPhoneOs,
      cCompiler: CCompilerConfig(
        cc: fakeClang,
        ld: fakeLd,
      ),
      buildMode: BuildMode.release,
      linkModePreference: LinkModePreference.preferStatic,
    );
    config.toString();
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
      outDir: outDirUri,
      packageName: packageName,
      packageRoot: packageRootUri,
      targetArchitecture: Architecture.x64,
      targetOs: OS.windows,
      cCompiler: CCompilerConfig(
        cc: fakeCl,
        envScript: fakeVcVars,
        envScriptArgs: ['x64'],
      ),
      buildMode: BuildMode.release,
      linkModePreference: LinkModePreference.dynamic,
    );

    final configFile = buildConfig1.toYaml();
    final config = Config(fileParsed: configFile);
    final fromConfig = BuildConfig.fromConfig(config);
    expect(fromConfig, equals(buildConfig1));
  });

  for (final version in ['9001.0.0', '0.0.1']) {
    test('BuildConfig version $version', () {
      final outDir = outDirUri;
      final config = Config(fileParsed: {
        'link_mode_preference': 'prefer-static',
        'out_dir': outDir.toFilePath(),
        'package_root': tempUri.toFilePath(),
        'target_os': 'linux',
        'target_architecture': 'x64',
        'version': version,
      });
      expect(
        () => BuildConfig.fromConfig(config),
        throwsA(predicate(
          (e) =>
              e is FormatException &&
              e.message.contains(version) &&
              e.message.contains(BuildConfig.version.toString()),
        )),
      );
    });
  }

  test('checksum', () async {
    await inTempDir((tempUri) async {
      final nativeAddUri = tempUri.resolve('native_add/');
      final fakeClangUri = tempUri.resolve('fake_clang');
      await File.fromUri(fakeClangUri).create();

      final name1 = BuildConfig.checksum(
        packageName: packageName,
        packageRoot: nativeAddUri,
        targetArchitecture: Architecture.x64,
        targetOs: OS.linux,
        buildMode: BuildMode.release,
        linkModePreference: LinkModePreference.dynamic,
      );

      // Using the checksum for a build folder should be stable.
      expect(name1, '037109b9824b2559502fa7bd42e1b6f8');

      // Build folder different due to metadata.
      final name2 = BuildConfig.checksum(
        packageName: packageName,
        packageRoot: nativeAddUri,
        targetArchitecture: Architecture.x64,
        targetOs: OS.linux,
        buildMode: BuildMode.release,
        linkModePreference: LinkModePreference.dynamic,
        dependencyMetadata: {
          'foo': const Metadata({'key': 'value'})
        },
      );
      printOnFailure([name1, name2].toString());
      expect(name1 != name2, true);

      // Build folder different due to cc.
      final name3 = BuildConfig.checksum(
          packageName: packageName,
          packageRoot: nativeAddUri,
          targetArchitecture: Architecture.x64,
          targetOs: OS.linux,
          buildMode: BuildMode.release,
          linkModePreference: LinkModePreference.dynamic,
          cCompiler: CCompilerConfig(
            cc: fakeClangUri,
          ));
      printOnFailure([name1, name3].toString());
      expect(name1 != name3, true);
    });
  });

  test('BuildConfig invalid target os architecture combination', () {
    final outDir = outDirUri;
    final config = Config(fileParsed: {
      'link_mode_preference': 'prefer-static',
      'out_dir': outDir.toFilePath(),
      'package_name': packageName,
      'package_root': tempUri.toFilePath(),
      'target_os': 'windows',
      'target_architecture': 'arm',
      'build_mode': 'debug',
      'version': BuildConfig.version.toString(),
    });
    expect(
      () => BuildConfig.fromConfig(config),
      throwsA(predicate(
        (e) => e is FormatException && e.message.contains('arm'),
      )),
    );
  });

  test('BuildConfig dry_run access invalid args', () {
    final outDir = outDirUri;
    final config = Config(fileParsed: {
      'link_mode_preference': 'prefer-static',
      'out_dir': outDir.toFilePath(),
      'package_name': packageName,
      'package_root': tempUri.toFilePath(),
      'target_os': 'windows',
      'target_architecture': 'arm64',
      'build_mode': 'debug',
      'dry_run': true,
      'version': BuildConfig.version.toString(),
    });
    expect(
      () => BuildConfig.fromConfig(config),
      throwsA(predicate(
        (e) =>
            e is FormatException && e.message.contains('In Flutter projects'),
      )),
    );
  });

  test('BuildConfig dry_run access invalid args', () {
    final outDir = outDirUri;
    final config = Config(fileParsed: {
      'link_mode_preference': 'prefer-static',
      'out_dir': outDir.toFilePath(),
      'package_name': packageName,
      'package_root': tempUri.toFilePath(),
      'target_os': 'windows',
      'dry_run': true,
      'version': BuildConfig.version.toString(),
    });
    final buildConfig = BuildConfig.fromConfig(config);
    expect(
      () => buildConfig.targetArchitecture,
      throwsA(predicate(
        (e) => e is StateError && e.message.contains('In Flutter projects'),
      )),
    );
  });

  test('BuildConfig dry_run access invalid args', () {
    final buildConfig = BuildConfig.dryRun(
      packageName: packageName,
      outDir: outDirUri,
      packageRoot: tempUri,
      targetOs: OS.windows,
      linkModePreference: LinkModePreference.dynamic,
    );
    buildConfig.toYamlString();
    // No crash.
  });
}
