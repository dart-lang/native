// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/config_provider/config.dart';
import 'package:ffigen/src/config_provider/public_ast.dart' as public_ast;
import 'package:ffigen/src/header_parser/parser.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

late Library actual;
void main() {
  group('decl_symbol_address_collision_test', () {
    setUpAll(() {
      final context = testContext(
        FfiGenerator(
          output: Output(
            dart: DartOutput(path: Uri.file('unused')),
            style: const DynamicLibraryBindings(wrapperName: 'Bindings'),
          ),
          visitors: [
            public_ast.Visitor(
              func: (node) => node.isIncluded = true,
              struct: (node) => node.isIncluded = true,
              enumClass: (node) => node.isIncluded = true,
              global: (node) => node.isIncluded = true,
              macroConstant: (node) => node.isIncluded = true,
              typealias: (node) => node.isIncluded = .always,
            ),
          ],
        ),
      );
      actual = Library(
        context: context,
        header: '// ignore_for_file: unused_element\n',
        bindings: transformBindings([
          Struct(context: context, name: 'addresses'),
          Struct(context: context, name: '_SymbolAddresses'),
          EnumClass(context: context, name: 'Bindings'),
          Func(
            name: '_library',
            returnType: NativeType(SupportedNativeType.voidType),
            exposeSymbolAddress: true,
            generateTypedefs: true,
          ),
          Func(
            name: '_SymbolAddresses_1',
            returnType: NativeType(SupportedNativeType.voidType),
            exposeSymbolAddress: true,
          ),
        ], context),
      );
    });
    test('declaration and symbol address conflict', () async {
      final context = testContext();
      await matchLibraryWithExpected(
        context,
        actual,
        'collision_test_decl_symbol_address_collision_output.dart',
        [
          'test',
          'collision_tests',
          'expected_bindings',
          '_expected_decl_symbol_address_collision_bindings.dart',
        ],
      );
    });
  });
}
