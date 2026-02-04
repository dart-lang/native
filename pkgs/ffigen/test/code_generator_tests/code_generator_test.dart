// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/config_provider/config.dart';
import 'package:ffigen/src/context.dart';
import 'package:ffigen/src/header_parser/parser.dart';
import 'package:meta/meta.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  const licenseHeader = '''
// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
''';

  Context makeContext({Output? output}) => testContext(
    FfiGenerator(
      output:
          output ??
          Output(
            dartFile: Uri.file('unused'),
            style: const DynamicLibraryBindings(wrapperName: 'Bindings'),
          ),
      enums: Enums.includeAll,
      functions: Functions.includeAll,
      globals: Globals.includeAll,
      macros: Macros.includeAll,
      structs: Structs.includeAll,
      typedefs: Typedefs.includeAll,
      unions: Unions.includeAll,
      unnamedEnums: UnnamedEnums.includeAll,
    ),
  );

  group('code_generator: ', () {
    @isTestGroup
    void withAndWithoutNative(String description, void Function(bool) runTest) {
      group(description, () {
        test('without Native', () => runTest(false));
        test('with Native', () => runTest(true));
      });
    }

    withAndWithoutNative('Function Binding (primitives, pointers)', (
      loadFromNativeAsset,
    ) {
      final nativeContext = makeContext(
        output: Output(
          dartFile: Uri.file('unused'),
          style: loadFromNativeAsset
              ? const NativeExternalBindings(assetId: 'test')
              : const DynamicLibraryBindings(wrapperName: 'Bindings'),
        ),
      );
      final library = Library(
        context: nativeContext,
        header: licenseHeader,
        bindings: transformBindings([
          Func(
            loadFromNativeAsset: loadFromNativeAsset,
            name: 'noParam',
            dartDoc: 'Just a test function\nheres another line',
            returnType: NativeType(SupportedNativeType.int32),
          ),
          Func(
            loadFromNativeAsset: loadFromNativeAsset,
            name: 'withPrimitiveParam',
            parameters: [
              Parameter(
                name: 'a',
                type: NativeType(SupportedNativeType.int32),
                objCConsumed: false,
              ),
              Parameter(
                name: 'b',
                type: NativeType(SupportedNativeType.uint8),
                objCConsumed: false,
              ),
            ],
            returnType: NativeType(SupportedNativeType.char),
          ),
          Func(
            loadFromNativeAsset: loadFromNativeAsset,
            name: 'withPointerParam',
            parameters: [
              Parameter(
                name: 'a',
                type: PointerType(NativeType(SupportedNativeType.int32)),
                objCConsumed: false,
              ),
              Parameter(
                name: 'b',
                type: PointerType(
                  PointerType(NativeType(SupportedNativeType.uint8)),
                ),
                objCConsumed: false,
              ),
            ],
            returnType: PointerType(NativeType(SupportedNativeType.double)),
          ),
          Func(
            loadFromNativeAsset: loadFromNativeAsset,
            isLeaf: true,
            name: 'leafFunc',
            dartDoc: 'A function with isLeaf: true',
            parameters: [
              Parameter(
                name: 'a',
                type: NativeType(SupportedNativeType.int32),
                objCConsumed: false,
              ),
            ],
            returnType: NativeType(SupportedNativeType.int32),
          ),
        ], nativeContext),
      );

      _matchLib(
        library,
        loadFromNativeAsset ? 'function_ffiNative' : 'function',
      );
    });

    test('Struct Binding (primitives, pointers)', () {
      final context = makeContext();
      final library = Library(
        context: context,
        header: licenseHeader,
        bindings: transformBindings([
          Struct(
            context: context,
            name: 'NoMember',
            dartDoc: 'Just a test struct\nheres another line',
          ),
          Struct(
            context: context,
            name: 'WithPrimitiveMember',
            members: [
              CompoundMember(
                name: 'a',
                type: NativeType(SupportedNativeType.int32),
              ),
              CompoundMember(
                name: 'b',
                type: NativeType(SupportedNativeType.double),
              ),
              CompoundMember(
                name: 'c',
                type: NativeType(SupportedNativeType.char),
              ),
            ],
          ),
          Struct(
            context: context,
            name: 'WithPointerMember',
            members: [
              CompoundMember(
                name: 'a',
                type: PointerType(NativeType(SupportedNativeType.int32)),
              ),
              CompoundMember(
                name: 'b',
                type: PointerType(
                  PointerType(NativeType(SupportedNativeType.double)),
                ),
              ),
              CompoundMember(
                name: 'c',
                type: NativeType(SupportedNativeType.char),
              ),
            ],
          ),
          Struct(
            context: context,
            name: 'WithIntPtrUintPtr',
            members: [
              CompoundMember(
                name: 'a',
                type: PointerType(NativeType(SupportedNativeType.uintPtr)),
              ),
              CompoundMember(
                name: 'b',
                type: PointerType(
                  PointerType(NativeType(SupportedNativeType.intPtr)),
                ),
              ),
            ],
          ),
        ], context),
      );

      _matchLib(library, 'struct');
    });

    test('Function and Struct Binding (pointer to Struct)', () {
      final context = makeContext();
      final structSome = Struct(
        context: context,
        name: 'SomeStruct',
        members: [
          CompoundMember(
            name: 'a',
            type: NativeType(SupportedNativeType.int32),
          ),
          CompoundMember(
            name: 'b',
            type: NativeType(SupportedNativeType.double),
          ),
          CompoundMember(name: 'c', type: NativeType(SupportedNativeType.char)),
        ],
      );
      final library = Library(
        context: context,
        header: licenseHeader,
        bindings: transformBindings([
          structSome,
          Func(
            name: 'someFunc',
            parameters: [
              Parameter(
                name: 'some',
                type: PointerType(PointerType(structSome)),
                objCConsumed: false,
              ),
            ],
            returnType: PointerType(structSome),
          ),
        ], context),
      );

      _matchLib(library, 'function_n_struct');
    });

    withAndWithoutNative('global (primitives, pointers, pointer to struct)', (
      loadFromNativeAsset,
    ) {
      final nativeContext = makeContext(
        output: Output(
          dartFile: Uri.file('unused'),
          style: loadFromNativeAsset
              ? const NativeExternalBindings(assetId: 'test')
              : const DynamicLibraryBindings(wrapperName: 'Bindings'),
        ),
      );

      final structSome = Struct(context: nativeContext, name: 'Some');
      final emptyGlobalStruct = Struct(
        context: nativeContext,
        name: 'EmptyStruct',
      );

      final library = Library(
        context: nativeContext,
        header: licenseHeader,
        bindings: transformBindings([
          Global(
            loadFromNativeAsset: loadFromNativeAsset,
            name: 'test1',
            type: NativeType(SupportedNativeType.int32),
          ),
          Global(
            loadFromNativeAsset: loadFromNativeAsset,
            name: 'test2',
            type: PointerType(NativeType(SupportedNativeType.float)),
            constant: true,
          ),
          Global(
            loadFromNativeAsset: loadFromNativeAsset,
            name: 'test3',
            type: ConstantArray(
              10,
              NativeType(SupportedNativeType.float),
              useArrayType: loadFromNativeAsset,
            ),
            constant: true,
          ),
          structSome,
          Global(
            loadFromNativeAsset: loadFromNativeAsset,
            name: 'test5',
            type: PointerType(structSome),
          ),
          emptyGlobalStruct,
          Global(
            loadFromNativeAsset: loadFromNativeAsset,
            name: 'globalStruct',
            type: emptyGlobalStruct,
          ),
        ], nativeContext),
      );
      _matchLib(library, loadFromNativeAsset ? 'global_native' : 'global');
    });

    test('constant', () {
      final context = makeContext();
      final library = Library(
        context: context,
        header: '$licenseHeader\n',
        bindings: transformBindings([
          MacroConstant(name: 'test1', rawType: 'int', rawValue: '20'),
          MacroConstant(name: 'test2', rawType: 'double', rawValue: '20.0'),
        ], context),
      );
      _matchLib(library, 'constant');
    });

    test('enum_class', () {
      final context = makeContext();
      final library = Library(
        context: context,
        header: '$licenseHeader\n',
        bindings: transformBindings([
          EnumClass(
            context: context,
            name: 'Constants',
            dartDoc: 'test line 1\ntest line 2',
            enumConstants: [
              EnumConstant(name: 'a', value: 10),
              EnumConstant(name: 'b', value: -1, dartDoc: 'negative'),
            ],
          ),
        ], context),
      );
      _matchLib(library, 'enumclass');
    });

    test('enum_class with duplicates', () {
      final context = makeContext();
      final library = Library(
        context: context,
        header: '$licenseHeader\n',
        bindings: transformBindings([
          EnumClass(
            context: context,
            name: 'Duplicates',
            dartDoc: 'test line 1\ntest line 2',
            enumConstants: [
              EnumConstant(
                name: 'a',
                value: 0,
                dartDoc: 'This is a unique value',
              ),
              EnumConstant(
                name: 'b',
                value: 1,
                dartDoc: 'This is an original value',
              ),
              EnumConstant(
                name: 'c',
                value: 1,
                dartDoc: 'This is a duplicate value',
              ),
            ],
          ),
        ], context),
      );
      _matchLib(library, 'enumclass_duplicates');
    });

    test('enum_class as integers', () {
      final context = makeContext();
      final enum1 = EnumClass(
        context: context,
        name: 'MyEnum',
        enumConstants: [
          EnumConstant(name: 'value1', value: 0),
          EnumConstant(name: 'value2', value: 1),
          EnumConstant(name: 'value3', value: 2),
        ],
      );
      final enum2 = EnumClass(
        context: context,
        name: 'MyIntegerEnum',
        style: EnumStyle.intConstants,
        enumConstants: [
          EnumConstant(name: 'int1', value: 1),
          EnumConstant(name: 'int2', value: 2),
          EnumConstant(name: 'int3', value: 10),
        ],
      );
      final library = Library(
        context: context,
        header: '$licenseHeader\n',
        silenceEnumWarning: true,
        bindings: transformBindings([
          enum1,
          enum2,
          Func(
            name: 'acceptsEnum',
            returnType: enum1,
            parameters: [
              Parameter(name: 'value', type: enum1, objCConsumed: false),
            ],
          ),
          Func(
            name: 'acceptsInt',
            returnType: enum2,
            parameters: [
              Parameter(name: 'value', type: enum2, objCConsumed: false),
            ],
          ),
        ], context),
      );
      _matchLib(library, 'enumclass_integers');
    });

    test('enum in structs and functions', () {
      final context = makeContext();
      final enum1 = EnumClass(
        context: context,
        name: 'Enum1',
        enumConstants: [
          EnumConstant(name: 'a', value: 0),
          EnumConstant(name: 'b', value: 1),
          EnumConstant(name: 'c', value: 2),
        ],
      );
      final enum2 = EnumClass(
        context: context,
        name: 'Enum2',
        style: EnumStyle.intConstants,
        enumConstants: [
          EnumConstant(name: 'value1', value: 0),
          EnumConstant(name: 'value2', value: 1),
          EnumConstant(name: 'value3', value: 2),
        ],
      );
      final func1 = Func(
        name: 'funcWithEnum1',
        returnType: enum1,
        parameters: [
          Parameter(type: enum1, name: 'value', objCConsumed: false),
        ],
      );
      final func2 = Func(
        name: 'funcWithEnum2',
        returnType: enum2,
        parameters: [
          Parameter(type: enum2, name: 'value', objCConsumed: false),
        ],
      );
      final func3 = Func(
        name: 'funcWithBothEnums',
        returnType: voidType,
        parameters: [
          Parameter(type: enum1, name: 'value1', objCConsumed: false),
          Parameter(type: enum2, name: 'value2', objCConsumed: false),
        ],
      );
      final struct1 = Struct(
        context: context,
        name: 'StructWithEnums',
        members: [
          CompoundMember(name: 'enum1', type: enum1),
          CompoundMember(name: 'enum2', type: enum2),
        ],
      );
      final func4 = Func(
        name: 'funcWithStruct',
        returnType: struct1,
        parameters: [
          Parameter(type: struct1, name: 'value', objCConsumed: false),
        ],
      );
      final lib = Library(
        context: context,
        header: '$licenseHeader\n',
        silenceEnumWarning: true,
        bindings: transformBindings([
          enum1,
          enum2,
          struct1,
          func1,
          func2,
          func3,
          func4,
        ], context),
      );
      _matchLib(lib, 'enumclass_func_and_struct');
    });

    test('Internal conflict resolution', () {
      final context = makeContext(
        output: Output(
          dartFile: Uri.file('unused'),
          style: const DynamicLibraryBindings(wrapperName: 'init_dylib'),
        ),
      );
      final library = Library(
        context: context,
        header: '$licenseHeader\n// ignore_for_file: unused_element\n',
        bindings: transformBindings([
          Func(
            name: 'test',
            returnType: NativeType(SupportedNativeType.voidType),
          ),
          Func(
            name: '_test',
            returnType: NativeType(SupportedNativeType.voidType),
          ),
          Func(
            name: '_c_test',
            returnType: NativeType(SupportedNativeType.voidType),
          ),
          Func(
            name: '_dart_test',
            returnType: NativeType(SupportedNativeType.voidType),
          ),
          Struct(
            context: context,
            name: '_Test',
            members: [
              CompoundMember(
                name: 'array',
                type: ConstantArray(
                  2,
                  NativeType(SupportedNativeType.int8),
                  // This flag is ignored for struct fields, which always use
                  // inline arrays.
                  useArrayType: true,
                ),
              ),
            ],
          ),
          Struct(context: context, name: 'ArrayHelperPrefixCollisionTest'),
          Func(
            name: 'Test',
            returnType: NativeType(SupportedNativeType.voidType),
          ),
          EnumClass(context: context, name: '_c_Test'),
          EnumClass(context: context, name: 'init_dylib'),
        ], context),
      );
      _matchLib(library, 'internal_conflict_resolution');
    });

    test('Adds Native symbol on mismatch', () {
      final context = makeContext(
        output: Output(
          dartFile: Uri.file('unused'),
          style: const NativeExternalBindings(assetId: 'test'),
        ),
      );
      final library = Library(
        context: context,
        header: '$licenseHeader\n',
        bindings: transformBindings([
          Func(
            loadFromNativeAsset: true,
            name: 'test',
            originalName: '_test',
            returnType: NativeType(SupportedNativeType.voidType),
          ),
          Global(
            loadFromNativeAsset: true,
            name: 'testField',
            originalName: '_testField',
            type: NativeType(SupportedNativeType.int16),
          ),
        ], context),
      );
      _matchLib(library, 'native_symbol');
    });
  });

  test('boolean_dartBool', () {
    final context = makeContext();
    final library = Library(
      context: context,
      header: licenseHeader,
      bindings: transformBindings([
        Func(
          name: 'test1',
          returnType: BooleanType(),
          parameters: [
            Parameter(name: 'a', type: BooleanType(), objCConsumed: false),
            Parameter(
              name: 'b',
              type: PointerType(BooleanType()),
              objCConsumed: false,
            ),
          ],
        ),
        Struct(
          context: context,
          name: 'Test2',
          members: [CompoundMember(name: 'a', type: BooleanType())],
        ),
      ], context),
    );
    _matchLib(library, 'boolean_dartbool');
  });

  test('Pack Structs', () {
    final context = makeContext();
    final library = Library(
      context: context,
      header: licenseHeader,
      bindings: transformBindings([
        Struct(
          context: context,
          name: 'NoPacking',
          pack: null,
          members: [
            CompoundMember(
              name: 'a',
              type: NativeType(SupportedNativeType.char),
            ),
          ],
        ),
        Struct(
          context: context,
          name: 'Pack1',
          pack: 1,
          members: [
            CompoundMember(
              name: 'a',
              type: NativeType(SupportedNativeType.char),
            ),
          ],
        ),
        Struct(
          context: context,
          name: 'Pack2',
          pack: 2,
          members: [
            CompoundMember(
              name: 'a',
              type: NativeType(SupportedNativeType.char),
            ),
          ],
        ),
        Struct(
          context: context,
          name: 'Pack4',
          pack: 4,
          members: [
            CompoundMember(
              name: 'a',
              type: NativeType(SupportedNativeType.char),
            ),
          ],
        ),
        Struct(
          context: context,
          name: 'Pack8',
          pack: 8,
          members: [
            CompoundMember(
              name: 'a',
              type: NativeType(SupportedNativeType.char),
            ),
          ],
        ),
        Struct(
          context: context,
          name: 'Pack16',
          pack: 16,
          members: [
            CompoundMember(
              name: 'a',
              type: NativeType(SupportedNativeType.char),
            ),
          ],
        ),
      ], context),
    );
    _matchLib(library, 'packed_structs');
  });

  test('Union Bindings', () {
    final context = makeContext();
    final struct1 = Struct(
      context: context,
      name: 'Struct1',
      members: [CompoundMember(name: 'a', type: charType)],
    );
    final union1 = Union(
      context: context,
      name: 'Union1',
      members: [CompoundMember(name: 'a', type: charType)],
    );
    final library = Library(
      context: context,
      header: licenseHeader,
      bindings: transformBindings([
        struct1,
        union1,
        Union(context: context, name: 'EmptyUnion'),
        Union(
          context: context,
          name: 'Primitives',
          members: [
            CompoundMember(name: 'a', type: charType),
            CompoundMember(name: 'b', type: intType),
            CompoundMember(name: 'c', type: floatType),
            CompoundMember(name: 'd', type: doubleType),
          ],
        ),
        Union(
          context: context,
          name: 'PrimitivesWithPointers',
          members: [
            CompoundMember(name: 'a', type: charType),
            CompoundMember(name: 'b', type: floatType),
            CompoundMember(name: 'c', type: PointerType(doubleType)),
            CompoundMember(name: 'd', type: PointerType(union1)),
            CompoundMember(name: 'd', type: PointerType(struct1)),
          ],
        ),
        Union(
          context: context,
          name: 'WithArray',
          members: [
            CompoundMember(
              name: 'a',
              type: ConstantArray(10, charType, useArrayType: true),
            ),
            CompoundMember(
              name: 'b',
              type: ConstantArray(10, union1, useArrayType: true),
            ),
            CompoundMember(
              name: 'b',
              type: ConstantArray(10, struct1, useArrayType: true),
            ),
            CompoundMember(
              name: 'c',
              type: ConstantArray(10, PointerType(union1), useArrayType: true),
            ),
          ],
        ),
      ], context),
    );
    _matchLib(library, 'unions');
  });

  test('Typealias Bindings', () {
    final context = makeContext();
    final struct2 = Struct(
      context: context,
      name: 'Struct2',
      members: [CompoundMember(name: 'a', type: doubleType)],
    );
    final struct2Typealias = Typealias(name: 'Struct2Typealias', type: struct2);
    final struct3 = Struct(context: context, name: 'Struct3');
    final struct3Typealias = Typealias(name: 'Struct3Typealias', type: struct3);
    final library = Library(
      context: context,
      header: '$licenseHeader\n',
      bindings: transformBindings([
        Typealias(
          name: 'RawUnused',
          type: Struct(context: context, name: 'Struct1'),
        ),
        Struct(
          context: context,
          name: 'WithTypealiasStruct',
          members: [CompoundMember(name: 't', type: struct2Typealias)],
        ),
        Func(
          name: 'WithTypealiasStruct',
          returnType: PointerType(
            NativeFunc(
              FunctionType(
                returnType: NativeType(SupportedNativeType.voidType),
                parameters: [],
              ),
            ),
          ),
          parameters: [
            Parameter(name: 't', type: struct3Typealias, objCConsumed: false),
          ],
        ),
        struct2,
        struct2Typealias,
        struct3,
        struct3Typealias,
      ], context),
    );
    _matchLib(library, 'typealias');
  });
}

/// Utility to match expected bindings to the generated bindings.
void _matchLib(Library lib, String testName) {
  matchLibraryWithExpected(lib, 'code_generator_test_${testName}_output.dart', [
    'test',
    'code_generator_tests',
    'expected_bindings',
    '_expected_${testName}_bindings.dart',
  ]);
}
