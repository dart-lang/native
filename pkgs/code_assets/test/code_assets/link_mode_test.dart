// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:code_assets/code_assets.dart';
import 'package:code_assets/src/code_assets/syntax.g.dart';
import 'package:test/test.dart';

void main() {
  test('LinkMode toString', () async {
    StaticLinking().toString();
  });

  test('Unknown LinkMode throws FormatException', () async {
    expect(
      () => LinkMode.fromJson({
        'type': 'my_custom_link_mode',
        'extra_data': 'some_value',
      }),
      throwsA(isA<FormatException>()),
    );
  });

  test('Unknown LinkModePreference throws FormatException', () async {
    expect(
      () => LinkModePreference.fromString('custom_pref'),
      throwsA(
        predicate(
          (e) =>
              e is FormatException &&
              e.message.contains(
                "Unexpected value 'custom_pref' (String) for ''."
                " Expected one of 'dynamic', 'prefer_dynamic',"
                " 'prefer_static', 'static'.",
              ),
        ),
      ),
    );
  });

  test(
    'Unknown LinkModePreferenceSyntax throws FormatException with JSON path',
    () async {
      expect(
        () => LinkModePreferenceSyntax.fromJson(
          'custom_pref',
          path: ['code', 'link_mode_preference'],
        ),
        throwsA(
          predicate(
            (e) =>
                e is FormatException &&
                e.message.contains(
                  "Unexpected value 'custom_pref' (String) for"
                  " 'code.link_mode_preference'.",
                ),
          ),
        ),
      );
    },
  );
}
