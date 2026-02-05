// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';

import 'package:meta/meta.dart' show internal;

import '../jobject.dart';
import '../jreference.dart';
import '../types.dart';
import 'jset.dart';

@internal
final class $JMap$NullableType$<$K extends JObject?, $V extends JObject?>
    extends JType<JMap<$K, $V>?> {
  final JType<$K> K;

  final JType<$V> V;

  const $JMap$NullableType$(
    this.K,
    this.V,
  );

  @override
  String get signature => r'Ljava/util/Map;';

  @override
  JMap<$K, $V>? fromReference(JReference reference) =>
      reference.isNull ? null : JMap<$K, $V>.fromReference(K, V, reference);

  @override
  JType get superType => const $JObject$Type$();

  @override
  JType<JMap<$K, $V>?> get nullableType => this;

  @override
  final superCount = 1;

  @override
  int get hashCode => Object.hash($JMap$NullableType$, K, V);

  @override
  bool operator ==(Object other) {
    return other.runtimeType == ($JMap$NullableType$<$K, $V>) &&
        other is $JMap$NullableType$<$K, $V> &&
        K == other.K &&
        V == other.V;
  }
}

@internal
final class $JMap$Type$<$K extends JObject?, $V extends JObject?>
    extends JType<JMap<$K, $V>> {
  final JType<$K> K;

  final JType<$V> V;

  const $JMap$Type$(
    this.K,
    this.V,
  );

  @override
  String get signature => r'Ljava/util/Map;';

  @override
  JMap<$K, $V> fromReference(JReference reference) =>
      JMap<$K, $V>.fromReference(K, V, reference);

  @override
  JType get superType => const $JObject$Type$();

  @override
  JType<JMap<$K, $V>?> get nullableType => $JMap$NullableType$<$K, $V>(K, V);

  @override
  final superCount = 1;

  @override
  int get hashCode => Object.hash($JMap$Type$, K, V);

  @override
  bool operator ==(Object other) {
    return other.runtimeType == ($JMap$Type$<$K, $V>) &&
        other is $JMap$Type$<$K, $V> &&
        K == other.K &&
        V == other.V;
  }
}

class JMap<$K extends JObject?, $V extends JObject?> extends JObject
    with MapMixin<$K, $V> {
  @internal
  @override
  // ignore: overridden_fields
  final JType<JMap<$K, $V>> $type;

  @internal
  final JType<$K> K;

  @internal
  final JType<$V> V;

  JMap.fromReference(
    this.K,
    this.V,
    JReference reference,
  )   : $type = type<$K, $V>(K, V),
        super.fromReference(reference);

  static final _class = JClass.forName(r'java/util/Map');

  /// The type which includes information such as the signature of this class.
  static JType<JMap<$K, $V>> type<$K extends JObject?, $V extends JObject?>(
    JType<$K> K,
    JType<$V> V,
  ) {
    return $JMap$Type$<$K, $V>(K, V);
  }

  /// The type which includes information such as the signature of this class.
  static JType<JMap<$K, $V>?>
      nullableType<$K extends JObject?, $V extends JObject?>(
    JType<$K> K,
    JType<$V> V,
  ) {
    return $JMap$NullableType$<$K, $V>(K, V);
  }

  static final _hashMapClass = JClass.forName(r'java/util/HashMap');
  static final _ctorId = _hashMapClass.constructorId(r'()V');
  JMap.hash(this.K, this.V)
      : $type = type<$K, $V>(K, V),
        super.fromReference(_ctorId(_hashMapClass, referenceType, []));

  static final _getId = _class.instanceMethodId(
      r'get', r'(Ljava/lang/Object;)Ljava/lang/Object;');
  @override
  $V? operator [](Object? key) {
    if (key is! JObject?) {
      return null;
    }
    final keyRef = key?.reference ?? jNullReference;
    final value = _getId(this, V.nullableType, [keyRef.pointer]);
    return value;
  }

  static final _putId = _class.instanceMethodId(
      r'put', r'(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;');
  @override
  void operator []=($K key, $V value) {
    final keyRef = key?.reference ?? jNullReference;
    final valueRef = value?.reference ?? jNullReference;
    _putId(this, V.nullableType, [keyRef.pointer, valueRef.pointer]);
  }

  static final _addAllId =
      _class.instanceMethodId(r'putAll', r'(Ljava/util/Map;)V');
  @override
  void addAll(Map<$K, $V> other) {
    if (other is JMap<$K, $V>) {
      final otherRef = other.reference;
      _addAllId(this, const jvoidType(), [otherRef.pointer]);
      return;
    }
    super.addAll(other);
  }

  static final _clearId = _class.instanceMethodId(r'clear', r'()V');
  @override
  void clear() {
    _clearId(this, const jvoidType(), []);
  }

  static final _containsKeyId =
      _class.instanceMethodId(r'containsKey', r'(Ljava/lang/Object;)Z');
  @override
  bool containsKey(Object? key) {
    if (key is! JObject?) {
      return false;
    }
    final keyRef = key?.reference ?? jNullReference;
    return _containsKeyId(this, const jbooleanType(), [keyRef.pointer]);
  }

  static final _containsValueId =
      _class.instanceMethodId(r'containsValue', r'(Ljava/lang/Object;)Z');
  @override
  bool containsValue(Object? value) {
    if (value is! JObject?) {
      return false;
    }
    final valueRef = value?.reference ?? jNullReference;
    return _containsValueId(this, const jbooleanType(), [valueRef.pointer]);
  }

  static final isEmptyId = _class.instanceMethodId(r'isEmpty', r'()Z');
  @override
  bool get isEmpty => isEmptyId(this, const jbooleanType(), []);

  @override
  bool get isNotEmpty => !isEmpty;

  static final _keysId =
      _class.instanceMethodId(r'keySet', r'()Ljava/util/Set;');
  @override
  JSet<$K> get keys => _keysId(this, $JSet$Type$<$K>(K), [])!;

  static final _sizeId = _class.instanceMethodId(r'size', r'()I');
  @override
  int get length => _sizeId(this, const jintType(), []);

  static final _removeId = _class.instanceMethodId(
      r'remove', r'(Ljava/lang/Object;)Ljava/lang/Object;');
  @override
  $V? remove(Object? key) {
    if (key is! JObject?) {
      return null;
    }
    final keyRef = key?.reference ?? jNullReference;
    final value = _removeId(this, V.nullableType, [keyRef.pointer]);
    return value;
  }
}

extension ToJavaMap<K extends JObject?, V extends JObject?> on Map<K, V> {
  JMap<K, V> toJMap(JType<K> keyType, JType<V> valueType) {
    final map = JMap.hash(keyType, valueType);
    map.addAll(this);
    return map;
  }
}
