// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:args/args.dart';
import 'package:native_test_helpers/native_test_helpers.dart';

void main(List<String> args) {
  final stopwatch = Stopwatch()..start();
  final parser = ArgParser()
    ..addFlag(
      'set-exit-if-changed',
      negatable: false,
      help: 'Return a non-zero exit code if any files were changed.',
    );
  final argResults = parser.parse(args);
  final setExitIfChanged = argResults['set-exit-if-changed'] as bool;

  final counts = Counts();
  final errors = <String>[];
  final hooksPackageRoot = findPackageRoot('hooks');
  for (final package in ['hooks', 'code_assets', 'data_assets']) {
    final packageRoot = hooksPackageRoot.resolve('../$package/');

    final files = Directory.fromUri(packageRoot)
        .listSync(recursive: true)
        .whereType<File>()
        .where((e) => e.path.endsWith('.dart'));

    for (final file in files) {
      updateSnippetsInFile(file, counts, errors);
    }
  }

  stopwatch.stop();
  final duration = stopwatch.elapsedMilliseconds / 1000.0;
  print(
    'Processed ${counts.processed} files (${counts.changed} changed) in '
    '${duration.toStringAsFixed(2)} seconds.',
  );

  if (errors.isNotEmpty) {
    for (final error in errors) {
      print(error);
    }
    print('See pkgs/hooks/CONTRIBUTING.md for details.');
    exit(1);
  }

  if (setExitIfChanged && counts.changed > 0) {
    exit(1);
  }
}

void updateSnippetsInFile(File file, Counts counts, List<String> errors) {
  final oldContent = file.readAsStringSync();
  var newContent = oldContent;

  newContent = updateSnippets(oldContent, file.uri, errors);

  final newContentNormalized = newContent.replaceAll('\r\n', '\n');
  final oldContentNormalized = oldContent.replaceAll('\r\n', '\n');
  if (newContentNormalized != oldContentNormalized) {
    file.writeAsStringSync(newContent);
    print('Updated snippets in ${file.uri} (content changed)');
    counts.changed++;
  }
  counts.processed++;
}

class Counts {
  int processed = 0;
  int changed = 0;
}

String updateSnippets(String oldContent, Uri fileUri, List<String> errors) {
  final codeBlockRegex = RegExp(
    r'((?:\s*/// <!-- (?:file://(\S+)|(no-source-file)) -->\n)?)(\s*)/// ```(\w+)\n([\s\S]*?)(?=\n\s*/// ```)\n\s*/// ```',
    multiLine: true,
  );

  return oldContent.replaceAllMapped(codeBlockRegex, (match) {
    final fileLine = match.group(1);
    final filePath = match.group(2);
    final noSourceFile = match.group(3) != null;
    final indent = match.group(4) ?? '';
    final language = match.group(5);

    if (language == null) {
      errors.add('Error: Code block without language in $fileUri.');
      return match.group(0)!;
    }

    if (language == 'dart') {
      if (noSourceFile) {
        return match.group(0)!;
      }

      if (filePath == null) {
        errors.add('Error: Dart code without a source file in $fileUri.');
        return match.group(0)!;
      }

      final snippetUri = fileUri.resolve(filePath);
      final snippetFile = File.fromUri(snippetUri);
      if (!snippetFile.existsSync()) {
        errors.add('Error: Snippet file not found: $snippetUri.');
        return match.group(0)!;
      }
      final snippetContent = snippetFile.readAsStringSync();

      var newContent = snippetContent;
      final anchorRegex = RegExp(
        r'// snippet-start\n([\s\S]*?)// snippet-end',
        multiLine: true,
      );
      final extractedMatch = anchorRegex.firstMatch(snippetContent);
      if (extractedMatch != null) {
        newContent = extractedMatch.group(1)!;
      }

      newContent = newContent.trim();

      final newBlock = StringBuffer();
      newBlock.write(fileLine ?? '');
      newBlock.write('$indent/// ```$language\n');
      newBlock.write(
        newContent
            .split('\n')
            .map((line) => line.isEmpty ? '$indent///' : '$indent/// $line')
            .join('\n'),
      );
      newBlock.write('\n$indent/// ```');

      return newBlock.toString();
    }

    return match.group(0)!;
  });
}
