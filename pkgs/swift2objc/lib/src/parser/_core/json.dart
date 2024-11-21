// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';
import 'dart:convert';

/// This is a helper class that helps with parsing Json values. It supports
/// accessing the json content using the subscript syntax similar to `List`
/// and `Map` types. Whenever you use the subscript syntax, you get back a
/// new `Json` object containing the value at the field/index being accessed.
///
/// The main purpose of this class is to assert the existence of fields we're
/// accessing, and in case of an issue (e.g field does not exist), let us know
/// exactly which field did the issue occure at by throwing an error containing
/// the full path to that field.
///
/// The class is also an `Iterable` so if the json is an array, you can directly
/// iterate over it with a `for` loop. If the json isn't an array, attempting to
/// iterate over it will throw an error.
class Json extends IterableBase<Json> {
  final List<String> _pathSegments;
  final dynamic _json;

  // Allows slicing the list if this is a json list.
  final int _startIndex;
  final int? _endIndex;

  String get path => _pathSegments.join('/');

  Json._(this._json, this._pathSegments,
      [this._startIndex = 0, this._endIndex]);

  Json(dynamic json, [List<String> pathSegments = const []])
      : this._(json, pathSegments);

  int get _sliceEnd => _endIndex ?? get<List>().length;

  int get length => _sliceEnd - _startIndex;
  bool get isEmpty => length == 0;

  /// The subscript syntax is intended to access a value at a field of a map or
  /// at an index if an array, and thus, the `index` parameter here can either
  /// be an integer index (to access an index of an array) or a string key
  /// (to access a field of a map)
  Json operator [](dynamic index) {
    if (index is String) {
      if (_json is! Map) {
        throw Exception(
          'Expected a map at "$path", found a ${_json.runtimeType}',
        );
      }
      return Json(_json[index], [..._pathSegments, index]);
    }

    if (index is int) {
      if (_json is! List) {
        throw Exception(
          'Expected a list at "$path", found a ${_json.runtimeType}',
        );
      }
      if (index < 0) {
        throw Exception(
          'Invalid negative index at "$path" (supplied index: $index)',
        );
      }
      final endIndex = _sliceEnd;
      final i = index + _startIndex;
      if (i >= endIndex) {
        throw Exception(
          'Index out of range at "$path" '
          '(index: $index, max-length: ${_json.length}'
          '${_endIndex == null ? '' : ', slice: [$_startIndex, $_endIndex]'})',
        );
      }
      return Json(_json[i], [..._pathSegments, '$index']);
    }

    throw Exception(
      'Invalid subscript type when accessing value at path "$path". '
      'Expected an integer index or a string key, got ${index.runtimeType}.',
    );
  }

  bool get exists => _json != null;

  T get<T>() {
    if (_json is T) return _json;
    throw Exception('Expected a $T at "$path", found ${_json.runtimeType}');
  }

  @override
  Iterator<Json> get iterator => _JsonIterator(this, _startIndex, _sliceEnd);

  bool jsonWithKeyExists(String key, [dynamic value]) {
    return any((json) {
      if (!json[key].exists) return false;

      if (value == null) {
        return true;
      } else {
        return json[key].get<dynamic>() == value;
      }
    });
  }

  Json firstJsonWhereKey(String key, dynamic value) {
    return firstWhere(
      (json) {
        try {
          return json[key].get<dynamic>() == value;
        } catch (_) {
          return false;
        }
      },
      orElse: () => throw Exception(
        'No map with key "$key" and value "$value" was found at $path',
      ),
    );
  }

  int indexWhere(bool test(Json element)) {
    int i = 0;
    for (final element in this) {
      if (test(element)) return i;
      ++i;
    }
    return -1;
  }

  @override
  String toString() => '${jsonEncode(_json)}'
      '${_endIndex == null ? '' : '[$_startIndex, $_endIndex]'}';

  Json slice(int startIndex, [int? endIndex]) {
    final start = startIndex + _startIndex;
    final end = endIndex != null ? endIndex + _startIndex : _sliceEnd;
    assert(start >= _startIndex &&
        end >= _startIndex &&
        start <= _sliceEnd &&
        end <= _sliceEnd);
    return Json._(_json, _pathSegments, start, end);
  }
}

class _JsonIterator implements Iterator<Json> {
  final Json _json;
  final List<dynamic> _list;
  final int _end;
  int _index;

  _JsonIterator._(this._json, this._list, this._end, this._index);

  _JsonIterator(Json json, int startIndex, int endIndex)
      : this._(json, json.get(), endIndex, startIndex - 1);

  @override
  Json get current => Json(_list[_index], [..._json._pathSegments, '$_index']);

  @override
  bool moveNext() {
    _index++;
    return _index < _end;
  }
}
