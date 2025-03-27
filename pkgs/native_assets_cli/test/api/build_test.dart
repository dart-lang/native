// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:file_testing/file_testing.dart';
import 'package:native_assets_cli/native_assets_cli.dart' show build;
import 'package:native_assets_cli/native_assets_cli_builder.dart';
import 'package:test/test.dart';

void main() async {
  late Uri tempUri;
  late Uri outFile;
  late Uri outDirUri;
  late Uri outputDirectoryShared;
  late String packageName;
  late Uri packageRootUri;
  late Uri buildInputUri;
  late BuildInput input;

  setUp(() async {
    tempUri = (await Directory.systemTemp.createTemp()).uri;
    outFile = tempUri.resolve('output.json');
    outDirUri = tempUri.resolve('out1/');
    await Directory.fromUri(outDirUri).create();
    outputDirectoryShared = tempUri.resolve('out_shared1/');
    packageName = 'my_package';
    packageRootUri = tempUri.resolve('$packageName/');
    await Directory.fromUri(packageRootUri).create();

    final inputBuilder = BuildInputBuilder();
    inputBuilder
      ..setupShared(
        packageRoot: tempUri,
        packageName: packageName,
        outputFile: outFile,
        outputDirectory: outDirUri,
        outputDirectoryShared: outputDirectoryShared,
      )
      ..config.setupBuild(linkingEnabled: false);
    input = BuildInput(inputBuilder.json);

    final inputJson = json.encode(input.json);
    buildInputUri = tempUri.resolve('input.json');
    await File.fromUri(buildInputUri).writeAsString(inputJson);
  });

  test('build method', () async {
    await build(['--config', buildInputUri.toFilePath()], (
      input,
      output,
    ) async {
      output.addDependency(packageRootUri.resolve('foo'));
    });
    final buildOutputUri = input.outputFile;
    expect(File.fromUri(buildOutputUri), exists);
  });
}
