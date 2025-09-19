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
  group('converter', () {
    setUpAll(() {
      // TODO(https://github.com/dart-lang/native/issues/1068): Remove this.
      DynamicLibrary.open(testDylib);
    });

    test('basics', () {
      final obj = NSObject();
      expect(toObjCObject(obj), obj);

      expect(NSNull.isInstance(toObjCObject(null)), isTrue);
      expect(toNullableDartObject(NSNull.null$()), null);

      expect(toObjCObject(123), isA<NSNumber>());
      expect((toObjCObject(123) as NSNumber).longLongValue, 123);
      expect(toDartObject(toObjCObject(123)), isA<int>());
      expect(toDartObject(toObjCObject(123)), 123);

      expect(toObjCObject(1.23), isA<NSNumber>());
      expect((toObjCObject(1.23) as NSNumber).doubleValue, 1.23);
      expect(toDartObject(toObjCObject(1.23)), isA<double>());
      expect(toDartObject(toObjCObject(1.23)), 1.23);

      expect(toObjCObject('hello'), isA<NSString>());
      expect((toObjCObject('hello') as NSString).toDartString(), 'hello');

      expect(toObjCObject(DateTime(2025)), isA<NSDate>());
      expect(
        (toObjCObject(DateTime(2025)) as NSDate).toDateTime(),
        DateTime(2025),
      );
    });

    test('list', () {
      final obj = NSObject();
      final dartList = [123, 'abc', obj];

      expect(toObjCObject(dartList), isA<NSArray>());
      final objCList = toObjCObject(dartList) as NSArray;
      expect(objCList.length, 3);

      expect(toDartObject(objCList[0]), 123);
      expect(toDartObject(objCList[1]), 'abc');
      expect(toDartObject(objCList[2]), obj);

      expect(toDartObject(objCList), dartList);

      final nestedDartList = [
        1,
        [2, 3],
        [
          4,
          [5],
        ],
      ];
      final nestedObjCList = toObjCObject(nestedDartList) as NSArray;
      expect(toDartObject(nestedObjCList), nestedDartList);
    });

    test('set', () {
      final obj = NSObject();
      final dartSet = {123, 'abc', obj};

      expect(toObjCObject(dartSet), isA<NSSet>());
      final objCSet = toObjCObject(dartSet) as NSSet;
      expect(objCSet.length, 3);

      expect(objCSet.contains(toObjCObject(123)), isTrue);
      expect(objCSet.contains(toObjCObject('abc')), isTrue);
      expect(objCSet.contains(toObjCObject(obj)), isTrue);

      expect(toDartObject(objCSet), dartSet);

      final nestedDartSet = {
        1,
        {2, 3},
        {
          4,
          {5},
        },
      };
      final nestedObjCSet = toObjCObject(nestedDartSet) as NSSet;
      expect(toDartObject(nestedObjCSet), nestedDartSet);
    });

    test('map', () {
      final obj = NSObject();
      final dartMap = {123: 'abc', 'def': 456, 789: obj};

      expect(toObjCObject(dartMap), isA<NSDictionary>());
      final objCMap = toObjCObject(dartMap) as NSDictionary;
      expect(objCMap.length, 3);

      expect(toDartObject(objCMap[toObjCObject(123)]!), 'abc');
      expect(toDartObject(objCMap[toObjCObject('def')]!), 456);
      expect(toDartObject(objCMap[toObjCObject(789)]!), obj);

      expect(toDartObject(objCMap), dartMap);

      final nestedDartMap = {
        1: {2: 3},
        4: {
          5: {6: 7},
        },
      };
      final nestedObjCMap = toObjCObject(nestedDartMap) as NSDictionary;
      expect(toDartObject(nestedObjCMap), nestedDartMap);
    });

    test('unsupported type', () {
      expect(
        () => toObjCObject(Future<void>.value()),
        throwsA(isA<UnimplementedError>()),
      );

      final obj = NSObject();
      expect(toObjCObject(obj), obj);
      expect(toDartObject(obj), obj);
    });

    test('custom converter in toObjCObject', () {
      final future = Future<void>.value();
      final obj = NSObject();

      ObjCObjectBase conv(Object _) => obj;

      expect(toObjCObject(future, convertOther: conv), obj);

      final list = toObjCObject([123, future], convertOther: conv);
      expect(toDartObject(list), [123, obj]);
    });

    test('custom converter in toDartObject', () {
      final future = Future<void>.value();
      final obj = NSObject();

      Object conv(ObjCObjectBase _) => future;

      expect(toDartObject(obj, convertOther: conv), future);

      final list = toObjCObject(['abc', obj]);
      expect(toDartObject(list, convertOther: conv), ['abc', future]);
    });
  });
}
