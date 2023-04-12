// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:jnigen/src/bindings/dart_generator.dart';
import 'package:test/test.dart';

void main() {
  test('OutsideInBuffer', () {
    final buffer = OutsideInBuffer();
    buffer.appendLeft('f(');
    buffer.prependRight('x)');
    buffer.appendLeft('g(');
    buffer.prependRight('y) + ');
    expect(buffer.toString(), 'f(g(y) + x)');
  });
}
