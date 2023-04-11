// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:native_assets_cli/native_assets_cli.dart';
import 'package:test/test.dart';

void main() {
  final metadata = Metadata({
    'key': 'value',
    'my_list': [1, 2, 3],
    'my_map': {
      3: 4,
      'foo': 'bar',
    },
  });

  test('Metadata toString', metadata.toString);

  test('Metadata toYamlString fromYamlString', () {
    final yamlString = metadata.toYamlString();
    final metadata2 = Metadata.fromYamlString(yamlString);
    expect(metadata2, metadata);
  });
}
