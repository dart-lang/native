// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';

import 'package:meta/meta.dart' show internal;

import '../jni.dart';
import '../jobject.dart';
import '../jreference.dart';
import '../types.dart';
import 'jiterator.dart';

@internal
final class $JSet$NullableType$<$E extends JObject?> extends JType<JSet<$E>?> {
  final JType<$E> E;

  const $JSet$NullableType$(
    this.E,
  );

  @override
  String get signature => r'Ljava/util/Set;';

  @override
  JSet<$E>? fromReference(JReference reference) =>
      reference.isNull ? null : JSet<$E>.fromReference(E, reference);

  @override
  JType get superType => const $JObject$Type$();

  @override
  JType<JSet<$E>?> get nullableType => this;

  @override
  final superCount = 1;

  @override
  int get hashCode => Object.hash($JSet$NullableType$, E);

  @override
  bool operator ==(Object other) {
    return other.runtimeType == ($JSet$NullableType$<$E>) &&
        other is $JSet$NullableType$<$E> &&
        E == other.E;
  }
}

@internal
final class $JSet$Type$<$E extends JObject?> extends JType<JSet<$E>> {
  final JType<$E> E;

  const $JSet$Type$(
    this.E,
  );

  @override
  String get signature => r'Ljava/util/Set;';

  @override
  JSet<$E> fromReference(JReference reference) =>
      JSet<$E>.fromReference(E, reference);

  @override
  JType get superType => const $JObject$Type$();

  @override
  JType<JSet<$E>?> get nullableType => $JSet$NullableType$<$E>(E);

  @override
  final superCount = 1;

  @override
  int get hashCode => Object.hash($JSet$Type$, E);

  @override
  bool operator ==(Object other) {
    return other.runtimeType == ($JSet$Type$<$E>) &&
        other is $JSet$Type$<$E> &&
        E == other.E;
  }
}

class JSet<$E extends JObject?> extends JObject with SetMixin<$E> {
  @internal
  @override
  // ignore: overridden_fields
  final JType<JSet<$E>> $type;

  @internal
  final JType<$E> E;

  JSet.fromReference(
    this.E,
    JReference reference,
  )   : $type = type<$E>(E),
        super.fromReference(reference);

  static final _class = JClass.forName(r'java/util/Set');

  /// The type which includes information such as the signature of this class.
  static JType<JSet<$E>> type<$E extends JObject?>(
    JType<$E> E,
  ) {
    return $JSet$Type$<$E>(E);
  }

  /// The type which includes information such as the signature of this class.
  static JType<JSet<$E>?> nullableType<$E extends JObject?>(
    JType<$E> E,
  ) {
    return $JSet$NullableType$<$E>(E);
  }

  static final _hashSetClass = JClass.forName(r'java/util/HashSet');
  static final _ctorId = _hashSetClass.constructorId(r'()V');
  JSet.hash(this.E)
      : $type = type<$E>(E),
        super.fromReference(_ctorId(_hashSetClass, referenceType, []));

  static final _addId =
      _class.instanceMethodId(r'add', r'(Ljava/lang/Object;)Z');
  @override
  bool add($E value) {
    final valueRef = value?.reference ?? jNullReference;
    return _addId(this, const jbooleanType(), [valueRef.pointer]);
  }

  static final _addAllId =
      _class.instanceMethodId(r'addAll', r'(Ljava/util/Collection;)Z');
  @override
  void addAll(Iterable<$E> elements) {
    if (elements is JObject) {
      final elementsRef = (elements as JObject).reference;
      if (Jni.env.IsInstanceOf(
          elementsRef.pointer, _collectionClass.reference.pointer)) {
        _addAllId(
          this,
          const jbooleanType(),
          [elementsRef.pointer],
        );
        return;
      }
    }

    return super.addAll(elements);
  }

  static final _clearId = _class.instanceMethodId(r'clear', r'()V');
  @override
  void clear() {
    _clearId(this, const jvoidType(), []);
  }

  static final _containsId =
      _class.instanceMethodId(r'contains', r'(Ljava/lang/Object;)Z');

  @override
  bool contains(Object? element) {
    if (element is! JObject?) {
      return false;
    }
    final elementRef = element?.reference ?? jNullReference;
    return _containsId(this, const jbooleanType(), [elementRef.pointer]);
  }

  static final _containsAllId =
      _class.instanceMethodId(r'containsAll', r'(Ljava/util/Collection;)Z');
  static final _collectionClass = JClass.forName('java/util/Collection');
  @override
  bool containsAll(Iterable<Object?> other) {
    if (other is JObject) {
      final otherRef = (other as JObject).reference;
      if (Jni.env
          .IsInstanceOf(otherRef.pointer, _collectionClass.reference.pointer)) {
        return _containsAllId(this, const jbooleanType(), [otherRef.pointer]);
      }
    }
    return super.containsAll(other);
  }

  static final _isEmptyId = _class.instanceMethodId(r'isEmpty', r'()Z');
  @override
  bool get isEmpty => _isEmptyId(this, const jbooleanType(), []);

  @override
  bool get isNotEmpty => !isEmpty;

  static final _iteratorId =
      _class.instanceMethodId(r'iterator', r'()Ljava/util/Iterator;');
  @override
  JIterator<$E> get iterator => _iteratorId(this, $JIterator$Type$<$E>(E), [])!;

  static final _sizeId = _class.instanceMethodId(r'size', r'()I');
  @override
  int get length => _sizeId(this, const jintType(), []);

  static final _removeId =
      _class.instanceMethodId(r'remove', r'(Ljava/lang/Object;)Z');
  @override
  bool remove(Object? value) {
    if (value is! JObject?) {
      return false;
    }
    final valueRef = value?.reference ?? jNullReference;
    return _removeId(this, const jbooleanType(), [valueRef.pointer]);
  }

  static final _removeAllId =
      _class.instanceMethodId(r'removeAll', r'(Ljava/util/Collection;)Z');
  @override
  void removeAll(Iterable<Object?> elements) {
    if (elements is JObject) {
      final elementsRef = (elements as JObject).reference;
      if (Jni.env.IsInstanceOf(
          elementsRef.pointer, _collectionClass.reference.pointer)) {
        _removeAllId(this, const jbooleanType(), [elementsRef.pointer]);
        return;
      }
    }
    return super.removeAll(elements);
  }

  static final _retainAllId =
      _class.instanceMethodId(r'retainAll', r'(Ljava/util/Collection;)Z');
  @override
  void retainAll(Iterable<Object?> elements) {
    if (elements is JObject) {
      final elementsRef = (elements as JObject).reference;
      if (Jni.env.IsInstanceOf(
          elementsRef.pointer, _collectionClass.reference.pointer)) {
        _retainAllId(this, const jbooleanType(), [elementsRef.pointer]);
        return;
      }
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

extension ToJavaSet<E extends JObject?> on Iterable<E> {
  JSet<E> toJSet(JType<E> type) {
    final set = JSet.hash(type);
    set.addAll(this);
    return set;
  }
}
