// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')
import 'dart:ffi';
import 'dart:io';

import 'package:ffigen/ffigen.dart';
import 'package:ffigen/src/header_parser.dart' show parse;
import 'package:path/path.dart' as path;
import 'package:test/test.dart';
import '../test_utils.dart';
import 'util.dart';

void main() {
  group('SDK variable', () {
    late final String bindings;
    setUpAll(() {
      final config = testConfigFromPath(path.join(
        packagePathForTests,
        'test',
        'native_objc_test',
        'sdk_variable_config.yaml',
      ));
      bindings = parse(testContext(config)).generate();
    });

    test('XCODE', () {
      expect(bindings, contains('extension type NSColorPicker.'));
    });

    test('IOS_SDK', () {
      expect(bindings, contains('extension type UIPickerView.'));
    });

    test('MACOS_SDK', () {
      expect(bindings, contains('extension type NSTextList.'));
    });
  });
}
