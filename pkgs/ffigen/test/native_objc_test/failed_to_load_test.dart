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
      generateBindingsForCoverage('failed_to_load');
    });

    test('Failed to load Objective-C class', () {
      // This class has a declaration but no implementation, so it fails to
      // load. The native objc_getClass returns null, which the wrapper in
      // package:objective_c turns into an exception.
      expect(
          () => ClassThatWillFailToLoad.new1(),
          throwsA(predicate(
              (e) => e.toString().contains('ClassThatWillFailToLoad'))));
    });
  });
}
