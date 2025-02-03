// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')

import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:objective_c/objective_c.dart';
import 'package:test/test.dart';
import '../test_utils.dart';
import 'bad_override_bindings.dart';
import 'util.dart';

void main() {
  group('bad overrides', () {
    setUpAll(() {
      // TODO(https://github.com/dart-lang/native/issues/1068): Remove this.
      DynamicLibrary.open('../objective_c/test/objective_c.dylib');
      final dylib = File('test/native_objc_test/objc_test.dylib');
      verifySetupFile(dylib);
      DynamicLibrary.open(dylib.absolute.path);
      generateBindingsForCoverage('bad_override');
    });

    test('Method vs getter', () {
      // In ObjC, supertypes and subtypes can have a method that's an ordinary
      // method in some classes of the heirarchy, and a property in others. This
      // isn't allowed in Dart, so we change all such conflicts to properties.
      // https://github.com/dart-lang/native/issues/1220
      expect(BadOverrideParent.new1().methodVsGetter, 1);
      expect(BadOverrideChild.new1().methodVsGetter, 11);
      expect(BadOverrideSibbling.new1().methodVsGetter, 12);
      expect(BadOverrideGrandchild.new1().methodVsGetter, 111);

      var inst = BadOverrideParent.new1();
      expect(inst.methodVsGetter, 1);
      inst = BadOverrideChild.new1();
      expect(inst.methodVsGetter, 11);
      inst = BadOverrideSibbling.new1();
      expect(inst.methodVsGetter, 12);
      inst = BadOverrideGrandchild.new1();
      expect(inst.methodVsGetter, 111);

      // Uncle isn't affected by the transform, so has an ordinary method.
      expect(BadOverrideUncle.new1().methodVsGetter(), 2);
    });

    test('Contravariant returns', () {
      // Return types are supposed to be covariant, but ObjC allows them to be
      // contravariant.
      // https://github.com/dart-lang/native/issues/1220
      Polygon parentResult = BadOverrideParent.new1().contravariantReturn();
      expect(parentResult.name().toDartString(), 'Rectangle');

      Polygon childResult = BadOverrideChild.new1().contravariantReturn();
      expect(childResult.name().toDartString(), 'Triangle');
    });

    test('Covariant args', () {
      // Arg types are supposed to be contravariant, but ObjC allows them to be
      // covariant.
      // https://github.com/dart-lang/native/issues/1220
      final square = Square.new1();
      final triangle = Triangle.new1();

      var parent = BadOverrideParent.new1();
      expect(parent.covariantArg_(square).toDartString(), 'Polygon: Square');
      expect(
          parent.covariantArg_(triangle).toDartString(), 'Polygon: Triangle');

      parent = BadOverrideChild.new1();
      expect(parent.covariantArg_(square).toDartString(), 'Rectangle: Square');
      expect(() => parent.covariantArg_(triangle), throwsA(isA<TypeError>()));
    });
  });
}
