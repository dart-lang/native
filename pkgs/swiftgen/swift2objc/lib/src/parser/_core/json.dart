// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';

class Json extends IterableBase<Json> {
  final List<String> _pathSegments;
  final dynamic _json;

  String get path => _pathSegments.join('/');

  Json(this._json, [this._pathSegments = const []]);

  Json operator [](dynamic index) {
    if (index is String) {
      if (_json is! Map) {
        throw 'Expected a map at "$path", found a ${_json.runtimeType}';
      }
      return Json(_json[index], [..._pathSegments, index]);
    }

    if (index is int) {
      if (_json is! List) {
        throw 'Expected a list at "$path", found a ${_json.runtimeType}';
      }
      if (index >= _json.length) {
        throw 'Index out of range at "$path" (index: $index, max-length: ${_json.length})';
      }
      return Json(_json[index], [..._pathSegments, "$index"]);
    }

    throw 'Invalid subscript type when accessing value at path "$path". Expected an integer index or a string key, got ${index.runtimeType}.';
  }

  T get<T>() {
    if (_json is T) return _json;
    throw 'Expected a $T at "$path", found ${_json.runtimeType}';
  }

  T? tryGet<T>() {
    if (_json is T) {
      return _json;
    } else {
      return null;
    }
  }

  @override
  Iterator<Json> get iterator => _JsonIterator(this);

  Json firstWhereKey(String key, dynamic value) {
    return firstWhere(
      (json) {
        try {
          return json[key].get() == value;
        } catch (_) {
          return false;
        }
      },
      orElse: () =>
          throw 'No map with key "$key" and value "$value" was found at $path',
    );
  }
}

class _JsonIterator implements Iterator<Json> {
  final Json _json;
  final List _list;
  var _index = -1;

  _JsonIterator(this._json) : _list = _json.get();

  @override
  Json get current => Json(_list[_index], [..._json._pathSegments, "$_index"]);

  @override
  bool moveNext() {
    _index++;
    return _index < _list.length;
  }
}
