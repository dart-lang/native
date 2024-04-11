// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')

import 'package:test/test.dart';
import '../test_utils.dart';
import 'failed_to_load_bindings.dart';
import 'util.dart';

void main() {
  group('Failed to load', () {
    setUpAll(() {
      logWarnings();
      generateBindingsForCoverage('failed_to_load');
    });

    test('Failed to load Objective-C class', () {
      // We haven't DynamicLibrary.open'd the dylib containing this class. The
      // core functions like objc_getClass are defined in the Dart executable,
      // so we can use objc_getClass, but it can't locate this class.
      expect(
          () => ClassThatWillFailToLoad.new1(),
          throwsA(predicate(
              (e) => e.toString().contains('ClassThatWillFailToLoad'))));
    });
  });
}
