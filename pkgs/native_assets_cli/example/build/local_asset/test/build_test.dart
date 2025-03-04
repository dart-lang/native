// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:native_assets_cli/code_assets_testing.dart';
import 'package:test/test.dart';

import '../hook/build.dart' as build;

void main() async {
  test('test my build hook', () async {
    await testCodeBuildHook(
      mainMethod: build.main,
      check: (_, output) {
        expect(output.assets.code, isNotEmpty);
        expect(output.assets.code.first.id, 'package:local_asset/asset.txt');
      },
    );
  });
}
