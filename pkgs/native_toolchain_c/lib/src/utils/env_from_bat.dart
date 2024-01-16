// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

/// Extracts the environment variables set by [batchFile].
///
/// If provided, passes [arguments] to the batch file invocation.
///
/// Note: needs to run [batchFile] to extract the modifications to the
/// environment variables.
Future<Map<String, String>> environmentFromBatchFile(
  Uri batchFile, {
  List<String> arguments = const [],
}) async {
  final fileName = batchFile.pathSegments.last;
  final dir = batchFile.resolve('.');
  const separator = '=======';
  final processResult = await Process.run(
    'set && echo $separator && $fileName ${arguments.join(' ')} > nul && set',
    [],
    runInShell: true,
    workingDirectory: dir.toFilePath(),
  );
  assert(processResult.exitCode == 0);
  final resultSplit = (processResult.stdout as String).split(separator);
  assert(resultSplit.length == 2);
  final unmodifiedParsed = _parseDefines(resultSplit.first.trim());
  final modifiedParsed = _parseDefines(resultSplit[1].trim());
  final result = <String, String>{};
  for (final entry in modifiedParsed.entries) {
    final key = entry.key;
    final value = entry.value;
    if (!unmodifiedParsed.containsKey(key) || value != unmodifiedParsed[key]) {
      result[key] = value;
    }
  }
  return result;
}

/// Parses a string of defines.
///
/// Expected format is separate lines of `KEY=value`.
///
/// Ensures it doesn't return empty keys.
Map<String, String> _parseDefines(String defines) {
  final result = <String, String>{};
  final lines = defines.trim().split('\r\n');
  for (final line in lines) {
    if (line.isEmpty) continue;
    final lineSplit = line.split('=');
    final key = lineSplit.first;
    final value = lineSplit.skip(1).join('=');
    result[key] = value;
  }
  return result;
}
