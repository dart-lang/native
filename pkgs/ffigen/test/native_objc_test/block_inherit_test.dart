// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: unused_local_variable

// Objective C support is only available on mac.
@TestOn('mac-os')

import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
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
      BlockInheritTestBase baseObj = BlockInheritTestBase.new1();
      expect(baseObj.getAnimal().laysEggs(), false);
      expect(baseObj.acceptAnimal_(Platypus.new1()), true);

      DartReturnMammal returner = DartReturnMammal(baseObj.getReturner());
      Mammal returnerResult = returner();
      expect(returnerResult.laysEggs(), false);

      DartAcceptPlatypus accepter = DartAcceptPlatypus(baseObj.getAccepter());
      expect(accepter(Platypus.new1()), true);

      final platypus = Platypus.new1();
      DartReturnPlatypus platypusReturner =
          DartReturnPlatypus.fromFunction(() => platypus);
      expect(baseObj.invokeReturner_(platypusReturner).laysEggs(), true);

      DartAcceptMammal mammalAccepter =
          DartAcceptMammal.fromFunction((Mammal mammal) => mammal.laysEggs());
      expect(baseObj.invokeAccepter_(mammalAccepter), false);
    });

    test('BlockInheritTestChild', () {
      BlockInheritTestChild childObj = BlockInheritTestChild.new1();
      BlockInheritTestBase baseObj = childObj;
      expect(baseObj.getAnimal().laysEggs(), true);
      expect(baseObj.acceptAnimal_(Platypus.new1()), true);
      expect(childObj.acceptAnimal_(Mammal.new1()), false);

      DartReturnMammal baseReturner = DartReturnMammal(baseObj.getReturner());
      Mammal baseReturnerResult = baseReturner();
      expect(baseReturnerResult.laysEggs(), true);

      DartReturnPlatypus childReturner =
          DartReturnPlatypus(childObj.getReturner());
      Platypus childReturnerResult = childReturner();
      expect(childReturnerResult.laysEggs(), true);

      DartAcceptPlatypus baseAccepter =
          DartAcceptPlatypus(baseObj.getAccepter());
      expect(baseAccepter(Platypus.new1()), true);

      DartAcceptMammal childAccepter = DartAcceptMammal(childObj.getAccepter());
      expect(childAccepter(Mammal.new1()), false);

      final platypus = Platypus.new1();
      DartReturnPlatypus platypusReturner =
          DartReturnPlatypus.fromFunction(() => platypus);
      expect(baseObj.invokeReturner_(platypusReturner).laysEggs(), true);

      final mammal = Mammal.new1();
      DartReturnMammal mammalReturner =
          DartReturnMammal.fromFunction(() => mammal);
      expect(childObj.invokeReturner_(mammalReturner).laysEggs(), false);
      expect(childObj.invokeReturner_(platypusReturner).laysEggs(), true);

      DartAcceptMammal mammalAccepter =
          DartAcceptMammal.fromFunction((Mammal mammal) => mammal.laysEggs());
      expect(baseObj.invokeAccepter_(mammalAccepter), true);

      DartAcceptPlatypus platypusAccepter = DartAcceptPlatypus.fromFunction(
          (Platypus platypus) => platypus.laysEggs());
      expect(childObj.invokeAccepter_(platypusAccepter), true);
      expect(childObj.invokeAccepter_(mammalAccepter), true);
    });
  });
}
