// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')

import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:ffigen/ffigen.dart';
import 'package:ffigen/src/config_provider/config.dart';
import 'package:ffigen/src/config_provider/config_types.dart';
import 'package:logging/logging.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:test/test.dart';
import '../test_utils.dart';
import 'util.dart';

void main() {
  group('method filtering', () {
    late final String bindings;
    group('no version info', () {
      late final String bindings;
      setUpAll(() {
        // TODO(https://github.com/dart-lang/native/issues/1068): Remove this.
        generateBindingsForCoverage('method_filtering');
        bindings = File('test/native_objc_test/objc_test.dart')
            .readAsStringSync();
      });

      test('interfaces', () {
        expect(bindings, contains('MethodFilteringTestInterface'));
        expect(bindings, contains('includedStaticMethod'));
        expect(bindings, contains('includedInstanceMethod'));
        expect(bindings, contains('includedProperty'));
        expect(bindings, isNot(contains('excludedStaticMethod')));
        expect(bindings, isNot(contains('excludedInstanceMethod')));
        expect(bindings, isNot(contains('excludedProperty')));
      });

      test('protocols', () {
        expect(bindings, contains('MethodFilteringTestProtocol'));
        expect(bindings, contains('includedProtocolMethod'));
        expect(bindings, isNot(contains('excludedProtocolMethod')));
      });
    });
  });
}
