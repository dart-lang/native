// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')
library;

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../tool/ffigen.dart' as ffigen_tool;
import 'util.dart';

void main() {
  group('ffigen.dart', () {
    test('Runs without exception', () async {
      // As well as testing that this returns normally, this also generates
      // coverage info for the parts of FFIgen that are gated by
      // generate-for-package-objective-c.
      final changedFiles = await ffigen_tool.run(
        format: true,
        packageRoot: Directory(pkgDir).uri,
        runTests: false,
        restoreIfChanged: true,
      );
      expect(
        changedFiles,
        isEmpty,
        reason:
            'Generated files are out of date. '
            'Run `dart pkgs/objective_c/tool/ffigen.dart` to regenerate.',
      );

      // Sanity check the generated code.
      final rBindings = File(
        p.join(pkgDir, 'lib', 'src', 'runtime_bindings_generated.dart'),
      ).readAsStringSync();
      expect(rBindings, contains('sel_registerName'));
      expect(rBindings, contains('objc_msgSend'));
      expect(rBindings, contains('_NSConcreteGlobalBlock'));
      expect(rBindings, contains('ObjCObject'));

      final cBindings = File(
        p.join(pkgDir, 'lib', 'src', 'c_bindings_generated.dart'),
      ).readAsStringSync();
      expect(cBindings, contains('createContext'));
      expect(cBindings, contains('DOBJC_Context'));
      expect(cBindings, contains('Dart_FinalizableHandle'));
      expect(cBindings, contains('ILLEGAL_PORT'));
      expect(cBindings, contains('ObjCBlockImpl'));

      final objcBindings = File(
        p.join(pkgDir, 'lib', 'src', 'objective_c_bindings_generated.dart'),
      ).readAsStringSync();
      expect(objcBindings, contains('class NSObject'));
      expect(objcBindings, contains('class NSString'));
      expect(objcBindings, contains('NSString(String str)'));
    });
  });
}
