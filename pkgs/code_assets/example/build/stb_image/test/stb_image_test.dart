// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:stb_image/stb_image.dart';
import 'package:test/test.dart';

void main() {
  test('file info', () {
    const fileName = 'data/icon_dart@2x.png';
    final result = getInfo(fileName);
    expect(result.x, equals(1001));
    expect(result.y, equals(1001));
    expect(result.comp, equals(4));
  });
}
