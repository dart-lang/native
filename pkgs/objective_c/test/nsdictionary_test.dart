// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')
library;

import 'dart:ffi';

import 'package:objective_c/objective_c.dart';
import 'package:test/test.dart';

import 'package:objective_c_helper/src/util.dart';

void main() {
  group('NSDictionary', () {
    test('of', () {
      final obj1 = 'obj1'.toNSString();
      final obj2 = 'obj2'.toNSString();
      final obj3 = 'obj3'.toNSString();
      final obj4 = 'obj4'.toNSString();
      final obj5 = 'obj5'.toNSString();
      final obj6 = 'obj6'.toNSString();

      final dict = NSDictionary.of({
        obj1: obj2,
        obj3: obj4,
        obj5: obj6,
      }).asDart();

      expect(dict.length, 3);
      expect(dict[obj1], obj2);
      expect(dict[obj3], obj4);
      expect(dict[obj5], obj6);

      // Keys are copied, so compare the string values.
      final actualKeys = <String>[];
      for (final key in dict.keys) {
        actualKeys.add(NSString.as(key).toDartString());
      }
      expect(actualKeys, unorderedEquals(['obj1', 'obj3', 'obj5']));

      // Values are stored by reference, so we can compare the actual objects.
      final actualValues = <ObjCObject>[];
      for (final value in dict.values) {
        actualValues.add(value);
      }
      expect(actualValues, unorderedEquals([obj2, obj4, obj6]));
    });

    test('immutable', () {
      final obj1 = 'obj1'.toNSString();
      final obj2 = 'obj2'.toNSString();
      final obj3 = 'obj3'.toNSString();
      final obj4 = 'obj4'.toNSString();
      final obj5 = 'obj5'.toNSString();
      final obj6 = 'obj6'.toNSString();

      // NSDictionary.of actually returns a NSMutableDictionary, so our
      // immutability tests wouldn't actually work. So convert it to a real
      // NSDictionary using an ObjC constructor.
      final dict = NSDictionary.dictionaryWithDictionary(
        NSDictionary.of({obj1: obj2, obj3: obj4, obj5: obj6}),
      ).asDart();

      expect(() => dict[obj3] = obj1, throwsUnsupportedError);
      expect(dict.clear, throwsUnsupportedError);
      expect(() => dict.remove(obj1), throwsUnsupportedError);
    });

    test('MapBase mixin', () {
      final obj1 = 'obj1'.toNSString();
      final obj2 = 'obj2'.toNSString();
      final obj3 = 'obj3'.toNSString();
      final obj4 = 'obj4'.toNSString();
      final obj5 = 'obj5'.toNSString();
      final obj6 = 'obj6'.toNSString();

      final dict = NSDictionary.of({
        obj1: obj2,
        obj3: obj4,
        obj5: obj6,
      }).asDart();

      expect(dict.isNotEmpty, isTrue);
      expect(dict.containsKey(obj1), isTrue);
      expect(dict.containsKey(obj4), isFalse);
      expect(dict.containsValue(obj2), isTrue);
      expect(dict.containsValue(obj3), isFalse);

      expect(
        dict.map((key, value) => MapEntry<ObjCObject, ObjCObject>(value, key)),
        {obj2: obj1, obj4: obj3, obj6: obj5},
      );
      expect(
        dict.keys.map((key) => NSString.as(key).toDartString()).toList(),
        unorderedEquals(['obj1', 'obj3', 'obj5']),
      );
      expect(dict.values.toList(), unorderedEquals([obj2, obj4, obj6]));
    });

    test('ref counting', () async {
      final pointers = <Pointer<ObjCObjectImpl>>[];
      Map<NSCopying, ObjCObject>? map;

      autoReleasePool(() {
        // The dictionary key has to implement NSCopying. NSString is used in
        // the other tests because it's easy to construct. But it isn't ref
        // counted in the same way as other objects, so here we use NSArray.
        final obj1 = NSArray.of(['apple'.toNSString()]);
        final obj2 = NSObject();
        final obj3 = NSArray.of(['banana'.toNSString()]);
        final obj4 = NSObject();
        final obj5 = NSArray.of(['carrot'.toNSString()]);
        final obj6 = NSObject();
        final objects = {obj1: obj2, obj3: obj4, obj5: obj6};
        final objCMap = NSDictionary.of(objects);
        map = objCMap.asDart();

        pointers.addAll(map!.keys.map((o) => o.ref.pointer));
        pointers.addAll(map!.values.map((o) => o.ref.pointer));
        pointers.add(objCMap.ref.pointer);

        for (final pointer in pointers) {
          expect(objectRetainCount(pointer), greaterThan(0));
        }
      });

      doGC();
      await Future<void>.delayed(Duration.zero);
      doGC();
      for (final pointer in pointers) {
        expect(objectRetainCount(pointer), greaterThan(0));
      }
      map = null;

      doGC();
      await Future<void>.delayed(Duration.zero);
      doGC();
      for (final pointer in pointers) {
        expect(objectRetainCount(pointer), 0);
      }
    });
  });
}
