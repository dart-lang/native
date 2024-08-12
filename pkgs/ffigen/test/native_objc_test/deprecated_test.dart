// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')

import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:test/test.dart';
import '../test_utils.dart';
import 'util.dart';

void main() {
  late final String bindings;
  group('deprecated', () {
    setUpAll(() {
      generateBindingsForCoverage('deprecated');
      bindings = File('test/native_objc_test/deprecated_bindings.dart')
          .readAsStringSync();
    });

    test('interfaces', () {
      expect(bindings, isNot(contains('DeprecatedInterface ')));
      expect(bindings, contains('DeprecatedInterfaceMethods '));
    });

    test('protocols', () {
      expect(bindings, isNot(contains('DeprecatedProtocol ')));
      expect(bindings, contains('DeprecatedProtocolMethods '));
    });

    test('interface methods', () {
      expect(bindings, contains('normalMethod'));
      expect(bindings, contains('unavailableMac'));
      expect(bindings, contains('unavailableIos'));
      expect(bindings, isNot(contains('unavailableBoth')));
      expect(bindings, contains('depMac2'));
      expect(bindings, contains('depMac3'));
      expect(bindings, contains('depIos2'));
      expect(bindings, isNot(contains('depIos2Mac2')));
      expect(bindings, contains('depIos2Mac3'));
      expect(bindings, contains('depIos3'));
      expect(bindings, contains('depIos3Mac2'));
      expect(bindings, contains('depIos3Mac3'));
      expect(bindings, isNot(contains('alwaysDeprecated')));
      expect(bindings, isNot(contains('alwaysUnavailable')));
    });

    test('interface properties', () {
      expect(bindings, contains('get normalProperty'));
      expect(bindings, contains('set normalProperty'));
      expect(bindings, isNot(contains('get deprecatedProperty')));
      expect(bindings, isNot(contains('set deprecatedProperty')));
    });

    test('protocol methods', () {
      expect(bindings, contains('protNormalMethod'));
      expect(bindings, contains('protUnavailableMac'));
      expect(bindings, contains('protUnavailableIos'));
      expect(bindings, isNot(contains('protUnavailableBoth')));
      expect(bindings, contains('protDepMac2'));
      expect(bindings, contains('protDepMac3'));
      expect(bindings, contains('protDepIos2'));
      expect(bindings, isNot(contains('protDepIos2Mac2')));
      expect(bindings, contains('protDepIos2Mac3'));
      expect(bindings, contains('protDepIos3'));
      expect(bindings, contains('protDepIos3Mac2'));
      expect(bindings, contains('protDepIos3Mac3'));
      expect(bindings, isNot(contains('protAlwaysDeprecated')));
      expect(bindings, isNot(contains('protAlwaysUnavailable')));
    });

    test('protocol properties', () {
      expect(bindings, contains('protNormalProperty'));
      expect(bindings, contains('setProtNormalProperty'));
      expect(bindings, isNot(contains('protDeprecatedProperty')));
      expect(bindings, isNot(contains('setProtDeprecatedProperty')));
    });

    test('functions', () {
      expect(bindings, contains('normalFunction'));
      expect(bindings, isNot(contains('deprecatedFunction')));
    });

    test('structs', () {
      expect(bindings, contains('NormalStruct'));
      expect(bindings, isNot(contains('DeprecatedStruct')));
    });

    test('unions', () {
      expect(bindings, contains('NormalUnion'));
      expect(bindings, isNot(contains('DeprecatedUnion')));
    });

    test('enums', () {
      expect(bindings, contains('NormalEnum'));
      expect(bindings, isNot(contains('DeprecatedEnum')));
    });

    test('unnamed enums', () {
      expect(bindings, contains('normalUnnamedEnum'));
      expect(bindings, isNot(contains('deprecatedUnnamedEnum')));
    });
  });
}
