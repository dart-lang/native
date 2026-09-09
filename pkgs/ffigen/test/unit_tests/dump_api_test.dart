// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:ffigen/ffigen.dart'
    show ApiDumperVisitor, DartOutput, FfiGenerator, Input, Output;
import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/code_generator/scope.dart';
import 'package:ffigen/src/header_parser/sub_parsers/api_availability.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  group('ApiDumperVisitor Tests', () {
    test('Synthetic public AST node dumping', () {
      final context = testContext();

      final func = Func(
        usr: 'c:@F@my_func',
        name: 'my_func',
        originalName: 'my_func',
        returnType: voidType,
        parameters: [Parameter(name: 'arg_0', type: intType)],
      );

      final struct = Struct(
        usr: 'c:@S@my_struct',
        name: 'my_struct',
        originalName: 'my_struct',
        context: context,
        members: [
          CompoundMember(
            name: 'field_x',
            originalName: 'field_x',
            type: intType,
          ),
        ],
      );

      final union = Union(
        usr: 'c:@U@my_union',
        name: 'my_union',
        originalName: 'my_union',
        context: context,
        members: [
          CompoundMember(
            name: 'u_field',
            originalName: 'u_field',
            type: floatType,
          ),
        ],
      );

      final enumClass = EnumClass(
        usr: 'c:@E@my_enum',
        name: 'my_enum',
        originalName: 'my_enum',
        context: context,
        enumConstants: [
          EnumConstant(name: 'VAL_A', originalName: 'VAL_A', value: 1),
        ],
      );

      final global = Global(
        usr: 'c:@my_global',
        name: 'my_global',
        originalName: 'my_global',
        type: intType,
      );

      final macro = MacroConstant(
        usr: 'c:@macro@MY_MACRO',
        name: 'MY_MACRO',
        originalName: 'MY_MACRO',
        rawType: 'int',
        rawValue: '123',
      );

      final typealias = Typealias(
        usr: 'c:@T@my_alias',
        name: 'my_alias',
        originalName: 'my_alias',
        type: intType,
      );

      final rawBindings = <Binding>[
        func,
        struct,
        union,
        enumClass,
        global,
        macro,
        typealias,
      ];

      final nodes = rawBindings
          .map((b) => b.toPublicAstNode())
          .nonNulls
          .toList();

      final dumped = ApiDumperVisitor.dump(nodes);

      expect(dumped, '''
Func(my_func, c:@F@my_func)
Param(arg_0, Func(my_func, c:@F@my_func))
Struct(my_struct, c:@S@my_struct)
Field(field_x, Struct(my_struct, c:@S@my_struct))
Union(my_union, c:@U@my_union)
Field(u_field, Union(my_union, c:@U@my_union))
EnumClass(my_enum, c:@E@my_enum)
EnumConstant(VAL_A, EnumClass(my_enum, c:@E@my_enum))
Global(my_global, c:@my_global)
MacroConstant(MY_MACRO, c:@macro@MY_MACRO)
Typealias(my_alias, c:@T@my_alias)
''');
    });

    test('Synthetic ObjC and C++ public AST node dumping', () {
      final context = testContext();

      final objcMethod = ObjCMethod(
        context: context,
        originalName: 'myMethod:',
        name: 'myMethod:',
        kind: ObjCMethodKind.method,
        isClassMethod: false,
        isOptional: false,
        returnType: voidType,
        family: null,
        apiAvailability: ApiAvailability.all,
        params: [Parameter(name: 'arg', type: intType)],
        ownershipAttribute: null,
        consumesSelfAttribute: false,
      );

      final objcInterface = ObjCInterface(
        context: context,
        usr: 'c:objc(cs)MyClass',
        originalName: 'MyClass',
        name: 'MyClass',
        apiAvailability: ApiAvailability.all,
      )..addMethod(objcMethod);

      final objcCategory = ObjCCategory(
        context: context,
        usr: 'c:objc(cy)MyClass@MyCategory',
        originalName: 'MyCategory',
        name: 'MyCategory',
        apiAvailability: ApiAvailability.all,
        parent: objcInterface,
      );

      final cppMethod = CppMethod(
        name: Symbol('cppFunc', SymbolKind.method),
        originalName: 'cppFunc',
        returnType: voidType,
        parameters: [Parameter(name: 'cppArg', type: intType)],
        isConstant: false,
      );

      final cppClass = CppClass(
        context: context,
        usr: 'c:@S@MyCppClass',
        originalName: 'MyCppClass',
        name: 'MyCppClass',
        methods: [cppMethod],
        fields: [],
      );

      final rawBindings = <Binding>[objcInterface, objcCategory, cppClass];

      final nodes = rawBindings
          .map((b) => b.toPublicAstNode())
          .nonNulls
          .toList();

      final dumped = ApiDumperVisitor.dump(nodes);

      expect(dumped, '''
ObjCInterface(MyClass, c:objc(cs)MyClass)
ObjCMethod(myMethod:, ObjCInterface(MyClass, c:objc(cs)MyClass))
Param(arg, ObjCMethod(myMethod:, ObjCInterface(MyClass, c:objc(cs)MyClass)))
ObjCCategory(MyCategory, c:objc(cy)MyClass@MyCategory, ObjCInterface(MyClass, c:objc(cs)MyClass))
CppClass(MyCppClass, c:@S@MyCppClass)
CppMethod(cppFunc, CppClass(MyCppClass, c:@S@MyCppClass))
Param(cppArg, CppMethod(cppFunc, CppClass(MyCppClass, c:@S@MyCppClass)))
''');
    });

    test('dumpApi extension method parses header and dumps AST', () async {
      final tempDir = Directory.systemTemp.createTempSync('dump_api_test_');
      addTearDown(() => tempDir.deleteSync(recursive: true));

      final header = File('${tempDir.path}/test.h');
      header.writeAsStringSync('''
        void calculate(int count);
        struct Point { int x; int y; };
        enum Direction { UP, DOWN };
      ''');

      final generator = FfiGenerator(
        output: Output(
          dart: DartOutput(path: Uri.file('${tempDir.path}/out.dart')),
        ),
        input: Input(entryPoints: [header.uri]),
      );

      final output = await generator.dumpApi();

      expect(output, contains('Func(calculate,'));
      expect(output, contains('Param(count, Func(calculate,'));
      expect(output, contains('Struct(Point,'));
      expect(output, contains('Field(x, Struct(Point,'));
      expect(output, contains('Field(y, Struct(Point,'));
      expect(output, contains('EnumClass(Direction,'));
      expect(output, contains('EnumConstant(UP, EnumClass(Direction,'));
      expect(output, contains('EnumConstant(DOWN, EnumClass(Direction,'));

      // Verify that out.dart was NOT created (dumpApi does not generate files)
      expect(File('${tempDir.path}/out.dart').existsSync(), isFalse);
    });
  });
}
