// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/ffigen.dart';
import 'package:ffigen/src/code_generator.dart' as cg;
import 'package:ffigen/src/header_parser.dart' as parser;
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  group('cpp_unsupported_fptr_typedef', () {
    late cg.Library library;

    setUpAll(() {
      library = parser.parse(
        testContext(
          FfiGenerator(
            output: Output(dart: DartOutput(path: Uri.file('unused'))),
            input: Input(
              entryPoints: [
                Uri.file(
                  absPath(
                    'test/header_parser_tests/cpp_unsupported_fptr_typedef.h',
                  ),
                ),
              ],
              compilerOptions: ['-x', 'c++'],
            ),
            visitors: [
              Visitor(
                struct: (node) => node.isIncluded = true,
                typealias: (node) => node.isIncluded = TypealiasInclude.always,
                func: (node) => node.isIncluded = true,
              ),
            ],
          ),
        ),
      );
    });

    test('typedef to a function pointer with an unsupported parameter', () {
      final typealiasNames = library.bindings
          .whereType<cg.Typealias>()
          .map((t) => t.originalName)
          .toSet();
      expect(typealiasNames, contains('GoodCallback'));
      expect(
        typealiasNames,
        isNot(contains('BadCallback')),
        reason: 'a C++ reference parameter has no Dart mapping',
      );
      expect(
        typealiasNames,
        isNot(contains('BadCallbackAlias')),
        reason: 'a typedef of an unsupported typedef is also unsupported',
      );
    });

    test('struct with a typedef-ed unsupported function pointer member', () {
      cg.Compound findStruct(String name) =>
          library.bindings.whereType<cg.Compound>().firstWhere(
            (c) => c.originalName == name,
            orElse: () => fail('$name was not parsed'),
          );
      // A struct with an unsupported member type is emitted as an opaque
      // struct, whether the member's type is reached through a typedef or
      // spelled out directly.
      for (final name in ['Holder', 'DirectHolder']) {
        final holder = findStruct(name);
        expect(holder.isOpaque, isTrue, reason: '$name should be opaque');
        expect(holder.members, isEmpty, reason: '$name should have no members');
      }
    });

    test('functions taking the typedefs', () {
      final functionNames = library.bindings
          .whereType<cg.Func>()
          .map((f) => f.originalName)
          .toSet();
      expect(functionNames, contains('useGood'));
      expect(functionNames, isNot(contains('useBad')));
      expect(functionNames, isNot(contains('useBadAlias')));
    });

    test('generating bindings does not throw', () {
      final output = library.generate();
      expect(output, contains('GoodCallback'));
      expect(output, contains('useGood'));
      expect(output, contains('class Holder extends ffi.Opaque'));
      expect(output, contains('class DirectHolder extends ffi.Opaque'));
      expect(output, isNot(contains('BadCallback')));
      expect(output, isNot(contains('useBad')));
    });
  });
}
