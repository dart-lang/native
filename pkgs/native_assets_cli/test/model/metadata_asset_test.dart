// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:native_assets_cli/src/encoded_asset.dart';
import 'package:native_assets_cli/src/metadata.dart';
import 'package:test/test.dart';

void main() async {
  final jsonEncoding = {
    'encoding': {
      'key': 'some_key',
      'value': {'foo': 'bar'},
    },
    'type': 'hooks/metadata',
  };
  final metadataAsset = MetadataAsset(key: 'some_key', value: {'foo': 'bar'});

  test('CodeAsset toJson', () {
    expect(metadataAsset.encode().toJson(), equals(jsonEncoding));
  });

  test('CodeAsset fromJson', () {
    final encodedAsset = EncodedAsset.fromJson(jsonEncoding);
    expect(encodedAsset.isMetadataAsset, isTrue);
    expect(MetadataAsset.fromEncoded(encodedAsset), metadataAsset);
  });
}
