// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')
import 'dart:ffi';
import 'dart:io';

import 'package:objective_c/objective_c.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import '../test_utils.dart';
import 'category_bindings.dart';
import 'util.dart';

void main() {
  group('categories', () {
    setUpAll(() {
      final dylib = File(
        path.join(
          packagePathForTests,
          'test',
          'native_objc_test',
          'objc_test.dylib',
        ),
      );
      verifySetupFile(dylib);
      DynamicLibrary.open(dylib.absolute.path);
      generateBindingsForCoverage('category');
    });

    test('Category methods', () {
      final thing = Thing();
      expect(thing.add(1000, Y: 234), 1234);
      expect(thing.sub(1234, Y: 1000), 234);
      expect(thing.mul(1234, Y: 1000), 1234000);
      expect(thing.someProperty, 456);
      expect(thing.anonymousCategoryMethod(), 404);
      expect(Thing.anonymousCategoryStaticMethod(), 128);
      expect(Sub.staticMethod(), 123);
    });

    test('Protocol methods', () {
      final thing = Thing();
      expect(thing.protoMethod(), 987);
      expect(CatImplementsProto.staticProtoMethod(), 654);
    });

    test('Instancetype', () {
      Thing thing1 = Thing();
      expect(Thing.isA(thing1), isTrue);
      expect(ChildOfThing.isA(thing1), isFalse);

      Thing thing2 = thing1.instancetypeMethod();
      expect(thing2, isNot(thing1));
      expect(Thing.isA(thing2), isTrue);
      expect(ChildOfThing.isA(thing2), isFalse);

      ChildOfThing child1 = ChildOfThing();
      expect(Thing.isA(child1), isTrue);
      expect(ChildOfThing.isA(child1), isTrue);

      ChildOfThing child2 = child1.instancetypeMethod();
      expect(child2, isNot(child1));
      expect(Thing.isA(child2), isTrue);
      expect(ChildOfThing.isA(child2), isTrue);
    });

    test('Category on built-in type', () {
      final str = 'Hello'.toNSString();

      expect(str.method().toDartString(), 'HelloWorld!');
      expect(
        InterfaceOnBuiltInType.staticMethod().method().toDartString(),
        'GoodbyeWorld!',
      );

      NSString str2 = str.instancetypeMethod();
      expect(str2.toDartString(), 'Hello');
    });

    test('Transitive category on built-in type', () {
      // Regression test for https://github.com/dart-lang/native/issues/1820.
      // Include transitive category of explicitly included buit-in type.
      expect(NSURL.alloc().extensionMethod(), 555);

      // Don't include transitive category of built-in type that hasn't been
      // explicitly included.
      final bindings = File(
        path.join(
          packagePathForTests,
          'test',
          'native_objc_test',
          'category_bindings.dart',
        ),
      ).readAsStringSync();
      expect(bindings, isNot(contains('excludedExtensionMethod')));

      // This method is from an NSObject extension, which shouldn't be included.
      expect(bindings, isNot(contains('autoContentAccessingProxy')));
    });
  });
}
