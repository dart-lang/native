// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';

import 'package:meta/meta.dart' show internal;

import '../jobject.dart';
import '../jreference.dart';
import '../types.dart';
import 'jset.dart';

final class JMapNullableType<$K extends JObject?, $V extends JObject?>
    extends JObjType<JMap<$K, $V>?> {
  @internal
  final JObjType<$K> K;

  @internal
  final JObjType<$V> V;

  @internal
  const JMapNullableType(
    this.K,
    this.V,
  );

  @internal
  @override
  String get signature => r'Ljava/util/Map;';

  @internal
  @override
  JMap<$K, $V>? fromReference(JReference reference) =>
      reference.isNull ? null : JMap<$K, $V>.fromReference(K, V, reference);

  @internal
  @override
  JObjType get superType => const JObjectType();

  @internal
  @override
  JObjType<JMap<$K, $V>?> get nullableType => this;

  @internal
  @override
  final superCount = 1;

  @override
  int get hashCode => Object.hash(JMapNullableType, K, V);

  @override
  bool operator ==(Object other) {
    return other.runtimeType == (JMapNullableType<$K, $V>) &&
        other is JMapNullableType<$K, $V> &&
        K == other.K &&
        V == other.V;
  }
}

final class JMapType<$K extends JObject?, $V extends JObject?>
    extends JObjType<JMap<$K, $V>> {
  @internal
  final JObjType<$K> K;

  @internal
  final JObjType<$V> V;

  @internal
  const JMapType(
    this.K,
    this.V,
  );

  @internal
  @override
  String get signature => r'Ljava/util/Map;';

  @internal
  @override
  JMap<$K, $V> fromReference(JReference reference) =>
      JMap<$K, $V>.fromReference(K, V, reference);

  @internal
  @override
  JObjType get superType => const JObjectType();

  @internal
  @override
  JObjType<JMap<$K, $V>?> get nullableType => JMapNullableType<$K, $V>(K, V);

  @internal
  @override
  final superCount = 1;

  @override
  int get hashCode => Object.hash(JMapType, K, V);

  @override
  bool operator ==(Object other) {
    return other.runtimeType == (JMapType<$K, $V>) &&
        other is JMapType<$K, $V> &&
        K == other.K &&
        V == other.V;
  }
}

class JMap<$K extends JObject?, $V extends JObject?> extends JObject
    with MapMixin<$K, $V> {
  @internal
  @override
  // ignore: overridden_fields
  final JObjType<JMap<$K, $V>> $type;

  @internal
  final JObjType<$K> K;

  @internal
  final JObjType<$V> V;

  JMap.fromReference(
    this.K,
    this.V,
    JReference reference,
  )   : $type = type<$K, $V>(K, V),
        super.fromReference(reference);

  static final _class = JClass.forName(r'java/util/Map');

  /// The type which includes information such as the signature of this class.
  static JMapType<$K, $V> type<$K extends JObject?, $V extends JObject?>(
    JObjType<$K> K,
    JObjType<$V> V,
  ) {
    return JMapType<$K, $V>(K, V);
  }

  /// The type which includes information such as the signature of this class.
  static JMapNullableType<$K, $V>
      nullableType<$K extends JObject?, $V extends JObject?>(
    JObjType<$K> K,
    JObjType<$V> V,
  ) {
    return JMapNullableType<$K, $V>(K, V);
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
    if (key is! JObject) {
      return null;
    }
    final keyRef = key.reference;
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
    if (key is! JObject) {
      return false;
    }
    final keyRef = key.reference;
    return _containsKeyId(this, const jbooleanType(), [keyRef.pointer]);
  }

  static final _containsValueId =
      _class.instanceMethodId(r'containsValue', r'(Ljava/lang/Object;)Z');
  @override
  bool containsValue(Object? value) {
    if (value is! JObject) {
      return false;
    }
    final valueRef = value.reference;
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
  JSet<$K> get keys => _keysId(this, JSetType<$K>(K), [])!;

  static final _sizeId = _class.instanceMethodId(r'size', r'()I');
  @override
  int get length => _sizeId(this, const jintType(), []);

  static final _removeId = _class.instanceMethodId(
      r'remove', r'(Ljava/lang/Object;)Ljava/lang/Object;');
  @override
  $V? remove(Object? key) {
    if (key is! JObject) {
      return null;
    }
    final keyRef = key.reference;
    final value = _removeId(this, V.nullableType, [keyRef.pointer]);
    return value;
  }
}

extension ToJavaMap<K extends JObject, V extends JObject> on Map<K, V> {
  JMap<K, V> toJMap(JObjType<K> keyType, JObjType<V> valueType) {
    final map = JMap.hash(keyType, valueType);
    map.addAll(this);
    return map;
  }
}
