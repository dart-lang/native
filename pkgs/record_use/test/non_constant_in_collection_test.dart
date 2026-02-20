// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:record_use/record_use_internal.dart';
import 'package:test/test.dart';

void main() {
  test('NonConstant in ListConstant throws FormatException', () {
    final json = {
      'metadata': {'version': '1.0.0', 'comment': 'test'},
      'constants': [
        {'type': 'non_constant'},
        {
          'type': 'list',
          'value': [0],
        },
      ],
    };

    expect(() => Recordings.fromJson(json), throwsFormatException);
  });

  test('NonConstant in MapConstant key throws FormatException', () {
    final json = {
      'metadata': {'version': '1.0.0', 'comment': 'test'},
      'constants': [
        {'type': 'non_constant'},
        {'type': 'int', 'value': 1},
        {
          'type': 'map',
          'value': [
            {'key': 0, 'value': 1},
          ],
        },
      ],
    };

    expect(() => Recordings.fromJson(json), throwsFormatException);
  });

  test('NonConstant in MapConstant value throws FormatException', () {
    final json = {
      'metadata': {'version': '1.0.0', 'comment': 'test'},
      'constants': [
        {'type': 'non_constant'},
        {'type': 'int', 'value': 1},
        {
          'type': 'map',
          'value': [
            {'key': 1, 'value': 0},
          ],
        },
      ],
    };

    expect(() => Recordings.fromJson(json), throwsFormatException);
  });

  test('NonConstant in InstanceConstant field throws FormatException', () {
    final json = {
      'metadata': {'version': '1.0.0', 'comment': 'test'},
      'constants': [
        {'type': 'non_constant'},
        {
          'type': 'instance',
          'definition_index': 0,
          'value': {'field': 0},
        },
      ],
      'definitions': [
        {
          'uri': 'package:a/a.dart',
          'path': [
            {'name': 'MyClass'},
          ],
        },
      ],
    };

    expect(() => Recordings.fromJson(json), throwsFormatException);
  });
}
