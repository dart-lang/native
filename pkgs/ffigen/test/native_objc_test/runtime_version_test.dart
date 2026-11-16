// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')
import 'dart:ffi';
import 'dart:io';

import 'package:objective_c/objective_c.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import '../test_utils.dart';
import 'runtime_version_test_bindings.dart';
import 'util.dart';

void main() {
  group('runtime version check', () {
    test('Interface', () {
      expect(() => FutureAPIInterface(), throwsA(isA<OsVersionError>()));
    });

    test('Interface methods', () {
      final api = FutureAPIMethods();
      if (Platform.isMacOS) {
        expect(() => api.unavailableMac(), throwsA(isA<OsVersionError>()));
        expect(api.unavailableIos(), 2);
        expect(() => api.unavailableBoth(), throwsA(isA<OsVersionError>()));
        expect(() => api.futureMethodMac(), throwsA(isA<OsVersionError>()));
        expect(api.futureMethodIos(), 5);
        expect(() => api.futureMethodBoth(), throwsA(isA<OsVersionError>()));
      } else {
        expect(api.unavailableMac(), 1);
        expect(() => api.unavailableIos(), throwsA(isA<OsVersionError>()));
        expect(() => api.unavailableBoth(), throwsA(isA<OsVersionError>()));
        expect(api.futureMethodMac(), 4);
        expect(() => api.futureMethodIos(), throwsA(isA<OsVersionError>()));
        expect(() => api.futureMethodBoth(), throwsA(isA<OsVersionError>()));
      }
    });

    test('Category methods', () {
      final api = NSObject();
      if (Platform.isMacOS) {
        expect(() => api.catUnavailableMac(), throwsA(isA<OsVersionError>()));
        expect(api.catUnavailableIos(), 2);
        expect(() => api.catUnavailableBoth(), throwsA(isA<OsVersionError>()));
        expect(() => api.catFutureMethodMac(), throwsA(isA<OsVersionError>()));
        expect(api.catFutureMethodIos(), 5);
        expect(() => api.catFutureMethodBoth(), throwsA(isA<OsVersionError>()));
      } else {
        expect(api.catUnavailableMac(), 1);
        expect(() => api.catUnavailableIos(), throwsA(isA<OsVersionError>()));
        expect(() => api.catUnavailableBoth(), throwsA(isA<OsVersionError>()));
        expect(api.catFutureMethodMac(), 4);
        expect(() => api.catFutureMethodIos(), throwsA(isA<OsVersionError>()));
        expect(() => api.catFutureMethodBoth(), throwsA(isA<OsVersionError>()));
      }
    });
  });
}
