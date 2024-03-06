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
  static final _ctorId = Jni.accessors
      .getMethodIDOf(_hashMapClass.reference.pointer, r"<init>", r"()V");
  JMap.hash(this.K, this.V)
      : super.fromRef(Jni.accessors.newObjectWithArgs(
            _hashMapClass.reference.pointer, _ctorId, []).object);

  static final _getId = Jni.accessors.getMethodIDOf(_class.reference.pointer,
      r"get", r"(Ljava/lang/Object;)Ljava/lang/Object;");
  @override
  $V? operator [](Object? key) {
    if (key is! JObject) {
      return null;
    }
    final value = V.fromRef(Jni.accessors.callMethodWithArgs(reference.pointer,
        _getId, JniCallType.objectType, [key.reference.pointer]).object);
    return value.isNull ? null : value;
  }

  static final _putId = Jni.accessors.getMethodIDOf(_class.reference.pointer,
      r"put", r"(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;");
  @override
  void operator []=($K key, $V value) {
    Jni.accessors.callMethodWithArgs(
        reference.pointer,
        _putId,
        JniCallType.objectType,
        [key.reference.pointer, value.reference.pointer]).object;
  }

  static final _addAllId = Jni.accessors.getMethodIDOf(
      _class.reference.pointer, r"putAll", r"(Ljava/util/Map;)V");
  @override
  void addAll(Map<$K, $V> other) {
    if (other is JMap<$K, $V>) {
      Jni.accessors.callMethodWithArgs(reference.pointer, _addAllId,
          JniCallType.voidType, [other.reference.pointer]).check();
      return;
    }
    super.addAll(other);
  }

  static final _clearId =
      Jni.accessors.getMethodIDOf(_class.reference.pointer, r"clear", r"()V");
  @override
  void clear() {
    Jni.accessors.callMethodWithArgs(
        reference.pointer, _clearId, JniCallType.voidType, []).check();
  }

  static final _containsKeyId = Jni.accessors.getMethodIDOf(
      _class.reference.pointer, r"containsKey", r"(Ljava/lang/Object;)Z");
  @override
  bool containsKey(Object? key) {
    if (key is! JObject) {
      return false;
    }
    return Jni.accessors.callMethodWithArgs(reference.pointer, _containsKeyId,
        JniCallType.booleanType, [key.reference.pointer]).boolean;
  }

  static final _containsValueId = Jni.accessors.getMethodIDOf(
      _class.reference.pointer, r"containsValue", r"(Ljava/lang/Object;)Z");
  @override
  bool containsValue(Object? value) {
    if (value is! JObject) {
      return false;
    }
    return Jni.accessors.callMethodWithArgs(reference.pointer, _containsValueId,
        JniCallType.booleanType, [value.reference.pointer]).boolean;
  }

  static final isEmptyId =
      Jni.accessors.getMethodIDOf(_class.reference.pointer, r"isEmpty", r"()Z");
  @override
  bool get isEmpty => Jni.accessors.callMethodWithArgs(
      reference.pointer, isEmptyId, JniCallType.booleanType, []).boolean;

  @override
  bool get isNotEmpty => !isEmpty;

  static final _keysId = Jni.accessors
      .getMethodIDOf(_class.reference.pointer, r"keySet", r"()Ljava/util/Set;");
  @override
  JSet<$K> get keys => JSetType(K).fromRef(Jni.accessors.callMethodWithArgs(
      reference.pointer, _keysId, JniCallType.objectType, []).object);

  static final _sizeId =
      Jni.accessors.getMethodIDOf(_class.reference.pointer, r"size", r"()I");
  @override
  int get length => Jni.accessors.callMethodWithArgs(
      reference.pointer, _sizeId, JniCallType.intType, []).integer;

  static final _removeId = Jni.accessors.getMethodIDOf(_class.reference.pointer,
      r"remove", r"(Ljava/lang/Object;)Ljava/lang/Object;");
  @override
  $V? remove(Object? key) {
    if (key is! JObject) {
      return null;
    }
    final value = V.fromRef(Jni.accessors.callMethodWithArgs(reference.pointer,
        _removeId, JniCallType.objectType, [key.reference.pointer]).object);
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
