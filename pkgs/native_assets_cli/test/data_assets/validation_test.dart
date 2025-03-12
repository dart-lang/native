// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:native_assets_cli/data_assets_builder.dart';
import 'package:native_assets_cli/src/config.dart';
import 'package:native_assets_cli/src/data_assets/validation.dart';
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

  BuildInput makeDataBuildInput() {
    final inputBuilder =
        BuildInputBuilder()
          ..setupShared(
            packageName: packageName,
            packageRoot: tempUri,
            outputFile: tempUri.resolve('output.json'),
            outputDirectory: outDirUri,
            outputDirectoryShared: outDirSharedUri,
          )
          ..config.setupBuild(linkingEnabled: false)
          ..config.setupShared(buildAssetTypes: [DataAsset.type]);
    return BuildInput(inputBuilder.json);
  }

  test('file exists', () async {
    final input = makeDataBuildInput();
    final outputBuilder = BuildOutputBuilder();
    final assetFile = File.fromUri(outDirUri.resolve('foo.txt'));
    outputBuilder.assets.data.add(
      DataAsset(
        package: input.packageName,
        name: 'foo.txt',
        file: assetFile.uri,
      ),
    );
    final errors = await validateDataAssetBuildOutput(
      input,
      BuildOutput(outputBuilder.json),
    );
    expect(errors, contains(contains('does not exist')));
  });

  test('asset id in wrong package', () async {
    final input = makeDataBuildInput();
    final outputBuilder = BuildOutputBuilder();
    final assetFile = File.fromUri(outDirUri.resolve('foo.dylib'));
    await assetFile.writeAsBytes([1, 2, 3]);
    outputBuilder.assets.data.add(
      DataAsset(
        package: 'different_package',
        name: 'foo.txt',
        file: assetFile.uri,
      ),
    );
    final errors = await validateDataAssetBuildOutput(
      input,
      BuildOutput(outputBuilder.json),
    );
    expect(
      errors,
      contains(contains('Data asset must have package name my_package')),
    );
  });

  test('duplicate asset id', () async {
    final input = makeDataBuildInput();
    final outputBuilder = BuildOutputBuilder();
    final assetFile = File.fromUri(outDirUri.resolve('foo.dylib'));
    await assetFile.writeAsBytes([1, 2, 3]);
    outputBuilder.assets.data.addAll([
      DataAsset(
        package: input.packageName,
        name: 'foo.txt',
        file: assetFile.uri,
      ),
      DataAsset(
        package: input.packageName,
        name: 'foo.txt',
        file: assetFile.uri,
      ),
    ]);
    final errors = await validateDataAssetBuildOutput(
      input,
      BuildOutput(outputBuilder.json),
    );
    expect(errors, contains(contains('More than one')));
  });

  test('addDataAssetDirectories processes multiple directories', () async {
    final input = makeDataBuildInput();
    final outputBuilder = BuildOutputBuilder();

    final assetsDir1Uri = packageRootUri.resolve('assets1');
    final assetsDir1 = Directory.fromUri(assetsDir1Uri);
    await assetsDir1.create(recursive: true);

    final assetsDir2Uri = packageRootUri.resolve('assets2');
    final assetsDir2 = Directory.fromUri(assetsDir2Uri);
    await assetsDir2.create(recursive: true);

    // Create a file in assets1.
    final file1Uri = assetsDir1.uri.resolve('file1.txt');
    final file1 = File.fromUri(file1Uri);
    await file1.writeAsString('Hello World');

    // Create a file in assets2.
    final file2Uri = assetsDir2.uri.resolve('file2.txt');
    final file2 = File.fromUri(file2Uri);
    await file2.writeAsString('Hello Dart');

    final output = BuildOutput(outputBuilder.json);
    await outputBuilder.addDataAssetDirectories([
      'assets1',
      'assets2',
    ], input: input);

    // Check that both subdirectories were added as dependencies.
    expect(output.dependencies, contains(assetsDir2.uri));
    expect(output.dependencies, contains(assetsDir2.uri));
    // Check that the files in both directories were added as dependencies.
    expect(output.dependencies, contains(file1Uri));
    expect(output.dependencies, contains(file2Uri));
  });

  test('addDataAssetDirectories processes one file', () async {
    final input = makeDataBuildInput();
    final outputBuilder = BuildOutputBuilder();

    final assetsDirUri = packageRootUri.resolve('single_assets');
    final assetsDir = Directory.fromUri(assetsDirUri);
    await assetsDir.create(recursive: true);

    // Create a file in the single_assets directory.
    final fileUri = assetsDir.uri.resolve('single_file.txt');
    final file = File.fromUri(fileUri);
    await file.writeAsString('Test content');

    final output = BuildOutput(outputBuilder.json);
    await outputBuilder.addDataAssetDirectories([
      'single_assets/single_file.txt',
    ], input: input);

    // Check that the directory was added as a dependency.
    expect(output.dependencies, contains(assetsDir.uri));
    // Check that the file in the directory was added as a dependency.
    expect(output.dependencies, contains(fileUri));
  });

  test('addDataAssetDirectories processes nested directories', () async {
    final input = makeDataBuildInput();
    final outputBuilder = BuildOutputBuilder();

    // Create top-level assets directory.
    final assetsDirUri = packageRootUri.resolve('assets3');
    final assetsDir = Directory.fromUri(assetsDirUri);
    await assetsDir.create(recursive: true);

    // Create nested subdirectory.
    final nestedDirUri = assetsDir.uri.resolve('subdir');
    final nestedDir = Directory.fromUri(nestedDirUri);
    await nestedDir.create(recursive: true);

    final nestedDir2Uri = nestedDir.uri.resolve('subdir2');
    final nestedDir2 = Directory.fromUri(nestedDir2Uri);
    await nestedDir2.create(recursive: true);

    // Create a file in the top-level assets directory.
    final fileTopUri = assetsDir.uri.resolve('top_file.txt');
    final fileTop = File.fromUri(fileTopUri);
    await fileTop.writeAsString('Top level file');

    // Create a file in the nested subdirectory.
    final nestedFileUri = nestedDir.uri.resolve('nested_file.txt');
    final nestedFile = File.fromUri(nestedFileUri);
    await nestedFile.writeAsString('Nested file');

    // Create a file in the nested subdirectory.
    final nestedFile2Uri = nestedDir2.uri.resolve('nested_file2.txt');
    final nestedFile2 = File.fromUri(nestedFile2Uri);
    await nestedFile2.writeAsString('Nested file 2');

    final output = BuildOutput(outputBuilder.json);
    await outputBuilder.addDataAssetDirectories(['assets3'], input: input);

    // Verify that the top-level directory, nested directory, and both files are
    // added.
    expect(output.dependencies, contains(assetsDir.uri));
    expect(output.dependencies, contains(nestedDir.uri));
    expect(output.dependencies, contains(fileTopUri));
    expect(output.dependencies, contains(nestedFileUri));
    expect(output.dependencies, contains(nestedFile2Uri));
  });
}
