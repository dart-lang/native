// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/header_parser.dart' as parser;
import 'package:ffigen/src/strings.dart' as strings;
import 'package:test/test.dart';

import '../test_utils.dart';

late Library actual, expected;

void main() {
  group('globals_test', () {
    setUpAll(() {
      logWarnings();
      expected = expectedLibrary();
      actual = parser.parse(
        testConfig('''
${strings.name}: 'NativeLibrary'
${strings.description}: 'Globals Test'
${strings.output}: 'unused'
${strings.headers}:
  ${strings.entryPoints}:
    - 'test/header_parser_tests/globals.h'
  ${strings.includeDirectives}:
    - '**globals.h'
${strings.globals}:
  ${strings.exclude}:
    - GlobalIgnore
  ${strings.symbolAddress}:
    ${strings.include}:
      - myInt
      - pointerToLongDouble
      - globalStruct
${strings.compilerOpts}: '-Wno-nullability-completeness'
${strings.ignoreSourceErrors}: true
        '''),
      );
    });

    test('Total bindings count', () {
      expect(actual.bindings.length, expected.bindings.length);
    });

    test('Parse global Values', () {
      expect(actual.getBindingAsString('coolGlobal'),
          expected.getBindingAsString('coolGlobal'));
      expect(actual.getBindingAsString('myInt'),
          expected.getBindingAsString('myInt'));
      expect(actual.getBindingAsString('aGlobalPointer0'),
          expected.getBindingAsString('aGlobalPointer0'));
      expect(actual.getBindingAsString('aGlobalPointer1'),
          expected.getBindingAsString('aGlobalPointer1'));
      expect(actual.getBindingAsString('aGlobalPointer2'),
          expected.getBindingAsString('aGlobalPointer2'));
      expect(actual.getBindingAsString('aGlobalPointer3'),
          expected.getBindingAsString('aGlobalPointer3'));
    });

    test('Ignore global values', () {
      expect(() => actual.getBindingAsString('GlobalIgnore'),
          throwsA(const TypeMatcher<NotFoundException>()));
      expect(() => actual.getBindingAsString('longDouble'),
          throwsA(const TypeMatcher<NotFoundException>()));
      expect(() => actual.getBindingAsString('pointerToLongDouble'),
          throwsA(const TypeMatcher<NotFoundException>()));
    });

    test('identifies constant globals', () {
      final globalPointers = [
        for (var i = 0; i < 4; i++)
          actual.getBinding('aGlobalPointer$i') as Global,
      ];

      expect(globalPointers[0].constant, isFalse); // int32_t*
      expect(globalPointers[1].constant, isTrue); // int32_t* const
      expect(globalPointers[2].constant, isFalse); // const int32_t*
      expect(globalPointers[3].constant, isTrue); // const int32_t* const
    });
  });
}

Library expectedLibrary() {
  final globalStruct = Struct(name: 'EmptyStruct');
  return Library(
    name: 'Bindings',
    bindings: [
      Global(type: BooleanType(), name: 'coolGlobal'),
      Global(
        type: NativeType(SupportedNativeType.int32),
        name: 'myInt',
        exposeSymbolAddress: true,
      ),
      Global(
        type: PointerType(NativeType(SupportedNativeType.int32)),
        name: 'aGlobalPointer0',
        exposeSymbolAddress: true,
      ),
      Global(
        type: PointerType(NativeType(SupportedNativeType.int32)),
        name: 'aGlobalPointer1',
        exposeSymbolAddress: true,
        constant: true,
      ),
      Global(
        type: PointerType(NativeType(SupportedNativeType.int32)),
        name: 'aGlobalPointer2',
        exposeSymbolAddress: true,
      ),
      Global(
        type: PointerType(NativeType(SupportedNativeType.int32)),
        name: 'aGlobalPointer3',
        exposeSymbolAddress: true,
        constant: true,
      ),
      globalStruct,
      Global(
        name: 'globalStruct',
        type: globalStruct,
        exposeSymbolAddress: true,
      ),
      Global(
        name: 'globalStruct_from_alias',
        type: Typealias(
          name: 'EmptyStruct_Alias',
          type: globalStruct,
        ),
        exposeSymbolAddress: true,
      )
    ],
  );
}
