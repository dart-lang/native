// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:native_assets_cli/native_assets_cli.dart';
import 'package:test/test.dart';

void main() {
  late Uri tempUri;

  setUp(() async {
    tempUri = (await Directory.systemTemp.createTemp()).uri;
  });

  tearDown(() async {
    await Directory.fromUri(tempUri).delete(recursive: true);
  });

  test('BuildOutput constructor', () {
    BuildOutput(
      timestamp: DateTime.parse('2022-11-10 13:25:01.000'),
      assets: [
        CCodeAsset(
          id: 'package:my_package/foo',
          file: Uri(path: 'path/to/libfoo.so'),
          dynamicLoading: BundledDylib(),
          os: OS.android,
          architecture: Architecture.x64,
          linkMode: LinkMode.dynamic,
        ),
        CCodeAsset(
          id: 'package:my_package/foo2',
          dynamicLoading: SystemDylib(Uri(path: 'path/to/libfoo2.so')),
          os: OS.android,
          architecture: Architecture.x64,
          linkMode: LinkMode.dynamic,
        ),
      ],
      dependencies: [
        Uri.file('path/to/file.ext'),
      ],
      metadata: {
        'key': 'value',
      },
    );
  });
}
