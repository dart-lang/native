// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:ffigen/src/config_provider/config_types.dart';
import 'package:ffigen/src/header_parser/clang_bindings/clang_bindings.dart'
    as clang_types;
import 'package:ffigen/src/header_parser/utils.dart';
import 'package:test/test.dart';

void main() {
  group('VersionTriple', () {
    test('toString', () {
      expect(const VersionTriple(1).toString(), '1.0.0');
      expect(const VersionTriple(1, 2).toString(), '1.2.0');
      expect(const VersionTriple(1, 2, 3).toString(), '1.2.3');
    });

    test('parse', () {
      expect(VersionTriple.parse('1').toString(), '1.0.0');
      expect(VersionTriple.parse('1.2').toString(), '1.2.0');
      expect(VersionTriple.parse('1.2.3').toString(), '1.2.3');
      expect(VersionTriple.parse('2983.91.01923').toString(), '2983.91.1923');
      expect(VersionTriple.parse(''), null);
      expect(VersionTriple.parse('asdf'), null);
      expect(VersionTriple.parse('1.'), null);
      expect(VersionTriple.parse('1.asdf'), null);
      expect(VersionTriple.parse('1.-1.0'), null);
      expect(VersionTriple.parse('1..0'), null);
    });

    test('compare', () {
      expect(const VersionTriple(1, 2, 3) >= null, false);
      expect(
          const VersionTriple(1, 2, 3) >= const VersionTriple(1, 2, 3), true);
      expect(
          const VersionTriple(1, 2, 3) >= const VersionTriple(1, 2, 2), true);
      expect(
          const VersionTriple(1, 2, 3) >= const VersionTriple(1, 2, 4), false);
      expect(
          const VersionTriple(1, 2, 3) >= const VersionTriple(1, 1, 3), true);
      expect(
          const VersionTriple(1, 2, 3) >= const VersionTriple(1, 3, 3), false);
      expect(
          const VersionTriple(1, 2, 3) >= const VersionTriple(0, 2, 3), true);
      expect(
          const VersionTriple(1, 2, 3) >= const VersionTriple(2, 2, 3), false);
    });

    test('CXVersion', () {
      final cxVersionPtr = calloc<clang_types.CXVersion>();
      clang_types.CXVersion cxVersion(int major, int minor, int subminor) =>
          cxVersionPtr.ref
            ..Major = major
            ..Minor = minor
            ..Subminor = subminor;

      expect(cxVersion(1, 2, 3).triple?.toString(), '1.2.3');
      expect(cxVersion(1, 2, -1).triple?.toString(), '1.2.0');
      expect(cxVersion(1, -1, -1).triple?.toString(), '1.0.0');
      expect(cxVersion(-1, -1, -1).triple, null);

      calloc.free(cxVersionPtr);
    });
  });
}
