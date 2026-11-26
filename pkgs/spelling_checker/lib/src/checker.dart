// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dictionary.dart';
import 'text_chunk.dart';

/// Core spell checker that validates words in extracted text against
/// dictionaries and allowlists.
class SpellingChecker {
  final List<Dictionary> dictionaries;

  static const _commonAbbreviations = {
    'e.g.',
    'e.g',
    'i.e.',
    'i.e',
    'etc.',
    'etc',
    'ex.',
  };

  SpellingChecker({required this.dictionaries});

  /// Checks the given text chunks and returns any detected spelling issues.
  List<SpellingIssue> checkChunks(List<TextChunk> chunks) {
    final issues = <SpellingIssue>[];

    for (final chunk in chunks) {
      final wordsWithCols = _splitIntoWords(chunk.text);

      for (final entry in wordsWithCols) {
        final col = entry.column;
        final rawWord = entry.word;
        final cleaned = _cleanWord(rawWord);

        if (cleaned.isEmpty) continue;

        if (!isValidWord(cleaned)) {
          final suggestions = findAlternatives(cleaned);
          issues.add(
            SpellingIssue(
              filePath: chunk.filePath,
              line: chunk.line,
              column: col,
              word: cleaned,
              suggestions: suggestions,
            ),
          );
        }
      }
    }

    return issues;
  }

  /// Checks if a single word is spelled correctly or allowed.
  bool isValidWord(String cleaned) {
    if (cleaned.isEmpty) return true;

    final lower = cleaned.toLowerCase();
    if (_commonAbbreviations.contains(lower)) return true;

    // Skip numbers, hex literals, hashes, version numbers (e.g. 1.2.3, 0x12)
    if (RegExp(r'^[0-9]').hasMatch(cleaned)) return true;
    if (RegExp(r'^[0-9a-fA-F]+$').hasMatch(cleaned) && cleaned.length >= 8) {
      return true; // likely a hash/commit/UUID
    }

    // Skip snake_case identifiers or symbols containing underscores
    if (cleaned.contains('_')) return true;

    // Check hyphenated words (e.g., Objective-C, pre-built, cross-platform)
    if (cleaned.contains('-')) {
      if (_checkInDictionaries(cleaned)) return true;
      final subWords = cleaned.split('-');
      if (subWords.every(isValidWord)) return true;
      return false;
    }

    // Direct lookup
    if (_checkInDictionaries(lower)) return true;

    // Standard English suffix heuristics if base word isn't listed with
    // every inflection.
    if (lower.endsWith("'s") &&
        _checkInDictionaries(lower.substring(0, lower.length - 2))) {
      return true;
    }
    if (lower.endsWith('s') &&
        lower.length > 3 &&
        _checkInDictionaries(lower.substring(0, lower.length - 1))) {
      return true;
    }
    if (lower.endsWith('es') &&
        lower.length > 4 &&
        _checkInDictionaries(lower.substring(0, lower.length - 2))) {
      return true;
    }
    if (lower.endsWith('ed') && lower.length > 4) {
      if (_checkInDictionaries(lower.substring(0, lower.length - 2))) {
        return true;
      }
      if (_checkInDictionaries(lower.substring(0, lower.length - 1))) {
        return true; // e.g. close -> closed
      }
    }
    if (lower.endsWith('ing') && lower.length > 5) {
      if (_checkInDictionaries(lower.substring(0, lower.length - 3))) {
        return true;
      }
      if (_checkInDictionaries('${lower.substring(0, lower.length - 3)}e')) {
        return true; // e.g. make -> making
      }
    }
    if (lower.endsWith('ly') &&
        lower.length > 4 &&
        _checkInDictionaries(lower.substring(0, lower.length - 2))) {
      return true;
    }

    return false;
  }

  bool _checkInDictionaries(String word) {
    final lower = word.toLowerCase();
    for (final dict in dictionaries) {
      if (dict.contains(lower)) return true;
    }
    return false;
  }

  /// Suggests closest matching alternative words.
  List<String> findAlternatives(String word) {
    final alternatives = <String>{};
    final cleaned = _cleanWord(word);
    for (final dict in dictionaries) {
      alternatives.addAll(dict.findAlternatives(cleaned));
    }
    return alternatives.toList()..sort();
  }

  static String _cleanWord(String word) {
    final lower = word.toLowerCase();
    if (_commonAbbreviations.contains(lower)) return lower;

    var start = 0;
    var end = word.length;

    while (start < end && _isPunctuation(word.codeUnitAt(start))) {
      start++;
    }
    while (end > start && _isPunctuation(word.codeUnitAt(end - 1))) {
      end--;
    }

    if (start >= end) return '';
    var result = word.substring(start, end);

    if (result.endsWith("'s") || result.endsWith('’s')) {
      result = result.substring(0, result.length - 2);
    }

    return result;
  }

  static bool _isPunctuation(int code) {
    // Keep letters, digits, and hyphens (for hyphenated words)
    if (code >= 65 && code <= 90) return false; // A-Z
    if (code >= 97 && code <= 122) return false; // a-z
    if (code >= 48 && code <= 57) return false; // 0-9
    if (code == 45) return false; // - (hyphen)
    return true;
  }

  List<_WordWithCol> _splitIntoWords(String text) {
    final results = <_WordWithCol>[];
    // Split on whitespace and slashes, pipes, ampersands, brackets, parentheses
    final regex = RegExp(r'[^\s/|&()\[\]{}]+');

    for (final match in regex.allMatches(text)) {
      final word = match.group(0)!;
      results.add(_WordWithCol(word: word, column: match.start + 1));
    }

    return results;
  }
}

class _WordWithCol {
  final String word;
  final int column;

  _WordWithCol({required this.word, required this.column});
}
