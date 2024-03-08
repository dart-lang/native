// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:native_assets_cli/native_assets_cli.dart';
import 'package:test/test.dart';

void main() {
  const resourceFile = '''{
  "_comment": "Resources referenced by annotated resource identifiers",
  "AppTag": "TBD",
  "environment": {
    "dart.tool.dart2js": false
  },
  "identifiers": []
}''';
  test('empty resources parsing', () {
    final resourceIdentifiers =
        ResourceIdentifiers.fromFileContents(resourceFile);
    expect(resourceIdentifiers.identifiers, isEmpty);
  });
}
