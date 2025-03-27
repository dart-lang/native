// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:native_assets_cli/code_assets_builder.dart';
import 'package:test/test.dart';

void main() async {
  final fileUri = Uri.file('/not there.txt');
  // TODO(https://github.com/dart-lang/native/issues/2040): Change to
  // toString if we change to json schema format uri.
  final fileUriSerialized = fileUri.toFilePath();
  test('CodeAsset toJson', () {
    expect(
      CodeAsset(
        package: 'my_package',
        name: 'name',
        linkMode: DynamicLoadingBundled(),
        os: OS.android,
        file: fileUri,
        architecture: Architecture.riscv64,
      ).encode().toJson(),
      {
        'architecture': 'riscv64',
        'file': fileUriSerialized,
        'id': 'package:my_package/name',
        'link_mode': {'type': 'dynamic_loading_bundle'},
        'os': 'android',
        'type': 'native_code',
        'encoding': {
          'architecture': 'riscv64',
          'file': fileUriSerialized,
          'id': 'package:my_package/name',
          'link_mode': {'type': 'dynamic_loading_bundle'},
          'os': 'android',
        },
      },
    );
  });

  for (final assetType in ['native_code', 'code_assets/code']) {
    for (final nestInEncoding in [true, false]) {
      test('CodeAsset fromJson', () {
        final encodedAsset = EncodedAsset.fromJson({
          'type': assetType,
          if (!nestInEncoding) ...{
            'architecture': 'riscv64',
            'file': fileUriSerialized,
            'id': 'package:my_package/name',
            'link_mode': {'type': 'dynamic_loading_bundle'},
            'os': 'android',
          },
          if (nestInEncoding)
            'encoding': {
              'architecture': 'riscv64',
              'file': fileUriSerialized,
              'id': 'package:my_package/name',
              'link_mode': {'type': 'dynamic_loading_bundle'},
              'os': 'android',
            },
        });
        expect(encodedAsset.isCodeAsset, isTrue);
        expect(
          CodeAsset.fromEncoded(encodedAsset),
          CodeAsset(
            package: 'my_package',
            name: 'name',
            linkMode: DynamicLoadingBundled(),
            os: OS.android,
            file: fileUri,
            architecture: Architecture.riscv64,
          ),
        );
      });
    }
  }
}
