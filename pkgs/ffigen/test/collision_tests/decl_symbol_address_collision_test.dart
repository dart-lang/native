// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/config_provider/config.dart';
import 'package:ffigen/src/header_parser/parser.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';
import '../test_utils.dart';

late Library actual;
void main() {
  group('decl_symbol_address_collision_test', () {
    setUpAll(() {
      logWarnings(Level.SEVERE);
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
      actual = Library(
        context: context,
        name: 'Bindings',
        header:
            '// ignore_for_file: unused_element, camel_case_types, non_constant_identifier_names\n',
        bindings: transformBindings([
          Struct(context: context, name: 'addresses'),
          Struct(context: context, name: '_SymbolAddresses'),
          EnumClass(context: context, name: 'Bindings'),
          Func(
            name: '_library',
            returnType: NativeType(SupportedNativeType.voidType),
            exposeSymbolAddress: true,
            exposeFunctionTypedefs: true,
          ),
          Func(
            name: '_SymbolAddresses_1',
            returnType: NativeType(SupportedNativeType.voidType),
            exposeSymbolAddress: true,
          ),
        ], context),
      );
    });
    test('declaration and symbol address conflict', () {
      matchLibraryWithExpected(
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
