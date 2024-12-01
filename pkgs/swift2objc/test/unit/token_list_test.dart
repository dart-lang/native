// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:swift2objc/src/parser/_core/json.dart';
import 'package:swift2objc/src/parser/_core/token_list.dart';
import 'package:test/test.dart';

void main() {
  String spelling(Iterable<Json> tokens) =>
      [...tokens.map((t) => t['spelling'])].toString();

  test('Slicing', () {
    final list = TokenList(Json(jsonDecode('''
[
  { "spelling": "a" },
  { "spelling": "b" },
  { "spelling": "c" },
  { "spelling": "d" },
  { "spelling": "e" },
  { "spelling": "f" }
]
''')));

    expect(list.length, 6);
    expect(list.slice(3).length, 3);
    expect(list.slice(2, 4).length, 2);
    expect(list.slice(3, 3).length, 0);

    expect(list.isEmpty, isFalse);
    expect(list.slice(3).isEmpty, isFalse);
    expect(list.slice(2, 4).isEmpty, isFalse);
    expect(list.slice(3, 3).isEmpty, isTrue);

    expect(spelling(list), '["a", "b", "c", "d", "e", "f"]');
    expect(spelling(list.slice(3)), '["d", "e", "f"]');
    expect(spelling(list.slice(2, 4)), '["c", "d"]');
    expect(spelling(list.slice(3, 3)), '[]');

    expect(list[2].toString(), '{"spelling":"c"}');
    expect(list.slice(2, 4)[1].toString(), '{"spelling":"d"}');

    expect(list.indexWhere((tok) => tok['spelling'].get<String>() == 'd'), 3);
    expect(
        list
            .slice(2, 4)
            .indexWhere((tok) => tok['spelling'].get<String>() == 'd'),
        1);
  });

  test('Split one token', () {
    List<Json> split(String json) =>
        TokenList.splitToken(Json(jsonDecode(json))).toList();
    expect(spelling(split('{ "kind": "text", "spelling": "a" }')), '["a"]');
    expect(spelling(split('{ "kind": "text", "spelling": "" }')), '[""]');
    expect(spelling(split('{ "kind": "text", "spelling": "    " }')), '[""]');
    expect(spelling(split('{ "kind": "text", "spelling": "?" }')), '["?"]');
    expect(spelling(split('{ "kind": "text", "spelling": "???" }')),
        '["?", "?", "?"]');
    expect(
        spelling(split('{ "kind": "text", "spelling": "()" }')), '["(", ")"]');
    expect(spelling(split('{ "kind": "text", "spelling": " ?) ->  () " }')),
        '["?", ")", "->", "(", ")"]');
    expect(spelling(split('{ "kind": "typeIdentifier", "spelling": "?)" }')),
        '["?)"]');

    // splitToken gives up as soon as it finds a non-matching prefix. Ideally
    // we'd keep splitting out any other tokens we find in the text, but that's
    // more complicated to implement (we're writing a full tokenizer at that
    // point), and we haven't seen a symbolgraph where that's necessary yet.
    expect(spelling(split('{ "kind": "text", "spelling": "?)>-??" }')),
        '["?", ")", ">-??"]');
    expect(spelling(split('{ "kind": "text", "spelling": "?)abc??" }')),
        '["?", ")", "abc??"]');
  });

  test('Split list', () {
    final list = TokenList(Json(jsonDecode('''
[
  { "kind": "text", "spelling": "a" },
  { "kind": "text", "spelling": "?(" },
  { "kind": "text", "spelling": "b" },
  { "kind": "text", "spelling": "c" },
  { "kind": "text", "spelling": "?)" },
  { "kind": "text", "spelling": "?, " },
  { "kind": "text", "spelling": "d" },
  { "kind": "typeIdentifier", "spelling": "?(" },
  { "kind": "text", "spelling": "e" }
]
''')));

    expect(spelling(list),
        '["a", "?", "(", "b", "c", "?", ")", "?", ",", "d", "?(", "e"]');

    // If kind != "text", the token isn't changed.
    expect(list[10].toString(), '{"kind":"typeIdentifier","spelling":"?("}');
  });
}
