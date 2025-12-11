// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/header_parser.dart' as parser;
import 'package:ffigen/src/strings.dart' as strings;
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import '../test_utils.dart';

late Library actual, expected;

void main() {
  group('static_const_test', () {
    setUpAll(() {
      expected = expectedLibrary();
      actual = parser.parse(
        testContext(
          testConfigFromPath(
            configPath(
              path.join(packagePathForTests, 'test', 'header_parser_tests'),
              'static_const_config.yaml',
            ),
          ),
        ),
      );
    });

    test('Total bindings count', () {
      expect(actual.bindings.length, expected.bindings.length);
    });

    test('TEST_INT', () {
      expect(
        actual.getBindingAsString('TEST_INT'),
        expected.getBindingAsString('TEST_INT'),
      );
    });

    test('TEST_NEGATIVE_INT', () {
      expect(
        actual.getBindingAsString('TEST_NEGATIVE_INT'),
        expected.getBindingAsString('TEST_NEGATIVE_INT'),
      );
    });

    test('TEST_DOUBLE', () {
      expect(
        actual.getBindingAsString('TEST_DOUBLE'),
        expected.getBindingAsString('TEST_DOUBLE'),
      );
    });

    test('TEST_NEGATIVE_DOUBLE', () {
      expect(
        actual.getBindingAsString('TEST_NEGATIVE_DOUBLE'),
        expected.getBindingAsString('TEST_NEGATIVE_DOUBLE'),
      );
    });

    test('TEST_EXPRESSION', () {
      expect(
        actual.getBindingAsString('TEST_EXPRESSION'),
        expected.getBindingAsString('TEST_EXPRESSION'),
      );
    });

    test('TEST_HEX', () {
      expect(
        actual.getBindingAsString('TEST_HEX'),
        expected.getBindingAsString('TEST_HEX'),
      );
    });

    test('TEST_NEGATIVE_HEX', () {
      expect(
        actual.getBindingAsString('TEST_NEGATIVE_HEX'),
        expected.getBindingAsString('TEST_NEGATIVE_HEX'),
      );
    });

    test('TEST_STRING', () {
      expect(
        actual.getBindingAsString('TEST_STRING'),
        expected.getBindingAsString('TEST_STRING'),
      );
    });

    test('TEST_STRING_SPECIAL', () {
      expect(
        actual.getBindingAsString('TEST_STRING_SPECIAL'),
        expected.getBindingAsString('TEST_STRING_SPECIAL'),
      );
    });

    test('TEST_STRING_QUOTES', () {
      expect(
        actual.getBindingAsString('TEST_STRING_QUOTES'),
        expected.getBindingAsString('TEST_STRING_QUOTES'),
      );
    });

    test('TEST_STRING_BACKSLASH', () {
      expect(
        actual.getBindingAsString('TEST_STRING_BACKSLASH'),
        expected.getBindingAsString('TEST_STRING_BACKSLASH'),
      );
    });

    test('TEST_STRING_CONTROLS', () {
      expect(
        actual.getBindingAsString('TEST_STRING_CONTROLS'),
        expected.getBindingAsString('TEST_STRING_CONTROLS'),
      );
    });

    test('TEST_INF', () {
      expect(
        actual.getBindingAsString('TEST_INF'),
        expected.getBindingAsString('TEST_INF'),
      );
    });

    test('TEST_NEGATIVE_INF', () {
      expect(
        actual.getBindingAsString('TEST_NEGATIVE_INF'),
        expected.getBindingAsString('TEST_NEGATIVE_INF'),
      );
    });

    test('TEST_NAN', () {
      expect(
        actual.getBindingAsString('TEST_NAN'),
        expected.getBindingAsString('TEST_NAN'),
      );
    });

    test('MyFlags typedef', () {
      expect(
        actual.getBindingAsString('MyFlags'),
        expected.getBindingAsString('MyFlags'),
      );
    });

    test('MyBufferUsage typedef', () {
      expect(
        actual.getBindingAsString('MyBufferUsage'),
        expected.getBindingAsString('MyBufferUsage'),
      );
    });

    test('MyBufferUsage_None', () {
      expect(
        actual.getBindingAsString('MyBufferUsage_None'),
        expected.getBindingAsString('MyBufferUsage_None'),
      );
    });

    test('MyBufferUsage_MapRead', () {
      expect(
        actual.getBindingAsString('MyBufferUsage_MapRead'),
        expected.getBindingAsString('MyBufferUsage_MapRead'),
      );
    });

    test('TEST_STRING_ARRAY', () {
      expect(
        actual.getBindingAsString('TEST_STRING_ARRAY'),
        expected.getBindingAsString('TEST_STRING_ARRAY'),
      );
    });

    test('test_global', () {
      expect(
        actual.getBindingAsString('test_global'),
        expected.getBindingAsString('test_global'),
      );
    });
  });
}

Library expectedLibrary() {
  final myFlags = Typealias(
    name: 'MyFlags',
    type: NativeType(SupportedNativeType.uint64),
  );
  final myBufferUsage = Typealias(name: 'MyBufferUsage', type: myFlags);

  return Library(
    context: testContext(),
    bindings: [
      Constant(name: 'TEST_INT', rawType: 'int', rawValue: '10'),
      Constant(name: 'TEST_NEGATIVE_INT', rawType: 'int', rawValue: '-10'),
      Constant(name: 'TEST_DOUBLE', rawType: 'double', rawValue: '3.14'),
      Constant(
        name: 'TEST_NEGATIVE_DOUBLE',
        rawType: 'double',
        rawValue: '-3.14',
      ),
      Constant(name: 'TEST_EXPRESSION', rawType: 'int', rawValue: '10'),
      Constant(name: 'TEST_HEX', rawType: 'int', rawValue: '255'),
      Constant(name: 'TEST_NEGATIVE_HEX', rawType: 'int', rawValue: '-255'),
      Constant(name: 'TEST_STRING', rawType: 'String', rawValue: "'test'"),
      Constant(
        name: 'TEST_STRING_SPECIAL',
        rawType: 'String',
        rawValue: r"'\$dollar'",
      ),
      Constant(
        name: 'TEST_STRING_QUOTES',
        rawType: 'String',
        rawValue: r"'test\'s'",
      ),
      Constant(
        name: 'TEST_STRING_BACKSLASH',
        rawType: 'String',
        rawValue: r"'test\\'",
      ),
      Constant(
        name: 'TEST_STRING_CONTROLS',
        rawType: 'String',
        rawValue: r"'hello\n\t\r\v\b'",
      ),
      Constant(
        name: 'TEST_INF',
        rawType: 'double',
        rawValue: strings.doubleInfinity,
      ),
      Constant(
        name: 'TEST_NEGATIVE_INF',
        rawType: 'double',
        rawValue: strings.doubleNegativeInfinity,
      ),
      Constant(
        name: 'TEST_NAN',
        rawType: 'double',
        rawValue: strings.doubleNaN,
      ),
      myFlags,
      myBufferUsage,
      Constant(name: 'MyBufferUsage_None', rawType: 'int', rawValue: '0'),
      Constant(name: 'MyBufferUsage_MapRead', rawType: 'int', rawValue: '1'),
      Global(
        name: 'TEST_STRING_ARRAY',
        type: ConstantArray(11, charType, useArrayType: false),
      ),
      Global(name: 'test_global', type: intType),
    ],
  )..forceFillNamesForTesting();
}
