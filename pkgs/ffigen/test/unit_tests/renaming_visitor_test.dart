// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/ffigen.dart'
    show CompoundDependencies, FfiGenerator, Output, YamlConfig;
import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/code_generator/scope.dart';
import 'package:ffigen/src/config_provider/config.dart';
import 'package:ffigen/src/config_provider/public_ast.dart' as public_ast;
import 'package:ffigen/src/header_parser/parser.dart';
import 'package:ffigen/src/header_parser/sub_parsers/api_availability.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

import '../test_utils.dart';

final class CustomRenamerVisitor extends public_ast.Visitor {
  CustomRenamerVisitor() : super.base();
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
      func.isIncluded = true;
      struct.isIncluded = true;
      enumClass.isIncluded = true;
      objcInterface.isIncluded = true;
      final nodes = rawBindings
          .map((b) => b.toPublicAstNode())
          .nonNulls
          .toList();

      expect(func.symbol.oldName, 'c_foo');
      expect(struct.symbol.oldName, 'c_struct');
      expect(struct.members[0].symbol.oldName, 'field_a');
      expect(enumClass.symbol.oldName, 'c_enum');
      expect(enumClass.enumConstants[0].symbol.oldName, 'K_VALUE_A');
      expect(objcInterface.symbol.oldName, 'MyClass');
      expect(objcMethod.symbol.oldName, 'compare');
      expect(objcMethod.params.elementAt(1).symbol.oldName, 'options');
      expect(objcMethod.params.elementAt(2).symbol.oldName, 'range');

      CustomRenamerVisitor().visitAll(nodes);

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

        final nodes = <Binding>[
          ObjCInterface(
            context: context,
            originalName: 'TestItf',
            name: 'TestItf',
            apiAvailability: ApiAvailability.all,
          )..addMethod(method),
        ].map((b) => b.toPublicAstNode()).nonNulls.toList();

        CustomRenamerVisitor().visitAll(nodes);

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

      final nodes = <Binding>[
        func,
        struct,
        objcInterface,
      ].map((b) => b.toPublicAstNode()).nonNulls.toList();
      generator.visitors.first.visitAll(nodes);

      expect(func.symbol.oldName, 'dart_func');
      expect(func.functionType.parameters[0].symbol.oldName, 'renamedParam1');

      expect(struct.symbol.oldName, 'MyStruct');
      expect(struct.members[0].symbol.oldName, 'newField');

      expect(objcInterface.symbol.oldName, 'NewClass');
      expect(objcMethod.symbol.oldName, 'customFoo:customBar:');
      expect(objcMethod.params.elementAt(1).symbol.oldName, 'bar');
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

      final nodes = rawBindings
          .map((b) => b.toPublicAstNode())
          .nonNulls
          .toList();

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

    test('Visitor callback-based factory constructor', () {
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

      final visitedFuncs = <String>[];
      final visitedStructs = <String>[];
      final visitedParams = <String>[];

      final visitor = public_ast.Visitor(
        func: (node) {
          visitedFuncs.add(node.name);
          if (node.name == 'c_foo') {
            node.name = 'dartFoo';
          }
        },
        struct: (node) {
          visitedStructs.add(node.name);
          if (node.name == 'c_struct') {
            node.name = 'DartStruct';
          }
        },
        param: (node) {
          visitedParams.add(node.name);
          if (node.name == 'arg_0') {
            node.name = 'renamedArg0';
          }
        },
      );

      final rawBindings = <Binding>[func, struct];
      func.isIncluded = true;
      struct.isIncluded = true;
      final nodes = rawBindings
          .map((b) => b.toPublicAstNode())
          .nonNulls
          .toList();
      visitor.visitAll(nodes);

      expect(visitedFuncs, ['c_foo']);
      expect(visitedStructs, ['c_struct']);
      expect(visitedParams, ['arg_0']);

      expect(func.symbol.oldName, 'dartFoo');
      expect(struct.symbol.oldName, 'DartStruct');
      expect(func.functionType.parameters[0].symbol.oldName, 'renamedArg0');
    });

    test('Parent and child pointers in public AST nodes', () {
      final context = testContext(
        FfiGenerator(output: Output(dartFile: Uri.file('out.dart'))),
      );

      final cgFunc = Func(
        name: 'my_func',
        originalName: 'my_func',
        returnType: voidType,
        parameters: [Parameter(name: 'p1', type: intType)],
      );
      final publicFunc = public_ast.Func(cgFunc);
      expect(publicFunc.params[0].parent, same(publicFunc));

      final cgStruct = Struct(
        name: 'my_struct',
        originalName: 'my_struct',
        context: context,
        members: [
          CompoundMember(name: 'f1', originalName: 'f1', type: intType),
        ],
      );
      final publicStruct = public_ast.Struct(cgStruct);
      expect(publicStruct.members[0].parent, same(publicStruct));

      final cgUnion = Union(
        name: 'my_union',
        originalName: 'my_union',
        context: context,
        members: [
          CompoundMember(name: 'u1', originalName: 'u1', type: intType),
        ],
      );
      final publicUnion = public_ast.Union(cgUnion);
      expect(publicUnion.members[0].parent, same(publicUnion));

      final cgEnum = EnumClass(
        name: 'my_enum',
        originalName: 'my_enum',
        context: context,
        enumConstants: [EnumConstant(name: 'C1', originalName: 'C1', value: 0)],
      );
      final publicEnum = public_ast.EnumClass(cgEnum);
      expect(publicEnum.constants[0].parent, same(publicEnum));

      final cgObjCMethod = ObjCMethod(
        context: context,
        originalName: 'doIt:',
        name: 'doIt:',
        kind: ObjCMethodKind.method,
        isClassMethod: false,
        isOptional: false,
        returnType: voidType,
        family: null,
        apiAvailability: ApiAvailability.all,
        params: [Parameter(name: 'arg1', type: intType)],
        ownershipAttribute: null,
        consumesSelfAttribute: false,
      );
      final cgObjCInterface = ObjCInterface(
        context: context,
        originalName: 'MyItf',
        name: 'MyItf',
        apiAvailability: ApiAvailability.all,
      )..addMethod(cgObjCMethod);
      final publicObjCInterface = public_ast.ObjCInterface(cgObjCInterface);
      expect(publicObjCInterface.methods[0].parent, same(publicObjCInterface));
      expect(
        publicObjCInterface.methods[0].params[0].parent,
        same(publicObjCInterface.methods[0]),
      );

      final cgObjCProtoMethod = ObjCMethod(
        context: context,
        originalName: 'protoMethod:',
        name: 'protoMethod:',
        kind: ObjCMethodKind.method,
        isClassMethod: false,
        isOptional: false,
        returnType: voidType,
        family: null,
        apiAvailability: ApiAvailability.all,
        params: [Parameter(name: 'pArg', type: intType)],
        ownershipAttribute: null,
        consumesSelfAttribute: false,
      );
      final cgObjCProtocol = ObjCProtocol(
        context: context,
        originalName: 'MyProto',
        name: 'MyProto',
        apiAvailability: ApiAvailability.all,
      )..addMethod(cgObjCProtoMethod);
      final publicObjCProtocol = public_ast.ObjCProtocol(cgObjCProtocol);
      expect(publicObjCProtocol.methods[0].parent, same(publicObjCProtocol));

      final cgObjCCatMethod = ObjCMethod(
        context: context,
        originalName: 'catMethod:',
        name: 'catMethod:',
        kind: ObjCMethodKind.method,
        isClassMethod: false,
        isOptional: false,
        returnType: voidType,
        family: null,
        apiAvailability: ApiAvailability.all,
        params: [Parameter(name: 'cArg', type: intType)],
        ownershipAttribute: null,
        consumesSelfAttribute: false,
      );
      final cgObjCCategory = ObjCCategory(
        context: context,
        originalName: 'MyCat',
        name: 'MyCat',
        parent: cgObjCInterface,
        apiAvailability: ApiAvailability.all,
      )..addMethod(cgObjCCatMethod);
      final publicObjCCategory = public_ast.ObjCCategory(cgObjCCategory);
      expect(publicObjCCategory.methods[0].parent, same(publicObjCCategory));
      expect(publicObjCCategory.interface.name, 'MyItf');

      final cgCppMethod = CppMethod(
        name: Symbol('cppFunc', SymbolKind.method),
        originalName: 'cppFunc',
        returnType: voidType,
        parameters: [Parameter(name: 'cppArg', type: intType)],
        isConstant: false,
      );
      final cgCppClass = CppClass(
        context: context,
        originalName: 'CppClass',
        name: 'CppClass',
        methods: [cgCppMethod],
        fields: [],
      );
      final publicCppClass = public_ast.CppClass(cgCppClass);
      expect(publicCppClass.methods[0].parent, same(publicCppClass));
      expect(
        publicCppClass.methods[0].params[0].parent,
        same(publicCppClass.methods[0]),
      );
    });

    test('EnumClass style and effectiveStyle', () {
      final context = testContext(
        FfiGenerator(output: Output(dartFile: Uri.file('out.dart'))),
      );

      final cgEnum = EnumClass(
        name: 'my_enum',
        originalName: 'my_enum',
        context: context,
      );
      final publicEnum = public_ast.EnumClass(cgEnum);

      // Verify style is null by default, effectiveStyle is dartEnum.
      expect(cgEnum.style, isNull);
      expect(cgEnum.effectiveStyle, EnumStyle.dartEnum);
      expect(publicEnum.style, isNull);

      // Setting style on publicEnum updates both.
      publicEnum.style = EnumStyle.intConstants;
      expect(publicEnum.style, EnumStyle.intConstants);
      expect(cgEnum.style, EnumStyle.intConstants);
      expect(cgEnum.effectiveStyle, EnumStyle.intConstants);

      // Resetting style to null.
      publicEnum.style = null;
      expect(publicEnum.style, isNull);
      expect(cgEnum.style, isNull);

      // Setting style on cgEnum updates both and effectiveStyle.
      cgEnum.style = EnumStyle.intConstants;
      expect(cgEnum.style, EnumStyle.intConstants);
      expect(publicEnum.style, EnumStyle.intConstants);
      expect(cgEnum.effectiveStyle, EnumStyle.intConstants);

      // Overriding style on publicEnum.
      publicEnum.style = EnumStyle.dartEnum;
      expect(publicEnum.style, EnumStyle.dartEnum);
      expect(cgEnum.style, EnumStyle.dartEnum);
      expect(cgEnum.effectiveStyle, EnumStyle.dartEnum);
    });

    test(
      'YamlConfigAstVisitor sets EnumClass.style when enumShouldBeInt is true',
      () {
        final yamlConfig = YamlConfig.fromYaml(
          loadYaml(r'''
output: 'unused.dart'
headers:
  entry-points:
    - 'unused.h'
enums:
  as-int:
    include:
      - 'MyIntEnum'
''')
              as YamlMap,
          createTestLogger(),
        );

        final generator = yamlConfig.configAdapter();
        final context = testContext(generator);

        final cgIntEnum = EnumClass(
          name: 'MyIntEnum',
          originalName: 'MyIntEnum',
          context: context,
        );
        final cgNormalEnum = EnumClass(
          name: 'MyNormalEnum',
          originalName: 'MyNormalEnum',
          context: context,
        );

        final nodes = <Binding>[
          cgIntEnum,
          cgNormalEnum,
        ].map((b) => b.toPublicAstNode()).nonNulls.toList();

        generator.visitors.first.visitAll(nodes);

        expect(
          (nodes[0] as public_ast.EnumClass).style,
          EnumStyle.intConstants,
        );
        expect((nodes[1] as public_ast.EnumClass).style, isNull);
        expect(cgNormalEnum.effectiveStyle, EnumStyle.dartEnum);
      },
    );

    test('EnumClass silenceWarning getter and setter', () {
      final context = testContext(
        FfiGenerator(output: Output(dartFile: Uri.file('out.dart'))),
      );

      final cgEnum = EnumClass(
        name: 'my_enum',
        originalName: 'my_enum',
        context: context,
      );
      final publicEnum = public_ast.EnumClass(cgEnum);

      expect(cgEnum.silenceWarning, false);
      expect(publicEnum.silenceWarning, false);

      publicEnum.silenceWarning = true;
      expect(publicEnum.silenceWarning, true);
      expect(cgEnum.silenceWarning, true);

      publicEnum.silenceWarning = false;
      expect(publicEnum.silenceWarning, false);
      expect(cgEnum.silenceWarning, false);
    });

    test('YamlConfigAstVisitor sets EnumClass.silenceWarning from config', () {
      final yamlConfig = YamlConfig.fromYaml(
        loadYaml(r'''
output: 'unused.dart'
headers:
  entry-points:
    - 'unused.h'
silence-enum-warning: true
''')
            as YamlMap,
        createTestLogger(),
      );

      final generator = yamlConfig.configAdapter();
      final context = testContext(generator);

      final cgEnum = EnumClass(
        name: 'MyEnum',
        originalName: 'MyEnum',
        context: context,
      );

      final nodes = <Binding>[
        cgEnum,
      ].map((b) => b.toPublicAstNode()).nonNulls.toList();

      generator.visitors.first.visitAll(nodes);

      expect((nodes[0] as public_ast.EnumClass).silenceWarning, true);
      expect(cgEnum.silenceWarning, true);
    });

    test('public_ast.Func.isLeaf getter and setter', () {
      final cgFunc = Func(
        name: 'c_foo',
        originalName: 'c_foo',
        returnType: voidType,
      );
      final publicFunc = public_ast.Func(cgFunc);

      expect(publicFunc.isLeaf, false);
      expect(cgFunc.isLeaf, false);

      publicFunc.isLeaf = true;
      expect(publicFunc.isLeaf, true);
      expect(cgFunc.isLeaf, true);

      publicFunc.isLeaf = false;
      expect(publicFunc.isLeaf, false);
      expect(cgFunc.isLeaf, false);
    });

    test('public_ast.Func.recordUse getter and setter', () {
      final cgFunc = Func(
        name: 'c_foo',
        originalName: 'c_foo',
        returnType: voidType,
      );
      final publicFunc = public_ast.Func(cgFunc);

      expect(publicFunc.recordUse, false);
      expect(cgFunc.recordUse, false);

      publicFunc.recordUse = true;
      expect(publicFunc.recordUse, true);
      expect(cgFunc.recordUse, true);

      publicFunc.recordUse = false;
      expect(publicFunc.recordUse, false);
      expect(cgFunc.recordUse, false);
    });

    test('YamlConfigAstVisitor sets Func.isLeaf from config', () {
      final yamlConfig = YamlConfig.fromYaml(
        loadYaml(r'''
output: 'unused.dart'
headers:
  entry-points:
    - 'unused.h'
functions:
  leaf:
    include:
      - 'leaf_func'
''')
            as YamlMap,
        createTestLogger(),
      );

      final generator = yamlConfig.configAdapter();
      final cgLeafFunc = Func(
        name: 'leaf_func',
        originalName: 'leaf_func',
        returnType: voidType,
      );
      final cgNormalFunc = Func(
        name: 'normal_func',
        originalName: 'normal_func',
        returnType: voidType,
      );

      final nodes = <Binding>[
        cgLeafFunc,
        cgNormalFunc,
      ].map((b) => b.toPublicAstNode()).nonNulls.toList();

      generator.visitors.first.visitAll(nodes);

      expect((nodes[0] as public_ast.Func).isLeaf, true);
      expect(cgLeafFunc.isLeaf, true);
      expect((nodes[1] as public_ast.Func).isLeaf, false);
      expect(cgNormalFunc.isLeaf, false);
    });

    test('public_ast.Struct.pack getter and setter', () {
      final context = testContext(
        FfiGenerator(output: Output(dartFile: Uri.file('out.dart'))),
      );
      final cgStruct = Struct(
        name: 'c_struct',
        originalName: 'c_struct',
        context: context,
      );
      final publicStruct = public_ast.Struct(cgStruct);

      expect(publicStruct.pack, isNull);
      expect(cgStruct.pack, isNull);

      publicStruct.pack = 4;
      expect(publicStruct.pack, 4);
      expect(cgStruct.pack, 4);

      publicStruct.pack = null;
      expect(publicStruct.pack, isNull);
      expect(cgStruct.pack, isNull);
    });

    test(
      'YamlConfigAstVisitor sets Struct.pack from config packing override',
      () {
        final yamlConfig = YamlConfig.fromYaml(
          loadYaml(r'''
output: 'unused.dart'
headers:
  entry-points:
    - 'unused.h'
structs:
  pack:
    'packed_struct': 4
''')
              as YamlMap,
          createTestLogger(),
        );

        final generator = yamlConfig.configAdapter();
        final context = testContext(generator);
        final cgPackedStruct = Struct(
          name: 'packed_struct',
          originalName: 'packed_struct',
          context: context,
        );
        final cgNormalStruct = Struct(
          name: 'normal_struct',
          originalName: 'normal_struct',
          context: context,
        );

        final nodes = <Binding>[
          cgPackedStruct,
          cgNormalStruct,
        ].map((b) => b.toPublicAstNode()).nonNulls.toList();

        generator.visitors.first.visitAll(nodes);

        expect((nodes[0] as public_ast.Struct).pack, 4);
        expect(cgPackedStruct.pack, 4);
        expect((nodes[1] as public_ast.Struct).pack, isNull);
        expect(cgNormalStruct.pack, isNull);
      },
    );

    test('public_ast.Func.exposeSymbolAddress getter and setter', () {
      final cgFunc = Func(
        name: 'c_foo',
        originalName: 'c_foo',
        returnType: voidType,
      );
      final publicFunc = public_ast.Func(cgFunc);

      expect(publicFunc.exposeSymbolAddress, false);
      expect(cgFunc.exposeSymbolAddress, false);

      publicFunc.exposeSymbolAddress = true;
      expect(publicFunc.exposeSymbolAddress, true);
      expect(cgFunc.exposeSymbolAddress, true);

      publicFunc.exposeSymbolAddress = false;
      expect(publicFunc.exposeSymbolAddress, false);
      expect(cgFunc.exposeSymbolAddress, false);
    });

    test('public_ast.Global.exposeSymbolAddress getter and setter', () {
      final cgGlobal = Global(
        name: 'c_global',
        originalName: 'c_global',
        type: intType,
      );
      final publicGlobal = public_ast.Global(cgGlobal);

      expect(publicGlobal.exposeSymbolAddress, false);
      expect(cgGlobal.exposeSymbolAddress, false);

      publicGlobal.exposeSymbolAddress = true;
      expect(publicGlobal.exposeSymbolAddress, true);
      expect(cgGlobal.exposeSymbolAddress, true);

      publicGlobal.exposeSymbolAddress = false;
      expect(publicGlobal.exposeSymbolAddress, false);
      expect(cgGlobal.exposeSymbolAddress, false);
    });

    test('YamlConfigAstVisitor sets Func.exposeSymbolAddress and '
        'Global.exposeSymbolAddress from config', () {
      final yamlConfig = YamlConfig.fromYaml(
        loadYaml(r'''
output: 'unused.dart'
headers:
  entry-points:
    - 'unused.h'
functions:
  symbol-address:
    include:
      - 'sym_func'
globals:
  symbol-address:
    include:
      - 'sym_global'
''')
            as YamlMap,
        createTestLogger(),
      );

      final generator = yamlConfig.configAdapter();
      final cgSymFunc = Func(
        name: 'sym_func',
        originalName: 'sym_func',
        returnType: voidType,
      );
      final cgNormalFunc = Func(
        name: 'normal_func',
        originalName: 'normal_func',
        returnType: voidType,
      );
      final cgSymGlobal = Global(
        name: 'sym_global',
        originalName: 'sym_global',
        type: intType,
      );
      final cgNormalGlobal = Global(
        name: 'normal_global',
        originalName: 'normal_global',
        type: intType,
      );

      final nodes = <Binding>[
        cgSymFunc,
        cgNormalFunc,
        cgSymGlobal,
        cgNormalGlobal,
      ].map((b) => b.toPublicAstNode()).nonNulls.toList();

      generator.visitors.first.visitAll(nodes);

      expect((nodes[0] as public_ast.Func).exposeSymbolAddress, true);
      expect(cgSymFunc.exposeSymbolAddress, true);
      expect((nodes[1] as public_ast.Func).exposeSymbolAddress, false);
      expect(cgNormalFunc.exposeSymbolAddress, false);

      expect((nodes[2] as public_ast.Global).exposeSymbolAddress, true);
      expect(cgSymGlobal.exposeSymbolAddress, true);
      expect((nodes[3] as public_ast.Global).exposeSymbolAddress, false);
      expect(cgNormalGlobal.exposeSymbolAddress, false);
    });

    test('public_ast.ObjCInterface.module getter and setter', () {
      final context = testContext(
        FfiGenerator(output: Output(dartFile: Uri.file('out.dart'))),
      );
      final cgInterface = ObjCInterface(
        context: context,
        originalName: 'MyClass',
        name: 'MyClass',
        apiAvailability: ApiAvailability.all,
      );
      final publicInterface = public_ast.ObjCInterface(cgInterface);

      expect(publicInterface.module, isNull);
      expect(cgInterface.module, isNull);

      publicInterface.module = 'MyModule';
      expect(publicInterface.module, 'MyModule');
      expect(cgInterface.module, 'MyModule');

      publicInterface.module = null;
      expect(publicInterface.module, isNull);
      expect(cgInterface.module, isNull);
    });

    test('public_ast.ObjCProtocol.module getter and setter', () {
      final context = testContext(
        FfiGenerator(output: Output(dartFile: Uri.file('out.dart'))),
      );
      final cgProtocol = ObjCProtocol(
        context: context,
        originalName: 'MyProtocol',
        name: 'MyProtocol',
        apiAvailability: ApiAvailability.all,
      );
      final publicProtocol = public_ast.ObjCProtocol(cgProtocol);

      expect(publicProtocol.module, isNull);
      expect(cgProtocol.module, isNull);

      publicProtocol.module = 'MyModule';
      expect(publicProtocol.module, 'MyModule');
      expect(cgProtocol.module, 'MyModule');

      publicProtocol.module = null;
      expect(publicProtocol.module, isNull);
      expect(cgProtocol.module, isNull);
    });

    test('YamlConfigAstVisitor sets ObjCInterface.module and '
        'ObjCProtocol.module from config', () {
      final yamlConfig = YamlConfig.fromYaml(
        loadYaml(r'''
output: 'unused.dart'
headers:
  entry-points:
    - 'unused.h'
objc-interfaces:
  module:
    'FooClass': 'FooModule'
objc-protocols:
  module:
    'BarProtocol': 'BarModule'
''')
            as YamlMap,
        createTestLogger(),
      );

      final generator = yamlConfig.configAdapter();
      final context = testContext(generator);

      final cgInterfaceMatch = ObjCInterface(
        context: context,
        originalName: 'FooClass',
        name: 'FooClass',
        apiAvailability: ApiAvailability.all,
      );
      final cgInterfaceNoMatch = ObjCInterface(
        context: context,
        originalName: 'OtherClass',
        name: 'OtherClass',
        apiAvailability: ApiAvailability.all,
      );
      final cgProtocolMatch = ObjCProtocol(
        context: context,
        originalName: 'BarProtocol',
        name: 'BarProtocol',
        apiAvailability: ApiAvailability.all,
      );
      final cgProtocolNoMatch = ObjCProtocol(
        context: context,
        originalName: 'OtherProtocol',
        name: 'OtherProtocol',
        apiAvailability: ApiAvailability.all,
      );

      final nodes = <Binding>[
        cgInterfaceMatch,
        cgInterfaceNoMatch,
        cgProtocolMatch,
        cgProtocolNoMatch,
      ].map((b) => b.toPublicAstNode()).nonNulls.toList();

      generator.visitors.first.visitAll(nodes);

      expect((nodes[0] as public_ast.ObjCInterface).module, 'FooModule');
      expect(cgInterfaceMatch.module, 'FooModule');
      expect((nodes[1] as public_ast.ObjCInterface).module, isNull);
      expect(cgInterfaceNoMatch.module, isNull);

      expect((nodes[2] as public_ast.ObjCProtocol).module, 'BarModule');
      expect(cgProtocolMatch.module, 'BarModule');
      expect((nodes[3] as public_ast.ObjCProtocol).module, isNull);
      expect(cgProtocolNoMatch.module, isNull);
    });

    test('public_ast.Struct.dependencies getter and setter', () {
      final context = testContext(
        FfiGenerator(output: Output(dartFile: Uri.file('out.dart'))),
      );
      final cgStruct = Struct(
        name: 'c_struct',
        originalName: 'c_struct',
        context: context,
      );
      final publicStruct = public_ast.Struct(cgStruct);

      expect(publicStruct.dependencies, CompoundDependencies.opaque);
      expect(cgStruct.dependencies, CompoundDependencies.opaque);

      publicStruct.dependencies = CompoundDependencies.full;
      expect(publicStruct.dependencies, CompoundDependencies.full);
      expect(cgStruct.dependencies, CompoundDependencies.full);

      publicStruct.dependencies = CompoundDependencies.opaque;
      expect(publicStruct.dependencies, CompoundDependencies.opaque);
      expect(cgStruct.dependencies, CompoundDependencies.opaque);
    });

    test('public_ast.Union.dependencies getter and setter', () {
      final context = testContext(
        FfiGenerator(output: Output(dartFile: Uri.file('out.dart'))),
      );
      final cgUnion = Union(
        name: 'c_union',
        originalName: 'c_union',
        context: context,
      );
      final publicUnion = public_ast.Union(cgUnion);

      expect(publicUnion.dependencies, CompoundDependencies.opaque);
      expect(cgUnion.dependencies, CompoundDependencies.opaque);

      publicUnion.dependencies = CompoundDependencies.full;
      expect(publicUnion.dependencies, CompoundDependencies.full);
      expect(cgUnion.dependencies, CompoundDependencies.full);

      publicUnion.dependencies = CompoundDependencies.opaque;
      expect(publicUnion.dependencies, CompoundDependencies.opaque);
      expect(cgUnion.dependencies, CompoundDependencies.opaque);
    });

    test('YamlConfigAstVisitor sets Struct.dependencies and '
        'Union.dependencies from config', () {
      final yamlConfig = YamlConfig.fromYaml(
        loadYaml(r'''
output: 'unused.dart'
headers:
  entry-points:
    - 'unused.h'
structs:
  dependency-only: full
unions:
  dependency-only: full
''')
            as YamlMap,
        createTestLogger(),
      );

      final generator = yamlConfig.configAdapter();
      final context = testContext(generator);

      final cgStruct = Struct(
        name: 'my_struct',
        originalName: 'my_struct',
        context: context,
      );
      final cgUnion = Union(
        name: 'my_union',
        originalName: 'my_union',
        context: context,
      );

      final nodes = <Binding>[
        cgStruct,
        cgUnion,
      ].map((b) => b.toPublicAstNode()).nonNulls.toList();

      generator.visitors.first.visitAll(nodes);

      expect(
        (nodes[0] as public_ast.Struct).dependencies,
        CompoundDependencies.full,
      );
      expect(cgStruct.dependencies, CompoundDependencies.full);

      expect(
        (nodes[1] as public_ast.Union).dependencies,
        CompoundDependencies.full,
      );
      expect(cgUnion.dependencies, CompoundDependencies.full);
    });

    test('User-defined AST visitors do not see internal nodes', () {
      final visitedNames = <String>[];
      final recordingVisitor = public_ast.Visitor(
        func: (node) => visitedNames.add(node.name),
        struct: (node) => visitedNames.add(node.name),
        typealias: (node) => visitedNames.add(node.name),
        objCInterface: (node) => visitedNames.add(node.name),
      );

      final context = testContext(
        FfiGenerator(
          output: Output(dartFile: Uri.file('out.dart')),
          visitors: [recordingVisitor],
        ),
      );

      final publicFunc = Func(
        name: 'public_func',
        originalName: 'public_func',
        returnType: voidType,
      );
      final publicStruct = Struct(
        name: 'public_struct',
        originalName: 'public_struct',
        context: context,
      );
      final publicTypealias = Typealias(
        name: 'public_typealias',
        type: intType,
      );
      final publicObjCInterface = ObjCInterface(
        context: context,
        originalName: 'PublicInterface',
        name: 'PublicInterface',
        apiAvailability: ApiAvailability.all,
      );

      final internalFunc = Func(
        name: 'internal_func',
        originalName: 'internal_func',
        returnType: voidType,
        isInternal: true,
      );
      final internalTypealias = Typealias(
        name: 'internal_typealias',
        type: intType,
        isInternal: true,
      );
      final internalObjCInterface = ObjCInterface(
        context: context,
        originalName: 'InternalInterface',
        name: 'InternalInterface',
        apiAvailability: ApiAvailability.all,
        isInternal: true,
      );

      final rawBindings = <Binding>[
        publicFunc,
        publicStruct,
        publicTypealias,
        publicObjCInterface,
        internalFunc,
        internalTypealias,
        internalObjCInterface,
      ];

      transformBindings(rawBindings, context);

      expect(visitedNames, contains('public_func'));
      expect(visitedNames, contains('public_struct'));
      expect(visitedNames, contains('public_typealias'));
      expect(visitedNames, contains('PublicInterface'));

      expect(visitedNames, isNot(contains('internal_func')));
      expect(visitedNames, isNot(contains('internal_typealias')));
      expect(visitedNames, isNot(contains('InternalInterface')));
    });
  });
}
