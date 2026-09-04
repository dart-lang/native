// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:ffigen/ffigen.dart';
import 'package:package_config/package_config.dart';
import 'package:test/test.dart';

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('symbol_files_test_');
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  group('importFromSymbolFile', () {
    test('single file via file: URI', () {
      final file = File('${tempDir.path}/symbols.yaml');
      file.writeAsStringSync('''
format_version: 1.0.0
files:
  package:foo/foo.dart:
    symbols:
      c:@F@my_func:
        name: my_func
''');

      final importType = importFromSymbolFile(file.uri);
      final decl = Declaration(usr: 'c:@F@my_func', originalName: 'my_func');
      final imported = importType(decl);

      expect(imported, isNotNull);
      expect(imported!.cType, 'my_func');
      expect(imported.dartType, 'my_func');
      expect(imported.nativeType, 'my_func');
      expect(imported.importedDartType, isTrue);
      expect(imported.libraryImport.importPath(false), 'package:foo/foo.dart');
    });

    test('single file via relative path URI without scheme', () {
      final file = File('${tempDir.path}/symbols.yaml');
      file.writeAsStringSync('''
format_version: 1.0.0
files:
  package:foo/foo.dart:
    symbols:
      c:@F@my_func:
        name: my_func
''');

      final importType = importFromSymbolFile(Uri(path: file.path));
      final decl = Declaration(usr: 'c:@F@my_func', originalName: 'my_func');
      final imported = importType(decl);

      expect(imported, isNotNull);
      expect(imported!.cType, 'my_func');
    });

    test('single file via package: URI with PackageConfig', () {
      final libDir = Directory('${tempDir.path}/lib')..createSync();
      final file = File('${libDir.path}/my_symbols.yaml');
      file.writeAsStringSync('''
format_version: 1.0.0
files:
  package:test_pkg/gen.dart:
    symbols:
      c:@F@pkg_func:
        name: pkg_func
''');

      final packageConfig = PackageConfig([Package('test_pkg', libDir.uri)]);

      final importType = importFromSymbolFile(
        Uri.parse('package:test_pkg/my_symbols.yaml'),
        packageConfig: packageConfig,
      );
      final decl = Declaration(usr: 'c:@F@pkg_func', originalName: 'pkg_func');
      final imported = importType(decl);

      expect(imported, isNotNull);
      expect(imported!.cType, 'pkg_func');
      expect(
        imported.libraryImport.importPath(false),
        'package:test_pkg/gen.dart',
      );
    });
  });

  group('importFromSymbolFiles', () {
    test(
      'multiple symbol files merging symbols, separate and shared libraries',
      () {
        final file1 = File('${tempDir.path}/symbols1.yaml');
        file1.writeAsStringSync('''
format_version: 1.0.0
files:
  package:lib_a/a.dart:
    symbols:
      c:@F@func_a:
        name: func_a
  package:shared_lib/shared.dart:
    symbols:
      c:@F@shared_func_1:
        name: shared_func_1
''');

        final file2 = File('${tempDir.path}/symbols2.yaml');
        file2.writeAsStringSync('''
format_version: 1.0.0
files:
  package:shared_lib/shared.dart:
    symbols:
      c:@F@shared_func_2:
        name: shared_func_2
  package:lib_b/b.dart:
    symbols:
      c:@F@func_b:
        name: func_b
''');

        final importType = importFromSymbolFiles([file1.uri, file2.uri]);

        final declA = Declaration(usr: 'c:@F@func_a', originalName: 'func_a');
        final declShared1 = Declaration(
          usr: 'c:@F@shared_func_1',
          originalName: 'shared_func_1',
        );
        final declShared2 = Declaration(
          usr: 'c:@F@shared_func_2',
          originalName: 'shared_func_2',
        );
        final declB = Declaration(usr: 'c:@F@func_b', originalName: 'func_b');

        final importedA = importType(declA);
        final importedShared1 = importType(declShared1);
        final importedShared2 = importType(declShared2);
        final importedB = importType(declB);

        expect(importedA, isNotNull);
        expect(importedShared1, isNotNull);
        expect(importedShared2, isNotNull);
        expect(importedB, isNotNull);

        expect(importedA!.cType, 'func_a');
        expect(
          importedA.libraryImport.importPath(false),
          'package:lib_a/a.dart',
        );

        expect(importedShared1!.cType, 'shared_func_1');
        expect(
          importedShared1.libraryImport.importPath(false),
          'package:shared_lib/shared.dart',
        );

        expect(importedShared2!.cType, 'shared_func_2');
        expect(
          importedShared2.libraryImport.importPath(false),
          'package:shared_lib/shared.dart',
        );

        expect(importedB!.cType, 'func_b');
        expect(
          importedB.libraryImport.importPath(false),
          'package:lib_b/b.dart',
        );

        // Shared library reuses the same LibraryImport
        expect(
          importedShared1.libraryImport,
          same(importedShared2.libraryImport),
        );

        // Separate libraries have different prefixes
        expect(
          importedA.libraryImport.name,
          isNot(equals(importedB.libraryImport.name)),
        );
        expect(
          importedA.libraryImport.name,
          isNot(equals(importedShared1.libraryImport.name)),
        );
      },
    );
  });

  group('declaration lookup', () {
    late ImportedType? Function(Declaration) importType;

    setUp(() {
      final file = File('${tempDir.path}/symbols.yaml');
      file.writeAsStringSync('''
format_version: 1.0.0
files:
  package:foo/foo.dart:
    symbols:
      c:@F@known_usr:
        name: known_name
''');
      importType = importFromSymbolFile(file.uri);
    });

    test('known USR', () {
      final decl = Declaration(
        usr: 'c:@F@known_usr',
        originalName: 'known_name',
      );
      final imported = importType(decl);
      expect(imported, isNotNull);
      expect(imported!.cType, 'known_name');
    });

    test('unknown USR', () {
      final decl = Declaration(
        usr: 'c:@F@unknown_usr',
        originalName: 'unknown_name',
      );
      expect(importType(decl), isNull);
    });

    test('empty USR', () {
      final decl = Declaration(usr: '', originalName: 'empty_usr');
      expect(importType(decl), isNull);
    });
  });

  group('ImportedType fields', () {
    late ImportedType? Function(Declaration) importType;

    setUp(() {
      final file = File('${tempDir.path}/symbols.yaml');
      file.writeAsStringSync('''
format_version: 1.0.0
files:
  package:types_lib/types.dart:
    symbols:
      c:@S@NormalType:
        name: NormalType
      c:@T@CustomType:
        name: NativeCustomType
        dart-name: DartCustomType
''');
      importType = importFromSymbolFile(file.uri);
    });

    test('default dartName matches name', () {
      final decl = Declaration(
        usr: 'c:@S@NormalType',
        originalName: 'NormalType',
      );
      final imported = importType(decl);

      expect(imported, isNotNull);
      expect(imported!.cType, 'NormalType');
      expect(imported.nativeType, 'NormalType');
      expect(imported.dartType, 'NormalType');
      expect(
        imported.libraryImport.importPath(false),
        'package:types_lib/types.dart',
      );
      expect(imported.importedDartType, isTrue);
    });

    test('explicit dartName override', () {
      final decl = Declaration(
        usr: 'c:@T@CustomType',
        originalName: 'NativeCustomType',
      );
      final imported = importType(decl);

      expect(imported, isNotNull);
      expect(imported!.cType, 'NativeCustomType');
      expect(imported.nativeType, 'NativeCustomType');
      expect(imported.dartType, 'DartCustomType');
      expect(
        imported.libraryImport.importPath(false),
        'package:types_lib/types.dart',
      );
      expect(imported.importedDartType, isTrue);
    });
  });

  group('error handling', () {
    test('missing file throws FileSystemException', () {
      final missingUri = tempDir.uri.resolve('non_existent_file.yaml');
      expect(
        () => importFromSymbolFile(missingUri),
        throwsA(isA<FileSystemException>()),
      );
    });

    test('missing package config for package: URI throws ArgumentError', () {
      expect(
        () => importFromSymbolFile(Uri.parse('package:foo/symbols.yaml')),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('unresolvable package: URI throws FormatException', () {
      final packageConfig = PackageConfig([]);
      expect(
        () => importFromSymbolFile(
          Uri.parse('package:unknown/symbols.yaml'),
          packageConfig: packageConfig,
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('unsupported URI scheme throws FormatException', () {
      expect(
        () =>
            importFromSymbolFile(Uri.parse('https://example.com/symbols.yaml')),
        throwsA(isA<FormatException>()),
      );
    });

    test('incompatible format version throws FormatException', () {
      final file = File('${tempDir.path}/incompatible.yaml');
      file.writeAsStringSync('''
format_version: 2.0.0
files: {}
''');
      expect(
        () => importFromSymbolFile(file.uri),
        throwsA(isA<FormatException>()),
      );
    });

    test('malformed yaml syntax throws FormatException', () {
      final file = File('${tempDir.path}/malformed.yaml');
      file.writeAsStringSync('''
format_version: 1.0.0
files: [}
''');
      expect(
        () => importFromSymbolFile(file.uri),
        throwsA(isA<FormatException>()),
      );
    });

    test('yaml content not a map throws FormatException', () {
      final file = File('${tempDir.path}/not_a_map.yaml');
      file.writeAsStringSync('- just\n- a\n- list\n');
      expect(
        () => importFromSymbolFile(file.uri),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
