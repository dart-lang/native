// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:json_schema/json_schema.dart';
import 'package:native_test_helpers/native_test_helpers.dart';
import 'package:test/test.dart';

import '../test_data.dart';

void main() {
  final schemaUri = packageUri.resolve('doc/schema/record_use.schema.json');
  final schemaJson =
      jsonDecode(File.fromUri(schemaUri).readAsStringSync())
          as Map<String, Object?>;
  final schema = JsonSchema.create(schemaJson);

  group('Definition.uri pattern', () {
    test('JSON schema validation succeeds for package URI', () {
      final json = recordedUses.toJson();
      final result = schema.validate(json);
      expect(result.isValid, isTrue);
    });

    test('JSON schema validation fails for non-package URI', () {
      final json = recordedUses.toJson();
      // Modify the first recording's definition URI to be invalid.
      final recordings = json['recordings'] as List;
      final recording = recordings[0] as Map;
      final definition = recording['definition'] as Map;
      definition['uri'] = 'dart:core'; // Should start with package:

      final result = schema.validate(json);
      expect(result.isValid, isFalse);
      expect(
        result.errors.any((e) => e.message.contains('pattern')),
        isTrue,
      );
    });
  });
}

Uri packageUri = findPackageRoot('record_use');
