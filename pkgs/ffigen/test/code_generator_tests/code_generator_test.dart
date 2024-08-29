// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/config_provider/config_types.dart';
import 'package:meta/meta.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  const licenseHeader = '''
// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
''';

  group('code_generator: ', () {
    @isTestGroup
    void withAndWithoutNative(
        String description, void Function(FfiNativeConfig) runTest) {
      group(description, () {
        test('without Native',
            () => runTest(const FfiNativeConfig(enabled: false)));
        test(
            'with Native',
            () =>
                runTest(const FfiNativeConfig(enabled: true, assetId: 'test')));
      });
    }

    withAndWithoutNative('Function Binding (primitives, pointers)',
        (nativeConfig) {
      final library = Library(
        name: 'Bindings',
        header: licenseHeader,
        bindings: [
          Func(
            ffiNativeConfig: nativeConfig,
            name: 'noParam',
            dartDoc: 'Just a test function\nheres another line',
            returnType: NativeType(
              SupportedNativeType.int32,
            ),
          ),
          Func(
            ffiNativeConfig: nativeConfig,
            name: 'withPrimitiveParam',
            parameters: [
              Parameter(
                name: 'a',
                type: NativeType(
                  SupportedNativeType.int32,
                ),
                objCConsumed: false,
              ),
              Parameter(
                name: 'b',
                type: NativeType(
                  SupportedNativeType.uint8,
                ),
                objCConsumed: false,
              ),
            ],
            returnType: NativeType(
              SupportedNativeType.char,
            ),
          ),
          Func(
            ffiNativeConfig: nativeConfig,
            name: 'withPointerParam',
            parameters: [
              Parameter(
                name: 'a',
                type: PointerType(
                  NativeType(
                    SupportedNativeType.int32,
                  ),
                ),
                objCConsumed: false,
              ),
              Parameter(
                name: 'b',
                type: PointerType(
                  PointerType(
                    NativeType(
                      SupportedNativeType.uint8,
                    ),
                  ),
                ),
                objCConsumed: false,
              ),
            ],
            returnType: PointerType(
              NativeType(
                SupportedNativeType.double,
              ),
            ),
          ),
          Func(
            ffiNativeConfig: nativeConfig,
            isLeaf: true,
            name: 'leafFunc',
            dartDoc: 'A function with isLeaf: true',
            parameters: [
              Parameter(
                name: 'a',
                type: NativeType(
                  SupportedNativeType.int32,
                ),
                objCConsumed: false,
              ),
            ],
            returnType: NativeType(
              SupportedNativeType.int32,
            ),
          ),
        ],
      );

      _matchLib(
          library, nativeConfig.enabled ? 'function_ffiNative' : 'function');
    });

    test('Struct Binding (primitives, pointers)', () {
      final library = Library(
        name: 'Bindings',
        header: licenseHeader,
        bindings: [
          Struct(
            name: 'NoMember',
            dartDoc: 'Just a test struct\nheres another line',
          ),
          Struct(
            name: 'WithPrimitiveMember',
            members: [
              Member(
                name: 'a',
                type: NativeType(
                  SupportedNativeType.int32,
                ),
              ),
              Member(
                name: 'b',
                type: NativeType(
                  SupportedNativeType.double,
                ),
              ),
              Member(
                name: 'c',
                type: NativeType(
                  SupportedNativeType.char,
                ),
              ),
            ],
          ),
          Struct(
            name: 'WithPointerMember',
            members: [
              Member(
                name: 'a',
                type: PointerType(
                  NativeType(
                    SupportedNativeType.int32,
                  ),
                ),
              ),
              Member(
                name: 'b',
                type: PointerType(
                  PointerType(
                    NativeType(
                      SupportedNativeType.double,
                    ),
                  ),
                ),
              ),
              Member(
                name: 'c',
                type: NativeType(
                  SupportedNativeType.char,
                ),
              ),
            ],
          ),
          Struct(
            name: 'WithIntPtrUintPtr',
            members: [
              Member(
                name: 'a',
                type: PointerType(
                  NativeType(
                    SupportedNativeType.uintPtr,
                  ),
                ),
              ),
              Member(
                name: 'b',
                type: PointerType(
                  PointerType(
                    NativeType(
                      SupportedNativeType.intPtr,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );

      _matchLib(library, 'struct');
    });

    test('Function and Struct Binding (pointer to Struct)', () {
      final structSome = Struct(
        name: 'SomeStruct',
        members: [
          Member(
            name: 'a',
            type: NativeType(
              SupportedNativeType.int32,
            ),
          ),
          Member(
            name: 'b',
            type: NativeType(
              SupportedNativeType.double,
            ),
          ),
          Member(
            name: 'c',
            type: NativeType(
              SupportedNativeType.char,
            ),
          ),
        ],
      );
      final library = Library(
        name: 'Bindings',
        header: licenseHeader,
        bindings: [
          structSome,
          Func(
            name: 'someFunc',
            parameters: [
              Parameter(
                name: 'some',
                type: PointerType(
                  PointerType(
                    structSome,
                  ),
                ),
                objCConsumed: false,
              ),
            ],
            returnType: PointerType(
              structSome,
            ),
          ),
        ],
      );

      _matchLib(library, 'function_n_struct');
    });

    withAndWithoutNative('global (primitives, pointers, pointer to struct)',
        (nativeConfig) {
      final structSome = Struct(
        name: 'Some',
      );
      final emptyGlobalStruct = Struct(name: 'EmptyStruct');

      final library = Library(
        name: 'Bindings',
        header: licenseHeader,
        bindings: [
          Global(
            nativeConfig: nativeConfig,
            name: 'test1',
            type: NativeType(
              SupportedNativeType.int32,
            ),
          ),
          Global(
            nativeConfig: nativeConfig,
            name: 'test2',
            type: PointerType(
              NativeType(
                SupportedNativeType.float,
              ),
            ),
            constant: true,
          ),
          Global(
            nativeConfig: nativeConfig,
            name: 'test3',
            type: ConstantArray(
              10,
              NativeType(
                SupportedNativeType.float,
              ),
              useArrayType: nativeConfig.enabled,
            ),
            constant: true,
          ),
          structSome,
          Global(
            nativeConfig: nativeConfig,
            name: 'test5',
            type: PointerType(
              structSome,
            ),
          ),
          emptyGlobalStruct,
          Global(
            nativeConfig: nativeConfig,
            name: 'globalStruct',
            type: emptyGlobalStruct,
          ),
        ],
      );
      _matchLib(library, nativeConfig.enabled ? 'global_native' : 'global');
    });

    test('constant', () {
      final library = Library(
        name: 'Bindings',
        header: '$licenseHeader\n// ignore_for_file: unused_import\n',
        bindings: [
          Constant(
            name: 'test1',
            rawType: 'int',
            rawValue: '20',
          ),
          Constant(
            name: 'test2',
            rawType: 'double',
            rawValue: '20.0',
          ),
        ],
      );
      _matchLib(library, 'constant');
    });

    test('enum_class', () {
      final library = Library(
        name: 'Bindings',
        header: '$licenseHeader\n// ignore_for_file: unused_import\n',
        bindings: [
          EnumClass(
            name: 'Constants',
            dartDoc: 'test line 1\ntest line 2',
            enumConstants: [
              const EnumConstant(
                name: 'a',
                value: 10,
              ),
              const EnumConstant(name: 'b', value: -1, dartDoc: 'negative'),
            ],
          ),
        ],
      );
      _matchLib(library, 'enumclass');
    });

    test('enum_class with duplicates', () {
      final library = Library(
        name: 'Bindings',
        header: '$licenseHeader\n// ignore_for_file: unused_import\n',
        bindings: [
          EnumClass(
            name: 'Duplicates',
            dartDoc: 'test line 1\ntest line 2',
            enumConstants: [
              const EnumConstant(
                name: 'a',
                value: 0,
                dartDoc: 'This is a unique value',
              ),
              const EnumConstant(
                name: 'b',
                value: 1,
                dartDoc: 'This is an original value',
              ),
              const EnumConstant(
                name: 'c',
                value: 1,
                dartDoc: 'This is a duplicate value',
              ),
            ],
          ),
        ],
      );
      _matchLib(library, 'enumclass_duplicates');
    });

    test('enum_class as integers', () {
      final enum1 = EnumClass(
        name: 'MyEnum',
        enumConstants: [
          const EnumConstant(
            name: 'value1',
            value: 0,
          ),
          const EnumConstant(
            name: 'value2',
            value: 1,
          ),
          const EnumConstant(
            name: 'value3',
            value: 2,
          ),
        ],
      );
      final enum2 = EnumClass(
        name: 'MyIntegerEnum',
        generateAsInt: true,
        enumConstants: [
          const EnumConstant(
            name: 'int1',
            value: 1,
          ),
          const EnumConstant(
            name: 'int2',
            value: 2,
          ),
          const EnumConstant(
            name: 'int3',
            value: 10,
          ),
        ],
      );
      final library = Library(
        name: 'Bindings',
        header: '$licenseHeader\n// ignore_for_file: unused_import\n',
        silenceEnumWarning: true,
        bindings: [
          enum1,
          enum2,
          Func(
            name: 'acceptsEnum',
            returnType: enum1,
            parameters: [
              Parameter(
                name: 'value',
                type: enum1,
                objCConsumed: false,
              )
            ],
          ),
          Func(
            name: 'acceptsInt',
            returnType: enum2,
            parameters: [
              Parameter(
                name: 'value',
                type: enum2,
                objCConsumed: false,
              )
            ],
          ),
        ],
      );
      _matchLib(library, 'enumclass_integers');
    });

    test('Internal conflict resolution', () {
      final library = Library(
        name: 'init_dylib',
        header:
            '$licenseHeader\n// ignore_for_file: unused_element, camel_case_types, non_constant_identifier_names\n',
        bindings: [
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
            name: '_Test',
            members: [
              Member(
                name: 'array',
                type: ConstantArray(
                  2,
                  NativeType(
                    SupportedNativeType.int8,
                  ),
                  // This flag is ignored for struct fields, which always use
                  // inline arrays.
                  useArrayType: true,
                ),
              ),
            ],
          ),
          Struct(name: 'ArrayHelperPrefixCollisionTest'),
          Func(
            name: 'Test',
            returnType: NativeType(SupportedNativeType.voidType),
          ),
          EnumClass(name: '_c_Test'),
          EnumClass(name: 'init_dylib'),
        ],
      );
      _matchLib(library, 'internal_conflict_resolution');
    });

    test('Adds Native symbol on mismatch', () {
      final nativeConfig = const FfiNativeConfig(enabled: true);
      final library = Library(
        name: 'init_dylib',
        header:
            '$licenseHeader\n// ignore_for_file: unused_element, camel_case_types, non_constant_identifier_names\n',
        bindings: [
          Func(
            ffiNativeConfig: nativeConfig,
            name: 'test',
            originalName: '_test',
            returnType: NativeType(SupportedNativeType.voidType),
          ),
          Global(
            nativeConfig: nativeConfig,
            name: 'testField',
            originalName: '_testField',
            type: NativeType(SupportedNativeType.int16),
          ),
        ],
      );
      _matchLib(library, 'native_symbol');
    });
  });
  test('boolean_dartBool', () {
    final library = Library(
      name: 'Bindings',
      header: licenseHeader,
      bindings: [
        Func(
          name: 'test1',
          returnType: BooleanType(),
          parameters: [
            Parameter(
              name: 'a',
              type: BooleanType(),
              objCConsumed: false,
            ),
            Parameter(
              name: 'b',
              type: PointerType(BooleanType()),
              objCConsumed: false,
            ),
          ],
        ),
        Struct(
          name: 'Test2',
          members: [
            Member(name: 'a', type: BooleanType()),
          ],
        ),
      ],
    );
    _matchLib(library, 'boolean_dartbool');
  });
  test('sort bindings', () {
    final library = Library(
      name: 'Bindings',
      header: licenseHeader,
      sort: true,
      bindings: [
        Func(name: 'b', returnType: NativeType(SupportedNativeType.voidType)),
        Func(name: 'a', returnType: NativeType(SupportedNativeType.voidType)),
        Struct(name: 'D'),
        Struct(name: 'C'),
      ],
    );
    _matchLib(library, 'sort_bindings');
  });
  test('Pack Structs', () {
    final library = Library(
      name: 'Bindings',
      header: licenseHeader,
      bindings: [
        Struct(name: 'NoPacking', pack: null, members: [
          Member(name: 'a', type: NativeType(SupportedNativeType.char)),
        ]),
        Struct(name: 'Pack1', pack: 1, members: [
          Member(name: 'a', type: NativeType(SupportedNativeType.char)),
        ]),
        Struct(name: 'Pack2', pack: 2, members: [
          Member(name: 'a', type: NativeType(SupportedNativeType.char)),
        ]),
        Struct(name: 'Pack2', pack: 4, members: [
          Member(name: 'a', type: NativeType(SupportedNativeType.char)),
        ]),
        Struct(name: 'Pack2', pack: 8, members: [
          Member(name: 'a', type: NativeType(SupportedNativeType.char)),
        ]),
        Struct(name: 'Pack16', pack: 16, members: [
          Member(name: 'a', type: NativeType(SupportedNativeType.char)),
        ]),
      ],
    );
    _matchLib(library, 'packed_structs');
  });
  test('Union Bindings', () {
    final struct1 =
        Struct(name: 'Struct1', members: [Member(name: 'a', type: charType)]);
    final union1 =
        Union(name: 'Union1', members: [Member(name: 'a', type: charType)]);
    final library = Library(
      name: 'Bindings',
      header: licenseHeader,
      bindings: [
        struct1,
        union1,
        Union(name: 'EmptyUnion'),
        Union(name: 'Primitives', members: [
          Member(name: 'a', type: charType),
          Member(name: 'b', type: intType),
          Member(name: 'c', type: floatType),
          Member(name: 'd', type: doubleType),
        ]),
        Union(name: 'PrimitivesWithPointers', members: [
          Member(name: 'a', type: charType),
          Member(name: 'b', type: floatType),
          Member(name: 'c', type: PointerType(doubleType)),
          Member(name: 'd', type: PointerType(union1)),
          Member(name: 'd', type: PointerType(struct1)),
        ]),
        Union(name: 'WithArray', members: [
          Member(
            name: 'a',
            type: ConstantArray(10, charType, useArrayType: true),
          ),
          Member(
            name: 'b',
            type: ConstantArray(10, union1, useArrayType: true),
          ),
          Member(
            name: 'b',
            type: ConstantArray(10, struct1, useArrayType: true),
          ),
          Member(
            name: 'c',
            type: ConstantArray(10, PointerType(union1), useArrayType: true),
          ),
        ]),
      ],
    );
    _matchLib(library, 'unions');
  });
  test('Typealias Bindings', () {
    final library = Library(
      name: 'Bindings',
      header:
          '$licenseHeader\n// ignore_for_file: non_constant_identifier_names\n',
      bindings: [
        Typealias(name: 'RawUnused', type: Struct(name: 'Struct1')),
        Struct(name: 'WithTypealiasStruct', members: [
          Member(
              name: 't',
              type: Typealias(
                  name: 'Struct2Typealias',
                  type: Struct(
                      name: 'Struct2',
                      members: [Member(name: 'a', type: doubleType)])))
        ]),
        Func(
            name: 'WithTypealiasStruct',
            returnType: PointerType(NativeFunc(FunctionType(
                returnType: NativeType(SupportedNativeType.voidType),
                parameters: []))),
            parameters: [
              Parameter(
                name: 't',
                type: Typealias(
                    name: 'Struct3Typealias', type: Struct(name: 'Struct3')),
                objCConsumed: false,
              )
            ]),
      ],
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
    '_expected_${testName}_bindings.dart'
  ]);
}
