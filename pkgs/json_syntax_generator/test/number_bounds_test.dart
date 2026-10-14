// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:json_schema/json_schema.dart';
import 'package:json_syntax_generator/json_syntax_generator.dart';
import 'package:test/test.dart';

void main() {
  test(
    'generated numeric bounds protect reads, writes, and validation',
    () async {
      final schema = JsonSchema.create({
        'definitions': {
          'NumericBounds': {
            'type': 'object',
            'properties': {
              'bounded': {
                'allOf': [
                  {'type': 'integer', 'minimum': 0, 'maximum': 10},
                  {'type': 'integer', 'minimum': 2, 'maximum': 7},
                ],
              },
              'min_only': {'type': 'integer', 'minimum': 1},
              'max_only': {'type': 'integer', 'maximum': 3},
              'optional': {
                'type': ['number', 'null'],
                'minimum': -0.5,
                'maximum': 4.5,
              },
            },
            'required': ['bounded', 'min_only', 'max_only'],
          },
        },
      });
      final analyzed = SchemaAnalyzer(
        schema,
        publicSetters: ['NumericBounds'],
      ).analyze();
      final generated = SyntaxGenerator(analyzed).generate();
      final directory = await Directory.systemTemp.createTemp(
        'numeric_bounds_',
      );
      addTearDown(() => directory.delete(recursive: true));
      final file = File.fromUri(directory.uri.resolve('check.dart'));
      await file.writeAsString('$generated\n$_checks');
      final result = await Process.run(Platform.resolvedExecutable, [
        file.path,
      ]);
      expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');
    },
  );
}

const _checks = r'''
void check(bool condition, String label) {
  if (!condition) throw StateError(label);
}

void rejects<T>(void Function() action, String label) {
  try {
    action();
  } catch (error) {
    if (error is T) return;
    rethrow;
  }
  throw StateError(label);
}

void main() {
  for (final edge in [2, 7]) {
    final value = NumericBoundsSyntax(bounded: edge, minOnly: 1, maxOnly: 3);
    check(value.bounded == edge && value.validate().isEmpty, 'inclusive edge');
    check(value.optional == null, 'optional absence');
    value.optional = -0.5;
    check(value.optional == -0.5 && value.validate().isEmpty, 'double minimum');
    value.optional = 4.5;
    check(value.optional == 4.5 && value.validate().isEmpty, 'double maximum');
    value.optional = null;
    check(value.optional == null && value.validate().isEmpty, 'optional null');
    rejects<ArgumentError>(() => value.bounded = 1, 'setter minimum');
    rejects<ArgumentError>(() => value.bounded = 8, 'setter maximum');
    check(value.bounded == edge, 'invalid setter must not mutate');
    rejects<ArgumentError>(() => value.minOnly = 0, 'minimum-only setter');
    rejects<ArgumentError>(() => value.maxOnly = 4, 'maximum-only setter');
    rejects<ArgumentError>(() => value.optional = -0.6, 'double setter minimum');
    rejects<ArgumentError>(() => value.optional = 4.6, 'double setter maximum');
    rejects<ArgumentError>(() => value.optional = double.nan, 'NaN setter');
  }
  rejects<ArgumentError>(
    () => NumericBoundsSyntax(bounded: 8, minOnly: 1, maxOnly: 3),
    'constructor maximum',
  );
  for (final entry in <String, List<Object?>>{
    'bounded': [1, 8, '2', null],
    'min_only': [0],
    'max_only': [4],
    'optional': [-0.6, 4.6, double.nan],
  }.entries) {
    for (final invalid in entry.value) {
      final value = NumericBoundsSyntax.fromJson(
        <String, Object?>{'bounded': 2, 'min_only': 1, 'max_only': 3,
          entry.key: invalid},
        path: ['sample'],
      );
      check(value.validate().isNotEmpty, 'validator ${entry.key}: $invalid');
      rejects<FormatException>(() {
        switch (entry.key) {
          case 'bounded': value.bounded;
          case 'min_only': value.minOnly;
          case 'max_only': value.maxOnly;
          case 'optional': value.optional;
        }
      }, 'getter ${entry.key}: $invalid');
      check(value.validate().first.contains('sample.${entry.key}'), 'path');
    }
  }
}
''';
