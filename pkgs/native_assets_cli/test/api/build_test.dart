// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:file_testing/file_testing.dart';
import 'package:native_assets_cli/native_assets_cli.dart' show build;
import 'package:native_assets_cli/native_assets_cli_builder.dart';
import 'package:native_assets_cli/native_assets_cli_internal.dart' show Hook;
import 'package:test/test.dart';

void main() async {
  late Uri tempUri;
  late Uri outDirUri;
  late Uri outputDirectoryShared;
  late String packageName;
  late Uri packageRootUri;
  late Uri buildConfigUri;
  late BuildConfig config;

  setUp(() async {
    tempUri = (await Directory.systemTemp.createTemp()).uri;
    outDirUri = tempUri.resolve('out1/');
    await Directory.fromUri(outDirUri).create();
    outputDirectoryShared = tempUri.resolve('out_shared1/');
    packageName = 'my_package';
    packageRootUri = tempUri.resolve('$packageName/');
    await Directory.fromUri(packageRootUri).create();

    final configBuilder = BuildConfigBuilder();
    configBuilder
      ..setupHookConfig(
        packageRoot: tempUri,
        packageName: packageName,
      )
      ..addBuildAssetType('foo')
      ..setupBuildConfig(
        dryRun: false,
        linkingEnabled: false,
      )
      ..setupBuildRunConfig(
        outputDirectory: outDirUri,
        outputDirectoryShared: outputDirectoryShared,
      );
    config = BuildConfig(configBuilder.json);

    final configJson = json.encode(config.json);
    buildConfigUri = tempUri.resolve('build_config.json');
    await File.fromUri(buildConfigUri).writeAsString(configJson);
  });

  test('build method', () async {
    await build(['--config', buildConfigUri.toFilePath()],
        (config, output) async {
      output.addDependency(packageRootUri.resolve('foo'));
    });
    final buildOutputUri =
        config.outputDirectory.resolve(Hook.build.outputName);
    expect(File.fromUri(buildOutputUri), exists);
  });
}
