// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:test/test.dart';
import 'package:test_case_selector/src/source_updater.dart';

void main() {
  group('SourceUpdater', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('source_updater_test');
    });

    tearDown(() async {
      await tempDir.delete(recursive: true);
    });

    test('updates file with table and ignore line', () {
      final file = File.fromUri(tempDir.uri.resolve('my_test.dart'));
      file.writeAsStringSync('''
// Copyright header

final configurations = TestCaseSelector(
  // ...
);
''');

      const newTable = '''
/// This comment is generated. To regenerate, run:
/// `REGENERATE_TEST_CONFIGS=true dart test`
///
/// | #   | Vehicle Type |
/// |-----|--------------|
/// | 1   | bicycle      |
''';

      final updater = SourceUpdater(
        tableUri: file.uri,
        newTable: newTable,
      );

      updater.updateOrValidate(update: true);

      final content = file.readAsStringSync();
      expect(
        content,
        contains('// ignore_for_file: lines_longer_than_80_chars'),
      );
      expect(content, contains('/// | #   | Vehicle Type |'));
      expect(content, contains('final configurations ='));
    });

    test('replaces existing doc comments', () {
      final file = File.fromUri(tempDir.uri.resolve('my_test.dart'));
      file.writeAsStringSync('''
// Copyright header

// ignore_for_file: lines_longer_than_80_chars

/// Old table
/// | # |
/// |---|
final configurations = TestCaseSelector(
  // ...
);
''');

      const newTable = '''
/// New table
/// | # |
/// |---|
''';

      final updater = SourceUpdater(
        tableUri: file.uri,
        newTable: newTable,
      );

      updater.updateOrValidate(update: true);

      final content = file.readAsStringSync();
      expect(content, isNot(contains('Old table')));
      expect(content, contains('/// New table'));
      expect(content, contains('final configurations ='));
    });
  });
}
