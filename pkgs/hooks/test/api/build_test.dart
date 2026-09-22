// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:file_testing/file_testing.dart';
import 'package:hooks/hooks.dart';
import 'package:test/test.dart';

class _TestExit implements Exception {
  final int exitCode;
  _TestExit(this.exitCode);
}

void main() async {
  late Uri tempUri;
  late Uri outFile;
  late Uri outDirUri;
  late Uri outputDirectoryShared;
  late String packageName;
  late Uri packageRootUri;
  late Uri buildInputUri;
  late BuildInput input;
  late Uri linkOutFile;
  late Uri linkInputUri;

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
        outputDirectoryShared: outputDirectoryShared,
      )
      ..config.setupBuild(linkingEnabled: false);
    input = inputBuilder.build();

    final inputJson = json.encode(input.json);
    buildInputUri = tempUri.resolve('input.json');
    await File.fromUri(buildInputUri).writeAsString(inputJson);

    linkOutFile = tempUri.resolve('link_output.json');
    final linkInputBuilder = LinkInputBuilder()
      ..setupShared(
        packageRoot: tempUri,
        packageName: packageName,
        outputFile: linkOutFile,
        outputDirectoryShared: outputDirectoryShared,
      )
      ..setupLink(assets: [], recordedUsesFile: null, assetsFromLinking: []);
    final linkInput = linkInputBuilder.build();
    linkInputUri = tempUri.resolve('link_input.json');
    await File.fromUri(linkInputUri).writeAsString(json.encode(linkInput.json));
  });

  test('build method', () async {
    await build(['--config', buildInputUri.toFilePath()], (
      input,
      output,
    ) async {
      output.dependencies.add(packageRootUri.resolve('foo'));
    });
    final buildOutputUri = input.outputFile;
    expect(File.fromUri(buildOutputUri), exists);
  });

  test('build method throws HookError', () async {
    await expectLater(
      () => IOOverrides.runZoned(
        () => build(['--config', buildInputUri.toFilePath()], (
          input,
          output,
        ) async {
          throw BuildError(
            message: 'build failed',
            wrappedException: Exception('inner'),
            wrappedTrace: StackTrace.current,
          );
        }),
        exit: (code) => throw _TestExit(code),
      ),
      throwsA(isA<_TestExit>().having((e) => e.exitCode, 'exitCode', 1)),
    );
    expect(File.fromUri(outFile), exists);
  });

  test('build method validation error', () async {
    await expectLater(
      () => IOOverrides.runZoned(
        () => build(['--config', buildInputUri.toFilePath()], (
          input,
          output,
        ) async {
          output.assets.addEncodedAsset(EncodedAsset('unsupported_type', {}));
        }),
        exit: (code) => throw _TestExit(code),
      ),
      throwsA(isA<_TestExit>().having((e) => e.exitCode, 'exitCode', 1)),
    );
    expect(File.fromUri(outFile), exists);
  });

  test('link method', () async {
    await link(['--config', linkInputUri.toFilePath()], (input, output) async {
      output.dependencies.add(packageRootUri.resolve('bar'));
    });
    expect(File.fromUri(linkOutFile), exists);
  });

  test('link method throws HookError', () async {
    await expectLater(
      () => IOOverrides.runZoned(
        () => link(['--config', linkInputUri.toFilePath()], (
          input,
          output,
        ) async {
          throw InfraError(message: 'infra failed');
        }),
        exit: (code) => throw _TestExit(code),
      ),
      throwsA(isA<_TestExit>().having((e) => e.exitCode, 'exitCode', 2)),
    );
    expect(File.fromUri(linkOutFile), exists);
  });

  test('link method validation error', () async {
    await expectLater(
      () => IOOverrides.runZoned(
        () => link(['--config', linkInputUri.toFilePath()], (
          input,
          output,
        ) async {
          output.assets.addEncodedAsset(EncodedAsset('unsupported_type', {}));
        }),
        exit: (code) => throw _TestExit(code),
      ),
      throwsA(isA<_TestExit>().having((e) => e.exitCode, 'exitCode', 1)),
    );
    expect(File.fromUri(linkOutFile), exists);
  });

  test('missing --config argument throws StateError', () {
    expect(() => build([], (input, output) async {}), throwsStateError);
  });
}
