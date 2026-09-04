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

    cg.CppClass findWidget() =>
        library.bindings.whereType<cg.CppClass>().firstWhere(
          (c) => c.originalName == 'Widget',
          orElse: () => fail('Widget was not parsed'),
        );

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
      final widget = findWidget();
      final methodNames = widget.methods.map((m) => m.originalName).toSet();

      expect(methodNames, contains('good'));
      expect(methodNames, contains('self'));
      expect(
        methodNames,
        contains('blobPtr'),
        reason: 'a pointer to an incomplete compound is bindable',
      );

      // Never bindable: these return a type with no definition anywhere in
      // the translation unit, so no future version of ffigen can support them
      // (C++ itself cannot define a function returning an incomplete type).
      expect(
        methodNames,
        isNot(contains('badUnionByValue')),
        reason: 'an incomplete compound cannot be returned by value',
      );
      expect(
        methodNames,
        isNot(contains('badAliasByValue')),
        reason:
            'a typedef of an incomplete compound cannot be returned by value',
      );
      expect(
        methodNames,
        isNot(contains('badClassByValue')),
        reason: 'a forward-declared class cannot be returned by value',
      );

      // Unsupported today: bindable in principle (a reference is ABI-wise a
      // pointer; a defined class could be heap-copied by the glue code). If
      // support is ever added, move these up to the bindable group with real
      // signature expectations instead of relaxing the checks.
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
      expect(
        methodNames,
        isNot(contains('badSelfByValue')),
        reason: 'a defined class returned by value is not supported',
      );
    });

    test(
      'methods with unbindable parameter types are dropped in the parser',
      () {
        final widget = findWidget();
        final methodNames = widget.methods.map((m) => m.originalName).toSet();

        expect(
          methodNames,
          contains('goodParams'),
          reason:
              'primitives and pointers (even to an incomplete compound or a '
              'C++ class) are bindable parameter types',
        );

        // Never bindable: a parameter whose type has no definition anywhere in
        // the translation unit cannot be passed by value (C++ itself cannot
        // define such a function).
        expect(
          methodNames,
          isNot(contains('badUnionParam')),
          reason: 'an incomplete compound cannot be passed by value',
        );
        expect(
          methodNames,
          isNot(contains('badAliasParam')),
          reason:
              'a typedef of an incomplete compound cannot be passed by value',
        );
        expect(
          methodNames,
          isNot(contains('badClassParam')),
          reason: 'a forward-declared class cannot be passed by value',
        );

        // Unsupported today: bindable in principle, see the equivalent return
        // type group above. If support is ever added, move these up to the
        // bindable group with real signature expectations.
        expect(
          methodNames,
          isNot(contains('badRefParam')),
          reason: 'a C++ reference parameter has no Dart mapping',
        );
        expect(
          methodNames,
          isNot(contains('badConstRefParam')),
          reason: 'a C++ reference parameter has no Dart mapping',
        );
        expect(
          methodNames,
          isNot(contains('badSelfParam')),
          reason: 'a defined class passed by value is not supported',
        );

        // The copy constructor takes a C++ reference, so only the default
        // constructor survives.
        final constructors = widget.methods.where((m) => m.isConstructor);
        expect(constructors, hasLength(1));
        expect(constructors.single.parameters, isEmpty);
      },
    );

    test('generating bindings for the class does not throw', () {
      // A method with an unbindable return type that survives parsing reaches
      // the writer as an UnimplementedType, which throws UnsupportedError
      // ('No mapping for type') when asked for its Dart spelling. The
      // bindable methods must still be generated.
      final output = library.generate();
      expect(output, contains('Widget_good'));
      expect(output, contains('Widget_self'));
      expect(output, contains('Widget_blobPtr'));
      expect(output, contains('Widget_goodParams'));
      // See the grouping in the return type test: the first three can never be
      // supported; the last three pin behavior that a future version may
      // relax, and should then move to positive expectations above.
      expect(output, isNot(contains('badUnionByValue')));
      expect(output, isNot(contains('badAliasByValue')));
      expect(output, isNot(contains('badClassByValue')));
      expect(output, isNot(contains('badRef')));
      expect(output, isNot(contains('badConstRef')));
      expect(output, isNot(contains('badSelfByValue')));
      // Same for the unsupported parameter types (badRefParam and
      // badConstRefParam are covered by the badRef/badConstRef prefix checks
      // above).
      expect(output, isNot(contains('badUnionParam')));
      expect(output, isNot(contains('badAliasParam')));
      expect(output, isNot(contains('badClassParam')));
      expect(output, isNot(contains('badSelfParam')));
      // With its only use dropped, the forward-declared class must not leave
      // a wrapper class behind in the bindings.
      expect(output, isNot(contains('class Incomplete')));
    });
  });
}
