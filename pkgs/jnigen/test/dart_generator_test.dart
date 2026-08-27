// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:jnigen/jnigen.dart';
import 'package:jnigen/src/bindings/dart_generator.dart';
import 'package:jnigen/src/bindings/linker.dart';
import 'package:jnigen/src/bindings/renamer.dart';
import 'package:jnigen/src/elements/elements.dart' as ast;
import 'package:test/test.dart';

import 'test_util/test_util.dart';

void main() async {
  await checkLocallyBuiltDependencies();

  test('OutsideInBuffer', () {
    final buffer = OutsideInBuffer();
    buffer.appendLeft('f(');
    buffer.prependRight('x)');
    buffer.appendLeft('g(');
    buffer.prependRight('y) + ');
    expect(buffer.toString(), 'f(g(y) + x)');
  });

  group('escapeDartString', () {
    test('leaves ordinary text unchanged', () {
      expect(
        escapeDartString('Use another method instead.'),
        'Use another method instead.',
      );
    });

    test('escapes backspace', () {
      expect(
        escapeDartString('\b'),
        r'\b',
      );
    });

    test('escapes newline', () {
      expect(
        escapeDartString('\n'),
        r'\n',
      );
    });

    test('escapes form feed', () {
      expect(
        escapeDartString('\f'),
        r'\f',
      );
    });

    test('escapes vertical tab', () {
      expect(
        escapeDartString('\v'),
        r'\v',
      );
    });

    test('escapes carriage return', () {
      expect(
        escapeDartString('\r'),
        r'\r',
      );
    });

    test('escapes tab', () {
      expect(
        escapeDartString('\t'),
        r'\t',
      );
    });

    test('escapes single quote', () {
      expect(
        escapeDartString("'"),
        r"\'",
      );
    });

    test('escapes backslash', () {
      expect(
        escapeDartString('\\'),
        r'\\',
      );
    });

    test('escapes dollar sign', () {
      expect(
        escapeDartString(r'$'),
        r'\$',
      );
    });

    test('preserves unicode text', () {
      expect(
        escapeDartString('Deprecated café'),
        'Deprecated café',
      );
    });

    test('escapes mixed text correctly', () {
      expect(
        escapeDartString('Hello\nWorld\t\$100'),
        r'Hello\nWorld\t\$100',
      );
    });
  });

  test('generates javadoc.io fallback when method Javadoc is missing',
      () async {
    final tempDirectory = Directory.systemTemp.createTempSync(
      'jnigen_javadoc_fallback_test_',
    );
    addTearDown(() => tempDirectory.deleteSync(recursive: true));

    final output = tempDirectory.uri.resolve('bindings.dart');

    final config = Config(
      input: Input(
        classes: ['com.google.gson.Gson'],
        mavenDownloads: MavenDownloads(
          sourceDeps: [
            'com.google.code.gson:gson:2.13.1',
          ],
        ),
      ),
      output: Output(
        dart: DartCodeOutput(
          path: output,
          structure: OutputStructure.singleFile,
        ),
      ),
    );

    final classes = ast.Classes({
      'com.google.gson.Gson': ast.ClassDecl(
        binaryName: 'com.google.gson.Gson',
        declKind: ast.DeclKind.classKind,
        superclass: ast.DeclaredType.object,
        methods: [
          ast.Method(
            name: 'example',
            returnType: ast.PrimitiveType.fromJson({'name': 'void'}),
          ),
        ],
      ),
    });

    await classes.accept(Linker(config));
    classes.accept(Renamer(config));
    await classes.accept(DartGenerator(config));

    final content = File.fromUri(output).readAsStringSync();

    expect(
      content,
      contains(
        '/// See the [Java documentation]('
        'https://javadoc.io/doc/com.google.code.gson/gson/2.13.1).',
      ),
    );
  });

  test('prefers existing Javadoc over javadoc.io fallback', () async {
    final tempDirectory = Directory.systemTemp.createTempSync(
      'jnigen_existing_javadoc_test_',
    );
    addTearDown(() => tempDirectory.deleteSync(recursive: true));

    final output = tempDirectory.uri.resolve('bindings.dart');

    final config = Config(
      input: Input(
        classes: ['com.google.gson.Gson'],
        mavenDownloads: MavenDownloads(
          sourceDeps: [
            'com.google.code.gson:gson:2.13.1',
          ],
        ),
      ),
      output: Output(
        dart: DartCodeOutput(
          path: output,
          structure: OutputStructure.singleFile,
        ),
      ),
    );

    final classes = ast.Classes({
      'com.google.gson.Gson': ast.ClassDecl(
        binaryName: 'com.google.gson.Gson',
        declKind: ast.DeclKind.classKind,
        superclass: ast.DeclaredType.object,
        methods: [
          ast.Method(
            name: 'example',
            javadoc: ast.JavaDocComment(
              comment: 'Existing Java documentation.',
            ),
            returnType: ast.PrimitiveType.fromJson({'name': 'void'}),
          ),
        ],
      ),
    });

    await classes.accept(Linker(config));
    classes.accept(Renamer(config));
    await classes.accept(DartGenerator(config));

    final content = File.fromUri(output).readAsStringSync();

    expect(
      content,
      contains('Existing Java documentation.'),
    );

    expect(
      content,
      isNot(contains('https://javadoc.io/')),
    );
  });
}
