// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:path/path.dart' as p;
import 'package:test_helpers/test_helpers.dart';
import 'package:test/test.dart';

final _whitespace = RegExp(r'\s+');

void expectString(String a, String b) {
  final trimmedA = a.replaceAll(_whitespace, '');
  final trimmedB = b.replaceAll(_whitespace, '');

  expect(trimmedA, trimmedB);
}

String testDir = p.normalize(
  p.join(
    findPackageRoot('swift2objc').toFilePath(),
    'test',
  ),
);
