// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:meta/meta.dart' show internal;

import '../jobject.dart';
import '../types.dart';

@internal
final class $JIterator$Type$ extends JType<JIterator> {
  const $JIterator$Type$();

  @override
  String get signature => r'Ljava/util/Iterator;';
}

extension type JIterator<E extends JObject?>(JObject _$this)
    implements JObject {
  static const JType<JIterator> type = $JIterator$Type$();

  static final _class = JClass.forName(r'java/util/Iterator');

  static final _hasNextId = _class.instanceMethodId(r'hasNext', r'()Z');
  bool _hasNext() => _hasNextId(this, const jbooleanType(), [])!;

  static final _nextId =
      _class.instanceMethodId(r'next', r'()Ljava/lang/Object;');
  E _next() => _nextId(this, JObject.type, []) as E;

  Iterator<E> asDart() => _JIteratorAdapter<E>(this);
}

final class _JIteratorAdapter<E extends JObject?> implements Iterator<E> {
  final JIterator<E> _itr;
  E? _current;

  _JIteratorAdapter(this._itr);

  @override
  E get current => _current!;

  @override
  @pragma('vm:prefer-inline')
  bool moveNext() {
    if (!_itr._hasNext()) {
      return false;
    }
    _current = _itr._next();
    return true;
  }
}
