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
  for (final package in ['hooks', 'code_assets', 'data_assets', 'record_use']) {
    final packageRoot = hooksPackageRoot.resolve('../$package/');

    final files = Directory.fromUri(packageRoot)
        .listSync(recursive: true)
        .whereType<File>()
        .where((e) => e.path.endsWith('.dart') || e.path.endsWith('.md'));

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

  final oldContentNormalized = oldContent.replaceAll('\r\n', '\n');
  newContent = updateSnippets(oldContentNormalized, file.uri, errors);

  final newContentNormalized = newContent.replaceAll('\r\n', '\n');
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
  var newContent = oldContent;

  final markers = RegExp(
    r'^([ \t]*/*[ ]?)```(\w*)',
    multiLine: true,
  ).allMatches(oldContent);

  if (markers.length % 2 != 0) {
    final lastMarker = markers.last;
    final line = oldContent.substring(0, lastMarker.start).split('\n').length;
    errors.add('Error: Unmatched ``` in $fileUri at line $line.');
  }

  for (var i = markers.length - 2; i >= 0; i -= 2) {
    final startMatch = markers.elementAt(i);
    final endMatch = markers.elementAt(i + 1);

    final prefix = startMatch.group(1)!;
    final prefixWithoutSpace = prefix.endsWith(' ')
        ? prefix.substring(0, prefix.length - 1)
        : prefix;
    final endPrefix = endMatch.group(1)!;

    if (prefix != endPrefix) {
      final line = oldContent.substring(0, startMatch.start).split('\n').length;
      errors.add(
        'Error: Mismatched prefixes for code block in $fileUri at line $line. '
        'Start prefix: "$prefix", end prefix: "$endPrefix"',
      );
      continue;
    }

    final contentStart = startMatch.end + 1;
    final contentEnd = endMatch.start;
    final content = oldContent.substring(contentStart, contentEnd);
    final contentLines = content.split('\n');

    var prefixesConsistent = true;
    for (var j = 0; j < contentLines.length; j++) {
      final line = contentLines[j];
      if (line.trim().isEmpty) continue;
      // Allow for empty lines at the end of the content.
      if (j == contentLines.length - 1 && line.isEmpty) continue;
      if (!line.startsWith(prefixWithoutSpace)) {
        final lineNumber =
            oldContent.substring(0, startMatch.end).split('\n').length + j;
        errors.add(
          'Error: Inconsistent prefix in code block in $fileUri on line '
          '$lineNumber. Expected prefix "$prefixWithoutSpace".',
        );
        prefixesConsistent = false;
        break;
      }
    }
    if (!prefixesConsistent) continue;

    final language = startMatch.group(2)!;
    if (language != 'dart') continue;

    final blockStartIndex = startMatch.start;
    final lastLineOfContentBefore =
        oldContent.substring(0, blockStartIndex).split('\n').length - 2;
    final lineBeforeText = oldContent.split('\n')[lastLineOfContentBefore];

    final fileLineMatch = RegExp(
      r'^(.*?)<!-- (?:file://./(\S+?)(?:#(\S+))?|(no-source-file)) -->\s*$',
    ).firstMatch(lineBeforeText);

    if (fileLineMatch == null) {
      final line = lastLineOfContentBefore + 1;
      errors.add(
        'Error: Did not find <!-- file://./... --> comment in $fileUri at line $line. ',
      );
      continue;
    }

    final fileLinePrefix = fileLineMatch.group(1)!;
    if (fileLinePrefix.trim() != prefix.trim()) {
      final line = oldContent.substring(0, blockStartIndex).split('\n').length;
      errors.add(
        'Error: Mismatched prefix for file metadata comment at $fileUri:$line. '
        'Expected "$prefix", found "$fileLinePrefix"',
      );
      continue;
    }

    final filePath = fileLineMatch.group(2);
    final anchor = fileLineMatch.group(3);
    final noSourceFile = fileLineMatch.group(4) != null;

    if (noSourceFile || filePath == null) continue;

    final snippetUri = fileUri.resolve(filePath);
    final snippetFile = File.fromUri(snippetUri);
    if (!snippetFile.existsSync()) {
      errors.add('Error: Snippet file not found: $snippetUri.');
      continue;
    }
    final snippetContent = snippetFile.readAsStringSync().replaceAll(
      '\r\n',
      '\n',
    );

    var newSnippetText = snippetContent;
    final String startMarker;
    final String endMarker;
    if (anchor == null) {
      startMarker = '// snippet-start';
      endMarker = '// snippet-end';
    } else {
      startMarker = '// snippet-start#$anchor';
      endMarker = '// snippet-end#$anchor';
    }

    final anchorRegex = RegExp(
      '${RegExp.escape(startMarker)}\\n([\\s\\S]*?)${RegExp.escape(endMarker)}',
      multiLine: true,
    );
    final extractedMatch = anchorRegex.firstMatch(snippetContent);
    if (extractedMatch != null) {
      newSnippetText = extractedMatch.group(1)!;
    } else {
      if (anchor != null) {
        errors.add('Error: Anchor "$anchor" not found in $snippetUri.');
        continue;
      }
      // If no anchor was specified and // snippet-start wasn't found,
      // we use the whole file (original behavior).
    }

    // Strip any (nested) snippet markers from the extracted content.
    final markerRegex = RegExp(
      r'^[ \t]*// snippet-(?:start|end)(?:#\S+)?[ \t]*\n?',
      multiLine: true,
    );
    newSnippetText = newSnippetText.replaceAll(markerRegex, '');

    newSnippetText = _dedent(newSnippetText);
    newSnippetText = newSnippetText.trim();

    final copyrightRegex = RegExp(r'''
// Copyright \(c\) [0-9]*, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
''');
    final copyrightHeader = copyrightRegex.firstMatch(newSnippetText);
    if (copyrightHeader != null) {
      newSnippetText = newSnippetText.replaceFirst(
        copyrightHeader.group(0)!,
        '',
      );
    }
    newSnippetText = newSnippetText.trim();

    final newContentForBlock = newSnippetText
        .split('\n')
        .map((l) => l.isEmpty ? prefixWithoutSpace : '$prefix$l')
        .join('\n');

    final trailingNewline = content.endsWith('\n') ? '\n' : '';
    newContent = newContent.replaceRange(
      contentStart,
      contentEnd,
      '$newContentForBlock$trailingNewline',
    );
  }

  return newContent;
}

String _dedent(String text) {
  final lines = text.split('\n');
  if (lines.isEmpty) return text;

  // Find minimum indentation of non-empty lines.
  int? minIndent;
  for (final line in lines) {
    if (line.trim().isEmpty) continue;
    final indent = line.length - line.trimLeft().length;
    if (minIndent == null || indent < minIndent) {
      minIndent = indent;
    }
  }

  if (minIndent == null || minIndent == 0) return text;

  return lines
      .map((line) {
        if (line.trim().isEmpty) return '';
        return line.substring(minIndent!);
      })
      .join('\n');
}
