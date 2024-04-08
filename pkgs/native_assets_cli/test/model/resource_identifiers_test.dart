// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:native_assets_cli/src/model/resource_identifiers.dart';
import 'package:test/test.dart';

import '../api/resource_data.dart';

void main() {
  test('empty resources parsing', () {
    final resourceIdentifiers =
        ResourceIdentifiers.fromFileContents(resourceFile);
    expect(resourceIdentifiers.identifiers, isEmpty);
  });
  test('Serialize to JSON', () {
    const jsonEncoder = JsonEncoder.withIndent('  ');
    expect(
      jsonEncoder.convert(resourceIdentifiers),
      jsonEncoder.convert(resourceIdentifiersJson),
    );
  });
  test('Deserialize from JSON', () {
    expect(
      ResourceIdentifiers.fromJson(resourceIdentifiersJson),
      resourceIdentifiers,
    );
  });
}
