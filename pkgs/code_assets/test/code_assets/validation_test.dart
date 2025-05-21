// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:code_assets/src/code_assets/validation.dart';
import 'package:hooks/hooks.dart';
import 'package:test/test.dart';

import '../../../hooks/test/helpers.dart';

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
    final inputBuilder = BuildInputBuilder()
      ..setupShared(
        packageName: packageName,
        packageRoot: tempUri,
        outputFile: tempUri.resolve('output.json'),
        outputDirectoryShared: outDirSharedUri,
      )
      ..config.setupBuild(linkingEnabled: false);
    return inputBuilder;
  }

  BuildInput makeCodeBuildInput({
    LinkModePreference linkModePreference = LinkModePreference.dynamic,
  }) {
    final builder = makeBuildInputBuilder()
      ..addExtension(
        CodeAssetExtension(
          targetOS: OS.linux,
          targetArchitecture: Architecture.arm64,
          linkModePreference: linkModePreference,
        ),
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
        linkMode: DynamicLoadingBundled(),
      ),
    );
    final errors = await validateCodeAssetBuildOutput(
      input,
      outputBuilder.build(),
    );
    expect(
      errors,
      contains(contains("No value was provided for 'assets.0.encoding.file'.")),
    );
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
        ),
      );
      final errors = await validateCodeAssetBuildOutput(
        input,
        outputBuilder.build(),
      );
      expect(
        errors,
        contains(
          contains('which is not allowed by by the input link mode preference'),
        ),
      );
    });
  }

  test('dynamic_loading_system uri missing', () async {
    final input = makeCodeBuildInput();
    final outputBuilder = BuildOutputBuilder();
    final assetFile = File.fromUri(outDirUri.resolve('foo.dylib'));
    await assetFile.writeAsBytes([1, 2, 3]);
    outputBuilder.assets.code.add(
      CodeAsset(
        package: input.packageName,
        name: 'src/sqlite_bindings.dart',
        file: assetFile.uri,
        linkMode: DynamicLoadingSystem(
          Uri.parse(input.config.code.targetOS.dylibFileName('sqlite')),
        ),
      ),
    );
    expect(
      await validateCodeAssetBuildOutput(input, outputBuilder.build()),
      isEmpty,
    );
    traverseJson<Map<String, Object?>>(outputBuilder.json, [
      'assets',
      0,
      'encoding',
      'link_mode',
    ]).remove('uri');
    final errors = await validateCodeAssetBuildOutput(
      input,
      outputBuilder.build(),
    );
    expect(
      errors,
      contains(
        contains(
          'No value was provided for \'assets.0.encoding.link_mode.uri\'.'
          ' Expected a String.',
        ),
      ),
    );
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
      ),
      CodeAsset(
        package: input.packageName,
        name: 'src/bar.dart',
        file: assetFile.uri,
        linkMode: DynamicLoadingBundled(),
      ),
    ]);
    final errors = await validateCodeAssetBuildOutput(
      input,
      outputBuilder.build(),
    );
    expect(errors, contains(contains('Duplicate dynamic library file name')));
  });

  group('BuildInput.config.code validation', () {
    for (final propertyKey in ['target_version', 'target_sdk']) {
      test('Missing targetIOSVersion', () async {
        final builder = makeBuildInputBuilder()
          ..addExtension(
            CodeAssetExtension(
              targetOS: OS.iOS,
              targetArchitecture: Architecture.arm64,
              linkModePreference: LinkModePreference.dynamic,
              iOS: IOSCodeConfig(
                targetSdk: IOSSdk.iPhoneOS,
                targetVersion: 123,
              ),
            ),
          );
        traverseJson<Map<String, Object?>>(builder.json, [
          'config',
          'extensions',
          'code_assets',
          'ios',
        ]).remove(propertyKey);
        final errors = await validateCodeAssetBuildInput(
          BuildInput(builder.json),
        );
        expect(
          errors,
          contains(
            contains(
              'No value was provided for '
              '\'config.extensions.code_assets.ios.$propertyKey\'.',
            ),
          ),
        );
      });
    }

    test('Missing targetAndroidNdkApi', () async {
      final builder = makeBuildInputBuilder()
        ..addExtension(
          CodeAssetExtension(
            targetOS: OS.android,
            targetArchitecture: Architecture.arm64,
            linkModePreference: LinkModePreference.dynamic,
            android: AndroidCodeConfig(targetNdkApi: 123),
          ),
        );
      traverseJson<Map<String, Object?>>(builder.json, [
        'config',
        'extensions',
        'code_assets',
        'android',
      ]).remove('target_ndk_api');
      expect(
        await validateCodeAssetBuildInput(BuildInput(builder.json)),
        contains(
          contains(
            'No value was provided for '
            '\'config.extensions.code_assets.android.target_ndk_api\'.'
            ' Expected a int.',
          ),
        ),
      );
    });

    test('Missing config.code.macos', () async {
      final builder = makeBuildInputBuilder()
        ..addExtension(
          CodeAssetExtension(
            targetOS: OS.macOS,
            targetArchitecture: Architecture.arm64,
            linkModePreference: LinkModePreference.dynamic,
            macOS: MacOSCodeConfig(targetVersion: 123),
          ),
        );

      traverseJson<Map<String, Object?>>(builder.json, [
        'config',
        'extensions',
        'code_assets',
        'macos',
      ]).remove('target_version');
      expect(
        await validateCodeAssetBuildInput(BuildInput(builder.json)),
        contains(
          contains(
            'No value was provided for '
            '\'config.extensions.code_assets.macos.target_version\'.'
            ' Expected a int.',
          ),
        ),
      );

      traverseJson<Map<String, Object?>>(builder.json, [
        'config',
        'extensions',
        'code_assets',
      ]).remove('macos');
      expect(
        await validateCodeAssetBuildInput(BuildInput(builder.json)),
        contains(
          contains(
            'No value was provided for '
            '\'config.extensions.code_assets.macos\'.',
          ),
        ),
      );
    });

    test('CCompilerConfig validation', () async {
      final nonExistent = outDirUri.resolve('foo baz');
      final builder = makeBuildInputBuilder()
        ..addExtension(
          CodeAssetExtension(
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

      // If developer command prompt is present, it must contain the script.
      traverseJson<Map<String, Object?>>(builder.json, [
        'config',
        'extensions',
        'code_assets',
        'c_compiler',
        'windows',
        'developer_command_prompt',
      ]).remove('script');
      expect(
        await validateCodeAssetBuildInput(BuildInput(builder.json)),
        contains(
          contains(
            'No value was provided for '
            "'config.extensions.code_assets.c_compiler."
            "windows.developer_command_prompt.script'.",
          ),
        ),
      );

      // `developer_command_prompt` is optional for the case where clang is
      // used on Windows. So no syntax error is expected.

      // If target OS is Windows, CCompilerConfig if present must contain
      // the Windows config.
      traverseJson<Map<String, Object?>>(builder.json, [
        'config',
        'extensions',
        'code_assets',
        'c_compiler',
      ]).remove('windows');
      expect(
        await validateCodeAssetBuildInput(BuildInput(builder.json)),
        contains(
          contains(
            'No value was provided for '
            "'config.extensions.code_assets.c_compiler.windows'.",
          ),
        ),
      );
    });
  });
}
