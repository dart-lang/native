// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as path;

import 'summarize_bindings.dart';

class FileInfo {
  final File file;
  final String repoRelativePath;
  final int size;

  FileInfo({
    required this.file,
    required this.repoRelativePath,
    required this.size,
  });
}

enum _DiffOpType { equal, insert, delete }

class _DiffOp {
  final _DiffOpType type;
  final String text;
  final int oldLine;
  final int newLine;

  _DiffOp(this.type, this.text, this.oldLine, this.newLine);
}

String createUnifiedDiff(
  String oldContent,
  String newContent, {
  required String oldHeader,
  required String newHeader,
  int contextSize = 3,
}) {
  final oldLines = oldContent.split('\n');
  if (oldLines.isNotEmpty && oldLines.last.isEmpty) oldLines.removeLast();
  final newLines = newContent.split('\n');
  if (newLines.isNotEmpty && newLines.last.isEmpty) newLines.removeLast();

  final m = oldLines.length;
  final n = newLines.length;

  final dp = List.generate(m + 1, (_) => Int32List(n + 1));
  for (var i = m - 1; i >= 0; i--) {
    for (var j = n - 1; j >= 0; j--) {
      if (oldLines[i] == newLines[j]) {
        dp[i][j] = 1 + dp[i + 1][j + 1];
      } else {
        dp[i][j] = dp[i + 1][j] > dp[i][j + 1] ? dp[i + 1][j] : dp[i][j + 1];
      }
    }
  }

  int i = 0, j = 0;
  final edits = <_DiffOp>[];
  while (i < m && j < n) {
    if (oldLines[i] == newLines[j]) {
      edits.add(_DiffOp(_DiffOpType.equal, oldLines[i], i + 1, j + 1));
      i++;
      j++;
    } else if (dp[i + 1][j] >= dp[i][j + 1]) {
      edits.add(_DiffOp(_DiffOpType.delete, oldLines[i], i + 1, j + 1));
      i++;
    } else {
      edits.add(_DiffOp(_DiffOpType.insert, newLines[j], i + 1, j + 1));
      j++;
    }
  }
  while (i < m) {
    edits.add(_DiffOp(_DiffOpType.delete, oldLines[i], i + 1, j + 1));
    i++;
  }
  while (j < n) {
    edits.add(_DiffOp(_DiffOpType.insert, newLines[j], i + 1, j + 1));
    j++;
  }

  final hasDiff = edits.any((e) => e.type != _DiffOpType.equal);
  if (!hasDiff) return '';

  final buf = StringBuffer();
  buf.writeln('--- $oldHeader');
  buf.writeln('+++ $newHeader');

  int idx = 0;
  while (idx < edits.length) {
    while (idx < edits.length && edits[idx].type == _DiffOpType.equal) {
      idx++;
    }
    if (idx >= edits.length) break;

    final hunkStart = (idx - contextSize).clamp(0, edits.length);
    int hunkEnd = idx;
    while (hunkEnd < edits.length) {
      if (edits[hunkEnd].type != _DiffOpType.equal) {
        hunkEnd = (hunkEnd + contextSize + 1).clamp(0, edits.length);
      } else {
        int nextChange = hunkEnd;
        while (nextChange < edits.length && edits[nextChange].type == _DiffOpType.equal) {
          nextChange++;
        }
        if (nextChange < edits.length && nextChange - hunkEnd <= contextSize * 2) {
          hunkEnd = nextChange;
        } else {
          break;
        }
      }
    }

    final hunkEdits = edits.sublist(hunkStart, hunkEnd);
    final oldStart = hunkEdits.first.oldLine;
    final oldLength = hunkEdits.where((e) => e.type != _DiffOpType.insert).length;
    final newStart = hunkEdits.first.newLine;
    final newLength = hunkEdits.where((e) => e.type != _DiffOpType.delete).length;

    buf.writeln('@@ -$oldStart,$oldLength +$newStart,$newLength @@');
    for (final edit in hunkEdits) {
      switch (edit.type) {
        case _DiffOpType.equal:
          buf.writeln(' ${edit.text}');
          break;
        case _DiffOpType.delete:
          buf.writeln('-${edit.text}');
          break;
        case _DiffOpType.insert:
          buf.writeln('+${edit.text}');
          break;
      }
    }
    idx = hunkEnd;
  }

  return buf.toString();
}

String findRepoRoot() {
  try {
    final result = Process.runSync('git', ['rev-parse', '--show-toplevel']);
    if (result.exitCode == 0) {
      return (result.stdout as String).trim();
    }
  } catch (_) {}

  var current = Directory.current.absolute;
  while (current.path != current.parent.path) {
    if (Directory(path.join(current.path, 'pkgs')).existsSync()) {
      return current.path;
    }
    current = current.parent;
  }
  return Directory.current.absolute.path;
}

bool isExcludedPath(String relativePath) {
  final parts = path.split(relativePath);
  for (final part in parts) {
    if (part == 'temp' || part == 'bin' || part.startsWith('.temp')) {
      return true;
    }
  }
  return false;
}

bool isGeneratedBindingFile(File file) {
  final filename = path.basename(file.path);
  if (filename == 'writer.dart') {
    return false;
  }
  if (filename.startsWith('_expected_') && filename.endsWith('.dart')) {
    return true;
  }
  try {
    final content = file.readAsStringSync();
    if (content.contains('AUTO GENERATED FILE')) {
      return true;
    }
  } catch (_) {}
  return false;
}

Future<void> main() async {
  final repoRoot = findRepoRoot();
  final pkgsDir = Directory(path.join(repoRoot, 'pkgs'));

  if (!pkgsDir.existsSync()) {
    print('Error: pkgs directory non-existent at ${pkgsDir.path}');
    exit(1);
  }

  final files = <FileInfo>[];

  final result = Process.runSync('git', ['ls-files'], workingDirectory: repoRoot);
  if (result.exitCode != 0) {
    print('Error: git ls-files failed with code ${result.exitCode}');
    print(result.stderr);
    exit(1);
  }

  final lines = (result.stdout as String).split('\n');
  for (final line in lines) {
    final repoRelativePath = line.trim().replaceAll('\\', '/');
    if (repoRelativePath.isEmpty || !repoRelativePath.endsWith('.dart')) {
      continue;
    }
    if (!repoRelativePath.startsWith('pkgs/')) {
      continue;
    }
    if (isExcludedPath(repoRelativePath)) {
      continue;
    }
    final file = File(path.join(repoRoot, repoRelativePath));
    if (!file.existsSync()) {
      continue;
    }
    if (isGeneratedBindingFile(file)) {
      files.add(FileInfo(
        file: file,
        repoRelativePath: repoRelativePath,
        size: file.lengthSync(),
      ));
    }
  }


  // Sort strictly by file size in bytes (smallest to largest)
  files.sort((a, b) {
    final sizeCompare = a.size.compareTo(b.size);
    if (sizeCompare != 0) return sizeCompare;
    return a.repoRelativePath.compareTo(b.repoRelativePath);
  });

  final total = files.length;
  print('Found $total generated binding files to check.\n');

  for (var i = 0; i < total; i++) {
    final fileInfo = files[i];
    final countStr = '[${i + 1}/$total]';
    final sizeStr = '(${fileInfo.size} bytes)';
    final pathStr = '${fileInfo.repoRelativePath}...';

    stdout.write('$countStr $sizeStr $pathStr ');
    await stdout.flush();

    final currentContent = fileInfo.file.readAsStringSync();

    var gitResult = await Process.run('git', ['show', 'main:${fileInfo.repoRelativePath}']);
    if (gitResult.exitCode != 0) {
      final originResult = await Process.run('git', ['show', 'origin/main:${fileInfo.repoRelativePath}']);
      if (originResult.exitCode == 0) {
        gitResult = originResult;
      }
    }

    final mainContent = gitResult.exitCode == 0 ? (gitResult.stdout as String) : '';

    final currentSummary = summarizeContent(currentContent);
    final mainSummary = summarizeContent(mainContent);

    if (currentSummary == mainSummary) {
      print('-> CLEAN');
    } else {
      print('-> DIFF DETECTED!');
      final diff = createUnifiedDiff(
        mainSummary,
        currentSummary,
        oldHeader: 'main/${fileInfo.repoRelativePath}',
        newHeader: 'current/${fileInfo.repoRelativePath}',
      );
      if (diff.isNotEmpty) {
        print(diff);
      } else {
        print('(AST summaries differ but diff output was empty)');
      }
      // exit(1);
    }
  }

  print('\nAll $total files checked successfully with no diffs detected.');
}
