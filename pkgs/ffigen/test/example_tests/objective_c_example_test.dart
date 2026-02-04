// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')
library;

import 'package:ffigen/src/header_parser.dart';
import 'package:test/test.dart';

import '../../example/objective_c/generate_code.dart' show config;
import '../test_utils.dart';

void main() {
  group('objective_c_example_test', () {
    test('objective_c', () {
      final output = parse(testContext(config)).generate();

      // Verify that the output contains all the methods and classes that the
      // example app uses.
      expect(
        output,
        contains('extension type AVAudioPlayer._(objc.ObjCObject '),
      );
      expect(
        output,
        contains('AVAudioPlayer? initWithContentsOfURL(objc.NSURL url) {'),
      );
      expect(output, contains('double get duration {'));
      expect(output, contains('bool play() {'));
    });
  });
}
