// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:hooks/hooks.dart';

import 'package:hooks_runner/src/model/build_result.dart';
import 'package:hooks_runner/src/model/hook_result.dart';
import 'package:test/test.dart';

void main() {
  test('HookResult toJson and fromJson', () {
    final asset = EncodedAsset('test_type', {'key': 'value'});
    final result = HookResult(
      encodedAssets: [asset],
      encodedAssetsForLinking: {
        'package_a': [asset],
      },
      dependencies: [Uri.parse('file:///test.dart')],
    );

    final json = result.toJson();
    final deserialized = HookResult.fromJson(json);

    expect(deserialized.encodedAssets, equals(result.encodedAssets));
    expect(
      deserialized.encodedAssetsForLinking,
      equals(result.encodedAssetsForLinking),
    );
    expect(deserialized.dependencies, equals(result.dependencies));
  });

  test('BuildResult.fromJson', () {
    final asset = EncodedAsset('test_type', {'key': 'value'});
    final result = HookResult(
      encodedAssets: [asset],
      encodedAssetsForLinking: {
        'package_a': [asset],
      },
      dependencies: [Uri.parse('file:///test.dart')],
    );

    final json = result.toJson();
    final deserialized = BuildResult.fromJson(json);

    expect(deserialized.encodedAssets, equals(result.encodedAssets));
    expect(
      deserialized.encodedAssetsForLinking,
      equals(result.encodedAssetsForLinking),
    );
    expect(deserialized.dependencies, equals(result.dependencies));
  });
}
