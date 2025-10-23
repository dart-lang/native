// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';

import 'converter.dart';
import 'internal.dart';
import 'ns_enumerator.dart';
import 'objective_c_bindings_generated.dart';

// Ideally we'd mixin UnmodifiableMapBase, but it's an ordinary class. So
// instead we mixin MapBase and then throw in all the modifying methods (which
// is essentially what UnmodifiableMapBase does anyway).
class _NSDictionaryAdapter with MapBase<NSCopying, ObjCObjectBase> {
  final NSDictionary _dictionary;

  _NSDictionaryAdapter(this._dictionary);

  @override
  int get length => _dictionary.count;

  @override
  ObjCObjectBase? operator [](Object? key) =>
      key is NSCopying ? _dictionary.objectForKey(key) : null;

  @override
  Iterable<NSCopying> get keys => _NSDictionaryKeyIterable(this);

  @override
  Iterable<ObjCObjectBase> get values => _NSDictionaryValueIterable(this);

  @override
  bool containsKey(Object? key) => this[key] != null;

  @override
  void operator []=(NSCopying key, ObjCObjectBase value) =>
      throw UnsupportedError('Cannot modify NSDictionary');

  @override
  void clear() => throw UnsupportedError('Cannot modify NSDictionary');

  @override
  ObjCObjectBase? remove(Object? key) =>
      throw UnsupportedError('Cannot modify NSDictionary');
}

extension NSDictionaryToAdapter on NSDictionary {
  /// Wraps this [NSDictionary] in an adapter that implements an immutable
  /// [Map].
  ///
  /// This is not a conversion, doesn't create a new map, or change the
  /// elements. For deep conversion, use [toDartMap].
  Map<NSCopying, ObjCObjectBase> toDart() => _NSDictionaryAdapter(this);
}

class _NSMutableDictionaryAdapter with MapBase<NSCopying, ObjCObjectBase> {
  final NSMutableDictionary _dictionary;

  _NSMutableDictionaryAdapter(this._dictionary);

  @override
  int get length => _dictionary.count;

  @override
  ObjCObjectBase? operator [](Object? key) =>
      key is NSCopying ? _dictionary.objectForKey(key) : null;

  @override
  void operator []=(NSCopying key, ObjCObjectBase value) =>
      NSMutableDictionary$Methods(
        _dictionary,
      ).setObject(value, forKey: NSCopying.castFrom(key));

  @override
  Iterable<NSCopying> get keys => _NSDictionaryAdapter(_dictionary).keys;

  @override
  Iterable<ObjCObjectBase> get values =>
      _NSDictionaryAdapter(_dictionary).values;

  @override
  bool containsKey(Object? key) => this[key] != null;

  @override
  void clear() => _dictionary.removeAllObjects();

  @override
  ObjCObjectBase? remove(Object? key) {
    if (key is! NSCopying) return null;
    final old = this[key];
    _dictionary.removeObjectForKey(key);
    return old;
  }
}

extension NSMutableDictionaryToAdapter on NSMutableDictionary {
  /// Wraps this [NSMutableDictionary] in an adapter that implements [Map].
  ///
  /// This is not a conversion, doesn't create a new map, or change the
  /// elements. For deep conversion, use [toDartMap].
  Map<NSCopying, ObjCObjectBase> toDart() => _NSMutableDictionaryAdapter(this);
}

class _NSDictionaryKeyIterable with Iterable<NSCopying> {
  final _NSDictionaryAdapter _adapter;

  _NSDictionaryKeyIterable(this._adapter);

  @override
  int get length => _adapter.length;

  @override
  Iterator<NSCopying> get iterator =>
      _NSDictionaryKeyIterator(_adapter._dictionary.keyEnumerator().toDart());

  @override
  bool contains(Object? key) => _adapter.containsKey(key);
}

class _NSDictionaryKeyIterator implements Iterator<NSCopying> {
  final Iterator<ObjCObjectBase> _iterator;

  _NSDictionaryKeyIterator(this._iterator);

  @override
  NSCopying get current => NSCopying.castFrom(_iterator.current);

  @override
  @pragma('vm:prefer-inline')
  bool moveNext() => _iterator.moveNext();
}

class _NSDictionaryValueIterable with Iterable<ObjCObjectBase> {
  final _NSDictionaryAdapter _adapter;

  _NSDictionaryValueIterable(this._adapter);

  @override
  int get length => _adapter.length;

  @override
  Iterator<ObjCObjectBase> get iterator =>
      _adapter._dictionary.objectEnumerator().toDart();
}
