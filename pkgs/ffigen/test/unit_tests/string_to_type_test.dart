// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/config_provider/spec_utils.dart';
import 'package:test/test.dart';

void main() {
  group('makeTypeFromRawVarArgType', () {
    group('primitive types', () {
      test('void', () {
        expect(makeTypeFromRawVarArgType('void', (_) => null), voidType);
      });

      test('int types', () {
        expect(makeTypeFromRawVarArgType('int', (_) => null), intType);
        expect(
          makeTypeFromRawVarArgType('unsigned int', (_) => null),
          unsignedIntType,
        );
        expect(makeTypeFromRawVarArgType('short', (_) => null), shortType);
        expect(
          makeTypeFromRawVarArgType('unsigned short', (_) => null),
          unsignedShortType,
        );
        expect(makeTypeFromRawVarArgType('long', (_) => null), longType);
        expect(
          makeTypeFromRawVarArgType('unsigned long', (_) => null),
          unsignedLongType,
        );
        expect(
          makeTypeFromRawVarArgType('long long', (_) => null),
          longLongType,
        );
        expect(
          makeTypeFromRawVarArgType('unsigned long long', (_) => null),
          unsignedLongLongType,
        );
      });

      test('char types', () {
        expect(makeTypeFromRawVarArgType('char', (_) => null), charType);
        expect(
          makeTypeFromRawVarArgType('signed char', (_) => null),
          signedCharType,
        );
        expect(
          makeTypeFromRawVarArgType('unsigned char', (_) => null),
          unsignedCharType,
        );
      });

      test('floating point types', () {
        expect(makeTypeFromRawVarArgType('float', (_) => null), floatType);
        expect(makeTypeFromRawVarArgType('double', (_) => null), doubleType);
      });
    });

    group('supported typedefs', () {
      test('size_t and wchar_t', () {
        expect(makeTypeFromRawVarArgType('size_t', (_) => null), sizeType);
        expect(makeTypeFromRawVarArgType('wchar_t', (_) => null), wCharType);
      });

      test('stdint native types', () {
        expect(
          makeTypeFromRawVarArgType('uint8_t', (_) => null),
          NativeType(SupportedNativeType.uint8),
        );
        expect(
          makeTypeFromRawVarArgType('uint16_t', (_) => null),
          NativeType(SupportedNativeType.uint16),
        );
        expect(
          makeTypeFromRawVarArgType('uint32_t', (_) => null),
          NativeType(SupportedNativeType.uint32),
        );
        expect(
          makeTypeFromRawVarArgType('uint64_t', (_) => null),
          NativeType(SupportedNativeType.uint64),
        );
        expect(
          makeTypeFromRawVarArgType('int8_t', (_) => null),
          NativeType(SupportedNativeType.int8),
        );
        expect(
          makeTypeFromRawVarArgType('int16_t', (_) => null),
          NativeType(SupportedNativeType.int16),
        );
        expect(
          makeTypeFromRawVarArgType('int32_t', (_) => null),
          NativeType(SupportedNativeType.int32),
        );
        expect(
          makeTypeFromRawVarArgType('int64_t', (_) => null),
          NativeType(SupportedNativeType.int64),
        );
        expect(
          makeTypeFromRawVarArgType('intptr_t', (_) => null),
          NativeType(SupportedNativeType.intPtr),
        );
        expect(
          makeTypeFromRawVarArgType('uintptr_t', (_) => null),
          NativeType(SupportedNativeType.uintPtr),
        );
      });
    });

    group('pointers', () {
      test('single level pointer', () {
        final type = makeTypeFromRawVarArgType('int*', (_) => null);
        expect(type, isA<PointerType>());
        expect((type as PointerType).child, intType);
      });

      test('multi-level pointer', () {
        final type = makeTypeFromRawVarArgType('char**', (_) => null);
        expect(type, isA<PointerType>());
        final child = (type as PointerType).child;
        expect(child, isA<PointerType>());
        expect((child as PointerType).child, charType);
      });

      test('triple pointer', () {
        final type = makeTypeFromRawVarArgType('double***', (_) => null);
        expect(type, isA<PointerType>());
        final c1 = (type as PointerType).child;
        expect(c1, isA<PointerType>());
        final c2 = (c1 as PointerType).child;
        expect(c2, isA<PointerType>());
        expect((c2 as PointerType).child, doubleType);
      });

      test('typedef pointer', () {
        final type = makeTypeFromRawVarArgType('uint8_t*', (_) => null);
        expect(type, isA<PointerType>());
        expect(
          (type as PointerType).child,
          NativeType(SupportedNativeType.uint8),
        );
      });

      test('struct pointer', () {
        final type = makeTypeFromRawVarArgType('MyStruct*', (_) => null);
        expect(type, isA<PointerType>());
        final child = (type as PointerType).child;
        expect(child, isA<SelfImportedType>());
        expect((child as SelfImportedType).cType, 'MyStruct');
      });

      test('library imported pointer', () {
        final type = makeTypeFromRawVarArgType('ffi.Void*', (_) => null);
        expect(type, isA<PointerType>());
        final child = (type as PointerType).child;
        expect(child, isA<ImportedType>());
        expect((child as ImportedType).cType, 'Void');
        expect(child.libraryImport, ffiImport);
      });
    });

    group('self-imported and library-imported types', () {
      test('self-imported type', () {
        final type = makeTypeFromRawVarArgType('MyCustomStruct', (_) => null);
        expect(type, isA<SelfImportedType>());
        expect((type as SelfImportedType).cType, 'MyCustomStruct');
        expect(type.dartType, 'MyCustomStruct');
      });

      test('ffi built-in library', () {
        final type = makeTypeFromRawVarArgType('ffi.Pointer', (_) => null);
        expect(type, isA<ImportedType>());
        final imported = type as ImportedType;
        expect(imported.libraryImport, ffiImport);
        expect(imported.cType, 'Pointer');
        expect(imported.dartType, 'Pointer');
      });

      test('pkg_ffi built-in library', () {
        final type = makeTypeFromRawVarArgType('pkg_ffi.Utf8', (_) => null);
        expect(type, isA<ImportedType>());
        final imported = type as ImportedType;
        expect(imported.libraryImport, ffiPkgImport);
        expect(imported.cType, 'Utf8');
      });

      test('objc built-in library', () {
        final type = makeTypeFromRawVarArgType('objc.ObjCObject', (_) => null);
        expect(type, isA<ImportedType>());
        final imported = type as ImportedType;
        expect(imported.libraryImport, objcPkgImport);
        expect(imported.cType, 'ObjCObject');
      });
    });

    group('importType overrides', () {
      const customLib = LibraryImport(
        'custom_lib',
        'package:custom/custom.dart',
      );
      final customType = ImportedType(
        customLib,
        'CustomC',
        'CustomDart',
        'CustomNative',
      );

      test('custom type resolved via importType', () {
        final type = makeTypeFromRawVarArgType('CustomDeclaredType', (d) {
          if (d.originalName == 'CustomDeclaredType') {
            return customType;
          }
          return null;
        });
        expect(type, customType);
      });

      test('importType overrides primitive type', () {
        final overrideType = ImportedType(customLib, 'MyInt', 'int', 'int');
        final type = makeTypeFromRawVarArgType('int', (d) {
          if (d.originalName == 'int') {
            return overrideType;
          }
          return null;
        });
        expect(type, overrideType);
      });

      test('importType with pointers', () {
        final type = makeTypeFromRawVarArgType('CustomDeclaredType**', (d) {
          if (d.originalName == 'CustomDeclaredType') {
            return customType;
          }
          return null;
        });
        expect(type, isA<PointerType>());
        final c1 = (type as PointerType).child;
        expect(c1, isA<PointerType>());
        expect((c1 as PointerType).child, customType);
      });
    });

    group('whitespace trimming and variations', () {
      test('leading and trailing whitespace', () {
        expect(makeTypeFromRawVarArgType('  int  ', (_) => null), intType);
      });

      test('whitespace around pointers', () {
        final type1 = makeTypeFromRawVarArgType('int *', (_) => null);
        expect(type1, isA<PointerType>());
        expect((type1 as PointerType).child, intType);

        final type2 = makeTypeFromRawVarArgType('  int   *   *  ', (_) => null);
        expect(type2, isA<PointerType>());
        final c2 = (type2 as PointerType).child;
        expect(c2, isA<PointerType>());
        expect((c2 as PointerType).child, intType);
      });

      test('internal spacing in multi-word types', () {
        expect(
          makeTypeFromRawVarArgType('unsigned   int', (_) => null),
          unsignedIntType,
        );
        final ptr = makeTypeFromRawVarArgType(
          '  unsigned   long   long  *  *  ',
          (_) => null,
        );
        expect(ptr, isA<PointerType>());
        final c = (ptr as PointerType).child;
        expect(c, isA<PointerType>());
        expect((c as PointerType).child, unsignedLongLongType);
      });

      test('whitespace around dots', () {
        final type = makeTypeFromRawVarArgType(
          '  ffi . Void  *  ',
          (_) => null,
        );
        expect(type, isA<PointerType>());
        final child = (type as PointerType).child;
        expect(child, isA<ImportedType>());
        expect((child as ImportedType).cType, 'Void');
        expect(child.libraryImport, ffiImport);
      });
    });

    group('error cases', () {
      test('empty and whitespace only', () {
        expect(
          () => makeTypeFromRawVarArgType('', (_) => null),
          throwsException,
        );
        expect(
          () => makeTypeFromRawVarArgType('   ', (_) => null),
          throwsException,
        );
      });

      test('stars only or leading stars', () {
        expect(
          () => makeTypeFromRawVarArgType('*', (_) => null),
          throwsException,
        );
        expect(
          () => makeTypeFromRawVarArgType('***', (_) => null),
          throwsException,
        );
        expect(
          () => makeTypeFromRawVarArgType('*int', (_) => null),
          throwsException,
        );
        expect(
          () => makeTypeFromRawVarArgType(' * int', (_) => null),
          throwsException,
        );
      });

      test('trailing characters after stars', () {
        expect(
          () => makeTypeFromRawVarArgType('int*char', (_) => null),
          throwsException,
        );
        expect(
          () => makeTypeFromRawVarArgType('int * foo', (_) => null),
          throwsException,
        );
        expect(
          () => makeTypeFromRawVarArgType('int * 123', (_) => null),
          throwsException,
        );
      });

      test('invalid characters', () {
        expect(
          () => makeTypeFromRawVarArgType('int@', (_) => null),
          throwsException,
        );
        expect(
          () => makeTypeFromRawVarArgType('int#foo', (_) => null),
          throwsException,
        );
        expect(
          () => makeTypeFromRawVarArgType('int[]', (_) => null),
          throwsException,
        );
      });

      test('malformed dot syntax', () {
        expect(
          () => makeTypeFromRawVarArgType('.int', (_) => null),
          throwsException,
        );
        expect(
          () => makeTypeFromRawVarArgType('int.', (_) => null),
          throwsException,
        );
        expect(
          () => makeTypeFromRawVarArgType('ffi..Void', (_) => null),
          throwsException,
        );
      });

      test('multiple dots', () {
        expect(
          () => makeTypeFromRawVarArgType('a.b.c', (_) => null),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Expected 0 or 1 .(dot) separators'),
            ),
          ),
        );
        expect(
          () => makeTypeFromRawVarArgType('ffi.pkg.Type*', (_) => null),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Expected 0 or 1 .(dot) separators'),
            ),
          ),
        );
      });

      test('unmapped / unknown library import', () {
        expect(
          () => makeTypeFromRawVarArgType('unknown_lib.MyType', (_) => null),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Unknown library import: unknown_lib'),
            ),
          ),
        );
      });
    });
  });

  group('makePostfixFromRawVarArgType', () {
    test('primitive and pointer types', () {
      expect(makePostfixFromRawVarArgType(['int', 'char*']), 'IntCharPtr');
    });

    test('multi-word and multi-pointer types', () {
      expect(
        makePostfixFromRawVarArgType(['unsigned int', 'long**']),
        'UnsignedintLongPtrPtr',
      );
    });

    test('typedefs and structs', () {
      expect(
        makePostfixFromRawVarArgType(['uint32_t', 'Struct_A*']),
        'Uint32Struct_APtr',
      );
    });

    test('dotted types', () {
      expect(makePostfixFromRawVarArgType(['ffi.Void*']), 'FfiVoidPtr');
    });
  });

  group('makeImportTypeMapping', () {
    test('built-in library mapping', () {
      final mappings = makeImportTypeMapping({
        'my_native_type': ['ffi', 'Int32', 'int'],
      }, {});
      expect(mappings.containsKey('my_native_type'), isTrue);
      final imported = mappings['my_native_type']!;
      expect(imported.libraryImport, ffiImport);
      expect(imported.cType, 'Int32');
      expect(imported.dartType, 'int');
      expect(imported.nativeType, 'my_native_type');
    });

    test('custom library mapping', () {
      const customLib = LibraryImport(
        'custom_lib',
        'package:custom/custom.dart',
      );
      final mappings = makeImportTypeMapping(
        {
          'custom_native': ['custom_lib', 'CustomC', 'CustomDart'],
        },
        {'custom_lib': customLib},
      );
      expect(mappings.containsKey('custom_native'), isTrue);
      final imported = mappings['custom_native']!;
      expect(imported.libraryImport, customLib);
      expect(imported.cType, 'CustomC');
      expect(imported.dartType, 'CustomDart');
      expect(imported.nativeType, 'custom_native');
    });

    test('undeclared library throws', () {
      expect(
        () => makeImportTypeMapping({
          'unknown_native': ['missing_lib', 'C', 'Dart'],
        }, {}),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Please declare missing_lib under library-imports'),
          ),
        ),
      );
    });
  });
}
