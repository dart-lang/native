// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:native_test_helpers/native_test_helpers.dart';
import 'package:path/path.dart' as p;

void main(List<String> arguments) {
  final stopwatch = Stopwatch()..start();
  final parser = ArgParser()
    ..addFlag(
      'set-exit-if-changed',
      negatable: false,
      help: 'Return a non-zero exit code if any files were changed.',
    );
  final argResults = parser.parse(arguments);

  final setExitIfChanged = argResults['set-exit-if-changed'] as bool;
  var processedCount = 0;
  var changedCount = 0;
  final packageUri = findPackageRoot('hooks');

  final directories = [
    Directory.fromUri(packageUri),
    Directory.fromUri(packageUri.resolve('../code_assets/')),
    Directory.fromUri(packageUri.resolve('../data_assets/')),
    Directory.fromUri(packageUri.resolve('../pub_formats/')),
  ];
  for (final directory in directories) {
    final result = processDirectory(directory);
    processedCount += result.processedCount;
    changedCount += result.changedCount;
  }

  stopwatch.stop();
  final duration = stopwatch.elapsedMilliseconds / 1000.0;
  print(
    'Normalized $processedCount files ($changedCount changed) in '
    '${duration.toStringAsFixed(2)} seconds.',
  );

  if (setExitIfChanged && changedCount > 0) {
    exit(1);
  }
}

class ProcessDirectoryResult {
  final int processedCount;
  final int changedCount;

  ProcessDirectoryResult(this.processedCount, this.changedCount);
}

ProcessDirectoryResult processDirectory(Directory directory) {
  var processedCount = 0;
  var changedCount = 0;
  final entities = directory.listSync(recursive: true);
  for (final entity in entities) {
    if (entity is File &&
        p.extension(entity.path) == '.json' &&
        !entity.path.contains('.dart_tool/')) {
      processedCount++;
      if (processFile(entity)) {
        changedCount += 1;
      }
    }
  }
  return ProcessDirectoryResult(processedCount, changedCount);
}

bool processFile(File file) {
  final contents = file.readAsStringSync();
  final dynamic decoded = json.decode(contents);
  final sorted = sortJson(decoded, file.path);

  const encoder = JsonEncoder.withIndent('  ');
  final sortedJson = encoder.convert(sorted); // Already has no trailing newline
  final newContents = '$sortedJson\n';

  final newContentNormalized = newContents.replaceAll('\r\n', '\n');
  final oldContentNormalized = contents.replaceAll('\r\n', '\n');
  if (newContentNormalized == oldContentNormalized) {
    return false;
  }

  file.writeAsStringSync(newContents);
  print('Normalized: ${file.path}');
  return true;
}

const List<String> _orderedKeysInSchemas = [
  // Schema Identification: Defines the JSON Schema version and identifier.
  // Should be at the top.
  '\$schema',
  '\$id',

  // Informational: Keyword for adding comments to the schema.
  '\$comment',

  // References to other schemas.
  '\$ref',

  // Schema Metadata: Human-readable information about the schema.
  'title',
  'description',

  // Core Types: The basic data types and related keywords.
  'type',
  'enum',
  'const',

  // Object Schemas: Keywords for defining and validating JSON objects.
  'properties',
  'required',
  'additionalProperties',
  'patternProperties',
  'unevaluatedProperties',

  // Array Schemas: Keywords for defining and validating JSON arrays.
  'items',
  'prefixItems',
  'contains',
  'minContains',
  'maxContains',

  // Combining Schemas: Keywords for combining and manipulating schemas.
  'allOf',
  'anyOf',
  'oneOf',
  'not',

  // Conditional Application: Keywords for applying schemas conditionally.
  'if',
  'then',
  'else',
  'dependentSchemas',
  'dependentRequired',

  // Reusable Definitions: Keywords for defining and referencing reusable schema
  // components.
  '\$defs',
  'definitions',

  // Semantic Validation: Keywords for validating data based on its semantic
  // type.
  'format',
  'examples',
  'default',

  // Metadata Annotations: Keywords for adding metadata annotations to schemas.
  'readOnly',
  'writeOnly',
  'deprecated',

  // Numeric Validation: Keywords for validating numeric data.
  'multipleOf',
  'maximum',
  'exclusiveMaximum',
  'minimum',
  'exclusiveMinimum',

  // String Validation: Keywords for validating string data.
  'maxLength',
  'minLength',
  'pattern',

  // Array Validation: Keywords for validating array data.
  'maxItems',
  'minItems',
  'uniqueItems',

  // Object Validation: Keywords for validating object data.
  'maxProperties',
  'minProperties',
];

dynamic sortJson(dynamic data, String filePath) {
  if (data is Map<String, Object?>) {
    final sortedMap = <String, Object?>{};
    final keys = data.keys.toList();

    final isSchema = filePath.endsWith('schema.json');
    if (isSchema) {
      keys.sort((a, b) {
        final aIndex = _orderedKeysInSchemas.indexOf(a);
        final bIndex = _orderedKeysInSchemas.indexOf(b);
        if (aIndex == -1 && bIndex == -1) {
          // Both keys are not in _orderedKeys, sort alphabetically.
          return a.compareTo(b);
        } else if (aIndex == -1) {
          // Only b is in _orderedKeys, sort b first
          return 1;
        } else if (bIndex == -1) {
          // Only a is in _orderedKeys, sort a first
          return -1;
        } else {
          return aIndex.compareTo(bIndex);
        }
      });
    } else {
      // Sort keys alphabetically for non-schemas.
      keys.sort();
    }

    for (final key in keys) {
      sortedMap[key] = sortJson(data[key], filePath);
    }
    return sortedMap;
  }
  if (data is List) {
    return data.map((item) => sortJson(item, filePath)).toList()..sort((a, b) {
      if (a is Map && b is Map) {
        return compareMaps(a, b);
      }
      if (a is String && b is String) {
        return a.compareTo(b);
      }
      throw UnimplementedError('Not implemented to compare $a and $b.');
    });
  }
  return data;
}

int _compareTwoItems(dynamic a, dynamic b) {
  if (a is Map && b is Map) {
    return compareMaps(a, b);
  }
  if (a is String && b is String) {
    return a.compareTo(b);
  }
  if (a is List && b is List) {
    return compareLists(a, b);
  }
  if (a is int && b is int) {
    return a.compareTo(b);
  }
  throw UnimplementedError('Not implemented to compare $a and $b.');
}

int compareMaps(Map<dynamic, dynamic> a, Map<dynamic, dynamic> b) {
  final aKeys = a.keys.toList();
  final bKeys = b.keys.toList();
  for (var i = 0; i < aKeys.length && i < bKeys.length; i++) {
    final keyComparison = _compareTwoItems(aKeys[i], bKeys[i]);
    if (keyComparison != 0) {
      return keyComparison;
    }
    final aValue = a[aKeys[i]];
    final bValue = b[bKeys[i]];
    final valueComparison = _compareTwoItems(aValue, bValue);
    if (valueComparison != 0) {
      return valueComparison;
    }
  }
  return 0;
}

int compareLists(List<dynamic> a, List<dynamic> b) {
  for (var i = 0; i < a.length && i < b.length; i++) {
    final comparison = _compareTwoItems(a[i], b[i]);
    if (comparison != 0) {
      return comparison;
    }
  }
  // If all common elements are equal, the shorter list comes first.
  return a.length.compareTo(b.length);
}
