// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// We're testing inheritance rules, so explicit types are handy for clarity.
// ignore_for_file: omit_local_variable_types

// Objective C support is only available on mac.
@TestOn('mac-os')

import 'dart:ffi';
import 'dart:io';

import 'package:objective_c/objective_c.dart';
import 'package:test/test.dart';

import '../test_utils.dart';
import 'block_inherit_bindings.dart';
import 'util.dart';

void main() {
  group('Block inheritance', () {
    setUpAll(() {
      // TODO(https://github.com/dart-lang/native/issues/1068): Remove this.
      DynamicLibrary.open('../objective_c/test/objective_c.dylib');
      final dylib = File('test/native_objc_test/block_inherit_test.dylib');
      verifySetupFile(dylib);
      DynamicLibrary.open(dylib.absolute.path);

      generateBindingsForCoverage('block_inherit');
    });

    test('BlockInheritTestBase', () {
      final BlockInheritTestBase baseObj = BlockInheritTestBase.new1();
      expect(baseObj.getAnimal().laysEggs(), false);
      expect(baseObj.acceptAnimal_(Platypus.new1()), true);

      final ObjCBlock<Mammal Function()> returner = baseObj.getReturner();
      final Mammal returnerResult = returner();
      expect(returnerResult.laysEggs(), false);

      final ObjCBlock<Bool Function(Platypus)> accepter = baseObj.getAccepter();
      expect(accepter(Platypus.new1()), true);

      final platypus = Platypus.new1();
      final ObjCBlock<Platypus Function()> platypusReturner =
          ObjCBlock_Platypus.fromFunction(() => platypus);
      expect(baseObj.invokeReturner_(platypusReturner).laysEggs(), true);

      final ObjCBlock<Bool Function(Mammal)> mammalAccepter =
          ObjCBlock_bool_Mammal.fromFunction(
              (Mammal mammal) => mammal.laysEggs());
      expect(baseObj.invokeAccepter_(mammalAccepter), false);
    });

    test('BlockInheritTestChild', () {
      final BlockInheritTestChild childObj = BlockInheritTestChild.new1();
      final BlockInheritTestBase baseObj = childObj;
      expect(baseObj.getAnimal().laysEggs(), true);
      expect(baseObj.acceptAnimal_(Platypus.new1()), true);
      expect(childObj.acceptAnimal_(Mammal.new1()), false);

      final ObjCBlock<Mammal Function()> baseReturner = baseObj.getReturner();
      final Mammal baseReturnerResult = baseReturner();
      expect(baseReturnerResult.laysEggs(), true);

      final ObjCBlock<Platypus Function()> childReturner =
          childObj.getReturner();
      final Platypus childReturnerResult = childReturner();
      expect(childReturnerResult.laysEggs(), true);

      final ObjCBlock<Bool Function(Platypus)> baseAccepter =
          baseObj.getAccepter();
      expect(baseAccepter(Platypus.new1()), true);

      final ObjCBlock<Bool Function(Mammal)> childAccepter =
          childObj.getAccepter();
      expect(childAccepter(Mammal.new1()), false);
      expect(childAccepter(Platypus.new1()), true);

      final platypus = Platypus.new1();
      final ObjCBlock<Platypus Function()> platypusReturner =
          ObjCBlock_Platypus.fromFunction(() => platypus);
      expect(baseObj.invokeReturner_(platypusReturner).laysEggs(), true);

      final mammal = Mammal.new1();
      final ObjCBlock<Mammal Function()> mammalReturner =
          ObjCBlock_Mammal.fromFunction(() => mammal);
      expect(childObj.invokeReturner_(mammalReturner).laysEggs(), false);
      expect(childObj.invokeReturner_(platypusReturner).laysEggs(), true);

      final ObjCBlock<Bool Function(Mammal)> mammalAccepter =
          ObjCBlock_bool_Mammal.fromFunction(
              (Mammal mammal) => mammal.laysEggs());
      expect(baseObj.invokeAccepter_(mammalAccepter), true);

      final ObjCBlock<Bool Function(Platypus)> platypusAccepter =
          ObjCBlock_bool_Platypus.fromFunction(
              (Platypus platypus) => platypus.laysEggs());
      expect(childObj.invokeAccepter_(platypusAccepter), true);
      expect(childObj.invokeAccepter_(mammalAccepter), true);
    });
  });
}
