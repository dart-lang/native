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

  /// Splits a single token on splittable characters, handling both prefix and
  /// suffix cases.
  ///
  /// Swift's symbol graph concatenates some tokens together, for example when
  /// a parameter has a default value: " = value) -> returnType" becomes a
  /// single text token. This method splits such tokens by:
  ///   1. Repeatedly extracting splittables from the start
  ///   2. For the remaining content, pull splittables from the end
  ///   3. Store removed suffix tokens and yield them in reverse order
  ///   4. Yield any remaining non-splittable content as a single text token
  ///
  /// This approach preserves the correct token sequence and ensures that even
  /// complex cases like " = foo) -> " are properly tokenized.
  @visibleForTesting
  static Iterable<Json> splitToken(Json token) sync* {
    const splittables = ['(', ')', '?', ',', '->', '='];
    Json textToken(String text) =>
        Json({'kind': 'text', 'spelling': text}, token.pathSegments);

    final text = getSpellingForKind(token, 'text')?.trim();
    if (text == null) {
      // Not a text token. Pass it through unchanged.
      yield token;
      return;
    }

    if (text.isEmpty) {
      // Input text token was nothing but whitespace. We still need it as a
      // separator for the parser.
      yield textToken(text);
      return;
    }

    var remaining = text;
    while (true) {
      var foundPrefix = false;
      for (final splittable in splittables) {
        if (remaining.startsWith(splittable)) {
          yield textToken(splittable);
          remaining = remaining.substring(splittable.length).trim();
          foundPrefix = true;
          break;
        }
      }

      if (foundPrefix) continue;

      // No more prefix splittables found; extract any trailing ones.
      // We collect them in a list and yield in reverse order to maintain
      // the original token sequence.
      final trailingTokens = <String>[];
      var currentSuffix = remaining;
      while (currentSuffix.isNotEmpty) {
        var foundSuffix = false;
        for (final splittable in splittables) {
          if (currentSuffix.endsWith(splittable)) {
            trailingTokens.add(splittable);
            currentSuffix = currentSuffix
                .substring(0, currentSuffix.length - splittable.length)
                .trim();
            foundSuffix = true;
            break;
          }
        }
        if (!foundSuffix) break;
      }

      // Yield the core content, then trailing splittables in reverse order.
      if (currentSuffix.isNotEmpty) yield textToken(currentSuffix);
      for (var i = trailingTokens.length - 1; i >= 0; i--) {
        yield textToken(trailingTokens[i]);
      }
      break;
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
    _list,
    startIndex + _start,
    endIndex != null ? endIndex + _start : _end,
  );

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
