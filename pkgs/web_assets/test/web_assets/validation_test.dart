// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:hooks/hooks.dart';
import 'package:test/test.dart';
import 'package:web_assets/src/web_assets/validation.dart';
import 'package:web_assets/web_assets.dart';

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

  BuildInput makeWebBuildInput() {
    final inputBuilder = BuildInputBuilder()
      ..setupShared(
        packageName: packageName,
        packageRoot: tempUri.resolve('$packageName/'),
        outputFile: tempUri.resolve('output.json'),
        outputDirectoryShared: outDirSharedUri,
      )
      ..config.setupBuild(linkingEnabled: false)
      ..addExtension(WebAssetsExtension());
    return inputBuilder.build();
  }

  LinkInput makeWebLinkInput({List<EncodedAsset> assets = const []}) {
    final inputBuilder = LinkInputBuilder()
      ..setupShared(
        packageName: packageName,
        packageRoot: tempUri.resolve('$packageName/'),
        outputFile: tempUri.resolve('output.json'),
        outputDirectoryShared: outDirSharedUri,
      )
      ..setupLink(assets: assets, assetsFromLinking: [], recordedUsesFile: null)
      ..addExtension(WebAssetsExtension());
    return inputBuilder.build();
  }

  test('build file exists', () async {
    final input = makeWebBuildInput();
    final outputBuilder = BuildOutputBuilder();
    final assetFile = File.fromUri(outDirUri.resolve('foo.txt'));
    outputBuilder.assets.webUri.add(
      WebUriAsset(
        package: input.packageName,
        name: 'foo.txt',
        file: assetFile.uri,
      ),
    );
    final errors = await validateWebAssetBuildOutput(
      input,
      outputBuilder.build(),
    );
    expect(errors, contains(contains('does not exist')));
  });

  test('link file exists', () async {
    final input = makeWebLinkInput();
    expect(input.assets.webUri, isEmpty);

    final outputBuilder = LinkOutputBuilder();
    final assetFile = File.fromUri(outDirUri.resolve('foo.txt'));
    outputBuilder.assets.webUri.addAll([
      WebUriAsset(
        package: input.packageName,
        name: 'foo.txt',
        file: assetFile.uri,
      ),
    ]);
    final output = outputBuilder.build();
    expect(output.assets.web, hasLength(1));

    final errors = await validateWebAssetLinkOutput(input, output);
    expect(errors, contains(contains('does not exist')));
  });

  test('invalid relative path', () async {
    final input = makeWebBuildInput();
    final outputBuilder = BuildOutputBuilder();
    outputBuilder.assets.webUri.add(
      WebUriAsset(
        package: input.packageName,
        name: 'foo.txt',
        file: Uri.parse('relative.txt'),
      ),
    );
    final errors = await validateWebAssetBuildOutput(
      input,
      outputBuilder.build(),
    );
    expect(errors, contains(contains('must be an absolute path')));
  });

  test('asset id in wrong package', () async {
    final input = makeWebBuildInput();
    final outputBuilder = BuildOutputBuilder();
    final assetFile = File.fromUri(outDirUri.resolve('foo.dylib'));
    await assetFile.writeAsBytes([1, 2, 3]);
    outputBuilder.assets.webUri.add(
      WebUriAsset(
        package: 'different_package',
        name: 'foo.txt',
        file: assetFile.uri,
      ),
    );
    final errors = await validateWebAssetBuildOutput(
      input,
      outputBuilder.build(),
    );
    expect(
      errors,
      contains(contains('Web uri asset must have package name my_package')),
    );
  });

  test('duplicate asset id', () async {
    final input = makeWebBuildInput();
    final outputBuilder = BuildOutputBuilder();
    final assetFile = File.fromUri(outDirUri.resolve('foo.dylib'));
    await assetFile.writeAsBytes([1, 2, 3]);
    outputBuilder.assets.webUri.addAll([
      WebUriAsset(
        package: input.packageName,
        name: 'foo.txt',
        file: assetFile.uri,
      ),
      WebUriAsset(
        package: input.packageName,
        name: 'foo.txt',
        file: assetFile.uri,
      ),
    ]);
    final errors = await validateWebAssetBuildOutput(
      input,
      outputBuilder.build(),
    );
    expect(errors, contains(contains('More than one')));
  });

  test('link input file exists', () async {
    final assetFile = File.fromUri(outDirUri.resolve('foo.txt'));
    final input = makeWebLinkInput(
      assets: [
        WebUriAsset(
          package: packageName,
          name: 'foo.txt',
          file: assetFile.uri,
        ).encode(),
      ],
    );
    expect(input.assets.webUri, hasLength(1));
    final errors = await validateWebAssetLinkInput(input);
    expect(errors, contains(contains('does not exist')));
  });

  test('build hook emits a valid web uri asset', () async {
    await testBuildHook(
      mainMethod: (args) async {
        await build(args, (input, output) async {
          expect(input.config.buildWebUriAssets, isTrue);
          final assetUri = input.outputDirectoryShared.resolve('foo.txt');
          await File.fromUri(assetUri).writeAsString('hello');
          output.assets.webUri.add(
            WebUriAsset(
              package: input.packageName,
              name: 'foo.txt',
              file: assetUri,
            ),
          );
        });
      },
      extensions: [WebAssetsExtension()],
      check: (input, output) {
        expect(output.assets.webUri, hasLength(1));
        expect(
          output.assets.webUri.single.id,
          'package:${input.packageName}/foo.txt',
        );
      },
    );
  });

  test('build hook fails when web uri asset file does not exist', () async {
    final testResult = testBuildHook(
      mainMethod: (args) async {
        await build(args, (input, output) async {
          output.assets.webUri.add(
            WebUriAsset(
              package: input.packageName,
              name: 'missing.txt',
              file: input.outputDirectoryShared.resolve('missing.txt'),
            ),
          );
        });
      },
      extensions: [WebAssetsExtension()],
      check: expectAsync2((_, _) {}, count: 0),
    );
    expect(testResult, throwsA(anything));
  });
}
