// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

Future<Map<String, String>> envFromBat(Uri batchFile) async {
  final fileName = batchFile.pathSegments.last;
  final dir = batchFile.resolve('.');
  const separator = '=======';
  final processResult = await Process.run(
    'set && echo $separator && $fileName > nul && set',
    [],
    runInShell: true,
    environment: {
      'PATH': dir.toFilePath(),
    },
  );
  assert(processResult.exitCode == 0);
  final resultSplit = (processResult.stdout as String).split(separator);
  assert(resultSplit.length == 2);
  final unmodifiedParsed = parseDefines(resultSplit.first.trim());
  final modifiedParsed = parseDefines(resultSplit[1].trim());
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

Map<String, String> parseDefines(String defines) {
  final result = <String, String>{};
  final lines = defines.split('\r\n');
  for (final line in lines) {
    final lineSplit = line.split('=');
    final key = lineSplit.first;
    final value = lineSplit.skip(1).join('=');
    result[key] = value;
  }
  return result;
}
