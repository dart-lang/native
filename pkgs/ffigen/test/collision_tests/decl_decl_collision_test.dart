// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/config_provider/config.dart';
import 'package:ffigen/src/header_parser/parser.dart';
import 'package:test/test.dart';
import '../test_utils.dart';

void main() {
  group('decl_decl_collision_test', () {
    test('declaration conflict', () {
      final context = testContext(
        FfiGenerator(
          output: Output(
            dartFile: Uri.file('unused'),
            style: const DynamicLibraryBindings(wrapperName: 'Bindings'),
          ),
          functions: Functions.includeAll,
          structs: Structs.includeAll,
          enums: Enums.includeAll,
          globals: Globals.includeAll,
          macros: Macros.includeAll,
          typedefs: Typedefs.includeAll,
        ),
      );
      final library = Library(
        context: context,
        bindings: transformBindings([
          Struct(context: context, name: 'TestStruct'),
          Struct(context: context, name: 'TestStruct'),
          EnumClass(context: context, name: 'TestEnum'),
          EnumClass(context: context, name: 'TestEnum'),
          Func(
            name: 'testFunc',
            returnType: NativeType(SupportedNativeType.voidType),
          ),
          Func(
            name: 'testFunc',
            returnType: NativeType(SupportedNativeType.voidType),
          ),
          MacroConstant(
            originalName: 'Test_Macro',
            name: 'Test_Macro',
            rawType: 'int',
            rawValue: '0',
          ),
          MacroConstant(
            originalName: 'Test_Macro',
            name: 'Test_Macro',
            rawType: 'int',
            rawValue: '0',
          ),
          Typealias(
            name: 'testAlias',
            type: NativeType(SupportedNativeType.voidType),
          ),
          Typealias(
            name: 'testAlias',
            type: NativeType(SupportedNativeType.voidType),
          ),

          /// Conflicts across declarations.
          Struct(context: context, name: 'testCrossDecl'),
          Func(
            name: 'testCrossDecl',
            returnType: NativeType(SupportedNativeType.voidType),
          ),
          MacroConstant(name: 'testCrossDecl', rawValue: '0', rawType: 'int'),
          EnumClass(context: context, name: 'testCrossDecl'),
          Typealias(
            name: 'testCrossDecl',
            type: NativeType(SupportedNativeType.voidType),
          ),

          /// Conflicts with ffi library prefix, name of prefix is changed.
          Struct(context: context, name: 'ffi'),
          Func(
            name: 'ffi\$1',
            returnType: NativeType(SupportedNativeType.voidType),
          ),
        ], context),
      );
      final context = testContext();
      matchLibraryWithExpected(
        context,
        library,
        'decl_decl_collision_test_output.dart',
        [
          'test',
          'collision_tests',
          'expected_bindings',
          '_expected_decl_decl_collision_bindings.dart',
        ],
      );
    });
  });
}
