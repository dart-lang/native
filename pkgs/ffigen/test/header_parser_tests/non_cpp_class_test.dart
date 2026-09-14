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
  group('non_cpp_class', () {
    late cg.Library library;

    setUpAll(() {
      library = parser.parse(
        testContext(
          // No `cpp:` entry: C++ support is off, so every class must take the
          // struct path.
          FfiGenerator(
            output: Output(dart: DartOutput(path: Uri.file('unused'))),
            input: Input(
              entryPoints: [
                Uri.file(absPath('test/header_parser_tests/non_cpp_class.h')),
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

    test('classes are not bound as C++ classes', () {
      expect(library.bindings.whereType<cg.CppClass>(), isEmpty);
    });

    test('functions using classes through pointers are kept', () {
      final funcNames = library.bindings
          .whereType<cg.Func>()
          .map((f) => f.originalName)
          .toSet();
      expect(
        funcNames,
        containsAll([
          'widget_create',
          'widget_size',
          'widget_destroy',
          'gadget_create',
        ]),
      );
    });

    test('a class reached through a pointer is bound as a struct', () {
      cg.Type returnTypeOf(String funcName) => library.bindings
          .whereType<cg.Func>()
          .firstWhere((f) => f.originalName == funcName)
          .functionType
          .returnType;

      for (final (funcName, className) in [
        ('widget_create', 'Widget'),
        ('gadget_create', 'Gadget'),
      ]) {
        final returnType = returnTypeOf(funcName);
        expect(returnType, isA<cg.PointerType>());
        final pointee = (returnType as cg.PointerType).child;
        expect(pointee, isA<cg.Struct>());
        expect((pointee as cg.Struct).originalName, className);
      }
    });
  });
}
