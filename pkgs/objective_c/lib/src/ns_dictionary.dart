// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';

import 'package:ffi/ffi.dart';

import 'internal.dart';
import 'ns_enumerator.dart';
import 'objective_c_bindings_generated.dart';

// Ideally we'd mixin UnmodifiableMapBase, but it's an ordinary class. So
// instead we mixin MapBase and then throw in all the modifying methods (which
// is essentially what UnmodifiableMapBase does anyway).
class NSDictionaryAdapter with MapBase<NSCopying, ObjCObjectBase> {
  final NSDictionary dictionary;

  NSDictionaryAdapter(this.dictionary);

  @override
  int get length => dictionary.count;

  @override
  ObjCObjectBase? operator [](Object? key) =>
      key is NSCopying ? dictionary.objectForKey(key) : null;

  @override
  Iterable<NSCopying> get keys => _NSDictionaryKeyIterable(this);

  @override
  Iterable<ObjCObjectBase> get values => _NSDictionaryValueIterable(this);

  @override
  bool containsKey(Object? key) => this[key] != null;

  @override
  void operator []=(NSCopying key, ObjCObjectBase value) =>
      throw UnsupportedError("Cannot modify NSDictionary");

  @override
  void clear() => throw UnsupportedError("Cannot modify NSDictionary");

  @override
  ObjCObjectBase? remove(Object? key) =>
      throw UnsupportedError("Cannot modify NSDictionary");
}

class NSMutableDictionaryAdapter with MapBase<NSCopying, ObjCObjectBase> {
  final NSMutableDictionary dictionary;

  NSMutableDictionaryAdapter(this.dictionary);

  @override
  int get length => dictionary.count;

  @override
  ObjCObjectBase? operator [](Object? key) =>
      key is NSCopying ? dictionary.objectForKey(key) : null;

  @override
  void operator []=(NSCopying key, ObjCObjectBase value) =>
      NSMutableDictionary$Methods(
        dictionary,
      ).setObject(value, forKey: NSCopying.castFrom(key));

  @override
  Iterable<NSCopying> get keys => NSDictionaryAdapter(dictionary).keys;

  @override
  Iterable<ObjCObjectBase> get values => NSDictionaryAdapter(dictionary).values;

  @override
  bool containsKey(Object? key) => this[key] != null;

  @override
  void clear() => dictionary.removeAllObjects();

  @override
  ObjCObjectBase? remove(Object? key) {
    if (key is! NSCopying) return null;
    final old = this[key];
    dictionary.removeObjectForKey(key);
    return old;
  }
}

class _NSDictionaryKeyIterable with Iterable<NSCopying> {
  NSDictionaryAdapter _dictionary;

  _NSDictionaryKeyIterable(this._dictionary);

  @override
  int get length => _dictionary.length;

  @override
  Iterator<NSCopying> get iterator =>
      _NSDictionaryKeyIterator(_dictionary.dictionary.keyEnumerator().toDart());

  @override
  bool contains(Object? key) => _dictionary.containsKey(key);
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
  NSDictionaryAdapter _dictionary;

  _NSDictionaryValueIterable(this._dictionary);

  @override
  int get length => _dictionary.length;

  @override
  Iterator<ObjCObjectBase> get iterator =>
      _dictionary.dictionary.objectEnumerator().toDart();
}
