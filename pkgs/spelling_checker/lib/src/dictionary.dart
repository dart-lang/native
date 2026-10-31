// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

/// Manages word lists, dictionaries, and allowlists for spell checking.
class Dictionary {
  final Set<String> _words = <String>{};
  final List<String> _headers = <String>[];

  Dictionary();

  /// Loads words from a file, ignoring `#` comments and empty lines.
  factory Dictionary.fromFile(File file) {
    final dict = Dictionary();
    if (!file.existsSync()) return dict;
    dict.loadString(file.readAsStringSync());
    return dict;
  }

  /// Loads words from a string.
  void loadString(String content) {
    final lines = content.replaceAll('\r\n', '\n').split('\n');
    var isHeader = true;

    for (final rawLine in lines) {
      final line = rawLine.trim();

      if (line.startsWith('#')) {
        if (isHeader) {
          _headers.add(rawLine);
        }
        continue;
      }

      if (line.isEmpty) {
        if (isHeader && _headers.isNotEmpty) {
          _headers.add(rawLine);
        }
        continue;
      }

      isHeader = false;

      // Strip inline comments if separated by space + '#'
      var word = line;
      final hashIndex = word.indexOf(' #');
      if (hashIndex != -1) {
        word = word.substring(0, hashIndex).trim();
      }

      if (word.isNotEmpty) {
        _words.add(word.toLowerCase());
      }
    }
  }

  bool contains(String word) => _words.contains(word.toLowerCase());

  void add(String word) {
    if (word.isNotEmpty) {
      _words.add(word.toLowerCase());
    }
  }

  void addAll(Iterable<String> words) {
    for (final word in words) {
      add(word);
    }
  }

  Set<String> get words => Set.unmodifiable(_words);

  /// Finds close matches within 1-edit distance (insert, delete, replace).
  List<String> findAlternatives(String word) {
    final w = word.toLowerCase();
    final alternatives = <String>{};

    bool check(String candidate) {
      return _words.contains(candidate);
    }

    // Try deletion
    for (var i = 0; i < w.length; i++) {
      final deleted = w.substring(0, i) + w.substring(i + 1);
      if (check(deleted)) alternatives.add(deleted);
    }

    // Try replacement
    for (var i = 0; i < w.length; i++) {
      for (var c = 97; c <= 122; c++) {
        final char = String.fromCharCode(c);
        final replaced = w.substring(0, i) + char + w.substring(i + 1);
        if (replaced != w && check(replaced)) alternatives.add(replaced);
      }
    }

    // Try insertion
    for (var i = 0; i <= w.length; i++) {
      for (var c = 97; c <= 122; c++) {
        final char = String.fromCharCode(c);
        final inserted = w.substring(0, i) + char + w.substring(i);
        if (check(inserted)) alternatives.add(inserted);
      }
    }

    return alternatives.toList()..sort();
  }

  /// Writes back sorted words with the original header.
  void saveToFile(File file) {
    final sortedWords = _words.toList()..sort();
    final buffer = StringBuffer();

    if (_headers.isNotEmpty) {
      for (final header in _headers) {
        buffer.writeln(header);
      }
      if (_headers.last.isNotEmpty) {
        buffer.writeln();
      }
    }

    for (final word in sortedWords) {
      buffer.writeln(word);
    }

    file.createSync(recursive: true);
    file.writeAsStringSync(buffer.toString());
  }
}
