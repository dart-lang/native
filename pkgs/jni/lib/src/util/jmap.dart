// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';

import '../accessors.dart';
import '../jni.dart';
import '../jobject.dart';
import '../third_party/jni_bindings_generated.dart';
import '../types.dart';
import 'jset.dart';

class JMapType<$K extends JObject, $V extends JObject>
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
  JMap<$K, $V> fromRef(JObjectPtr ref) => JMap.fromRef(K, V, ref);

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

  JMap.fromRef(
    this.K,
    this.V,
    JObjectPtr ref,
  ) : super.fromRef(ref);

  static final _class = Jni.findJClass(r"java/util/Map");

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

  static final _hashMapClass = Jni.findJClass(r"java/util/HashMap");
  static final _ctorId =
      Jni.accessors.getMethodIDOf(_hashMapClass.reference, r"<init>", r"()V");
  JMap.hash(this.K, this.V)
      : super.fromRef(Jni.accessors
            .newObjectWithArgs(_hashMapClass.reference, _ctorId, []).object);

  static final _getId = Jni.accessors.getMethodIDOf(
      _class.reference, r"get", r"(Ljava/lang/Object;)Ljava/lang/Object;");
  @override
  $V? operator [](Object? key) {
    if (key is! JObject) {
      return null;
    }
    final value = V.fromRef(Jni.accessors.callMethodWithArgs(
        reference, _getId, JniCallType.objectType, [key.reference]).object);
    return value.isNull ? null : value;
  }

  static final _putId = Jni.accessors.getMethodIDOf(_class.reference, r"put",
      r"(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;");
  @override
  void operator []=($K key, $V value) {
    Jni.accessors.callMethodWithArgs(reference, _putId, JniCallType.objectType,
        [key.reference, value.reference]).object;
  }

  static final _addAllId = Jni.accessors
      .getMethodIDOf(_class.reference, r"putAll", r"(Ljava/util/Map;)V");
  @override
  void addAll(Map<$K, $V> other) {
    if (other is JMap<$K, $V>) {
      Jni.accessors.callMethodWithArgs(reference, _addAllId,
          JniCallType.voidType, [other.reference]).check();
    } else {
      for (final entry in other.entries) {
        this[entry.key] = entry.value;
      }
    }
  }

  static final _clearId =
      Jni.accessors.getMethodIDOf(_class.reference, r"clear", r"()V");
  @override
  void clear() {
    Jni.accessors.callMethodWithArgs(
        reference, _clearId, JniCallType.voidType, []).check();
  }

  static final _containsKeyId = Jni.accessors.getMethodIDOf(
      _class.reference, r"containsKey", r"(Ljava/lang/Object;)Z");
  @override
  bool containsKey(Object? key) {
    if (key is! JObject) {
      return false;
    }
    return Jni.accessors.callMethodWithArgs(reference, _containsKeyId,
        JniCallType.booleanType, [key.reference]).boolean;
  }

  static final _containsValueId = Jni.accessors.getMethodIDOf(
      _class.reference, r"containsValue", r"(Ljava/lang/Object;)Z");
  @override
  bool containsValue(Object? value) {
    if (value is! JObject) {
      return false;
    }
    return Jni.accessors.callMethodWithArgs(reference, _containsValueId,
        JniCallType.booleanType, [value.reference]).boolean;
  }

  static final isEmptyId =
      Jni.accessors.getMethodIDOf(_class.reference, r"isEmpty", r"()Z");
  @override
  bool get isEmpty => Jni.accessors.callMethodWithArgs(
      reference, isEmptyId, JniCallType.booleanType, []).boolean;

  @override
  bool get isNotEmpty => !isEmpty;

  static final _keysId = Jni.accessors
      .getMethodIDOf(_class.reference, r"keySet", r"()Ljava/util/Set;");
  @override
  JSet<$K> get keys => JSetType(K).fromRef(Jni.accessors.callMethodWithArgs(
      reference, _keysId, JniCallType.objectType, []).object);

  static final _sizeId =
      Jni.accessors.getMethodIDOf(_class.reference, r"size", r"()I");
  @override
  int get length => Jni.accessors
      .callMethodWithArgs(reference, _sizeId, JniCallType.intType, []).integer;

  static final _removeId = Jni.accessors.getMethodIDOf(
      _class.reference, r"remove", r"(Ljava/lang/Object;)Ljava/lang/Object;");
  @override
  $V? remove(Object? key) {
    if (key is! JObject) {
      return null;
    }
    final value = V.fromRef(Jni.accessors.callMethodWithArgs(
        reference, _removeId, JniCallType.objectType, [key.reference]).object);
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
