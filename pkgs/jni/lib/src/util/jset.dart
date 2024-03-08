// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';

import 'package:jni/src/third_party/generated_bindings.dart';

import '../accessors.dart';
import '../jni.dart';
import '../jobject.dart';
import '../types.dart';
import 'jiterator.dart';

final class JSetType<$E extends JObject> extends JObjType<JSet<$E>> {
  final JObjType<$E> E;

  const JSetType(
    this.E,
  );

  @override
  String get signature => r"Ljava/util/Set;";

  @override
  JSet<$E> fromReference(JObjectPtr ref) => JSet.fromReference(E, ref);

  @override
  JObjType get superType => const JObjectType();

  @override
  final superCount = 1;

  @override
  int get hashCode => Object.hash(JSetType, E);

  @override
  bool operator ==(Object other) {
    return other.runtimeType == (JSetType<$E>) &&
        other is JSetType<$E> &&
        E == other.E;
  }
}

class JSet<$E extends JObject> extends JObject with SetMixin<$E> {
  @override
  // ignore: overridden_fields
  late final JObjType<JSet> $type = type(E);

  final JObjType<$E> E;

  JSet.fromReference(
    this.E,
    JObjectPtr ref,
  ) : super.fromReference(ref);

  static final _class = Jni.findJClass(r"java/util/Set");

  /// The type which includes information such as the signature of this class.
  static JSetType<$E> type<$E extends JObject>(
    JObjType<$E> E,
  ) {
    return JSetType(
      E,
    );
  }

  static final _hashSetClass = Jni.findJClass(r"java/util/HashSet");
  static final _ctorId = Jni.accessors
      .getMethodIDOf(_hashSetClass.reference.pointer, r"<init>", r"()V");
  JSet.hash(this.E)
      : super.fromReference(Jni.accessors.newObjectWithArgs(
            _hashSetClass.reference.pointer, _ctorId, []).object);

  static final _addId = Jni.accessors.getMethodIDOf(
      _class.reference.pointer, r"add", r"(Ljava/lang/Object;)Z");
  @override
  bool add($E value) {
    return Jni.accessors.callMethodWithArgs(reference.pointer, _addId,
        JniCallType.booleanType, [value.reference.pointer]).boolean;
  }

  static final _addAllId = Jni.accessors.getMethodIDOf(
      _class.reference.pointer, r"addAll", r"(Ljava/util/Collection;)Z");
  @override
  void addAll(Iterable<$E> elements) {
    if (elements is JObject &&
        Jni.env.IsInstanceOf((elements as JObject).reference.pointer,
            _collectionClass.reference.pointer)) {
      Jni.accessors.callMethodWithArgs(
        reference.pointer,
        _addAllId,
        JniCallType.booleanType,
        [(elements as JObject).reference.pointer],
      ).boolean;
      return;
    }
    return super.addAll(elements);
  }

  static final _clearId =
      Jni.accessors.getMethodIDOf(_class.reference.pointer, r"clear", r"()V");
  @override
  void clear() {
    return Jni.accessors.callMethodWithArgs(
        reference.pointer, _clearId, JniCallType.voidType, []).check();
  }

  static final _containsId = Jni.accessors.getMethodIDOf(
      _class.reference.pointer, r"contains", r"(Ljava/lang/Object;)Z");

  @override
  bool contains(Object? element) {
    if (element is! JObject) {
      return false;
    }
    return Jni.accessors.callMethodWithArgs(reference.pointer, _containsId,
        JniCallType.booleanType, [element.reference.pointer]).boolean;
  }

  static final _containsAllId = Jni.accessors.getMethodIDOf(
      _class.reference.pointer, r"containsAll", r"(Ljava/util/Collection;)Z");
  static final _collectionClass = Jni.findJClass("java/util/Collection");
  @override
  bool containsAll(Iterable<Object?> other) {
    if (other is JObject &&
        Jni.env.IsInstanceOf((other as JObject).reference.pointer,
            _collectionClass.reference.pointer)) {
      return Jni.accessors.callMethodWithArgs(
          reference.pointer,
          _containsAllId,
          JniCallType.booleanType,
          [(other as JObject).reference.pointer]).boolean;
    }
    return super.containsAll(other);
  }

  static final _isEmptyId =
      Jni.accessors.getMethodIDOf(_class.reference.pointer, r"isEmpty", r"()Z");
  @override
  bool get isEmpty => Jni.accessors.callMethodWithArgs(
      reference.pointer, _isEmptyId, JniCallType.booleanType, []).boolean;

  @override
  bool get isNotEmpty => !isEmpty;

  static final _iteratorId = Jni.accessors.getMethodIDOf(
      _class.reference.pointer, r"iterator", r"()Ljava/util/Iterator;");
  @override
  JIterator<$E> get iterator =>
      JIteratorType(E).fromReference(Jni.accessors.callMethodWithArgs(
          reference.pointer, _iteratorId, JniCallType.objectType, []).object);

  static final _sizeId =
      Jni.accessors.getMethodIDOf(_class.reference.pointer, r"size", r"()I");
  @override
  int get length => Jni.accessors.callMethodWithArgs(
      reference.pointer, _sizeId, JniCallType.intType, []).integer;

  static final _removeId = Jni.accessors.getMethodIDOf(
      _class.reference.pointer, r"remove", r"(Ljava/lang/Object;)Z");
  @override
  bool remove(Object? value) {
    if (value is! $E) {
      return false;
    }
    return Jni.accessors.callMethodWithArgs(reference.pointer, _removeId,
        JniCallType.booleanType, [value.reference.pointer]).boolean;
  }

  static final _removeAllId = Jni.accessors.getMethodIDOf(
      _class.reference.pointer, r"removeAll", r"(Ljava/util/Collection;)Z");
  @override
  void removeAll(Iterable<Object?> elements) {
    if (elements is JObject &&
        Jni.env.IsInstanceOf((elements as JObject).reference.pointer,
            _collectionClass.reference.pointer)) {
      Jni.accessors.callMethodWithArgs(
          reference.pointer,
          _removeAllId,
          JniCallType.booleanType,
          [(elements as JObject).reference.pointer]).boolean;
      return;
    }
    return super.removeAll(elements);
  }

  static final _retainAllId = Jni.accessors.getMethodIDOf(
      _class.reference.pointer, r"retainAll", r"(Ljava/util/Collection;)Z");
  @override
  void retainAll(Iterable<Object?> elements) {
    if (elements is JObject &&
        Jni.env.IsInstanceOf((elements as JObject).reference.pointer,
            _collectionClass.reference.pointer)) {
      Jni.accessors.callMethodWithArgs(
          reference.pointer,
          _retainAllId,
          JniCallType.booleanType,
          [(elements as JObject).reference.pointer]).boolean;
      return;
    }
    return super.retainAll(elements);
  }

  @override
  $E? lookup(Object? element) {
    if (contains(element)) return element as $E;
    return null;
  }

  @override
  JSet<$E> toSet() {
    return toJSet(E);
  }
}

extension ToJavaSet<E extends JObject> on Iterable<E> {
  JSet<E> toJSet(JObjType<E> type) {
    final set = JSet.hash(type);
    set.addAll(this);
    return set;
  }
}
