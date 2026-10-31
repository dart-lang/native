// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'text_chunk.dart';

/// Extracts natural text from Markdown (.md) files, ignoring code blocks and
/// inline code.
class MarkdownExtractor {
  static final RegExp _backticksRegex = RegExp(r'`[^`]*`');
  static final RegExp _linkRegex = RegExp(r'\[([^\]]+)\]\([^)]+\)');
  static final RegExp _htmlTagRegex = RegExp(r'<[^>]+>');
  static final RegExp _urlRegex = RegExp(r'https?://[^\s]+');

  /// Extracts text chunks from a Markdown file.
  List<TextChunk> extractFromFile(File file) {
    if (!file.existsSync()) return const [];
    final content = file.readAsStringSync();
    return extractFromString(content, filePath: file.path);
  }

  /// Extracts text chunks from Markdown content string.
  List<TextChunk> extractFromString(
    String content, {
    String filePath = '<memory>',
  }) {
    final lines = content.replaceAll('\r\n', '\n').split('\n');
    final chunks = <TextChunk>[];

    var inCodeFence = false;
    var inHtmlComment = false;

    for (var i = 0; i < lines.length; i++) {
      final lineNum = i + 1;
      var line = lines[i];

      // Handle HTML comments
      if (inHtmlComment) {
        if (line.contains('-->')) {
          inHtmlComment = false;
          line = line.substring(line.indexOf('-->') + 3);
        } else {
          continue;
        }
      } else if (line.contains('<!--')) {
        if (line.contains('-->')) {
          line = line.replaceAll(RegExp(r'<!--.*?-->'), ' ');
        } else {
          inHtmlComment = true;
          line = line.substring(0, line.indexOf('<!--'));
        }
      }

      final trimmed = line.trim();

      // Check code block fences (``` or ~~~)
      if (trimmed.startsWith('```') || trimmed.startsWith('~~~')) {
        inCodeFence = !inCodeFence;
        continue;
      }

      if (inCodeFence || trimmed.isEmpty) {
        continue;
      }

      // Ignore markdown table divider lines (e.g. |---|---|)
      if (RegExp(r'^[|\s\-:]+$').hasMatch(trimmed) && trimmed.contains('-')) {
        continue;
      }

      // Clean inline elements
      var cleaned = line;
      cleaned = cleaned.replaceAll(_backticksRegex, ' ');
      cleaned = cleaned.replaceAll(_linkRegex, r'$1');
      cleaned = cleaned.replaceAll(_htmlTagRegex, ' ');
      cleaned = cleaned.replaceAll(_urlRegex, ' ');

      if (cleaned.trim().isNotEmpty) {
        chunks.add(
          TextChunk(
            text: cleaned,
            filePath: filePath,
            line: lineNum,
            column: 1,
          ),
        );
      }
    }

    return chunks;
  }
}
