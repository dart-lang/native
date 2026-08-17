// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/ffigen.dart';
import 'package:test/test.dart';

Declaration decl(String name) => Declaration(usr: '', originalName: name);

void main() {
  group('Config utils', () {
    test('Functions defaults', () {
      final funcs = const Functions();
      expect(funcs.includeTypedef(decl('foo')), isFalse);
      expect(funcs.varArgs, isEmpty);
    });
  });
}
