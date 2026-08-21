// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:ffigen/ffigen.dart';
import 'package:test/test.dart';

void main() {
  group('SymbolFile.load', () {
    late Directory tempDir;
    late File tempSymbolFile;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('ffigen_symbol_test_');
      tempSymbolFile = File('${tempDir.path}/test_symbols.yaml');
      tempSymbolFile.writeAsStringSync('''
format_version: '1.0.0'
files:
  'package:test_pkg/test_pkg.dart':
    symbols:
      'c:@S@TestStruct':
        name: 'TestStruct'
        dart-name: 'TestStructDart'
      'c:@F@testFunction':
        name: 'testFunction'
''');
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    test('loads symbols and resolves declarations via callback', () {
      final importType = SymbolFile.load([tempSymbolFile.uri]);

      final structDecl = Declaration(
        usr: 'c:@S@TestStruct',
        originalName: 'TestStruct',
      );
      final structType = importType(structDecl);
      expect(structType, isNotNull);
      expect(structType!.cType, 'TestStruct');
      expect(structType.dartType, 'TestStructDart');
      expect(
        structType.libraryImport.importPath(false),
        'package:test_pkg/test_pkg.dart',
      );

      final funcDecl = Declaration(
        usr: 'c:@F@testFunction',
        originalName: 'testFunction',
      );
      final funcType = importType(funcDecl);
      expect(funcType, isNotNull);
      expect(funcType!.cType, 'testFunction');

      final unknownDecl = Declaration(
        usr: 'c:@S@Unknown',
        originalName: 'Unknown',
      );
      expect(importType(unknownDecl), isNull);
    });

    test('importFromSymbolFiles works identically', () {
      final importType = importFromSymbolFiles([tempSymbolFile.uri]);
      final structDecl = Declaration(
        usr: 'c:@S@TestStruct',
        originalName: 'TestStruct',
      );
      expect(importType(structDecl)?.cType, 'TestStruct');
    });
  });
}
