// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Represents a chunk of natural text extracted from a file for spell-checking.
class TextChunk {
  final String text;
  final String filePath;
  final int line;
  final int column;

  const TextChunk({
    required this.text,
    required this.filePath,
    required this.line,
    required this.column,
  });

  @override
  String toString() => '$filePath:$line:$column: "$text"';
}

/// Represents a detected misspelling.
class SpellingIssue {
  final String filePath;
  final int line;
  final int column;
  final String word;
  final List<String> suggestions;

  const SpellingIssue({
    required this.filePath,
    required this.line,
    required this.column,
    required this.word,
    this.suggestions = const [],
  });

  @override
  String toString() {
    final buffer = StringBuffer(
      '$filePath:$line:$column: Misspelled word \'$word\'',
    );
    if (suggestions.isNotEmpty) {
      buffer.write(' (did you mean: ${suggestions.take(3).join(', ')}?)');
    }
    return buffer.toString();
  }
}
