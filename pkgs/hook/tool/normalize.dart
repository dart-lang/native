// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;

import '../test/schema/helpers.dart' show packageUri;

void main() {
  final directories = [
    Directory.fromUri(packageUri),
    Directory.fromUri(packageUri.resolve('../code_assets/')),
    Directory.fromUri(packageUri.resolve('../data_assets/')),
  ];
  for (final directory in directories) {
    processDirectory(directory);
  }
}

void processDirectory(Directory directory) {
  final stream = directory.listSync(recursive: true);
  for (final entity in stream) {
    if (entity is File &&
        p.extension(entity.path) == '.json' &&
        !entity.path.contains('.dart_tool/')) {
      processFile(entity);
    }
  }
}

void processFile(File file) {
  try {
    final contents = file.readAsStringSync();
    final dynamic decoded = json.decode(contents);

    final sorted = sortJson(decoded);

    const encoder = JsonEncoder.withIndent('  ');
    final sortedJson = encoder.convert(sorted);

    file.writeAsStringSync('$sortedJson\n');
    print('Normalized: ${file.path}');
  } catch (e) {
    print('Error processing ${file.path}: $e');
  }
}

dynamic sortJson(dynamic data) {
  if (data is Map<String, Object?>) {
    final sortedMap = <String, Object?>{};
    final keys = data.keys.toList()..sort();
    for (final key in keys) {
      sortedMap[key] = sortJson(data[key]);
    }
    return sortedMap;
  } else if (data is List) {
    return data.map(sortJson).toList()..sort((a, b) {
      if (a is Map && b is Map) {
        final aKeys = a.keys.toList()..sort();
        final bKeys = b.keys.toList()..sort();
        for (var i = 0; i < aKeys.length && i < bKeys.length; i++) {
          final comparison = aKeys[i].toString().compareTo(bKeys[i].toString());
          if (comparison != 0) {
            return comparison;
          }
          final aValue = a[aKeys[i]];
          final bValue = b[bKeys[i]];
          if (aValue is String && bValue is String) {
            final valueComparison = aValue.compareTo(bValue);
            if (valueComparison != 0) {
              return valueComparison;
            }
          }
        }
        return 0;
      }
      if (a is String && b is String) {
        return a.compareTo(b);
      }
      return 0;
    });
  } else {
    return data;
  }
}
