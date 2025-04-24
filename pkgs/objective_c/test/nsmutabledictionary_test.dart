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
  group('NSMutableDictionary', () {
    setUpAll(() {
      // TODO(https://github.com/dart-lang/native/issues/1068): Remove this.
      DynamicLibrary.open('test/objective_c.dylib');
    });

    test('of', () {
      final obj1 = 'obj1'.toNSString();
      final obj2 = 'obj2'.toNSString();
      final obj3 = 'obj3'.toNSString();
      final obj4 = 'obj4'.toNSString();
      final obj5 = 'obj5'.toNSString();
      final obj6 = 'obj6'.toNSString();

      final dict = NSMutableDictionary.of({
        obj1: obj2,
        obj3: obj4,
        obj5: obj6,
      });

      expect(dict.length, 3);
      expect(dict[obj1], obj2);
      expect(dict[obj3], obj4);
      expect(dict[obj5], obj6);

      // Keys are copied, so compare the string values.
      final actualKeys = <String>[];
      for (final key in dict.keys) {
        actualKeys.add(NSString.castFrom(key).toDartString());
      }
      expect(actualKeys, unorderedEquals(['obj1', 'obj3', 'obj5']));

      // Values are stored by reference, so we can compare the actual objects.
      final actualValues = <ObjCObjectBase>[];
      for (final value in dict.values) {
        actualValues.add(value);
      }
      expect(actualValues, unorderedEquals([obj2, obj4, obj6]));
    });

    test('mutable', () {
      final obj1 = 'obj1'.toNSString();
      final obj2 = 'obj2'.toNSString();
      final obj3 = 'obj3'.toNSString();
      final obj4 = 'obj4'.toNSString();
      final obj5 = 'obj5'.toNSString();
      final obj6 = 'obj6'.toNSString();

      final dict = NSMutableDictionary.of({
        obj1: obj2,
        obj3: obj4,
        obj5: obj6,
      });

      dict[obj3] = obj1;
      expect(dict, {
        obj1: obj2,
        obj3: obj1,
        obj5: obj6,
      });

      expect(dict.remove(null), null);
      expect(dict.remove(123), null);
      expect(dict.remove(obj1), obj2);
      expect(dict, {
        obj3: obj1,
        obj5: obj6,
      });

      dict.clear();
      expect(dict, {});
    });

    test('MapBase mixin', () {
      final obj1 = 'obj1'.toNSString();
      final obj2 = 'obj2'.toNSString();
      final obj3 = 'obj3'.toNSString();
      final obj4 = 'obj4'.toNSString();
      final obj5 = 'obj5'.toNSString();
      final obj6 = 'obj6'.toNSString();

      final dict = NSMutableDictionary.of({
        obj1: obj2,
        obj3: obj4,
        obj5: obj6,
      });

      expect(dict.isNotEmpty, isTrue);
      expect(dict.containsKey(obj1), isTrue);
      expect(dict.containsKey(obj4), isFalse);
      expect(dict.containsValue(obj2), isTrue);
      expect(dict.containsValue(obj3), isFalse);

      expect(
          dict.map((key, value) =>
              MapEntry<ObjCObjectBase, ObjCObjectBase>(value, key)),
          {
            obj2: obj1,
            obj4: obj3,
            obj6: obj5,
          });
      expect(
          dict.keys
              .map((key) => NSString.castFrom(key).toDartString())
              .toList(),
          unorderedEquals(['obj1', 'obj3', 'obj5']));
      expect(dict.values.toList(), unorderedEquals([obj2, obj4, obj6]));
    });
  });
}
