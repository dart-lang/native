// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:jnigen/jnigen.dart';
import 'package:test/test.dart';

void main() {
  group('SymbolFile in JNIgen', () {
    late Directory tempDir;
    late File tempSymbolFile;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('jnigen_symbol_test_');
      tempSymbolFile = File('${tempDir.path}/test_symbols.yaml');
      tempSymbolFile.writeAsStringSync('''
version: 1.0.0
files:
  'test_pkg.dart':
    'com.example.TestClass':
      name: TestClass
      super_count: 1
      type_params:
        T:
          'java.lang.Object': DECLARED
      methods:
        'foo()V': 0
    'com.example.HiddenClass':
      name: HiddenClass
      super_count: 1
''');
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    test('loadSync parses custom symbol file and resolves default JNI types',
        () {
      final importType = SymbolFile.loadSync(
        symbolFiles: [tempSymbolFile.uri],
        hide: ['com.example.HiddenClass'],
      );

      // Custom class
      final testDecl = Declaration(binaryName: 'com.example.TestClass');
      final testType = importType(testDecl);
      expect(testType, isNotNull);
      expect(testType!.name, 'TestClass');
      expect(testType.typeParams, hasLength(1));
      expect(testType.typeParams.first.name, 'T');
      expect(testType.methodNumsAfterRenaming['foo()V'], 0);

      // Hidden class
      final hiddenDecl = Declaration(binaryName: 'com.example.HiddenClass');
      expect(importType(hiddenDecl), isNull);

      // Default JNI symbols
      final objDecl = Declaration(binaryName: 'java.lang.Object');
      final objType = importType(objDecl);
      expect(objType, isNotNull);
      expect(objType!.name, 'JObject');
      expect(objType.importPath, 'package:jni/jni.dart');

      final strDecl = Declaration(binaryName: 'java.lang.String');
      final strType = importType(strDecl);
      expect(strType, isNotNull);
      expect(strType!.name, 'JString');
      expect(strType.importPath, 'package:jni/jni.dart');

      // Unknown class
      final unknownDecl = Declaration(binaryName: 'com.unknown.Class');
      expect(importType(unknownDecl), isNull);
    });

    test('load (async) parses custom symbol file', () async {
      final importType = await SymbolFile.load(
        symbolFiles: [tempSymbolFile.uri],
        hide: ['com.example.HiddenClass'],
      );

      final testDecl = Declaration(binaryName: 'com.example.TestClass');
      final testType = importType(testDecl);
      expect(testType, isNotNull);
      expect(testType!.name, 'TestClass');

      final hiddenDecl = Declaration(binaryName: 'com.example.HiddenClass');
      expect(importType(hiddenDecl), isNull);
    });
  });
}
