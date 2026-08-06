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
    if (node.name == 'c_foo') {
      node.name = 'dartFoo';
    }
    super.visitFunc(node);
  }

  @override
  void visitStruct(public_ast.Struct node) {
    if (node.name == 'c_struct') {
      node.name = 'DartStruct';
    }
    super.visitStruct(node);
  }

  @override
  void visitField(public_ast.Field node) {
    if (node.name == 'field_a') {
      node.name = 'renamedFieldA';
    }
  }

  @override
  void visitEnum(public_ast.EnumClass node) {
    if (node.name == 'c_enum') {
      node.name = 'DartEnum';
    }
    super.visitEnum(node);
  }

  @override
  void visitEnumConstant(public_ast.EnumConstant node) {
    if (node.name == 'K_VALUE_A') {
      node.name = 'valueA';
    }
  }

  @override
  void visitObjCInterface(public_ast.ObjCInterface node) {
    if (node.name == 'MyClass') {
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

  @override
  void visitParam(public_ast.Param node) {
    if (node.name == 'arg_0') {
      node.name = 'renamedArg0';
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

    test('Public AST nodes expose usr getter', () {
      final context = testContext(
        FfiGenerator(output: Output(dartFile: Uri.file('out.dart'))),
      );

      final func = Func(
        usr: 'c_foo_usr',
        name: 'c_foo',
        originalName: 'c_foo',
        returnType: voidType,
      );
      final struct = Struct(
        usr: 'c_struct_usr',
        name: 'c_struct',
        originalName: 'c_struct',
        context: context,
      );
      final union = Union(
        usr: 'c_union_usr',
        name: 'c_union',
        originalName: 'c_union',
        context: context,
      );
      final enumClass = EnumClass(
        usr: 'c_enum_usr',
        name: 'c_enum',
        originalName: 'c_enum',
        context: context,
      );
      final global = Global(
        usr: 'c_global_usr',
        name: 'c_global',
        originalName: 'c_global',
        type: intType,
      );
      final macro = MacroConstant(
        usr: 'c_macro_usr',
        name: 'c_macro',
        originalName: 'c_macro',
        rawType: 'int',
        rawValue: '42',
      );
      final typealias = Typealias(
        usr: 'c_typealias_usr',
        name: 'c_typealias',
        type: intType,
      );
      final objcInterface = ObjCInterface(
        usr: 'c_interface_usr',
        context: context,
        originalName: 'MyClass',
        name: 'MyClass',
        apiAvailability: ApiAvailability.all,
      );
      final objcProtocol = ObjCProtocol(
        usr: 'c_protocol_usr',
        context: context,
        originalName: 'MyProto',
        name: 'MyProto',
        apiAvailability: ApiAvailability.all,
      );
      final objcCategory = ObjCCategory(
        usr: 'c_category_usr',
        context: context,
        originalName: 'MyCat',
        name: 'MyCat',
        parent: objcInterface,
        apiAvailability: ApiAvailability.all,
      );
      final cppClass = CppClass(
        usr: 'c_cppclass_usr',
        name: 'CppClass',
        originalName: 'CppClass',
        context: context,
        methods: [],
        fields: [],
      );
      final unnamedEnumConst = UnnamedEnumConstant(
        usr: 'c_unnamed_usr',
        name: 'c_unnamed',
        originalName: 'c_unnamed',
        rawType: 'int',
        rawValue: '0',
      );

      final rawBindings = <Binding>[
        func,
        struct,
        union,
        enumClass,
        global,
        macro,
        typealias,
        objcInterface,
        objcProtocol,
        objcCategory,
        cppClass,
        unnamedEnumConst,
      ];

      final publicAst = public_ast.PublicAst(rawBindings);
      final nodes = publicAst.nodes;

      expect((nodes[0] as public_ast.Func).usr, 'c_foo_usr');
      expect((nodes[1] as public_ast.Struct).usr, 'c_struct_usr');
      expect((nodes[2] as public_ast.Union).usr, 'c_union_usr');
      expect((nodes[3] as public_ast.EnumClass).usr, 'c_enum_usr');
      expect((nodes[4] as public_ast.Global).usr, 'c_global_usr');
      expect((nodes[5] as public_ast.MacroConstant).usr, 'c_macro_usr');
      expect((nodes[6] as public_ast.Typealias).usr, 'c_typealias_usr');
      expect((nodes[7] as public_ast.ObjCInterface).usr, 'c_interface_usr');
      expect((nodes[8] as public_ast.ObjCProtocol).usr, 'c_protocol_usr');
      expect((nodes[9] as public_ast.ObjCCategory).usr, 'c_category_usr');
      expect((nodes[10] as public_ast.CppClass).usr, 'c_cppclass_usr');
      expect(
        (nodes[11] as public_ast.UnnamedEnumConstant).usr,
        'c_unnamed_usr',
      );
    });
  });
}
