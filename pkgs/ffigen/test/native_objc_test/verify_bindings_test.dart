// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import '../test_utils.dart';
import 'util.dart';

void main() {
  group('verify_bindings_test', () {
    final testDir = Directory(
      path.join(packagePathForTests, 'test', 'native_objc_test'),
    );

    // These tests don't use verifyBindings because they generate their bindings
    // programmatically.
    const excludedTests = {
      'deprecated_test.dart',
      'ns_range_test.dart',
      'swift_unavailable_test.dart',
      'transitive_test.dart',
      'verify_bindings_test.dart',
    };

    const customVerifiers = {
      'protocol_test.dart': (
        _verifyProtocolTestDartBindings,
        _verifyProtocolTestObjCBindings,
      ),
    };

    final testFiles =
        testDir
            .listSync()
            .whereType<File>()
            .where((f) => f.path.endsWith('_test.dart'))
            .map((f) => path.basename(f.path))
            .where((f) => !excludedTests.contains(f))
            .toList()
          ..sort();

    for (final testFile in testFiles) {
      final configName = testFile.replaceFirst('_test.dart', '');

      test('verifyBindings for $testFile', () {
        final verifiers = customVerifiers[testFile];
        verifyBindings(
          configName,
          dartVerify: verifiers?.$1,
          objCVerify: verifiers?.$2,
        );
      });
    }
  });
}

bool _verifyProtocolTestDartBindings(String expected, String actual) {
  expect(
    actual,
    contains('extension type ProtocolConsumer._(objc.ObjCObject '),
  );
  expect(
    actual,
    contains('extension type ObjCProtocolImpl._(objc.ObjCObject '),
  );
  expect(actual, contains('extension type MyProtocol._(objc.ObjCProtocol '));
  expect(
    actual,
    contains('extension type SecondaryProtocol._(objc.ObjCProtocol '),
  );
  expect(actual, contains(r'interface class MyProtocol$Builder {'));
  expect(actual, contains(r'interface class SecondaryProtocol$Builder {'));
  expect(
    actual,
    contains(
      'objc.NSString instanceMethod('
      'objc.NSString s, {required double withDouble})',
    ),
  );
  expect(actual, contains('int optionalMethod(SomeStruct s)'));
  expect(
    actual,
    contains(
      'int otherMethod('
      'int a, {required int b, required int c, required int d})',
    ),
  );
  expect(actual, contains('int fooMethod()'));
  expect(actual, contains('extension type EmptyProtocol._(objc.ObjCProtocol '));
  expect(actual, isNot(contains('EmptyProtocol is a stub')));
  expect(actual, contains('SuperProtocol is a stub'));
  expect(actual, contains('FilteredProtocol is a stub'));
  return true;
}

bool _verifyProtocolTestObjCBindings(String expected, String actual) {
  expect(actual, contains('@protocol(EmptyProtocol)'));
  expect(actual, contains('@protocol(MyProtocol)'));
  expect(actual, contains('@protocol(SecondaryProtocol)'));
  expect(actual, contains('@protocol(UnusedProtocol)'));
  expect(actual, contains('BLOCKING_BLOCK_IMPL'));
  return true;
}
