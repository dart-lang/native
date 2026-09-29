// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:meta/meta.dart' show internal;

import '../core_bindings.dart';
import '../jobject.dart';

extension JIteratorToAdapter<E extends JObject?> on JIterator<E> {
  /// Wraps this [JIterator] in an adapter that implements an [Iterator].
  Iterator<E> asDart() => JIteratorAdapter<E>(this);
}

@internal
final class JIteratorAdapter<E extends JObject?> implements Iterator<E> {
  final JIterator<E?> _itr;
  E? _current;

  JIteratorAdapter(this._itr);

  @override
  E get current => _current as E;

  @override
  @pragma('vm:prefer-inline')
  bool moveNext() {
    if (!_itr.hasNext()) {
      return false;
    }
    _current = _itr.next() as E;
    return true;
  }
}
