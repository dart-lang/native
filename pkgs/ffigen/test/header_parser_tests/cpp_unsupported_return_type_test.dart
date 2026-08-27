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
  group('cpp_unsupported_return_type', () {
    late cg.Library library;

    setUpAll(() {
      library = parser.parse(
        testContext(
          FfiGenerator(
            output: Output(
              dart: DartOutput(path: Uri.file('unused')),
              style: const NativeExternalBindings(
                assetId: 'package:ffigen/cpp_test',
              ),
            ),
            input: Input(
              entryPoints: [
                Uri.file(
                  absPath(
                    'test/header_parser_tests/cpp_unsupported_return_type.h',
                  ),
                ),
              ],
              compilerOptions: [
                '-x',
                'c++',
                '-std=c++17',
                if (Platform.isMacOS) ...['-isysroot', macSdkPath],
              ],
            ),
            cpp: const Cpp(),
            visitors: [
              Visitor(
                cppClass: (node) =>
                    node.isIncluded = node.originalName == 'Widget',
              ),
            ],
          ),
        ),
      );
    });

    test('methods with unbindable return types are dropped in the parser', () {
      final widget = library.bindings.whereType<cg.CppClass>().firstWhere(
        (c) => c.originalName == 'Widget',
        orElse: () => fail('Widget was not parsed'),
      );
      final methodNames = widget.methods.map((m) => m.originalName).toSet();

      expect(methodNames, contains('good'));
      expect(methodNames, contains('self'));
      expect(
        methodNames,
        isNot(contains('badRef')),
        reason: 'a C++ reference return type has no Dart mapping',
      );
      expect(
        methodNames,
        isNot(contains('badConstRef')),
        reason: 'a C++ reference return type has no Dart mapping',
      );
    });

    test('generating bindings for the class does not throw', () {
      // A method with an unbindable return type that survives parsing reaches
      // the writer as an UnimplementedType, which throws UnsupportedError
      // ('No mapping for type') when asked for its Dart spelling. The
      // bindable methods must still be generated.
      final output = library.generate();
      expect(output, contains('Widget_good'));
      expect(output, contains('Widget_self'));
      expect(output, isNot(contains('badRef')));
      expect(output, isNot(contains('badConstRef')));
    });
  });
}
