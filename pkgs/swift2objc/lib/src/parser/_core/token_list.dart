// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'json.dart';
import 'utils.dart';

/// A slicable list of json tokens from the symbolgraph.
///
/// These token lists appear in the symbolgraph json under keys like
/// 'declarationFragments'. They represent things like argument lists, or
/// variable declarations.
///
/// We have to do a little bit of preprocessing on the raw json list before we
/// can pass it to parseType, because certain tokens get concatenated by the
/// swift compiler. This class performs that preprocessing, as well as providing
/// convenience methods for parsing, like slicing.
class TokenList {
  final List<Json> _list;
  final int _start;
  final int _end;

  TokenList._(this._list, this._start, this._end)
      : assert(0 <= _start && _start <= _end && _end <= _list.length);

  // Visible for testing.
  TokenList.raw(List<Json> list, [int start = 0, int? end])
      : this._(list, start, end ?? list.length);

  TokenList(Json fragments) : this.raw(_preprocess(fragments));

  int get length => _end - _start;
  bool get isEmpty => length == 0;
  Json operator [](int index) => _list[index + _start];

  int indexWhere(bool Function(Json element) test) {
    for (var i = _start; i < _end; ++i) {
      if (test(_list[i])) return i - _start;
    }
    return -1;
  }

  TokenList slice(int startIndex, [int? endIndex]) => TokenList._(
      _list, startIndex + _start, endIndex != null ? endIndex + _start : _end);

  static List<Json> _preprocess(Json fragments) {
    const splits = {
      '?(': ['?', '('],
      '?)': ['?', ')'],
      '?, ': ['?', ', '],
    };

    final list = <Json>[];
    for (final token in fragments) {
      final split = splits[getSpellingForKind(token, 'text')];
      if (split != null) {
        for (final sub in split) {
          list.add(Json({'kind': 'text', 'spelling': sub}));
        }
      } else {
        list.add(token);
      }
    }
    return list;
  }

  @override
  String toString() => _list.getRange(_start, _end).toString();
}
