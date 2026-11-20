// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/token.dart';

import 'text_chunk.dart';

/// Extracts natural text from comments in Dart source files using
/// `package:analyzer`.
class CommentExtractor {
  static final RegExp _backticksRegex = RegExp(r'`[^`]*`');
  static final RegExp _docRefRegex = RegExp(r'\[([^\]]+)\](?:\([^)]*\))?');
  static final RegExp _urlRegex = RegExp(r'https?://[^\s]+');

  /// Extracts comment text chunks from the given Dart file.
  List<TextChunk> extractFromFile(File file) {
    if (!file.existsSync()) return const [];
    final content = file.readAsStringSync();
    return extractFromString(content, filePath: file.path);
  }

  /// Extracts comment text chunks from Dart source code.
  List<TextChunk> extractFromString(
    String source, {
    String filePath = '<memory>',
  }) {
    final parseResult = parseString(
      content: source,
      featureSet: FeatureSet.latestLanguageVersion(),
      throwIfDiagnostics: false,
    );

    final lineInfo = parseResult.lineInfo;
    final chunks = <TextChunk>[];

    var inCodeFence = false;

    void processCommentToken(Token commentToken) {
      final lexeme = commentToken.lexeme;
      final startOffset = commentToken.offset;
      final location = lineInfo.getLocation(startOffset);

      // Split multiline block comments or process single line
      final lines = lexeme.split('\n');
      for (var i = 0; i < lines.length; i++) {
        var rawLine = lines[i];
        final currentLineNum = location.lineNumber + i;

        // Strip comment delimiters
        rawLine = rawLine.trim();
        if (rawLine.startsWith('///')) {
          rawLine = rawLine.substring(3);
        } else if (rawLine.startsWith('//')) {
          rawLine = rawLine.substring(2);
        } else if (rawLine.startsWith('/**')) {
          rawLine = rawLine.substring(3);
        } else if (rawLine.startsWith('/*')) {
          rawLine = rawLine.substring(2);
        }
        if (rawLine.endsWith('*/')) {
          rawLine = rawLine.substring(0, rawLine.length - 2);
        }
        if (rawLine.startsWith('*')) {
          rawLine = rawLine.substring(1);
        }

        final trimmed = rawLine.trim();

        // Check for markdown code fences within comments
        if (trimmed.startsWith('```')) {
          inCodeFence = !inCodeFence;
          continue;
        }

        if (inCodeFence || trimmed.isEmpty) {
          continue;
        }

        // Clean out inline code `foo`, URLs, and doc references [foo]
        var cleaned = rawLine;
        cleaned = cleaned.replaceAll(_backticksRegex, ' ');
        cleaned = cleaned.replaceAll(_urlRegex, ' ');
        cleaned = cleaned.replaceAllMapped(_docRefRegex, (match) {
          final target = match.group(1) ?? '';
          // If the bracketed text looks like a code identifier
          // (e.g. [MyClass], [foo.bar]), remove it.
          if (target.contains('.') ||
              target.contains('(') ||
              target.startsWith('_') ||
              RegExp(r'[A-Z]').hasMatch(target)) {
            return ' ';
          }
          return target; // regular bracketed text like [some words]
        });

        if (cleaned.trim().isNotEmpty) {
          chunks.add(
            TextChunk(
              text: cleaned,
              filePath: filePath,
              line: currentLineNum,
              column: 1,
            ),
          );
        }
      }
    }

    // Traverse all tokens and their preceding comments
    Token? token = parseResult.unit.beginToken;
    while (token != null) {
      Token? comment = token.precedingComments;
      while (comment != null) {
        processCommentToken(comment);
        comment = comment.next;
      }
      if (token.isEof) break;
      token = token.next;
    }

    return chunks;
  }
}
