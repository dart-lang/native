// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';

import '../../_internal.dart';
import '../core_bindings.dart';
import '../jobject.dart';

/// Extension on [JList] to provide a Dart [List] adapter view.
extension JListToAdapter<E extends JObject?> on JList<E> {
  /// Wraps this [JList] in an adapter that implements a [List].
  ///
  /// This is not a conversion, doesn't create a new list, or change the
  /// elements.
  List<E> asDart() => _JListAdapter<E>(this);
}

final class _JListAdapter<E extends JObject?> with ListBase<E> {
  final JList<E> _jlist;

  _JListAdapter(this._jlist);

  @override
  int get length => _jlist.size();

  @override
  set length(int newLength) {
    RangeError.checkNotNegative(newLength);
    while (length < newLength) {
      add(null as E);
    }
    while (newLength < length) {
      removeAt(length - 1);
    }
  }

  @override
  E removeAt(int index) {
    RangeError.checkValidIndex(index, this);
    return _jlist.remove(index) as E;
  }

  @override
  Iterator<E> get iterator => JIteratorAdapter<E>(_jlist.iterator()!);

  @override
  E operator [](int index) {
    RangeError.checkValidIndex(index, this);
    return _jlist.get(index) as E;
  }

  @override
  void operator []=(int index, E value) {
    RangeError.checkValidIndex(index, this);
    _jlist.set(index, value);
  }

  @override
  void add(E value) => _jlist.add(value);
}

/// Extension on [Iterable] to create a [JList].
extension ToJavaList<E extends JObject?> on Iterable<E> {
  /// Converts this [Iterable] to a [JList].
  JList<E> toJList() {
    // TODO(https://github.com/dart-lang/native/issues/2012): Remove this as
    // hack.
    final list = (JArrayList() as JObject) as JList<E>;
    list.asDart().addAll(this);
    return list;
  }
}
