// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/ffigen.dart' show FfiGenerator, Output, YamlConfig;
import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/code_generator/scope.dart';
import 'package:ffigen/src/config_provider/public_ast.dart' as public_ast;
import 'package:ffigen/src/header_parser/sub_parsers/api_availability.dart';
import 'package:ffigen/src/visitor/apply_config_filters.dart';
import 'package:ffigen/src/visitor/visitor.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

import '../test_utils.dart';

final class FilteringVisitor extends public_ast.Visitor {
  FilteringVisitor() : super.base();

  @override
  void visitFunc(public_ast.Func node) {
    if (node.originalName != 'excluded_func') {
      node.isIncluded = true;
    }
  }

  @override
  void visitStruct(public_ast.Struct node) {
    if (node.originalName != 'excluded_struct') {
      node.isIncluded = true;
    }
  }

  @override
  void visitUnion(public_ast.Union node) {
    if (node.originalName != 'excluded_union') {
      node.isIncluded = true;
    }
  }

  @override
  void visitEnum(public_ast.EnumClass node) {
    if (node.originalName != 'excluded_enum') {
      node.isIncluded = true;
    }
  }

  @override
  void visitGlobal(public_ast.Global node) {
    if (node.originalName != 'excluded_global') {
      node.isIncluded = true;
    }
  }

  @override
  void visitMacro(public_ast.MacroConstant node) {
    if (node.originalName != 'EXCLUDED_MACRO') {
      node.isIncluded = true;
    }
  }

  @override
  void visitTypealias(public_ast.Typealias node) {
    if (node.originalName != 'excluded_typedef') {
      node.isIncluded = true;
    }
  }

  @override
  void visitObjCInterface(public_ast.ObjCInterface node) {
    if (node.originalName != 'ExcludedInterface') {
      node.isIncluded = true;
    }
  }

  @override
  void visitObjCProtocol(public_ast.ObjCProtocol node) {
    if (node.originalName != 'ExcludedProtocol') {
      node.isIncluded = true;
    }
  }

  @override
  void visitObjCCategory(public_ast.ObjCCategory node) {
    if (node.originalName != 'ExcludedCategory') {
      node.isIncluded = true;
    }
  }

  @override
  void visitCppClass(public_ast.CppClass node) {
    if (node.originalName != 'ExcludedCppClass') {
      node.isIncluded = true;
    }
  }

  @override
  void visitUnnamedEnumConstant(public_ast.UnnamedEnumConstant node) {
    if (node.originalName != 'EXCLUDED_UNNAMED_ENUM') {
      node.isIncluded = true;
    }
  }

  @override
  void visitObjCMethod(public_ast.ObjCMethod node) {
    if (node.originalName != 'excludedMethod') {
      node.isIncluded = true;
    }
  }

  @override
  void visitCppMethod(public_ast.CppMethod node) {
    if (node.originalName != 'excludedMethod') {
      node.isIncluded = true;
    }
  }
}

void main() {
  group('FilteringVisitor Tests', () {
    test('isIncluded defaults to false on Bindings and ObjCMethod', () {
      final context = testContext(
        FfiGenerator(output: Output(dartFile: Uri.file('out.dart'))),
      );

      final func = Func(
        name: 'my_func',
        originalName: 'my_func',
        returnType: voidType,
      );
      expect(func.isIncluded, isFalse);

      final method = ObjCMethod(
        context: context,
        originalName: 'myMethod',
        name: 'myMethod',
        kind: ObjCMethodKind.method,
        isClassMethod: false,
        isOptional: false,
        returnType: voidType,
        family: null,
        apiAvailability: ApiAvailability.all,
        params: [],
        ownershipAttribute: null,
        consumesSelfAttribute: false,
      );
      expect(method.isIncluded, isFalse);
    });

    test('Custom Visitor setting isIncluded = false', () {
      final context = testContext(
        FfiGenerator(output: Output(dartFile: Uri.file('out.dart'))),
      );

      final includedFunc = Func(
        name: 'included_func',
        originalName: 'included_func',
        returnType: voidType,
      );

      final excludedFunc = Func(
        name: 'excluded_func',
        originalName: 'excluded_func',
        returnType: voidType,
      );

      final includedStruct = Struct(
        name: 'included_struct',
        originalName: 'included_struct',
        context: context,
      );

      final excludedStruct = Struct(
        name: 'excluded_struct',
        originalName: 'excluded_struct',
        context: context,
      );

      final rawBindings = <Binding>[
        includedFunc,
        excludedFunc,
        includedStruct,
        excludedStruct,
      ];

      final nodes = rawBindings
          .map((b) => b.toPublicAstNode())
          .nonNulls
          .toList();

      FilteringVisitor().visitAll(nodes);

      expect(includedFunc.isIncluded, isTrue);
      expect(excludedFunc.isIncluded, isFalse);
      expect(includedStruct.isIncluded, isTrue);
      expect(excludedStruct.isIncluded, isFalse);

      final visitation = ApplyConfigFiltersVisitation(context);
      visit(context, visitation, rawBindings);

      expect(visitation.directlyIncluded.contains(includedFunc), isTrue);
      expect(visitation.directlyIncluded.contains(excludedFunc), isFalse);
      expect(visitation.directlyIncluded.contains(includedStruct), isTrue);
      expect(visitation.directlyIncluded.contains(excludedStruct), isFalse);
    });

    test(
      'YamlConfigAstVisitor sets isIncluded = false from YAML configuration',
      () {
        final yamlConfig = YamlConfig.fromYaml(
          loadYaml(r'''
output: 'out.dart'
headers:
  entry-points:
    - 'foo.h'
functions:
  include:
    - 'funcA'
structs:
  include:
    - 'StructA'
''')
              as YamlMap,
          createTestLogger(),
        );

        final generator = yamlConfig.configAdapter();
        final yamlVisitor = generator.visitors.first;

        final funcA = Func(
          name: 'funcA',
          originalName: 'funcA',
          returnType: voidType,
        );
        final funcB = Func(
          name: 'funcB',
          originalName: 'funcB',
          returnType: voidType,
        );

        final nodes = [
          funcA,
          funcB,
        ].map((b) => b.toPublicAstNode()).nonNulls.toList();
        yamlVisitor.visitAll(nodes);

        expect(funcA.isIncluded, isTrue);
        expect(funcB.isIncluded, isFalse);
      },
    );

    test(
      'node.accept(visitor) does not visit children when isIncluded is false',
      () {
        final context = testContext(
          FfiGenerator(output: Output(dartFile: Uri.file('out.dart'))),
        );

        final func =
            Func(
                  name: 'func',
                  originalName: 'func',
                  returnType: voidType,
                  parameters: [Parameter(name: 'p1', type: intType)],
                ).toPublicAstNode()
                as public_ast.Func;

        final struct =
            Struct(
                  name: 'struct',
                  originalName: 'struct',
                  context: context,
                  members: [
                    CompoundMember(
                      name: 'm1',
                      originalName: 'm1',
                      type: intType,
                    ),
                  ],
                ).toPublicAstNode()
                as public_ast.Struct;

        final union =
            Union(
                  name: 'union',
                  originalName: 'union',
                  context: context,
                  members: [
                    CompoundMember(
                      name: 'm1',
                      originalName: 'm1',
                      type: intType,
                    ),
                  ],
                ).toPublicAstNode()
                as public_ast.Union;

        final enumClass =
            EnumClass(
                  name: 'enum',
                  originalName: 'enum',
                  context: context,
                  enumConstants: [
                    EnumConstant(name: 'c1', originalName: 'c1', value: 0),
                  ],
                ).toPublicAstNode()
                as public_ast.EnumClass;

        ObjCMethod createObjCMethod() => ObjCMethod(
          context: context,
          originalName: 'm1',
          name: 'm1',
          kind: ObjCMethodKind.method,
          isClassMethod: false,
          isOptional: false,
          returnType: voidType,
          family: null,
          apiAvailability: ApiAvailability.all,
          params: [Parameter(name: 'p1', type: intType)],
          ownershipAttribute: null,
          consumesSelfAttribute: false,
        );

        final objcInterfaceInternal = ObjCInterface(
          context: context,
          originalName: 'itf',
          name: 'itf',
          apiAvailability: ApiAvailability.all,
        )..addMethod(createObjCMethod());
        final objcInterface =
            objcInterfaceInternal.toPublicAstNode() as public_ast.ObjCInterface;

        final objcProtocolInternal = ObjCProtocol(
          context: context,
          originalName: 'proto',
          name: 'proto',
          apiAvailability: ApiAvailability.all,
        )..addMethod(createObjCMethod());
        final objcProtocol =
            objcProtocolInternal.toPublicAstNode() as public_ast.ObjCProtocol;

        final objcCategoryInternal = ObjCCategory(
          context: context,
          originalName: 'cat',
          name: 'cat',
          parent: objcInterfaceInternal,
          apiAvailability: ApiAvailability.all,
        )..addMethod(createObjCMethod());
        final objcCategory =
            objcCategoryInternal.toPublicAstNode() as public_ast.ObjCCategory;

        final cppMethodInternal = CppMethod(
          name: Symbol('m1', SymbolKind.method),
          originalName: 'm1',
          returnType: voidType,
          parameters: [Parameter(name: 'p1', type: intType)],
          isConstant: false,
        );
        final cppClassInternal = CppClass(
          name: 'cppClass',
          originalName: 'cppClass',
          context: context,
          methods: [cppMethodInternal],
          fields: [],
        );
        final cppClass =
            cppClassInternal.toPublicAstNode() as public_ast.CppClass;

        final objcMethod = objcInterface.methods.first;
        final cppMethod = cppClass.methods.first;

        final testCases = <(String, public_ast.AstNode)>[
          ('Func', func),
          ('Struct', struct),
          ('Union', union),
          ('EnumClass', enumClass),
          ('ObjCInterface', objcInterface),
          ('ObjCProtocol', objcProtocol),
          ('ObjCCategory', objcCategory),
          ('CppClass', cppClass),
          ('ObjCMethod', objcMethod),
          ('CppMethod', cppMethod),
        ];

        for (final (name, node) in testCases) {
          final visitedWhenIncluded = <public_ast.AstNode>[];
          final visitorIncluded = public_ast.Visitor(
            visitFunc: visitedWhenIncluded.add,
            visitStruct: visitedWhenIncluded.add,
            visitUnion: visitedWhenIncluded.add,
            visitEnum: visitedWhenIncluded.add,
            visitObjCInterface: visitedWhenIncluded.add,
            visitObjCProtocol: visitedWhenIncluded.add,
            visitObjCCategory: visitedWhenIncluded.add,
            visitCppClass: visitedWhenIncluded.add,
            visitCppMethod: visitedWhenIncluded.add,
            visitObjCMethod: visitedWhenIncluded.add,
            visitField: visitedWhenIncluded.add,
            visitEnumConstant: visitedWhenIncluded.add,
            visitParam: visitedWhenIncluded.add,
          );

          (node as dynamic).isIncluded = true;
          node.accept(visitorIncluded);
          expect(
            visitedWhenIncluded.length,
            greaterThan(1),
            reason: '$name should visit children when included',
          );
          expect(visitedWhenIncluded.first, same(node));

          final visitedWhenExcluded = <public_ast.AstNode>[];
          final visitorExcluded = public_ast.Visitor(
            visitFunc: visitedWhenExcluded.add,
            visitStruct: visitedWhenExcluded.add,
            visitUnion: visitedWhenExcluded.add,
            visitEnum: visitedWhenExcluded.add,
            visitObjCInterface: visitedWhenExcluded.add,
            visitObjCProtocol: visitedWhenExcluded.add,
            visitObjCCategory: visitedWhenExcluded.add,
            visitCppClass: visitedWhenExcluded.add,
            visitCppMethod: visitedWhenExcluded.add,
            visitObjCMethod: visitedWhenExcluded.add,
            visitField: visitedWhenExcluded.add,
            visitEnumConstant: visitedWhenExcluded.add,
            visitParam: visitedWhenExcluded.add,
          );

          (node as dynamic).isIncluded = false;
          node.accept(visitorExcluded);
          expect(
            visitedWhenExcluded,
            [same(node)],
            reason: '$name should NOT visit children when not included',
          );
        }
      },
    );

    test('CppMethod.accept visits its parameters when isIncluded is true', () {
      final context = testContext(
        FfiGenerator(output: Output(dartFile: Uri.file('out.dart'))),
      );

      final cppMethodInternal = CppMethod(
        name: Symbol('m1', SymbolKind.method),
        originalName: 'm1',
        returnType: voidType,
        parameters: [Parameter(name: 'p1', type: intType)],
        isConstant: false,
      );
      final cppClassInternal = CppClass(
        name: 'cppClass',
        originalName: 'cppClass',
        context: context,
        methods: [cppMethodInternal],
        fields: [],
      );
      final cppClass =
          cppClassInternal.toPublicAstNode() as public_ast.CppClass;
      final cppMethod = cppClass.methods.first;

      final visited = <public_ast.AstNode>[];
      final visitor = public_ast.Visitor(
        visitCppMethod: visited.add,
        visitParam: visited.add,
      );

      cppMethod.isIncluded = true;
      cppMethod.accept(visitor);
      expect(visited, [cppMethod, cppMethod.params.first]);
    });
  });
}
