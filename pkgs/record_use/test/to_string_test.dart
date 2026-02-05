// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:record_use/src/reference.dart';
import 'package:test/test.dart';

void main() {
  group('toString', () {
    test('CallWithArguments', () {
      const call = CallWithArguments(
        positionalArguments: [],
        namedArguments: {},
        loadingUnit: 'dart.foo',
      );
      expect(
        call.toString(),
        'CallWithArguments(loadingUnit: dart.foo)',
      );
    });

    test('CallWithArguments with multiple args', () {
      const call = CallWithArguments(
        positionalArguments: [null, null],
        namedArguments: {'bar': null, 'baz': null},
        loadingUnit: 'dart.foo',
      );
      expect(
        call.toString(),
        'CallWithArguments(positional: null, null, named: bar=null, baz=null, '
        'loadingUnit: dart.foo)',
      );
    });
  });
}
