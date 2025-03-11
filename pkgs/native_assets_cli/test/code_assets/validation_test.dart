// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:native_assets_cli/code_assets_builder.dart';
import 'package:native_assets_cli/src/code_assets/validation.dart';
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

  BuildInputBuilder makeBuildInputBuilder() {
    final inputBuilder =
        BuildInputBuilder()
          ..setupShared(
            packageName: packageName,
            packageRoot: tempUri,
            outputFile: tempUri.resolve('output.json'),
            outputDirectory: outDirUri,
            outputDirectoryShared: outDirSharedUri,
          )
          ..config.setupBuild(linkingEnabled: false);
    return inputBuilder;
  }

  BuildInput makeCodeBuildInput({
    LinkModePreference linkModePreference = LinkModePreference.dynamic,
  }) {
    final builder =
        makeBuildInputBuilder()
          ..config.setupShared(buildAssetTypes: [CodeAsset.type])
          ..config.setupCode(
            targetOS: OS.linux,
            targetArchitecture: Architecture.arm64,
            linkModePreference: linkModePreference,
          );
    return BuildInput(builder.json);
  }

  test('file not set', () async {
    final input = makeCodeBuildInput();
    final outputBuilder = BuildOutputBuilder();
    outputBuilder.assets.code.add(
      CodeAsset(
        package: input.packageName,
        name: 'foo.dylib',
        architecture: input.config.code.targetArchitecture,
        os: input.config.code.targetOS,
        linkMode: DynamicLoadingBundled(),
      ),
    );
    final errors = await validateCodeAssetBuildOutput(
      input,
      BuildOutput(outputBuilder.json),
    );
    expect(errors, contains(contains('has no file')));
  });

  for (final (linkModePreference, linkMode) in [
    (LinkModePreference.static, DynamicLoadingBundled()),
    (LinkModePreference.dynamic, StaticLinking()),
  ]) {
    test('native code asset wrong linking $linkModePreference', () async {
      final input = makeCodeBuildInput(linkModePreference: linkModePreference);
      final outputBuilder = BuildOutputBuilder();
      final assetFile = File.fromUri(outDirUri.resolve('foo.dylib'));
      await assetFile.writeAsBytes([1, 2, 3]);
      outputBuilder.assets.code.add(
        CodeAsset(
          package: input.packageName,
          name: 'foo.dart',
          file: assetFile.uri,
          linkMode: linkMode,
          os: input.config.code.targetOS,
          architecture: input.config.code.targetArchitecture,
        ),
      );
      final errors = await validateCodeAssetBuildOutput(
        input,
        BuildOutput(outputBuilder.json),
      );
      expect(
        errors,
        contains(
          contains('which is not allowed by by the input link mode preference'),
        ),
      );
    });
  }

  test('native code wrong architecture', () async {
    final input = makeCodeBuildInput();
    final outputBuilder = BuildOutputBuilder();
    final assetFile = File.fromUri(outDirUri.resolve('foo.dylib'));
    await assetFile.writeAsBytes([1, 2, 3]);
    outputBuilder.assets.code.add(
      CodeAsset(
        package: input.packageName,
        name: 'foo.dart',
        file: assetFile.uri,
        linkMode: DynamicLoadingBundled(),
        os: input.config.code.targetOS,
        architecture: Architecture.x64,
      ),
    );
    final errors = await validateCodeAssetBuildOutput(
      input,
      BuildOutput(outputBuilder.json),
    );
    expect(errors, contains(contains('which is not the target architecture')));
  });

  test('native code no architecture', () async {
    final input = makeCodeBuildInput();
    final outputBuilder = BuildOutputBuilder();
    final assetFile = File.fromUri(outDirUri.resolve('foo.dylib'));
    await assetFile.writeAsBytes([1, 2, 3]);
    outputBuilder.assets.code.add(
      CodeAsset(
        package: input.packageName,
        name: 'foo.dart',
        file: assetFile.uri,
        linkMode: DynamicLoadingBundled(),
        os: input.config.code.targetOS,
      ),
    );
    final errors = await validateCodeAssetBuildOutput(
      input,
      BuildOutput(outputBuilder.json),
    );
    expect(errors, contains(contains('has no architecture')));
  });

  test('native code asset wrong os', () async {
    final input = makeCodeBuildInput();
    final outputBuilder = BuildOutputBuilder();
    final assetFile = File.fromUri(outDirUri.resolve('foo.dylib'));
    await assetFile.writeAsBytes([1, 2, 3]);
    outputBuilder.assets.code.add(
      CodeAsset(
        package: input.packageName,
        name: 'foo.dart',
        file: assetFile.uri,
        linkMode: DynamicLoadingBundled(),
        os: OS.windows,
        architecture: input.config.code.targetArchitecture,
      ),
    );
    final errors = await validateCodeAssetBuildOutput(
      input,
      BuildOutput(outputBuilder.json),
    );
    expect(errors, contains(contains('which is not the target os')));
  });

  test('duplicate dylib name', () async {
    final input = makeCodeBuildInput();
    final outputBuilder = BuildOutputBuilder();
    final fileName = input.config.code.targetOS.dylibFileName('foo');
    final assetFile = File.fromUri(outDirUri.resolve(fileName));
    await assetFile.writeAsBytes([1, 2, 3]);
    outputBuilder.assets.code.addAll([
      CodeAsset(
        package: input.packageName,
        name: 'src/foo.dart',
        file: assetFile.uri,
        linkMode: DynamicLoadingBundled(),
        os: input.config.code.targetOS,
        architecture: input.config.code.targetArchitecture,
      ),
      CodeAsset(
        package: input.packageName,
        name: 'src/bar.dart',
        file: assetFile.uri,
        linkMode: DynamicLoadingBundled(),
        os: input.config.code.targetOS,
        architecture: input.config.code.targetArchitecture,
      ),
    ]);
    final errors = await validateCodeAssetBuildOutput(
      input,
      BuildOutput(outputBuilder.json),
    );
    expect(errors, contains(contains('Duplicate dynamic library file name')));
  });

  group('BuildInput.config.code validation', () {
    for (final (propertyKey, name) in [
      ('target_version', 'targetVersion'),
      ('target_sdk', 'targetSdk'),
    ]) {
      test('Missing targetIOSVersion', () async {
        final builder =
            makeBuildInputBuilder()
              ..config.setupShared(buildAssetTypes: [CodeAsset.type])
              ..config.setupCode(
                targetOS: OS.iOS,
                targetArchitecture: Architecture.arm64,
                linkModePreference: LinkModePreference.dynamic,
                iOS: IOSCodeConfig(
                  targetSdk: IOSSdk.iPhoneOS,
                  targetVersion: 123,
                ),
              );
        traverseJson<Map<String, Object?>>(builder.json, [
          'config',
          'code',
          'ios',
        ]).remove(propertyKey);
        final errors = await validateCodeAssetBuildInput(
          BuildInput(builder.json),
        );
        expect(
          errors,
          contains(contains('BuildInput.config.code.iOS.$name was missing')),
        );
      });
    }

    test('Missing targetAndroidNdkApi', () async {
      final builder =
          makeBuildInputBuilder()
            ..config.setupShared(buildAssetTypes: [CodeAsset.type])
            ..config.setupCode(
              targetOS: OS.android,
              targetArchitecture: Architecture.arm64,
              linkModePreference: LinkModePreference.dynamic,
              android: AndroidCodeConfig(targetNdkApi: 123),
            );
      traverseJson<Map<String, Object?>>(builder.json, [
        'config',
        'code',
        'android',
      ]).remove('target_ndk_api');
      expect(
        await validateCodeAssetBuildInput(BuildInput(builder.json)),
        contains(
          contains('BuildInput.config.code.android.targetNdkApi was missing'),
        ),
      );
    });
    test('Missing targetMacOSVersion', () async {
      final builder =
          makeBuildInputBuilder()
            ..config.setupShared(buildAssetTypes: [CodeAsset.type])
            ..config.setupCode(
              targetOS: OS.macOS,
              targetArchitecture: Architecture.arm64,
              linkModePreference: LinkModePreference.dynamic,
              macOS: MacOSCodeConfig(targetVersion: 123),
            );

      traverseJson<Map<String, Object?>>(builder.json, [
        'config',
        'code',
        'macos',
      ]).remove('target_version');
      expect(
        await validateCodeAssetBuildInput(BuildInput(builder.json)),
        contains(
          contains(
            'BuildInput.config.code.macOS.targetVersion'
            ' was missing',
          ),
        ),
      );
    });
    test('Nonexisting compiler/archiver/linker/envScript', () async {
      final nonExistent = outDirUri.resolve('foo baz');
      final builder =
          makeBuildInputBuilder()
            ..config.setupShared(buildAssetTypes: [CodeAsset.type])
            ..config.setupCode(
              targetOS: OS.windows,
              targetArchitecture: Architecture.x64,
              linkModePreference: LinkModePreference.dynamic,
              cCompiler: CCompilerConfig(
                compiler: nonExistent,
                linker: nonExistent,
                archiver: nonExistent,
                windows: WindowsCCompilerConfig(
                  developerCommandPrompt: DeveloperCommandPrompt(
                    script: nonExistent,
                    arguments: [],
                  ),
                ),
              ),
            );
      final errors = await validateCodeAssetBuildInput(
        BuildInput(builder.json),
      );

      bool matches(String error, String field) => RegExp(
        'BuildInput.config.code.cCompiler.$field (.*foo baz).* does not'
        ' exist.',
      ).hasMatch(error);

      expect(errors.any((e) => matches(e, 'compiler')), true);
      expect(errors.any((e) => matches(e, 'linker')), true);
      expect(errors.any((e) => matches(e, 'archiver')), true);
      expect(
        errors.any((e) => matches(e, 'windows.developerCommandPrompt.script')),
        true,
      );
    });
  });
}

T traverseJson<T extends Object?>(Object json, List<Object> path) {
  while (path.isNotEmpty) {
    final key = path.removeAt(0);
    switch (key) {
      case final int i:
        json = (json as List)[i] as Object;
        break;
      case final String s:
        json = (json as Map)[s] as Object;
        break;
      default:
        throw UnsupportedError(key.toString());
    }
  }
  return json as T;
}
