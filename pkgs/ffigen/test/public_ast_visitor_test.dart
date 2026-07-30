// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/ffigen.dart';
import 'package:ffigen/src/code_generator.dart' as code_gen;
import 'package:ffigen/src/header_parser.dart' as parser;
import 'package:test/test.dart';

import 'test_utils.dart';

class CustomRenamerVisitor extends Visitor {
  @override
  void visitFunc(Func node) {
    if (node.originalName == 'func1') {
      node.name = 'myCustomFunc';
    }
  }

  @override
  void visitStruct(Struct node) {
    if (node.originalName == 'StructA') {
      node.name = 'MyStructA';
    }
    super.visitStruct(node);
  }

  @override
  void visitField(Field node) {
    if (node.originalName == 'foo') {
      node.name = 'bar';
    }
  }
}

class CustomExcluderVisitor extends Visitor {
  @override
  void visitFunc(Func node) {
    if (node.originalName == 'func2') {
      node.isIncluded = false;
    }
  }

  @override
  void visitStruct(Struct node) {
    if (node.originalName == 'StructB') {
      node.isIncluded = false;
    }
  }
}

class CustomLeafVisitor extends Visitor {
  @override
  void visitFunc(Func node) {
    if (node.originalName == 'func1' || node.name == 'myCustomFunc') {
      node.isLeaf = true;
    }
  }
}

void main() {
  group('Public AST Visitors Test', () {
    test('Visitor renaming, excluding, and leaf setting', () {
      final headerUri = Uri.file(
        absPath('test/header_parser_tests/functions.h'),
      );
      final generator = FfiGenerator(
        input: Input(entryPoints: [headerUri]),
        output: Output(dartFile: Uri.file('unused.dart')),
        visitors: [
          const IncludeAllVisitor(),
          CustomRenamerVisitor(),
          CustomExcluderVisitor(),
          CustomLeafVisitor(),
        ],
      );

      final library = parser.parse(testContext(generator));

      // Check that func1 was renamed to myCustomFunc and marked leaf
      final customFunc = library.getBinding('myCustomFunc') as code_gen.Func;
      expect(customFunc.name, 'myCustomFunc');
      expect(customFunc.isLeaf, isTrue);

      // Check that func2 was excluded
      expect(
        () => library.getBinding('func2'),
        throwsA(isA<NotFoundException>()),
      );
    });

    test('Automatic AST walking via visitChildren', () {
      final headerUri = Uri.file(
        absPath('test/header_parser_tests/function_n_struct.h'),
      );
      final autoWalker = _AutoWalkVisitor();
      final generator = FfiGenerator(
        input: Input(entryPoints: [headerUri]),
        output: Output(dartFile: Uri.file('unused.dart')),
        visitors: [const IncludeAllVisitor(), autoWalker],
      );

      parser.parse(testContext(generator));

      // Verify fields were visited without manually looping inside visitStruct
      expect(autoWalker.visitedFieldNames, contains('a'));
    });

    test('Inline callback-based Visitor constructor', () {
      final headerUri = Uri.file(
        absPath('test/header_parser_tests/function_n_struct.h'),
      );
      final visitedFields = <String>[];
      final generator = FfiGenerator(
        input: Input(entryPoints: [headerUri]),
        output: Output(dartFile: Uri.file('unused.dart')),
        visitors: [
          const IncludeAllVisitor(),
          Visitor(
            visitFunc: (node) {
              if (node.originalName == 'func1') {
                node.name = 'inlineRenamedFunc1';
              }
            },
            visitField: (node) {
              visitedFields.add(node.originalName);
            },
          ),
        ],
      );

      final library = parser.parse(testContext(generator));

      final renamedFunc =
          library.getBinding('inlineRenamedFunc1') as code_gen.Func;
      expect(renamedFunc.name, 'inlineRenamedFunc1');
      expect(visitedFields, contains('a'));
    });

    test('IncludeSetVisitor per-type inclusion', () {
      final headerUri = Uri.file(
        absPath('test/header_parser_tests/function_n_struct.h'),
      );
      final generator = FfiGenerator(
        input: Input(entryPoints: [headerUri]),
        output: Output(dartFile: Uri.file('unused.dart')),
        visitors: [
          const IncludeAllVisitor(),
          const IncludeSetVisitor(functions: {'func1'}, structs: {'Struct1'}),
        ],
      );

      final library = parser.parse(testContext(generator));

      expect(library.getBinding('func1'), isNotNull);
      expect(
        () => library.getBinding('func2'),
        throwsA(isA<NotFoundException>()),
      );
      expect(library.getBinding('Struct1'), isNotNull);
      expect(
        () => library.getBinding('Struct6'),
        throwsA(isA<NotFoundException>()),
      );
    });

    test('EnumClass.silenceWarning option on public AST', () {
      final headerUri = Uri.file(
        absPath('test/header_parser_tests/enum_int_mimic.h'),
      );
      final generator = FfiGenerator(
        input: Input(entryPoints: [headerUri]),
        output: Output(dartFile: Uri.file('unused.dart')),
        visitors: [
          const IncludeAllVisitor(),
          Visitor(
            visitEnum: (node) {
              node.silenceWarning = true;
            },
          ),
        ],
      );

      final library = parser.parse(testContext(generator));
      final enumClass = library.getBinding('Simple') as code_gen.EnumClass;
      expect(enumClass.silenceWarning, isTrue);
    });

    test('ObjCInterface.includeCategories option on public AST', () {
      final headerUri = Uri.file(
        absPath('test/native_objc_test/transitive_test.h'),
      );
      final generator = FfiGenerator(
        input: Input(entryPoints: [headerUri]),
        output: Output(dartFile: Uri.file('unused.dart')),
        objectiveC: const ObjectiveC(),
        visitors: [
          const IncludeSetVisitor(
            objcInterfaces: {'DirectlyIncludedIntForCat'},
          ),
          Visitor(
            visitObjCInterface: (node) {
              if (node.originalName == 'DirectlyIncludedIntForCat') {
                expect(node.includeCategories, isTrue);
                node.includeCategories = false;
                expect(node.includeCategories, isFalse);
              }
            },
          ),
        ],
      );

      final library = parser.parse(testContext(generator));
      final interface =
          library.getBinding('DirectlyIncludedIntForCat')
              as code_gen.ObjCInterface;
      expect(interface.includeCategories, isFalse);
    });

    test('Visitor setting varArgs for variadic functions', () {
      final headerUri = Uri.file(absPath('test/header_parser_tests/varargs.h'));
      final generator = FfiGenerator(
        input: Input(entryPoints: [headerUri]),
        output: Output(dartFile: Uri.file('unused.dart')),
        visitors: [
          const IncludeAllVisitor(),
          Visitor(
            visitFunc: (Func node) {
              if (node.originalName == 'myfunc') {
                node.varArgs = [
                  VarArgFunction('custom', [code_gen.intType]),
                ];
              }
            },
          ),
        ],
      );

      final library = parser.parse(testContext(generator));
      final func = library.getBinding('myfunccustom') as code_gen.Func;
      expect(func, isNotNull);
      expect(func.name, 'myfunccustom');
    });
  });
}

class _AutoWalkVisitor extends Visitor {
  final visitedFieldNames = <String>[];

  @override
  void visitField(Field node) {
    visitedFieldNames.add(node.originalName);
  }
}
