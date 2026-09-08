// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:ffigen/ffigen.dart';
import 'package:ffigen/src/header_parser.dart';
import 'package:package_config/package_config.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

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
      const decl = Declaration(usr: 'c:@F@my_func', originalName: 'my_func');
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
      const decl = Declaration(usr: 'c:@F@my_func', originalName: 'my_func');
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
      const decl = Declaration(usr: 'c:@F@pkg_func', originalName: 'pkg_func');
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

        const declA = Declaration(usr: 'c:@F@func_a', originalName: 'func_a');
        const declShared1 = Declaration(
          usr: 'c:@F@shared_func_1',
          originalName: 'shared_func_1',
        );
        const declShared2 = Declaration(
          usr: 'c:@F@shared_func_2',
          originalName: 'shared_func_2',
        );
        const declB = Declaration(usr: 'c:@F@func_b', originalName: 'func_b');

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
      const decl = Declaration(
        usr: 'c:@F@known_usr',
        originalName: 'known_name',
      );
      final imported = importType(decl);
      expect(imported, isNotNull);
      expect(imported!.cType, 'known_name');
    });

    test('unknown USR', () {
      const decl = Declaration(
        usr: 'c:@F@unknown_usr',
        originalName: 'unknown_name',
      );
      expect(importType(decl), isNull);
    });

    test('empty USR', () {
      const decl = Declaration(usr: '', originalName: 'empty_usr');
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
      const decl = Declaration(
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
      const decl = Declaration(
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

    test('files not a map throws FormatException', () {
      final stringFile = File('${tempDir.path}/files_string.yaml');
      stringFile.writeAsStringSync('''
format_version: 1.0.0
files: "not-a-map"
''');
      expect(
        () => importFromSymbolFile(stringFile.uri),
        throwsA(isA<FormatException>()),
      );

      final listFile = File('${tempDir.path}/files_list.yaml');
      listFile.writeAsStringSync('''
format_version: 1.0.0
files:
  - 1
  - 2
''');
      expect(
        () => importFromSymbolFile(listFile.uri),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('importFromSymbols', () {
    const lib = LibraryImport('foo', 'package:foo/foo.dart');
    const symbolMap = <String, ImportedType>{
      'c:@F@my_func': ImportedType(
        lib,
        'my_func',
        'my_func',
        'my_func',
        importedDartType: true,
      ),
      'c:@T@MyType': ImportedType(
        lib,
        'my_type',
        'MyType',
        'my_type',
        importedDartType: true,
      ),
    };

    test('lookup known USR with Map', () {
      final importType = importFromSymbols(symbolMap);
      const decl = Declaration(usr: 'c:@F@my_func', originalName: 'my_func');
      final imported = importType(decl);
      expect(imported, isNotNull);
      expect(imported!.cType, 'my_func');
      expect(imported.dartType, 'my_func');
      expect(imported.libraryImport, lib);
    });

    test('lookup known USR with FfigenSymbols', () {
      const ffigenSymbols = FfigenSymbols(
        formatVersion: '1.0.0',
        symbols: symbolMap,
      );
      final importType = importFromSymbols(ffigenSymbols);
      const decl = Declaration(usr: 'c:@F@my_func', originalName: 'my_func');
      final imported = importType(decl);
      expect(imported, isNotNull);
      expect(imported!.cType, 'my_func');
      expect(imported.dartType, 'my_func');
      expect(imported.libraryImport, lib);
    });

    test('lookup unknown USR', () {
      final importType = importFromSymbols(symbolMap);
      const decl = Declaration(usr: 'c:@F@unknown', originalName: 'unknown');
      expect(importType(decl), isNull);
    });

    test('lookup empty USR', () {
      final importType = importFromSymbols(symbolMap);
      const decl = Declaration(usr: '', originalName: 'empty');
      expect(importType(decl), isNull);
    });
  });

  group('importFromSymbolMaps', () {
    const lib1 = LibraryImport('foo', 'package:foo/foo.dart');
    const lib2 = LibraryImport('bar', 'package:bar/bar.dart');
    const map1 = <String, ImportedType>{
      'c:@F@func1': ImportedType(
        lib1,
        'func1',
        'func1',
        'func1',
        importedDartType: true,
      ),
      'c:@F@shared': ImportedType(
        lib1,
        'shared',
        'shared_v1',
        'shared',
        importedDartType: true,
      ),
    };
    const map2 = <String, ImportedType>{
      'c:@F@func2': ImportedType(
        lib2,
        'func2',
        'func2',
        'func2',
        importedDartType: true,
      ),
      'c:@F@shared': ImportedType(
        lib2,
        'shared',
        'shared_v2',
        'shared',
        importedDartType: true,
      ),
    };

    test('merges multiple maps with precedence', () {
      final importType = importFromSymbolMaps([map1, map2]);
      const decl1 = Declaration(usr: 'c:@F@func1', originalName: 'func1');
      const decl2 = Declaration(usr: 'c:@F@func2', originalName: 'func2');
      const sharedDecl = Declaration(
        usr: 'c:@F@shared',
        originalName: 'shared',
      );

      expect(importType(decl1)!.libraryImport, lib1);
      expect(importType(decl2)!.libraryImport, lib2);
      expect(importType(sharedDecl)!.dartType, 'shared_v2');
      expect(importType(sharedDecl)!.libraryImport, lib2);
    });

    test('merges multiple FfigenSymbols with precedence', () {
      const symbols1 = FfigenSymbols(symbols: map1);
      const symbols2 = FfigenSymbols(symbols: map2);
      final importType = importFromSymbolMaps([symbols1, symbols2]);
      const decl1 = Declaration(usr: 'c:@F@func1', originalName: 'func1');
      const decl2 = Declaration(usr: 'c:@F@func2', originalName: 'func2');
      const sharedDecl = Declaration(
        usr: 'c:@F@shared',
        originalName: 'shared',
      );

      expect(importType(decl1)!.libraryImport, lib1);
      expect(importType(decl2)!.libraryImport, lib2);
      expect(importType(sharedDecl)!.dartType, 'shared_v2');
      expect(importType(sharedDecl)!.libraryImport, lib2);
    });
  });

  group('generateSymbolOutputFile', () {
    test('generates Dart symbol file when extension is .dart', () {
      final file = File('${tempDir.path}/symbols.dart');
      final headerFile = File('${tempDir.path}/test.h')
        ..writeAsStringSync('void foo();\n');

      final config = FfiGenerator(
        output: Output(
          dart: DartOutput(path: Uri.file('${tempDir.path}/bindings.dart')),
        ),
        input: Input(entryPoints: [headerFile.uri]),
        visitors: [Visitor(func: (node) => node.isIncluded = true)],
      );
      final context = testContext(config);
      final library = parse(context);
      library.generate();
      library.generateSymbolOutputFile(file, 'package:foo/foo.dart');

      expect(file.existsSync(), isTrue);
      final content = file.readAsStringSync();
      expect(
        content,
        contains("import 'package:ffigen_symbols/ffigen_symbols.dart';"),
      );
      expect(content, contains('const _import = LibraryImport('));
      expect(content, contains("'package:foo/foo.dart'"));
      expect(content, contains('const symbols = FfigenSymbols('));
      expect(content, contains("'c:@F@foo': ImportedType("));
    });

    test('generates YAML symbol file when extension is .yaml', () {
      final file = File('${tempDir.path}/symbols.yaml');
      final headerFile = File('${tempDir.path}/test.h')
        ..writeAsStringSync('void foo();\n');

      final config = FfiGenerator(
        output: Output(
          dart: DartOutput(path: Uri.file('${tempDir.path}/bindings.dart')),
        ),
        input: Input(entryPoints: [headerFile.uri]),
        visitors: [Visitor(func: (node) => node.isIncluded = true)],
      );
      final context = testContext(config);
      final library = parse(context);
      library.generate();
      library.generateSymbolOutputFile(file, 'package:foo/foo.dart');

      expect(file.existsSync(), isTrue);
      final content = file.readAsStringSync();
      expect(content, contains('format_version: 1.0.0'));
      expect(content, contains('package:foo/foo.dart:'));
      expect(content, contains('c:@F@foo:'));
      expect(content, contains('name: foo'));
    });

    test('createSymbols returns in-memory FfigenSymbols', () {
      final headerFile = File('${tempDir.path}/test.h')
        ..writeAsStringSync('void foo();\n');

      final config = FfiGenerator(
        output: Output(
          dart: DartOutput(path: Uri.file('${tempDir.path}/bindings.dart')),
        ),
        input: Input(entryPoints: [headerFile.uri]),
        visitors: [Visitor(func: (node) => node.isIncluded = true)],
      );
      final context = testContext(config);
      final library = parse(context);
      library.generate();
      final symbols = library.createSymbols('package:foo/foo.dart');

      expect(symbols.formatVersion, '1.0.0');
      expect(symbols.containsKey('c:@F@foo'), isTrue);
      final imported = symbols['c:@F@foo'];
      expect(imported, isNotNull);
      expect(imported!.cType, 'foo');
      expect(imported.dartType, 'foo');
      expect(imported.libraryImport.importPath(false), 'package:foo/foo.dart');
    });
  });

  group('FfiGeneratorResult', () {
    test(
      'generate returns FfiGeneratorResult with symbols when configured',
      () async {
        final headerFile = File('${tempDir.path}/test.h')
          ..writeAsStringSync('void foo();\n');
        final dartOutput = Uri.file('${tempDir.path}/result_bindings.dart');
        final symbolOutput = Uri.file('${tempDir.path}/result_symbols.dart');

        final config = FfiGenerator(
          output: Output(
            dart: DartOutput(path: dartOutput),
            symbolFile: SymbolFile(
              Uri.parse('package:result_pkg/result_bindings.dart'),
              symbolOutput,
            ),
          ),
          input: Input(entryPoints: [headerFile.uri]),
          visitors: [Visitor(func: (node) => node.isIncluded = true)],
        );

        final result = await config.generate(logger: createTestLogger());

        expect(result.dartFile.existsSync(), isTrue);
        expect(result.symbolFile, isNotNull);
        expect(result.symbolFile!.existsSync(), isTrue);
        expect(result.symbols, isNotNull);
        expect(result.symbols!.containsKey('c:@F@foo'), isTrue);
        expect(result.symbols!['c:@F@foo']!.cType, 'foo');
      },
    );

    test(
      'generate returns in-memory symbols when symbolFile output is null',
      () async {
        final headerFile = File('${tempDir.path}/test.h')
          ..writeAsStringSync('void foo();\n');
        final dartOutput = Uri.file('${tempDir.path}/in_mem_bindings.dart');

        final config = FfiGenerator(
          output: Output(
            dart: DartOutput(path: dartOutput),
            symbolFile: SymbolFile(
              Uri.parse('package:in_mem_pkg/in_mem_bindings.dart'),
            ),
          ),
          input: Input(entryPoints: [headerFile.uri]),
          visitors: [Visitor(func: (node) => node.isIncluded = true)],
        );

        final result = await config.generate(logger: createTestLogger());

        expect(result.dartFile.existsSync(), isTrue);
        expect(result.symbolFile, isNull);
        expect(result.symbols, isNotNull);
        expect(result.symbols!.containsKey('c:@F@foo'), isTrue);
      },
    );

    test(
      'generate returns null symbols when symbolFile is not configured',
      () async {
        final headerFile = File('${tempDir.path}/test.h')
          ..writeAsStringSync('void foo();\n');
        final dartOutput = Uri.file('${tempDir.path}/no_symbols_bindings.dart');

        final config = FfiGenerator(
          output: Output(dart: DartOutput(path: dartOutput)),
          input: Input(entryPoints: [headerFile.uri]),
          visitors: [Visitor(func: (node) => node.isIncluded = true)],
        );

        final result = await config.generate(logger: createTestLogger());

        expect(result.dartFile.existsSync(), isTrue);
        expect(result.symbolFile, isNull);
        expect(result.symbols, isNull);
      },
    );
  });
}
