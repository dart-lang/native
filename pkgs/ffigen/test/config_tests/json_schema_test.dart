// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:ffigen/ffigen.dart';
import 'package:ffigen/src/strings.dart' as strings;
import 'package:json_schema/json_schema.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  group('json_schema_test', () {
    final context = testContext();
    final schema = YamlConfig.getsRootConfigSpec(
      context.logger,
    ).generateJsonSchema(strings.ffigenJsonSchemaId);

    test('Schema Changes', () {
      matchFileWithExpected(
        context: context,
        pathForActual: 'ffigen.schema.json',
        pathToExpected: [strings.ffigenJsonSchemaFileName],
        fileWriter: (File file, _) {
          final actualJsonSchema =
              const JsonEncoder.withIndent(
                strings.ffigenJsonSchemaIndent,
              ).convert(
                YamlConfig.getsRootConfigSpec(
                  context.logger,
                ).generateJsonSchema(strings.ffigenJsonSchemaId),
              );
          file.writeAsStringSync(actualJsonSchema);
        },
      );
    });

    final jsonSchema = JsonSchema.create(schema);
    test('Valid json schema', () {
      expect(jsonSchema, isNot(null));
    });

    test('Bare minimal input', () {
      expect(
        jsonSchema
            .validate({
              'output': 'abcd.dart',
              'headers': {
                'entry-points': ['a.h'],
              },
            })
            .errors
            .isEmpty,
        true,
      );
    });
    test('Fail input', () {
      expect(jsonSchema.validate(null).errors.isNotEmpty, true);
      expect(jsonSchema.validate({'a': 1}).errors.isNotEmpty, true);
      expect(
        jsonSchema.validate({'output': 'abcd.dart'}).errors.isNotEmpty,
        true,
      );
    });
  });
}
