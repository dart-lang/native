// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:ffigen/ffigen.dart';
import 'package:ffigen/src/code_generator.dart' as cg;
import 'package:ffigen/src/header_parser.dart' as parser;
import 'package:test/test.dart';

import '../test_utils.dart';

const _cyclicClasses = {'Node', 'Merger', 'Owner', 'Leaf', 'Branch'};

void main() {
  group('cpp_cyclic_class', () {
    late cg.Library library;

    setUpAll(() {
      library = parser.parse(
        testContext(
          FfiGenerator(
            output: Output(dart: DartOutput(path: Uri.file('unused'))),
            input: Input(
              entryPoints: [
                Uri.file(
                  absPath('test/header_parser_tests/cpp_cyclic_class.h'),
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
                cppClass: (node) => node.isIncluded = _cyclicClasses.contains(
                  node.originalName,
                ),
              ),
            ],
          ),
        ),
      );
    });

    test('classes that name themselves are parsed exactly once', () {
      final names =
          library.bindings
              .whereType<cg.CppClass>()
              .map((c) => c.originalName)
              .toList()
            ..sort();

      // Every class of the header, once each: a member type that closes a cycle
      // must resolve to the class already being parsed, not to a second copy of
      // it.
      expect(names, _cyclicClasses.toList()..sort());
    });

    test('a cyclic member resolves to the class already being parsed', () {
      cg.CppClass classNamed(String name) => library.bindings
          .whereType<cg.CppClass>()
          .firstWhere((c) => c.originalName == name);

      cg.CppClass returnedClass(cg.CppClass cls, String methodName) {
        final method = cls.methods.firstWhere(
          (m) => m.originalName == methodName,
          orElse: () => fail('${cls.originalName} has no method $methodName'),
        );
        expect(method.returnType, isA<cg.CppClassPointerType>());
        return (method.returnType as cg.CppClassPointerType).cppClass;
      }

      final node = classNamed('Node');
      final leaf = classNamed('Leaf');
      final branch = classNamed('Branch');

      expect(
        returnedClass(node, 'clone'),
        same(node),
        reason: 'a cyclic return type must not be a second copy of the class',
      );
      expect(returnedClass(leaf, 'parent'), same(branch));
      expect(returnedClass(branch, 'firstLeaf'), same(leaf));
    });
  });
}
