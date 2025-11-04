// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';

import 'converter.dart';
import 'internal.dart';
import 'objective_c_bindings_generated.dart';

class _NSArrayAdapter with ListBase<ObjCObject> {
  final NSArray _array;

  _NSArrayAdapter(this._array);

  @override
  int get length => _array.count;

  @override
  ObjCObject elementAt(int index) => _array.objectAtIndex(index);

  @override
  Iterator<ObjCObject> get iterator => _NSArrayIterator(this);

  @override
  ObjCObject operator [](int index) => _array.objectAtIndex(index);

  @override
  set length(int newLength) => throw UnsupportedError('Cannot modify NSArray');

  @override
  void operator []=(int index, ObjCObject value) =>
      throw UnsupportedError('Cannot modify NSArray');

  @override
  void add(ObjCObject value) =>
      throw UnsupportedError('Cannot modify NSArray');
}

extension NSArrayToAdapter on NSArray {
  /// Wraps this [NSArray] in an adapter that implements an immutable [List].
  ///
  /// This is not a conversion, doesn't create a new list, or change the
  /// elements. For deep conversion, use [toDartList].
  List<ObjCObject> toDart() => _NSArrayAdapter(this);
}

class _NSMutableArrayAdapter with ListBase<ObjCObject> {
  final NSMutableArray _array;

  _NSMutableArrayAdapter(this._array);

  @override
  int get length => _array.count;

  @override
  set length(int newLength) {
    var len = length;
    RangeError.checkValueInInterval(newLength, 0, len);
    for (; len > newLength; --len) {
      _array.removeLastObject();
    }
  }

  @override
  ObjCObject elementAt(int index) => _array.objectAtIndex(index);

  @override
  Iterator<ObjCObject> get iterator => _NSArrayIterator(this);

  @override
  ObjCObject operator [](int index) => _array.objectAtIndex(index);

  @override
  void operator []=(int index, ObjCObject value) =>
      _array.replaceObjectAtIndex(index, withObject: value);

  @override
  void add(ObjCObject value) => _array.addObject(value);
}

extension NSMutableArrayToAdapter on NSMutableArray {
  /// Wraps this [NSMutableArray] in an adapter that implements [List].
  ///
  /// This is not a conversion, doesn't create a new list, or change the
  /// elements. For deep conversion, use [toDartList].
  List<ObjCObject> toDart() => _NSMutableArrayAdapter(this);
}

class _NSArrayIterator implements Iterator<ObjCObject> {
  final Iterable<ObjCObject> _iterable;
  final int _length;
  int _index;
  ObjCObject? _current;

  _NSArrayIterator(Iterable<ObjCObject> iterable)
    : _iterable = iterable,
      _length = iterable.length,
      _index = 0;

  @override
  ObjCObject get current => _current!;

  @override
  @pragma('vm:prefer-inline')
  bool moveNext() {
    final length = _iterable.length;
    if (_length != length) {
      throw ConcurrentModificationError(_iterable);
    }
    if (_index >= length) {
      _current = null;
      return false;
    }
    _current = _iterable.elementAt(_index);
    _index++;
    return true;
  }
}
