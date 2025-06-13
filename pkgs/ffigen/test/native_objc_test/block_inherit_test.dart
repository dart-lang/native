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
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import '../test_utils.dart';
import 'block_inherit_bindings.dart';
import 'util.dart';

void main() {
  group('Block inheritance', () {
    setUpAll(() {
      // TODO(https://github.com/dart-lang/native/issues/1068): Remove this.
      DynamicLibrary.open(
        path.join(
          packagePathForTests,
          '..',
          'objective_c',
          'test',
          'objective_c.dylib',
        ),
      );
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

      generateBindingsForCoverage('block_inherit');
    });

    test('BlockInheritTestBase', () {
      final BlockInheritTestBase baseObj = BlockInheritTestBase();
      expect(baseObj.getAnimal().laysEggs(), false);
      expect(baseObj.acceptAnimal(Platypus()), true);

      final ObjCBlock<Mammal Function()> returner = baseObj.getReturner();
      final Mammal returnerResult = returner();
      expect(returnerResult.laysEggs(), false);

      final ObjCBlock<Bool Function(Platypus)> accepter = baseObj.getAccepter();
      expect(accepter(Platypus()), true);

      final platypus = Platypus();
      final ObjCBlock<Platypus Function()> platypusReturner =
          ObjCBlock_Platypus.fromFunction(() => platypus);
      expect(baseObj.invokeReturner(platypusReturner).laysEggs(), true);

      final ObjCBlock<Bool Function(Mammal)> mammalAccepter =
          ObjCBlock_bool_Mammal.fromFunction(
            (Mammal mammal) => mammal.laysEggs(),
          );
      expect(baseObj.invokeAccepter(mammalAccepter), false);
    });

    test('BlockInheritTestChild', () {
      final BlockInheritTestChild childObj = BlockInheritTestChild();
      final BlockInheritTestBase baseObj = childObj;
      expect(baseObj.getAnimal().laysEggs(), true);
      expect(baseObj.acceptAnimal(Platypus()), true);
      expect(childObj.acceptAnimal(Mammal()), false);

      final ObjCBlock<Mammal Function()> baseReturner = baseObj.getReturner();
      final Mammal baseReturnerResult = baseReturner();
      expect(baseReturnerResult.laysEggs(), true);

      final ObjCBlock<Platypus Function()> childReturner = childObj
          .getReturner();
      final Platypus childReturnerResult = childReturner();
      expect(childReturnerResult.laysEggs(), true);

      final ObjCBlock<Bool Function(Platypus)> baseAccepter = baseObj
          .getAccepter();
      expect(baseAccepter(Platypus()), true);

      final ObjCBlock<Bool Function(Mammal)> childAccepter = childObj
          .getAccepter();
      expect(childAccepter(Mammal()), false);
      expect(childAccepter(Platypus()), true);

      final platypus = Platypus();
      final ObjCBlock<Platypus Function()> platypusReturner =
          ObjCBlock_Platypus.fromFunction(() => platypus);
      expect(baseObj.invokeReturner(platypusReturner).laysEggs(), true);

      final mammal = Mammal();
      final ObjCBlock<Mammal Function()> mammalReturner =
          ObjCBlock_Mammal.fromFunction(() => mammal);
      expect(childObj.invokeReturner(mammalReturner).laysEggs(), false);
      expect(childObj.invokeReturner(platypusReturner).laysEggs(), true);

      final ObjCBlock<Bool Function(Mammal)> mammalAccepter =
          ObjCBlock_bool_Mammal.fromFunction(
            (Mammal mammal) => mammal.laysEggs(),
          );
      expect(baseObj.invokeAccepter(mammalAccepter), true);

      final ObjCBlock<Bool Function(Platypus)> platypusAccepter =
          ObjCBlock_bool_Platypus.fromFunction(
            (Platypus platypus) => platypus.laysEggs(),
          );
      expect(childObj.invokeAccepter(platypusAccepter), true);
      expect(childObj.invokeAccepter(mammalAccepter), true);
    });
  });
}
