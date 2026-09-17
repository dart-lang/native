// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:ffigen/ffigen.dart';
import 'package:ffigen/src/code_generator.dart' as cg;
import 'package:ffigen/src/header_parser.dart' as parser;
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  group('unexposed_using_type', () {
    late cg.Library library;

    setUpAll(() {
      library = parser.parse(
        testContext(
          FfiGenerator(
            output: Output(dart: DartOutput(path: Uri.file('unused'))),
            input: Input(
              entryPoints: [
                Uri.file(
                  absPath('test/header_parser_tests/unexposed_using_type.h'),
                ),
              ],
              compilerOptions: [
                '-x',
                'c++',
                '-std=c++17',
                if (Platform.isMacOS) ...['-isysroot', macSdkPath],
              ],
            ),
            visitors: [Visitor(func: (node) => node.isIncluded = true)],
          ),
        ),
      );
    });

    cg.Func funcNamed(String name) =>
        library.bindings.whereType<cg.Func>().firstWhere(
          (f) => f.originalName == name,
          orElse: () => fail('function $name was dropped from the bindings'),
        );

    test('functions using a using-declared type are kept', () {
      final funcNames = library.bindings
          .whereType<cg.Func>()
          .map((f) => f.originalName)
          .toSet();
      expect(
        funcNames,
        containsAll([
          'take_u16',
          'take_u32',
          'take_point',
          'take_color',
          'control_u16',
          'control_point',
          'control_ushort',
          'control_uint',
        ]),
      );
    });

    test('a using-declared primitive resolves to its underlying type', () {
      // The unexposed type resolves through its canonical type, so it lands on
      // the underlying native type rather than keeping the typedef name the
      // way `control_u16` does.
      for (final (usingFunc, canonicalFunc) in [
        ('take_u16', 'control_ushort'),
        ('take_u32', 'control_uint'),
      ]) {
        final viaUsing = funcNamed(usingFunc).functionType.returnType;
        final canonical = funcNamed(canonicalFunc).functionType.returnType;
        expect(
          viaUsing,
          canonical,
          reason:
              '$usingFunc should resolve to the same native type as '
              '$canonicalFunc',
        );
        expect(
          funcNamed(usingFunc).functionType.parameters.single.type,
          canonical,
        );
      }
    });

    test('a using-declared compound resolves to the compound itself', () {
      final viaUsing = funcNamed('take_point').functionType.returnType;
      final viaNamespace = funcNamed('control_point').functionType.returnType;
      expect(viaUsing, isA<cg.Struct>());
      expect((viaUsing as cg.Struct).originalName, 'Point');
      expect(
        viaUsing,
        same(viaNamespace),
        reason:
            'both spellings name one struct, so one binding must serve '
            'both',
      );
    });

    test('a using-declared enum resolves to the enum itself', () {
      final returnType = funcNamed('take_color').functionType.returnType;
      expect(returnType, isA<cg.EnumClass>());
      expect((returnType as cg.EnumClass).originalName, 'Color');
    });
  });
}
