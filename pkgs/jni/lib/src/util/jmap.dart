// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';

import '../core_bindings.dart';
import '../jobject.dart';
import 'jiterator.dart';

extension JMapToAdapter<K extends JObject?, V extends JObject?> on JMap<K, V> {
  /// Wraps this [JMap] in an adapter that implements an immutable [Map].
  ///
  /// This is not a conversion, doesn't create a new map, or change the
  /// elements. For deep conversion, use [toDartMap].
  ///
  /// TODO: Implement toDartMap if it doesn't exist. Be consistent with objc.
  Map<K, V> asDart() => _JMapAdapter<K, V>(this);
}

final class _JMapAdapter<K extends JObject?, V extends JObject?>
    with MapBase<K, V> {
  final JMap<K, V> _jmap;

  _JMapAdapter(this._jmap);

  @override
  int get length => _jmap.size();

  @override
  V? operator [](Object? key) => key is K ? _jmap.get(key) : null;

  @override
  void operator []=(K key, V value) => _jmap.put(key, value);

  @override
  Iterable<K> get keys => _JMapKeySetAdapter<K>(_jmap.keySet()!);

  @override
  Iterable<V> get values => _JMapValueCollectionsAdapter<V>(_jmap.values()!);

  @override
  bool containsKey(Object? key) => key is K ? _jmap.containsKey(key) : false;

  @override
  bool containsValue(Object? key) =>
      key is K ? _jmap.containsValue(key) : false;

  @override
  void clear() => _jmap.clear();

  @override
  V? remove(Object? key) => key is K ? _jmap.remove(key) : null;
}

// Note: We could just use _JSetAdapter, except that Java's Map.keySet method
// returns JSet<K?> instead of JSet<K>.
final class _JMapKeySetAdapter<K extends JObject?> with Iterable<K> {
  final JSet<K?> _keys;

  _JMapKeySetAdapter(this._keys);

  @override
  int get length => _keys.size();

  @override
  Iterator<K> get iterator => JIteratorAdapter<K>(_keys.iterator()!);

  @override
  bool contains(Object? key) => key is K ? _keys.contains(key) : false;
}

final class _JMapValueCollectionsAdapter<V extends JObject?> with Iterable<V> {
  final JCollection<V?> _values;

  _JMapValueCollectionsAdapter(this._values);

  @override
  Iterator<V> get iterator => JIteratorAdapter<V>(_values.iterator()!);
}

extension ToJavaMap<K extends JObject?, V extends JObject?> on Map<K, V> {
  JMap<K, V> toJMap() {
    // TODO(https://github.com/dart-lang/native/issues/2012): Remove this as
    // hack.
    final map = (JHashMap() as JObject) as JMap<K, V>;
    map.asDart().addAll(this);
    return map;
  }
}
