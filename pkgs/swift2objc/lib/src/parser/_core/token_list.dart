// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:meta/meta.dart';

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
class TokenList extends Iterable<Json> {
  final List<Json> _list;
  final int _start;
  final int _end;

  TokenList._(this._list, this._start, this._end)
      : assert(0 <= _start && _start <= _end && _end <= _list.length);

  factory TokenList(Json fragments) {
    final list = [for (final token in fragments) ...splitToken(token)];
    return TokenList._(list, 0, list.length);
  }

  @visibleForTesting
  static Iterable<Json> splitToken(Json token) sync* {
    const splittables = ['(', ')', '?', ',', '->'];
    Json textToken(String text) =>
        Json({'kind': 'text', 'spelling': text}, token.pathSegments);

    final text = getSpellingForKind(token, 'text')?.trim();
    if (text == null) {
      // Not a text token. Pass it though unchanged.
      yield token;
      return;
    }

    if (text.isEmpty) {
      // Input text token was nothing but whitespace. The loop below would yield
      // nothing, but we still need it as a separator.
      yield textToken(text);
      return;
    }

    var suffix = text;
    while (true) {
      var any = false;
      for (final prefix in splittables) {
        if (suffix.startsWith(prefix)) {
          yield textToken(prefix);
          suffix = suffix.substring(prefix.length).trim();
          any = true;
          break;
        }
      }
      if (!any) {
        // Remaining text isn't splittable.
        if (suffix.isNotEmpty) yield textToken(suffix);
        break;
      }
    }
  }

  @override
  int get length => _end - _start;

  @override
  Iterator<Json> get iterator => _TokenListIterator(this);

  Json operator [](int index) => _list[index + _start];

  int indexWhere(bool Function(Json element) test) {
    for (var i = _start; i < _end; ++i) {
      if (test(_list[i])) return i - _start;
    }
    return -1;
  }

  TokenList slice(int startIndex, [int? endIndex]) => TokenList._(
      _list, startIndex + _start, endIndex != null ? endIndex + _start : _end);

  @override
  String toString() => _list.getRange(_start, _end).toString();
}

class _TokenListIterator implements Iterator<Json> {
  final TokenList _list;
  var _index = -1;

  _TokenListIterator(this._list);

  @override
  Json get current => _list[_index];

  @override
  bool moveNext() {
    _index++;
    return _index < _list.length;
  }
}
