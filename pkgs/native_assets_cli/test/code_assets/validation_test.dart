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

  BuildInputBuilder makeBuildInputBuilder() {
    final inputBuilder = BuildInputBuilder()
      ..setupHookInput(
        packageName: packageName,
        packageRoot: tempUri,
        outputDirectory: outDirUri,
        outputDirectoryShared: outDirSharedUri,
      )
      ..setupBuildInput(
        linkingEnabled: false,
        dryRun: false,
      );
    return inputBuilder;
  }

  BuildInput makeCodeBuildInput({
    LinkModePreference linkModePreference = LinkModePreference.dynamic,
  }) {
    final builder = makeBuildInputBuilder()
      ..setupCodeConfig(
        targetOS: OS.linux,
        targetArchitecture: Architecture.arm64,
        linkModePreference: linkModePreference,
      );
    return BuildInput(builder.json);
  }

  test('file not set', () async {
    final input = makeCodeBuildInput();
    final outputBuilder = BuildOutputBuilder();
    outputBuilder.codeAssets.add(CodeAsset(
      package: input.packageName,
      name: 'foo.dylib',
      architecture: input.codeConfig.targetArchitecture,
      os: input.codeConfig.targetOS,
      linkMode: DynamicLoadingBundled(),
    ));
    final errors = await validateCodeAssetBuildOutput(
        input, BuildOutput(outputBuilder.json));
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
      final input =
          makeCodeBuildInput(linkModePreference: linkModePreference);
      final outputBuilder = BuildOutputBuilder();
      final assetFile = File.fromUri(outDirUri.resolve('foo.dylib'));
      await assetFile.writeAsBytes([1, 2, 3]);
      outputBuilder.codeAssets.add(
        CodeAsset(
          package: input.packageName,
          name: 'foo.dart',
          file: assetFile.uri,
          linkMode: linkMode,
          os: input.codeConfig.targetOS,
          architecture: input.codeConfig.targetArchitecture,
        ),
      );
      final errors = await validateCodeAssetBuildOutput(
          input, BuildOutput(outputBuilder.json));
      expect(
        errors,
        contains(contains(
          'which is not allowed by by the input link mode preference',
        )),
      );
    });
  }

  test('native code wrong architecture', () async {
    final input = makeCodeBuildInput();
    final outputBuilder = BuildOutputBuilder();
    final assetFile = File.fromUri(outDirUri.resolve('foo.dylib'));
    await assetFile.writeAsBytes([1, 2, 3]);
    outputBuilder.codeAssets.add(
      CodeAsset(
        package: input.packageName,
        name: 'foo.dart',
        file: assetFile.uri,
        linkMode: DynamicLoadingBundled(),
        os: input.codeConfig.targetOS,
        architecture: Architecture.x64,
      ),
    );
    final errors = await validateCodeAssetBuildOutput(
        input, BuildOutput(outputBuilder.json));
    expect(
      errors,
      contains(contains(
        'which is not the target architecture',
      )),
    );
  });

  test('native code no architecture', () async {
    final input = makeCodeBuildInput();
    final outputBuilder = BuildOutputBuilder();
    final assetFile = File.fromUri(outDirUri.resolve('foo.dylib'));
    await assetFile.writeAsBytes([1, 2, 3]);
    outputBuilder.codeAssets.add(
      CodeAsset(
        package: input.packageName,
        name: 'foo.dart',
        file: assetFile.uri,
        linkMode: DynamicLoadingBundled(),
        os: input.codeConfig.targetOS,
      ),
    );
    final errors = await validateCodeAssetBuildOutput(
        input, BuildOutput(outputBuilder.json));
    expect(
      errors,
      contains(contains(
        'has no architecture',
      )),
    );
  });

  test('native code asset wrong os', () async {
    final input = makeCodeBuildInput();
    final outputBuilder = BuildOutputBuilder();
    final assetFile = File.fromUri(outDirUri.resolve('foo.dylib'));
    await assetFile.writeAsBytes([1, 2, 3]);
    outputBuilder.codeAssets.add(
      CodeAsset(
        package: input.packageName,
        name: 'foo.dart',
        file: assetFile.uri,
        linkMode: DynamicLoadingBundled(),
        os: OS.windows,
        architecture: input.codeConfig.targetArchitecture,
      ),
    );
    final errors = await validateCodeAssetBuildOutput(
        input, BuildOutput(outputBuilder.json));
    expect(
      errors,
      contains(contains(
        'which is not the target os',
      )),
    );
  });

  test('duplicate dylib name', () async {
    final input = makeCodeBuildInput();
    final outputBuilder = BuildOutputBuilder();
    final fileName = input.codeConfig.targetOS.dylibFileName('foo');
    final assetFile = File.fromUri(outDirUri.resolve(fileName));
    await assetFile.writeAsBytes([1, 2, 3]);
    outputBuilder.codeAssets.addAll([
      CodeAsset(
        package: input.packageName,
        name: 'src/foo.dart',
        file: assetFile.uri,
        linkMode: DynamicLoadingBundled(),
        os: input.codeConfig.targetOS,
        architecture: input.codeConfig.targetArchitecture,
      ),
      CodeAsset(
        package: input.packageName,
        name: 'src/bar.dart',
        file: assetFile.uri,
        linkMode: DynamicLoadingBundled(),
        os: input.codeConfig.targetOS,
        architecture: input.codeConfig.targetArchitecture,
      ),
    ]);
    final errors = await validateCodeAssetBuildOutput(
        input, BuildOutput(outputBuilder.json));
    expect(
      errors,
      contains(contains('Duplicate dynamic library file name')),
    );
  });

  group('BuildInput.codeConfig validation', () {
    test('Missing targetIOSVersion', () async {
      final builder = makeBuildInputBuilder()
        ..setupCodeConfig(
          targetOS: OS.iOS,
          targetArchitecture: Architecture.arm64,
          linkModePreference: LinkModePreference.dynamic,
        );
      final errors =
          await validateCodeAssetBuildInput(BuildInput(builder.json));
      expect(
          errors,
          contains(contains(
              'BuildInput.codeConfig.iOSConfig.targetVersion was missing')));
      expect(
          errors,
          contains(
              contains('BuildInput.codeConfig.targetIOSSdk was missing')));
    });
    test('Missing targetAndroidNdkApi', () async {
      final builder = makeBuildInputBuilder()
        ..setupCodeConfig(
          targetOS: OS.android,
          targetArchitecture: Architecture.arm64,
          linkModePreference: LinkModePreference.dynamic,
        );
      expect(
        await validateCodeAssetBuildInput(BuildInput(builder.json)),
        contains(contains(
            'BuildInput.codeConfig.androidConfig.targetNdkApi was missing')),
      );
    });
    test('Missing targetMacOSVersion', () async {
      final builder = makeBuildInputBuilder()
        ..setupCodeConfig(
          targetOS: OS.macOS,
          targetArchitecture: Architecture.arm64,
          linkModePreference: LinkModePreference.dynamic,
        );
      expect(
          await validateCodeAssetBuildInput(BuildInput(builder.json)),
          contains(contains(
              'BuildInput.codeConfig.macOSConfig.targetVersion was missing')));
    });
    test('Nonexisting compiler/archiver/linker/envScript', () async {
      final nonExistent = outDirUri.resolve('foo baz');
      final builder = makeBuildInputBuilder()
        ..setupCodeConfig(
            targetOS: OS.linux,
            targetArchitecture: Architecture.arm64,
            linkModePreference: LinkModePreference.dynamic,
            cCompilerConfig: CCompilerConfig(
              compiler: nonExistent,
              linker: nonExistent,
              archiver: nonExistent,
              envScript: nonExistent,
            ));
      final errors =
          await validateCodeAssetBuildInput(BuildInput(builder.json));

      bool matches(String error, String field) =>
          RegExp('BuildInput.codeConfig.$field (.*foo baz).* does not exist.')
              .hasMatch(error);

      expect(errors.any((e) => matches(e, 'compiler')), true);
      expect(errors.any((e) => matches(e, 'linker')), true);
      expect(errors.any((e) => matches(e, 'archiver')), true);
      expect(errors.any((e) => matches(e, 'envScript')), true);
    });
  });
}
