// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')
library;

import 'dart:ffi';

import 'package:objective_c/objective_c.dart';
import 'package:test/test.dart';

void main() {
  group('Selector', () {
    setUpAll(() {
      // TODO(https://github.com/dart-lang/native/issues/1068): Remove this.
      DynamicLibrary.open('test/objective_c.dylib');
    });

    test('from String and back', () {
      expect('hello'.toSelector().toDartString(), 'hello');
      expect(''.toSelector().toDartString(), '');
      expect('foo:with:args:'.toSelector().toDartString(), 'foo:with:args:');
    });

    test('responds to selector', () {
      final sel1 = 'addObserver:forKeyPath:options:context:'.toSelector();
      expect(NSObject.new1().respondsToSelector_(sel1), isTrue);
      expect(NSObject.new1().respondsToSelector_('foo'.toSelector()), isFalse);

      final sel2 = 'canBeConvertedToEncoding:'.toSelector();
      expect(NSString.new1().respondsToSelector_(sel2), isTrue);
      expect(NSString.new1().respondsToSelector_('bar'.toSelector()), isFalse);
    });
  });
}
