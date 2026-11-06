// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')
library;

import 'dart:io';

import 'package:native_test_helpers/native_test_helpers.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../tool/ffigen.dart' as ffigen_tool;

void _matchFileWithExpected(Uri expectedUri, Uri actualUri) {
  final expectedPath = expectedUri.toFilePath();
  final expectedFile = File(expectedPath);
  final actualPath = actualUri.toFilePath();
  final actualFile = File(actualPath);

  final actualFileExists = actualFile.existsSync();
  final actualContent = actualFileExists
      ? actualFile.readAsStringSync().replaceAll('\r', '')
      : null;

  final expectedFileExists = expectedFile.existsSync();
  final expectedContent = expectedFileExists
      ? expectedFile.readAsStringSync().replaceAll('\r', '')
      : null;

  if (expectedContent != actualContent) {
    final String diff;
    if (expectedFileExists && actualFileExists) {
      diff = Process.runSync('git', [
        'diff',
        '--no-index',
        '--color=always',
        expectedPath,
        actualPath,
      ]).stdout.toString();
    } else if (expectedFileExists) {
      diff = "Expected file exists, but actual file doesn't";
    } else {
      diff = "Expected file doesn't exist, but actual file does";
    }

    fail('''
$diff

Expected output does not match actual output:
  ${p.relative(expectedPath)}
      vs
  ${p.relative(actualPath)}

Regenerate bindings with `dart run pkgs/objective_c/tool/ffigen.dart`.
''');
  }
}

void main() {
  group('ffigen.dart', () {
    test('Runs without exception', () async {
      final packageRoot = findPackageRoot('objective_c');
      final tempDir = Directory.fromUri(
        packageRoot.resolve('test/'),
      ).createTempSync();
      try {
        // As well as testing that the generated code is up to date, this also
        // generates coverage info for the parts of FFIgen that are gated by
        // generate-for-package-objective-c.
        await expectLater(
          ffigen_tool.run(
            format: true,
            packageRoot: packageRoot,
            outDir: tempDir.uri,
          ),
          completes,
        );

        // Sanity check the generated code.
        final rBindings = File.fromUri(
          tempDir.uri.resolve(ffigen_tool.runtimeBindings),
        ).readAsStringSync();
        expect(rBindings, contains('sel_registerName'));
        expect(rBindings, contains('objc_msgSend'));
        expect(rBindings, contains('_NSConcreteGlobalBlock'));
        expect(rBindings, contains('ObjCObject'));

        final cBindings = File.fromUri(
          tempDir.uri.resolve(ffigen_tool.cBindings),
        ).readAsStringSync();
        expect(cBindings, contains('createContext'));
        expect(cBindings, contains('DOBJC_Context'));
        expect(cBindings, contains('Dart_FinalizableHandle'));
        expect(cBindings, contains('ILLEGAL_PORT'));
        expect(cBindings, contains('ObjCBlockImpl'));

        final objcBindings = File.fromUri(
          tempDir.uri.resolve(ffigen_tool.objcBindings),
        ).readAsStringSync();
        expect(objcBindings, contains('class NSObject'));
        expect(objcBindings, contains('class NSString'));
        expect(objcBindings, contains('NSString(String str)'));

        for (final file in [
          ffigen_tool.runtimeBindings,
          ffigen_tool.cBindings,
          ffigen_tool.objcBindings,
          ffigen_tool.objcLangBindings,
          ffigen_tool.objcExports,
        ]) {
          _matchFileWithExpected(
            packageRoot.resolve(file),
            tempDir.uri.resolve(file),
          );
        }
        _matchFileWithExpected(
          packageRoot.resolve('../${ffigen_tool.builtInTypes}'),
          tempDir.uri.resolve(ffigen_tool.builtInTypes),
        );
      } finally {
        tempDir.deleteSync(recursive: true);
      }
    });
  });
}
