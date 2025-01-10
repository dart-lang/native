// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')
library;

import 'dart:io';

import 'package:test/test.dart';

import '../tool/generate_code.dart' as generate_code;

void main() {
  group('generate_code.dart', () {
    test('Runs without exception', () async {
      // As well as testing that this returns normally, this also generates
      // coverage info for the parts of ffigen that are gated by
      // generate-for-package-objective-c. The github workflow that runs this
      // test also uses it to verify that there are no git-diffs in the output.
      await expectLater(generate_code.run(), completes);

      // Sanity check the generated code.
      final cBindings =
          File('lib/src/c_bindings_generated.dart').readAsStringSync();
      expect(cBindings, contains('sel_registerName'));
      expect(cBindings, contains('objc_msgSend'));
      expect(cBindings, contains('_ObjCBlock'));

      final objcBindings = File('lib/src/objective_c_bindings_generated.dart')
          .readAsStringSync();
      expect(objcBindings, contains('class NSObject'));
      expect(objcBindings, contains('class NSString'));
      expect(objcBindings, contains('factory NSString(String str)'));
    });
  });
}
