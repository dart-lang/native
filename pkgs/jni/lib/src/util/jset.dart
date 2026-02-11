// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';

import '../core_bindings.dart';
import '../jobject.dart';
import '../types.dart';
import 'jiterator.dart';

extension JSetToAdapter<E extends JObject?> on JSet<E> {
  /// Wraps this [JSet] in an adapter that implements a [Set].
  ///
  /// This is not a conversion, doesn't create a new list, or change the
  /// elements. For deep conversion, use [toDartSet].
  ///
  /// TODO: Implement toDartSet if it doesn't exist. Be consistent with objc.
  Set<E> asDart() => _JSetAdapter<E>(this);
}

final class _JSetAdapter<E extends JObject?> with SetBase<E> {
  final JSet<E> _jset;

  _JSetAdapter(this._jset);

  @override
  int get length => _jset.size();

  @override
  bool contains(Object? element) =>
      element is JObject? ? _jset.contains(element) : false;

  @override
  E? lookup(Object? element) => throw UnsupportedError(
      "Java's Set class has no equivalent of Dart's Set.lookup method.");

  @override
  Iterator<E> get iterator => JIteratorAdapter<E>(_jset.iterator()!);

  @override
  Set<E> toSet() => {...this};

  @override
  bool add(E value) => _jset.add(value);

  @override
  bool remove(Object? value) => value is JObject? ? _jset.remove(value) : false;

  @override
  void clear() => _jset.clear();
}

extension ToJavaSet<E extends JObject?> on Iterable<E> {
  JSet<E> toJSet() {
    // TODO(https://github.com/dart-lang/native/issues/2012): Remove this as
    // hack.
    final set = (JHashSet() as JObject) as JSet<E>;
    set.asDart().addAll(this);
    return set;
  }
}
