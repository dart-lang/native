// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:hooks/hooks.dart';
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

  BuildInput makeBuildInput() {
    final inputBuilder = BuildInputBuilder()
      ..setupShared(
        packageName: packageName,
        packageRoot: tempUri,
        outputFile: tempUri.resolve('output.json'),
        outputDirectoryShared: outDirSharedUri,
      )
      ..config.setupBuild(linkingEnabled: false);
    return inputBuilder.build();
  }

  test('linking not enabled', () async {
    final input = makeBuildInput();
    final outputBuilder = BuildOutputBuilder();
    final assetFile = File.fromUri(outDirUri.resolve('foo.dylib'));
    await assetFile.writeAsBytes([1, 2, 3]);
    outputBuilder.assets.addEncodedAsset(
      EncodedAsset('my-asset-type', {}),
      routing: const ToLinkHook('bar'),
    );
    final errors = await ProtocolBase.validateBuildOutput(
      input,
      outputBuilder.build(),
    );
    expect(errors, contains(contains('linkingEnabled is false')));
  });

  test('supported asset type', () async {
    final input = makeBuildInput();
    final outputBuilder = BuildOutputBuilder();
    final assetFile = File.fromUri(outDirUri.resolve('foo.dylib'));
    await assetFile.writeAsBytes([1, 2, 3]);
    outputBuilder.assets.addEncodedAsset(EncodedAsset('baz', {}));
    final errors = await ProtocolBase.validateBuildOutput(
      input,
      outputBuilder.build(),
    );
    expect(errors, contains(contains('"baz" is not a supported asset type')));
  });
}
