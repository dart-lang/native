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

      WrapperReturnMammal returner = WrapperReturnMammal(baseObj.getReturner());
      Mammal returnerResult = returner();
      expect(returnerResult.laysEggs(), false);

      WrapperAcceptPlatypus accepter =
          WrapperAcceptPlatypus(baseObj.getAccepter());
      expect(accepter(Platypus.new1()), true);

      final platypus = Platypus.new1();
      WrapperReturnPlatypus platypusReturner =
          WrapperReturnPlatypus.fromFunction(() => platypus);
      expect(baseObj.invokeReturner_(platypusReturner).laysEggs(), true);

      WrapperAcceptMammal mammalAccepter = WrapperAcceptMammal.fromFunction(
          (Mammal mammal) => mammal.laysEggs());
      expect(baseObj.invokeAccepter_(mammalAccepter), false);
    });

    test('BlockInheritTestChild', () {
      BlockInheritTestChild childObj = BlockInheritTestChild.new1();
      BlockInheritTestBase baseObj = childObj;
      expect(baseObj.getAnimal().laysEggs(), true);
      expect(baseObj.acceptAnimal_(Platypus.new1()), true);
      expect(childObj.acceptAnimal_(Mammal.new1()), false);

      WrapperReturnMammal baseReturner =
          WrapperReturnMammal(baseObj.getReturner());
      Mammal baseReturnerResult = baseReturner();
      expect(baseReturnerResult.laysEggs(), true);

      WrapperReturnPlatypus childReturner =
          WrapperReturnPlatypus(childObj.getReturner());
      Platypus childReturnerResult = childReturner();
      expect(childReturnerResult.laysEggs(), true);

      WrapperAcceptPlatypus baseAccepter =
          WrapperAcceptPlatypus(baseObj.getAccepter());
      expect(baseAccepter(Platypus.new1()), true);

      WrapperAcceptMammal childAccepter =
          WrapperAcceptMammal(childObj.getAccepter());
      expect(childAccepter(Mammal.new1()), false);

      final platypus = Platypus.new1();
      WrapperReturnPlatypus platypusReturner =
          WrapperReturnPlatypus.fromFunction(() => platypus);
      expect(baseObj.invokeReturner_(platypusReturner).laysEggs(), true);

      final mammal = Mammal.new1();
      WrapperReturnMammal mammalReturner =
          WrapperReturnMammal.fromFunction(() => mammal);
      expect(childObj.invokeReturner_(mammalReturner).laysEggs(), false);
      expect(childObj.invokeReturner_(platypusReturner).laysEggs(), true);

      WrapperAcceptMammal mammalAccepter = WrapperAcceptMammal.fromFunction(
          (Mammal mammal) => mammal.laysEggs());
      expect(baseObj.invokeAccepter_(mammalAccepter), true);

      WrapperAcceptPlatypus platypusAccepter =
          WrapperAcceptPlatypus.fromFunction(
              (Platypus platypus) => platypus.laysEggs());
      expect(childObj.invokeAccepter_(platypusAccepter), true);
      expect(childObj.invokeAccepter_(mammalAccepter), true);
    });
  });
}
