// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/config_provider/config.dart';
import 'package:ffigen/src/config_provider/public_ast.dart' as public_ast;
import 'package:ffigen/src/header_parser/parser.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  group('struct_member_toplevel_func_collision_test', () {
    test('struct member does not conflict with top-level function', () async {
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
            ),
          ],
        ),
      );

      final struct = Struct(
        context: context,
        name: 'JniEnv',
        members: [
          CompoundMember(
            name: 'FindClass',
            type: PointerType(
              NativeFunc(
                FunctionType(
                  returnType: NativeType(SupportedNativeType.voidType),
                  parameters: [],
                ),
              ),
            ),
          ),
        ],
      );
      final func = Func(
        name: 'FindClass',
        returnType: NativeType(SupportedNativeType.voidType),
      );

      final library = Library(
        context: context,
        bindings: transformBindings([func, struct], context),
      );

      expect(struct.members.first.name, 'FindClass');
      expect(func.name, 'FindClass');

      await matchLibraryWithExpected(
        context,
        library,
        'struct_member_toplevel_func_collision_test_output.dart',
        [
          'test',
          'collision_tests',
          'expected_bindings',
          '_expected_struct_member_toplevel_func_collision_bindings.dart',
        ],
      );
    });
  });
}
