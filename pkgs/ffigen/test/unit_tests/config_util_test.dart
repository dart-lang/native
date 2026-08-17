// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/ffigen.dart';
import 'package:test/test.dart';

Declaration decl(String name) => Declaration(usr: '', originalName: name);

void main() {
  group('Declarations utils', () {
    test('default includeSymbolAddress', () {
      final decls = const Declarations();
      expect(decls.includeSymbolAddress(decl('foo')), isFalse);
    });
  });
}
