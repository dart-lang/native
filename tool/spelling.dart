// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart' as p;
import 'package:spelling_checker/spelling_checker.dart';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addFlag(
      'set-exit-if-changed',
      negatable: false,
      help: 'Return a non-zero exit code if any spelling mistakes are found.',
    )
    ..addFlag(
      'update-allowlist',
      negatable: false,
      help:
          'Automatically append unrecognized words to tool/spelling_allowlist.txt.',
    )
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Prints this help message.',
    );

  final argResults = parser.parse(arguments);

  if (argResults['help'] as bool) {
    print('Usage: dart tool/spelling.dart [options] [directories or files]');
    print(parser.usage);
    return;
  }

  final repoRoot = Platform.script.resolve('../');
  final commonWordsFile = File.fromUri(
    repoRoot.resolve('pkgs/spelling_checker/data/common_words.txt'),
  );
  final codeWordsFile = File.fromUri(
    repoRoot.resolve('pkgs/spelling_checker/data/code_words.txt'),
  );
  final allowlistFile = File.fromUri(
    repoRoot.resolve('tool/spelling_allowlist.txt'),
  );

  final commonDict = Dictionary.fromFile(commonWordsFile);
  final codeDict = Dictionary.fromFile(codeWordsFile);
  final allowlistDict = Dictionary.fromFile(allowlistFile);

  final checker = SpellingChecker(
    dictionaries: [commonDict, codeDict, allowlistDict],
  );
  final commentExtractor = CommentExtractor();
  final markdownExtractor = MarkdownExtractor();

  final targets = argResults.rest.isEmpty ? ['.'] : argResults.rest;
  final updateAllowlist = argResults['update-allowlist'] as bool;
  final setExitIfChanged = argResults['set-exit-if-changed'] as bool;

  final filesToCheck = <File>[];
  for (final target in targets) {
    final entityType = FileSystemEntity.typeSync(target);
    if (entityType == FileSystemEntityType.file) {
      filesToCheck.add(File(target));
    } else if (entityType == FileSystemEntityType.directory) {
      await for (final entity in Directory(target).list(recursive: true)) {
        if (entity is File) {
          final path = entity.path;
          if (_isIgnored(path)) continue;
          if (path.endsWith('.dart') || path.endsWith('.md')) {
            filesToCheck.add(entity);
          }
        }
      }
    }
  }

  var totalIssues = 0;
  final newWords = <String>{};
  final stopwatch = Stopwatch()..start();

  for (final file in filesToCheck) {
    List<TextChunk> chunks;
    if (file.path.endsWith('.dart')) {
      chunks = commentExtractor.extractFromFile(file);
    } else if (file.path.endsWith('.md')) {
      chunks = markdownExtractor.extractFromFile(file);
    } else {
      continue;
    }

    final issues = checker.checkChunks(chunks);
    if (issues.isNotEmpty) {
      totalIssues += issues.length;
      for (final issue in issues) {
        final relPath = p.relative(issue.filePath, from: repoRoot.toFilePath());
        final suggestionText = issue.suggestions.isNotEmpty
            ? " (did you mean: ${issue.suggestions.take(3).join(', ')}?)"
            : '';
        print(
          '$relPath:${issue.line}:${issue.column}: '
          'Misspelled word \'${issue.word}\'$suggestionText',
        );
        newWords.add(issue.word.toLowerCase());
      }
    }
  }

  final seconds = (stopwatch.elapsedMilliseconds / 1000.0).toStringAsFixed(2);

  if (updateAllowlist && newWords.isNotEmpty) {
    allowlistDict.addAll(newWords);
    allowlistDict.saveToFile(allowlistFile);
    print('Updated ${allowlistFile.path} with ${newWords.length} words.');
  }

  if (totalIssues > 0) {
    print(
      'Checked ${filesToCheck.length} files in $seconds s. '
      'Found $totalIssues spelling issue(s).',
    );
    if (setExitIfChanged && !updateAllowlist) {
      exit(1);
    }
  } else {
    print(
      'Checked ${filesToCheck.length} files in $seconds s. '
      'No spelling issues found.',
    );
  }
}

bool _isIgnored(String filePath) {
  final segments = filePath.split(RegExp(r'[/\\]'));
  for (final segment in segments) {
    if (segment == '.dart_tool' ||
        segment == '.git' ||
        segment == '.jj' ||
        segment == 'build' ||
        segment == 'ephemeral' ||
        segment == 'third_party') {
      return true;
    }
  }
  return false;
}
