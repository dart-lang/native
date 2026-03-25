// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'test_case.dart';

/// Renders a list of [TestCase]s as a Markdown table.
class MarkdownRenderer {
  final List<TestCase> testCases;
  final List<Type> dimensionTypes;
  final String prefix;

  MarkdownRenderer({
    required this.testCases,
    required this.dimensionTypes,
    this.prefix = '',
  });

  /// Renders the Markdown table as a string.
  String render() {
    if (testCases.isEmpty) return '';

    // 1. Gather all strings for the table.
    final headerStrings = [
      '#',
      ...dimensionTypes.map((t) {
        // Default: split CamelCase into spaces (e.g., AndroidApiLevel ->
        // Android Api Level).
        return t
            .toString()
            .split('.')
            .last
            .replaceAllMapped(
              RegExp(r'([a-z])([A-Z])'),
              (match) => '${match.group(1)} ${match.group(2)}',
            );
      }),
    ];

    final rowStrings =
        testCases
            .map(
              (config) =>
                  dimensionTypes
                      .map((t) => config.values[t]!.toString())
                      .toList(),
            )
            .toList();

    // 2. Sort rows alphabetically based on the first column.
    rowStrings.sort((a, b) {
      for (var i = 0; i < a.length; i++) {
        final cmp = a[i].compareTo(b[i]);
        if (cmp != 0) return cmp;
      }
      return 0;
    });

    // 3. Add numbering.
    for (var i = 0; i < rowStrings.length; i++) {
      rowStrings[i].insert(0, (i + 1).toString());
    }

    // 4. Calculate max width for each column.
    final numColumns = dimensionTypes.length + 1;
    final columnWidths = List<int>.filled(numColumns, 0);
    for (var i = 0; i < numColumns; i++) {
      columnWidths[i] = headerStrings[i].length;
      for (final row in rowStrings) {
        if (row[i].length > columnWidths[i]) {
          columnWidths[i] = row[i].length;
        }
      }
      // Ensure a minimum width for the separator (---)
      if (columnWidths[i] < 3) columnWidths[i] = 3;
    }

    // 5. Format rows with padding.
    String formatRow(List<String> cells) {
      final paddedCells = <String>[];
      for (var i = 0; i < cells.length; i++) {
        paddedCells.add(cells[i].padRight(columnWidths[i]));
      }
      return '$prefix| ${paddedCells.join(' | ')} |';
    }

    final header = formatRow(headerStrings);
    final separator = formatRow(
      List<String>.filled(
        numColumns,
        '---',
      ).map((s) => s.substring(0, 3)).toList(),
    ).replaceAll(' ', '-'); // Make separator look like | --- | --- |
    // But don't replace the prefix spaces if any.
    final actualSeparator = prefix + separator.substring(prefix.length);

    final rows = rowStrings.map(formatRow);

    return [
      '${prefix}This comment is generated. To regenerate, run:',
      '$prefix`REGENERATE_TEST_CONFIGS=true dart test`',
      prefix.trimRight(),
      header,
      actualSeparator,
      ...rows,
    ].join('\n');
  }
}
