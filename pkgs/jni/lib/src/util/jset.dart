// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';

import '../jni.dart';
import '../jobject.dart';
import '../jreference.dart';
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
  JSet<$E> fromReference(JReference reference) =>
      JSet.fromReference(E, reference);

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
    JReference reference,
  ) : super.fromReference(reference);

  static final _class = JClass.forName(r"java/util/Set");

  /// The type which includes information such as the signature of this class.
  static JSetType<$E> type<$E extends JObject>(
    JObjType<$E> E,
  ) {
    return JSetType(
      E,
    );
  }

  static final _hashSetClass = JClass.forName(r"java/util/HashSet");
  static final _ctorId = _hashSetClass.constructorId(r"()V");
  JSet.hash(this.E)
      : super.fromReference(_ctorId(_hashSetClass, referenceType, []));

  static final _addId =
      _class.instanceMethodId(r"add", r"(Ljava/lang/Object;)Z");
  @override
  bool add($E value) {
    return _addId(this, const jbooleanType(), [value.reference.pointer]);
  }

  static final _addAllId =
      _class.instanceMethodId(r"addAll", r"(Ljava/util/Collection;)Z");
  @override
  void addAll(Iterable<$E> elements) {
    if (elements is JObject &&
        Jni.env.IsInstanceOf((elements as JObject).reference.pointer,
            _collectionClass.reference.pointer)) {
      _addAllId(
        this,
        const jbooleanType(),
        [(elements as JObject).reference.pointer],
      );
      return;
    }
    return super.addAll(elements);
  }

  static final _clearId = _class.instanceMethodId(r"clear", r"()V");
  @override
  void clear() {
    _clearId(this, const jvoidType(), []);
  }

  static final _containsId =
      _class.instanceMethodId(r"contains", r"(Ljava/lang/Object;)Z");

  @override
  bool contains(Object? element) {
    if (element is! JObject) {
      return false;
    }
    return _containsId(this, const jbooleanType(), [element.reference.pointer]);
  }

  static final _containsAllId =
      _class.instanceMethodId(r"containsAll", r"(Ljava/util/Collection;)Z");
  static final _collectionClass = JClass.forName("java/util/Collection");
  @override
  bool containsAll(Iterable<Object?> other) {
    if (other is JObject &&
        Jni.env.IsInstanceOf((other as JObject).reference.pointer,
            _collectionClass.reference.pointer)) {
      return _containsAllId(
          this, const jbooleanType(), [(other as JObject).reference.pointer]);
    }
    return super.containsAll(other);
  }

  static final _isEmptyId = _class.instanceMethodId(r"isEmpty", r"()Z");
  @override
  bool get isEmpty => _isEmptyId(this, const jbooleanType(), []);

  @override
  bool get isNotEmpty => !isEmpty;

  static final _iteratorId =
      _class.instanceMethodId(r"iterator", r"()Ljava/util/Iterator;");
  @override
  JIterator<$E> get iterator => _iteratorId(this, JIteratorType(E), []);

  static final _sizeId = _class.instanceMethodId(r"size", r"()I");
  @override
  int get length => _sizeId(this, const jintType(), []);

  static final _removeId =
      _class.instanceMethodId(r"remove", r"(Ljava/lang/Object;)Z");
  @override
  bool remove(Object? value) {
    if (value is! $E) {
      return false;
    }
    return _removeId(this, const jbooleanType(), [value.reference.pointer]);
  }

  static final _removeAllId =
      _class.instanceMethodId(r"removeAll", r"(Ljava/util/Collection;)Z");
  @override
  void removeAll(Iterable<Object?> elements) {
    if (elements is JObject &&
        Jni.env.IsInstanceOf((elements as JObject).reference.pointer,
            _collectionClass.reference.pointer)) {
      _removeAllId(this, const jbooleanType(),
          [(elements as JObject).reference.pointer]);
      return;
    }
    return super.removeAll(elements);
  }

  static final _retainAllId =
      _class.instanceMethodId(r"retainAll", r"(Ljava/util/Collection;)Z");
  @override
  void retainAll(Iterable<Object?> elements) {
    if (elements is JObject &&
        Jni.env.IsInstanceOf((elements as JObject).reference.pointer,
            _collectionClass.reference.pointer)) {
      _retainAllId(this, const jbooleanType(),
          [(elements as JObject).reference.pointer]);
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
