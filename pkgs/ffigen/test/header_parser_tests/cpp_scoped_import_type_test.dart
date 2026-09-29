// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:ffigen/ffigen.dart';
import 'package:ffigen/src/code_generator.dart' as cg;
import 'package:ffigen/src/header_parser.dart' as parser;
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  group('cpp_scoped_import_type', () {
    late cg.Library library;
    final importedNames = <String>{};

    setUpAll(() {
      library = parser.parse(
        testContext(
          FfiGenerator(
            output: Output(dart: DartOutput(path: Uri.file('unused'))),
            input: Input(
              entryPoints: [
                Uri.file(
                  absPath('test/native_cpp_test/cpp_scoped_struct_test.h'),
                ),
                Uri.file(
                  absPath('test/native_cpp_test/cpp_namespace_enum_test.h'),
                ),
              ],
              compilerOptions: [
                '-x',
                'c++',
                '-std=c++17',
                if (Platform.isMacOS) ...['-isysroot', macSdkPath],
              ],
            ),
            importType: (declaration) {
              importedNames.add(declaration.originalName);
              // Replace one scoped struct to check the import takes effect.
              return declaration.originalName == 'outer::inner::Point'
                  ? cg.ImportedType(cg.ffiImport, 'Int32', 'int', 'int')
                  : null;
            },
            visitors: [
              Visitor(
                struct: (node) => node.isIncluded = true,
                union: (node) => node.isIncluded = true,
                enumClass: (node) => node.isIncluded = true,
              ),
            ],
          ),
        ),
      );
    });

    test('importType sees the qualified name of scoped records', () {
      expect(
        importedNames,
        containsAll([
          'GlobalBox',
          'GlobalBox::Lid',
          'outer::Point',
          'outer::inner::Point',
          'outer::Palette::Entry',
          'other::Point',
          'other::Value',
        ]),
      );
    });

    test('importType sees the qualified name of scoped enums', () {
      expect(
        importedNames,
        containsAll([
          'outer::Color',
          'outer::inner::Color',
          'outer::Palette::Tone',
          'other::Color',
          'GlobalPalette::Shade',
          'GlobalBox::State',
        ]),
      );
    });

    test('a scoped record matched by importType is not generated', () {
      final structNames = library.bindings
          .whereType<cg.Struct>()
          .map((s) => s.originalName)
          .toSet();
      expect(structNames, contains('outer::Point'));
      expect(structNames, isNot(contains('outer::inner::Point')));
    });
  });
}
