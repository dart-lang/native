// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/ffigen.dart' show FfiGenerator, Output, YamlConfig;
import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/header_parser/sub_parsers/api_availability.dart';
import 'package:ffigen/src/public_ast.dart' as public_ast;
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

import '../test_utils.dart';

class CustomRenamerVisitor extends public_ast.Visitor {
  @override
  void visitFunc(public_ast.Func node) {
    if (node.originalName == 'c_foo') {
      node.name = 'dartFoo';
    }
    super.visitFunc(node);
  }

  @override
  void visitStruct(public_ast.Struct node) {
    if (node.originalName == 'c_struct') {
      node.name = 'DartStruct';
    }
    super.visitStruct(node);
  }

  @override
  void visitField(public_ast.Field node) {
    if (node.originalName == 'field_a') {
      node.name = 'renamedFieldA';
    }
  }

  @override
  void visitEnum(public_ast.EnumClass node) {
    if (node.originalName == 'c_enum') {
      node.name = 'DartEnum';
    }
    super.visitEnum(node);
  }

  @override
  void visitEnumConstant(public_ast.EnumConstant node) {
    if (node.originalName == 'K_VALUE_A') {
      node.name = 'valueA';
    }
  }

  @override
  void visitObjCInterface(public_ast.ObjCInterface node) {
    if (node.originalName == 'MyClass') {
      node.name = 'RenamedMyClass';
    }
    super.visitObjCInterface(node);
  }

  @override
  void visitObjCMethod(public_ast.ObjCMethod node) {
    if (node.selector == 'compare:options:range:') {
      node.name = 'customCompare';
      node.params[1].name = 'customOptions';
      node.params[2].name = 'customRange';
    }
  }
}

void main() {
  group('RenamingVisitor Tests', () {
    test('Top-level and member renames via Custom Visitor', () {
      final context = testContext(
        FfiGenerator(output: Output(dartFile: Uri.file('out.dart'))),
      );

      final func = Func(
        name: 'c_foo',
        originalName: 'c_foo',
        returnType: voidType,
        parameters: [Parameter(name: 'arg_0', type: intType)],
      );

      final struct = Struct(
        name: 'c_struct',
        originalName: 'c_struct',
        context: context,
        members: [
          CompoundMember(
            name: 'field_a',
            originalName: 'field_a',
            type: intType,
          ),
        ],
      );

      final enumClass = EnumClass(
        name: 'c_enum',
        originalName: 'c_enum',
        context: context,
        enumConstants: [
          EnumConstant(name: 'K_VALUE_A', originalName: 'K_VALUE_A', value: 0),
        ],
      );

      final objcMethod = ObjCMethod(
        context: context,
        originalName: 'compare:options:range:',
        name: 'compare:options:range:',
        kind: ObjCMethodKind.method,
        isClassMethod: false,
        isOptional: false,
        returnType: intType,
        family: null,
        apiAvailability: ApiAvailability.all,
        params: [
          Parameter(name: 'str', type: intType),
          Parameter(name: 'opts', type: intType),
          Parameter(name: 'rng', type: intType),
        ],
        ownershipAttribute: null,
        consumesSelfAttribute: false,
      );

      final objcInterface = ObjCInterface(
        context: context,
        originalName: 'MyClass',
        name: 'MyClass',
        apiAvailability: ApiAvailability.all,
      )..addMethod(objcMethod);

      final rawBindings = <Binding>[func, struct, enumClass, objcInterface];
      final publicAst = public_ast.PublicAst(rawBindings);

      expect(func.symbol.oldName, 'c_foo');
      expect(struct.symbol.oldName, 'c_struct');
      expect(struct.members[0].symbol.oldName, 'field_a');
      expect(enumClass.symbol.oldName, 'c_enum');
      expect(enumClass.enumConstants[0].symbol.oldName, 'K_VALUE_A');
      expect(objcInterface.symbol.oldName, 'MyClass');
      expect(objcMethod.symbol.oldName, 'compare');
      expect(objcMethod.params.elementAt(1).symbol.oldName, 'options');
      expect(objcMethod.params.elementAt(2).symbol.oldName, 'range');

      publicAst.accept(CustomRenamerVisitor());

      expect(func.symbol.oldName, 'dartFoo');
      expect(struct.symbol.oldName, 'DartStruct');
      expect(struct.members[0].symbol.oldName, 'renamedFieldA');
      expect(enumClass.symbol.oldName, 'DartEnum');
      expect(enumClass.enumConstants[0].symbol.oldName, 'valueA');
      expect(objcInterface.symbol.oldName, 'RenamedMyClass');
      expect(objcMethod.symbol.oldName, 'customCompare');
      expect(objcMethod.params.elementAt(1).symbol.oldName, 'customOptions');
      expect(objcMethod.params.elementAt(2).symbol.oldName, 'customRange');
    });

    test(
      'ObjC method selector splitting in constructor and visitor overrides',
      () {
        final context = testContext(
          FfiGenerator(output: Output(dartFile: Uri.file('out.dart'))),
        );

        final method = ObjCMethod(
          context: context,
          originalName: 'doSomething:withArg:andOther:',
          name: 'doSomething:withArg:andOther:',
          kind: ObjCMethodKind.method,
          isClassMethod: false,
          isOptional: false,
          returnType: voidType,
          family: null,
          apiAvailability: ApiAvailability.all,
          params: [
            Parameter(name: 'a', type: intType),
            Parameter(name: 'b', type: intType),
            Parameter(name: 'c', type: intType),
          ],
          ownershipAttribute: null,
          consumesSelfAttribute: false,
        );

        expect(method.originalName, 'doSomething:withArg:andOther:');
        expect(method.symbol.oldName, 'doSomething');
        expect(method.params.elementAt(0).symbol.oldName, 'a');
        expect(method.params.elementAt(1).symbol.oldName, 'withArg');
        expect(method.params.elementAt(2).symbol.oldName, 'andOther');

        final publicAst = public_ast.PublicAst([
          ObjCInterface(
            context: context,
            originalName: 'TestItf',
            name: 'TestItf',
            apiAvailability: ApiAvailability.all,
          )..addMethod(method),
        ]);

        publicAst.accept(CustomRenamerVisitor());

        expect(method.symbol.oldName, 'doSomething');
        expect(method.params.elementAt(1).symbol.oldName, 'withArg');
      },
    );

    test('YamlConfigAstVisitor exact, regex, and member renames', () {
      final yamlConfig = YamlConfig.fromYaml(
        loadYaml(r'''
output: 'unused.dart'
headers:
  entry-points:
    - 'unused.h'
functions:
  rename:
    'c_(.*)': 'dart_$1'
  member-rename:
    'c_func':
      'param1': 'renamedParam1'
structs:
  rename:
    'my_struct': 'MyStruct'
  member-rename:
    'my_struct':
      'old_field': 'newField'
objc-interfaces:
  rename:
    'OldClass': 'NewClass'
  member-rename:
    'OldClass':
      'foo:bar:': 'customFoo:customBar:'
''')
            as YamlMap,
        createTestLogger(),
      );

      final generator = yamlConfig.configAdapter();
      expect(generator.visitors.length, 1);

      final context = testContext(generator);

      final func = Func(
        name: 'c_func',
        originalName: 'c_func',
        returnType: voidType,
        parameters: [Parameter(name: 'param1', type: intType)],
      );

      final struct = Struct(
        name: 'my_struct',
        originalName: 'my_struct',
        context: context,
        members: [
          CompoundMember(
            name: 'old_field',
            originalName: 'old_field',
            type: intType,
          ),
        ],
      );

      final objcMethod = ObjCMethod(
        context: context,
        originalName: 'foo:bar:',
        name: 'foo:bar:',
        kind: ObjCMethodKind.method,
        isClassMethod: false,
        isOptional: false,
        returnType: voidType,
        family: null,
        apiAvailability: ApiAvailability.all,
        params: [
          Parameter(name: 'a', type: intType),
          Parameter(name: 'b', type: intType),
        ],
        ownershipAttribute: null,
        consumesSelfAttribute: false,
      );

      final objcInterface = ObjCInterface(
        context: context,
        originalName: 'OldClass',
        name: 'OldClass',
        apiAvailability: ApiAvailability.all,
      )..addMethod(objcMethod);

      final publicAst = public_ast.PublicAst([func, struct, objcInterface]);
      publicAst.accept(generator.visitors.first);

      expect(func.symbol.oldName, 'dart_func');
      expect(func.functionType.parameters[0].symbol.oldName, 'renamedParam1');

      expect(struct.symbol.oldName, 'MyStruct');
      expect(struct.members[0].symbol.oldName, 'newField');

      expect(objcInterface.symbol.oldName, 'NewClass');
      expect(objcMethod.symbol.oldName, 'customFoo');
      expect(objcMethod.params.elementAt(1).symbol.oldName, 'customBar');
    });
  });
}
