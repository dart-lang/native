// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:file_testing/file_testing.dart';
import 'package:test/test.dart';

import '../hook/build.dart' as build;

void main() async {
  test('test my build hook', () async {
    await testCodeBuildHook(
      mainMethod: build.main,
      check: (input, output) {
        expect(output.assets.encodedAssets.length, equals(1));
        expect(output.assets.code, isNotEmpty);
        expect(output.assets.code.first.id, 'package:local_asset/asset.txt');
        expect(File.fromUri(output.assets.code.first.file!), exists);
        expect(
          output.dependencies,
          equals([input.packageRoot.resolve('assets/asset.txt')]),
        );
      },
    );
  });
}
