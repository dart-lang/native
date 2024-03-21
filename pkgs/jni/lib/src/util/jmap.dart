// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';

import '../jobject.dart';
import '../jreference.dart';
import '../types.dart';
import 'jset.dart';

final class JMapType<$K extends JObject, $V extends JObject>
    extends JObjType<JMap<$K, $V>> {
  final JObjType<$K> K;
  final JObjType<$V> V;

  const JMapType(
    this.K,
    this.V,
  );

  @override
  String get signature => r"Ljava/util/Map;";

  @override
  JMap<$K, $V> fromReference(JReference reference) =>
      JMap.fromReference(K, V, reference);

  @override
  JObjType get superType => const JObjectType();

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

class JMap<$K extends JObject, $V extends JObject> extends JObject
    with MapMixin<$K, $V> {
  @override
  // ignore: overridden_fields
  late final JObjType<JMap> $type = type(K, V);

  final JObjType<$K> K;
  final JObjType<$V> V;

  JMap.fromReference(
    this.K,
    this.V,
    JReference reference,
  ) : super.fromReference(reference);

  static final _class = JClass.forName(r"java/util/Map");

  /// The type which includes information such as the signature of this class.
  static JMapType<$K, $V> type<$K extends JObject, $V extends JObject>(
    JObjType<$K> K,
    JObjType<$V> V,
  ) {
    return JMapType(
      K,
      V,
    );
  }

  static final _hashMapClass = JClass.forName(r"java/util/HashMap");
  static final _ctorId = _hashMapClass.constructorId(r"()V");
  JMap.hash(this.K, this.V)
      : super.fromReference(_ctorId(_hashMapClass, referenceType, []));

  static final _getId = _class.instanceMethodId(
      r"get", r"(Ljava/lang/Object;)Ljava/lang/Object;");
  @override
  $V? operator [](Object? key) {
    if (key is! JObject) {
      return null;
    }
    final value = _getId(this, V, [key.reference.pointer]);
    return value.isNull ? null : value;
  }

  static final _putId = _class.instanceMethodId(
      r"put", r"(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;");
  @override
  void operator []=($K key, $V value) {
    _putId(this, V, [key.reference.pointer, value.reference.pointer]);
  }

  static final _addAllId =
      _class.instanceMethodId(r"putAll", r"(Ljava/util/Map;)V");
  @override
  void addAll(Map<$K, $V> other) {
    if (other is JMap<$K, $V>) {
      _addAllId(this, const jvoidType(), [other.reference.pointer]);
      return;
    }
    super.addAll(other);
  }

  static final _clearId = _class.instanceMethodId(r"clear", r"()V");
  @override
  void clear() {
    _clearId(this, const jvoidType(), []);
  }

  static final _containsKeyId =
      _class.instanceMethodId(r"containsKey", r"(Ljava/lang/Object;)Z");
  @override
  bool containsKey(Object? key) {
    if (key is! JObject) {
      return false;
    }
    return _containsKeyId(this, const jbooleanType(), [key.reference.pointer]);
  }

  static final _containsValueId =
      _class.instanceMethodId(r"containsValue", r"(Ljava/lang/Object;)Z");
  @override
  bool containsValue(Object? value) {
    if (value is! JObject) {
      return false;
    }
    return _containsValueId(
        this, const jbooleanType(), [value.reference.pointer]);
  }

  static final isEmptyId = _class.instanceMethodId(r"isEmpty", r"()Z");
  @override
  bool get isEmpty => isEmptyId(this, const jbooleanType(), []);

  @override
  bool get isNotEmpty => !isEmpty;

  static final _keysId =
      _class.instanceMethodId(r"keySet", r"()Ljava/util/Set;");
  @override
  JSet<$K> get keys => _keysId(this, JSetType(K), []);

  static final _sizeId = _class.instanceMethodId(r"size", r"()I");
  @override
  int get length => _sizeId(this, const jintType(), []);

  static final _removeId = _class.instanceMethodId(
      r"remove", r"(Ljava/lang/Object;)Ljava/lang/Object;");
  @override
  $V? remove(Object? key) {
    if (key is! JObject) {
      return null;
    }
    final value = _removeId(this, V, [key.reference.pointer]);
    return value.isNull ? null : value;
  }
}

extension ToJavaMap<K extends JObject, V extends JObject> on Map<K, V> {
  JMap<K, V> toJMap(JObjType<K> keyType, JObjType<V> valueType) {
    final map = JMap.hash(keyType, valueType);
    map.addAll(this);
    return map;
  }
}
