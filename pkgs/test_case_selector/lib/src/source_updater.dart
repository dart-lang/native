// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:test/test.dart';

/// Updates a Dart source file with a generated Markdown table.
class SourceUpdater {
  final Uri tableUri;
  final String newTable;

  static const _regenerateEnvVar = 'REGENERATE_TEST_CONFIGS';

  SourceUpdater({
    required this.tableUri,
    required this.newTable,
  });

  /// Updates the file if the environment variable is set, or runs a test to
  /// check if the file is up-to-date.
  void updateOrValidate({bool? update}) {
    final file = File.fromUri(tableUri);
    final shouldUpdate =
        update ?? Platform.environment[_regenerateEnvVar] == 'true';

    if (shouldUpdate) {
      final content = file.readAsStringSync().replaceAll('\r\n', '\n');
      final lines = content.split('\n');

      // Ensure ignore_for_file is present.
      const ignoreLine = '// ignore_for_file: lines_longer_than_80_chars';
      if (!content.contains(ignoreLine)) {
        var insertIndex = 0;
        for (var i = 0; i < lines.length; i++) {
          if (lines[i].startsWith('//') || lines[i].trim().isEmpty) {
            insertIndex = i + 1;
          } else {
            break;
          }
        }
        lines.insert(insertIndex, ignoreLine);
        lines.insert(insertIndex + 1, '');
      }

      // Find where the TestCaseSelector is instantiated.
      var startIndex = -1;
      for (var i = 0; i < lines.length; i++) {
        if (lines[i].trim().startsWith('final configurations =')) {
          startIndex = i;
          break;
        }
      }

      if (startIndex != -1) {
        var firstCommentIndex = startIndex;
        while (firstCommentIndex > 0 &&
            lines[firstCommentIndex - 1].trim().startsWith('///')) {
          firstCommentIndex--;
        }

        final newLines = [
          ...lines.sublist(0, firstCommentIndex),
          newTable,
          ...lines.sublist(startIndex),
        ];
        file.writeAsStringSync(newLines.join('\n'));
      } else {
        throw StateError(
          'Could not find "final configurations =" in '
          '${tableUri.toFilePath()}.\n'
          'Ensure the file contains a top-level assignment for configurations.',
        );
      }
    } else {
      test('Test configuration table up-to-date', () {
        final content =
            file.existsSync()
                ? file.readAsStringSync().replaceAll('\r\n', '\n')
                : '';
        final actual = _extractTableFromDart(content);
        final expected = newTable.replaceAll('\r\n', '\n');
        expect(
          actual,
          expected,
          reason:
              'The test configurations table at $tableUri is not '
              'up-to-date. Please run the tests with $_regenerateEnvVar=true '
              'to regenerate it.',
        );
      });
    }
  }

  String _extractTableFromDart(String content) {
    final lines = content.split('\n');
    final tableLines = <String>[];
    var inTable = false;
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('///')) {
        final commentBody = trimmed.substring(3).trimLeft();
        if (commentBody.startsWith('This comment is generated.') ||
            commentBody.startsWith('| #')) {
          inTable = true;
        }
        if (inTable) {
          tableLines.add(line);
        }
      } else if (inTable) {
        break;
      }
    }
    return tableLines.join('\n');
  }
}
