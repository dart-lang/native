// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:native_assets_cli/native_assets_cli.dart';
import 'package:native_assets_cli/src/api/link_config.dart';
import 'package:test/test.dart';

import 'resource_data.dart';

void main() {
  test('Parse resource identifiers', () {
    expect(
      fromIdentifiers(resourceIdentifiers),
      [
        Resource(name: 'methodName1', metadata: 'someMetadata'),
        Resource(name: 'methodName2', metadata: 'someOtherMetadata'),
      ],
    );
  });
}
