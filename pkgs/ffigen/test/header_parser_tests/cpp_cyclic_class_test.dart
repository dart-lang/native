// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/ffigen.dart';
import 'package:ffigen/src/code_generator.dart' as cg;
import 'package:ffigen/src/header_parser.dart' as parser;
import 'package:test/test.dart';

import '../test_utils.dart';

/// A C++ class whose own member signatures name that same class is parsed by
/// re-entering the class parser for a class that is still being parsed. The
/// parser has to recognize the class it is already working on: without that,
/// parsing recurses until the stack is exhausted, which takes the whole process
/// down (a segfault, or an exception thrown through the libclang visitor
/// callback) rather than failing the test.
/// The header's own classes: self-reference through a return type, through a
/// parameter, through a std::unique_ptr, and a cycle between two classes.
const _cyclicClasses = {'Node', 'Merger', 'Owner', 'Leaf', 'Branch'};

void main() {
  group('cpp_cyclic_class', () {
    late cg.Library library;

    setUpAll(() {
      library = parser.parse(
        testContext(
          FfiGenerator(
            output: Output(dartFile: Uri.file('unused')),
            input: Input(
              entryPoints: [
                Uri.file(absPath('test/header_parser_tests/cpp_cyclic_class.h')),
              ],
              compilerOptions: const ['-x', 'c++', '-std=c++17'],
            ),
            cpp: const Cpp(),
            visitors: [
              // A C++ class is excluded by default. Only the header's own
              // classes are included: <memory> drags the whole standard library
              // in behind std::unique_ptr, and what it declares differs per
              // toolchain.
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
      cg.CppClass classNamed(String name) =>
          library.bindings.whereType<cg.CppClass>().firstWhere(
            (c) => c.originalName == name,
          );

      final node = classNamed('Node');
      final leaf = classNamed('Leaf');
      final branch = classNamed('Branch');

      expect(
        node.methods.map((m) => m.originalName),
        contains('clone'),
        reason: 'the member whose type closes the cycle is still parsed',
      );
      expect(leaf.methods.map((m) => m.originalName), contains('parent'));
      expect(branch.methods.map((m) => m.originalName), contains('firstLeaf'));
    });
  });
}
