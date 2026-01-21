// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:record_use/src/location.dart';
import 'package:record_use/src/reference.dart';
import 'package:test/test.dart';

void main() {
  group('toString', () {
    test('Location', () {
      const location = Location(uri: 'package:foo/foo.dart');
      expect(location.toString(), 'Location(uri: package:foo/foo.dart)');
    });

    test('CallWithArguments', () {
      const call = CallWithArguments(
        positionalArguments: [],
        namedArguments: {},
        loadingUnit: 'dart.foo',
        location: Location(uri: 'package:foo/foo.dart'),
      );
      expect(
        call.toString(),
        'CallWithArguments(location: Location(uri: package:foo/foo.dart), loadingUnit: dart.foo)',
      );
    });

    test('CallWithArguments with args', () {
      const call = CallWithArguments(
        positionalArguments: [null],
        namedArguments: {'bar': null},
        loadingUnit: 'dart.foo',
        location: Location(uri: 'package:foo/foo.dart'),
      );
      expect(
        call.toString(),
        'CallWithArguments(positional: null, named: bar=null, location: Location(uri: package:foo/foo.dart), loadingUnit: dart.foo)',
      );
    });
  });
}
