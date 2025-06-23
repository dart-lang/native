// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')
library;

import 'dart:ffi';

import 'package:objective_c/objective_c.dart';
import 'package:test/test.dart';

import 'util.dart';

void main() {
  group('CFString', () {
    setUpAll(() {
      // TODO(https://github.com/dart-lang/native/issues/1068): Remove this.
      DynamicLibrary.open(testDylib);
    });

    for (final s in ['Hello', '🇵🇬', 'Embedded\u0000Null']) {
      test('CFString conversions [$s]', () {
        final cfString = s
            .toNSString()
            .ref
            .retainAndAutorelease()
            .cast<CFString>();
        expect(cfString.toDartString(), s);
        expect(cfString.toNSString().toDartString(), s);
      });
    }
  });
}
