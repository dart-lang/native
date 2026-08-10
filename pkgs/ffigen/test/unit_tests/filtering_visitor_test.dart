// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/ffigen.dart' show FfiGenerator, Output, YamlConfig;
import 'package:ffigen/src/code_generator.dart';
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
    if (node.originalName == 'excluded_func') {
      node.isIncluded = false;
    }
  }

  @override
  void visitStruct(public_ast.Struct node) {
    if (node.originalName == 'excluded_struct') {
      node.isIncluded = false;
    }
  }

  @override
  void visitUnion(public_ast.Union node) {
    if (node.originalName == 'excluded_union') {
      node.isIncluded = false;
    }
  }

  @override
  void visitEnum(public_ast.EnumClass node) {
    if (node.originalName == 'excluded_enum') {
      node.isIncluded = false;
    }
  }

  @override
  void visitGlobal(public_ast.Global node) {
    if (node.originalName == 'excluded_global') {
      node.isIncluded = false;
    }
  }

  @override
  void visitMacro(public_ast.MacroConstant node) {
    if (node.originalName == 'EXCLUDED_MACRO') {
      node.isIncluded = false;
    }
  }

  @override
  void visitTypealias(public_ast.Typealias node) {
    if (node.originalName == 'excluded_typedef') {
      node.isIncluded = false;
    }
  }

  @override
  void visitObjCInterface(public_ast.ObjCInterface node) {
    if (node.originalName == 'ExcludedInterface') {
      node.isIncluded = false;
    }
  }

  @override
  void visitObjCProtocol(public_ast.ObjCProtocol node) {
    if (node.originalName == 'ExcludedProtocol') {
      node.isIncluded = false;
    }
  }

  @override
  void visitObjCCategory(public_ast.ObjCCategory node) {
    if (node.originalName == 'ExcludedCategory') {
      node.isIncluded = false;
    }
  }

  @override
  void visitCppClass(public_ast.CppClass node) {
    if (node.originalName == 'ExcludedCppClass') {
      node.isIncluded = false;
    }
  }

  @override
  void visitUnnamedEnumConstant(public_ast.UnnamedEnumConstant node) {
    if (node.originalName == 'EXCLUDED_UNNAMED_ENUM') {
      node.isIncluded = false;
    }
  }

  @override
  void visitObjCMethod(public_ast.ObjCMethod node) {
    if (node.originalName == 'excludedMethod') {
      node.isIncluded = false;
    }
  }
}

void main() {
  group('FilteringVisitor Tests', () {
    test('isIncluded defaults to true on Bindings and ObjCMethod', () {
      final context = testContext(
        FfiGenerator(output: Output(dartFile: Uri.file('out.dart'))),
      );

      final func = Func(
        name: 'my_func',
        originalName: 'my_func',
        returnType: voidType,
      );
      expect(func.isIncluded, isTrue);

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
      expect(method.isIncluded, isTrue);
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
''') as YamlMap,
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
  });
}
