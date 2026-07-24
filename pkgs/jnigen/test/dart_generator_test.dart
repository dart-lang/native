// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:jnigen/src/bindings/dart_generator.dart';
import 'package:test/test.dart';

import 'test_util/test_util.dart';

void main() async {
  await checkLocallyBuiltDependencies();

  test('OutsideInBuffer', () {
    final buffer = OutsideInBuffer();
    buffer.appendLeft('f(');
    buffer.prependRight('x)');
    buffer.appendLeft('g(');
    buffer.prependRight('y) + ');
    expect(buffer.toString(), 'f(g(y) + x)');
  });

  group('escapeDartString', () {
    test('leaves ordinary text unchanged', () {
      expect(
        escapeDartString('Use another method instead.'),
        'Use another method instead.',
      );
    });

    test('escapes backspace', () {
      expect(
        escapeDartString('\b'),
        r'\b',
      );
    });

    test('escapes newline', () {
      expect(
        escapeDartString('\n'),
        r'\n',
      );
    });

    test('escapes form feed', () {
      expect(
        escapeDartString('\f'),
        r'\f',
      );
    });

    test('escapes vertical tab', () {
      expect(
        escapeDartString('\v'),
        r'\v',
      );
    });

    test('escapes carriage return', () {
      expect(
        escapeDartString('\r'),
        r'\r',
      );
    });

    test('escapes tab', () {
      expect(
        escapeDartString('\t'),
        r'\t',
      );
    });

    test('escapes single quote', () {
      expect(
        escapeDartString("'"),
        r"\'",
      );
    });

    test('escapes backslash', () {
      expect(
        escapeDartString('\\'),
        r'\\',
      );
    });

    test('escapes dollar sign', () {
      expect(
        escapeDartString(r'$'),
        r'\$',
      );
    });

    test('preserves unicode text', () {
      expect(
        escapeDartString('Deprecated café'),
        'Deprecated café',
      );
    });

    test('escapes mixed text correctly', () {
      expect(
        escapeDartString('Hello\nWorld\t\$100'),
        r'Hello\nWorld\t\$100',
      );
    });
  });
}
