// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';

import 'package:meta/meta.dart' show internal;

import '../../_internal.dart';
import '../jni.dart';
import '../jobject.dart';
import '../jreference.dart';
import '../jvalues.dart';
import '../types.dart';
import 'jiterator.dart';
import 'jset.dart';

@internal
final class $JList$Type$ extends JType<JList> {
  const $JList$Type$();

  @override
  String get signature => r'Ljava/util/List;';
}

extension type JList<$E extends JObject?>(JObject _$this) implements JObject {
  static final _class = JClass.forName(r'java/util/List');

  /// The type which includes information such as the signature of this class.
  static const JType<JList> type = $JList$Type$();

  static final _arrayListClassRef = JClass.forName(r'java/util/ArrayList');
  static final _ctorId = _arrayListClassRef.constructorId(r'()V');
  static final _new$ = ProtectedJniExtensions.lookup<
          NativeFunction<
              JniResult Function(
                Pointer<Void>,
                JMethodIDPtr,
              )>>('globalEnv_NewObject')
      .asFunction<
          JniResult Function(
            Pointer<Void>,
            JMethodIDPtr,
          )>();
  factory JList.array() =>
      _new$(_arrayListClassRef.reference.pointer, _ctorId as JMethodIDPtr)
          .object<JList<$E>>();

  static final _sizeId = _class.instanceMethodId(r'size', r'()I');
  int get size => _sizeId(this, const jintType(), [])!;

  static final _getId =
      _class.instanceMethodId(r'get', r'(I)Ljava/lang/Object;');
  $E get(int index) =>
      _getId(this, JObject.type, [JValueInt(index)]) as $E;

  static final _setId = _class.instanceMethodId(
      r'set', r'(ILjava/lang/Object;)Ljava/lang/Object;');
  void set(int index, $E value) =>
      _setId(this, JObject.type, [JValueInt(index), value]);

  static final _addId =
      _class.instanceMethodId(r'add', r'(Ljava/lang/Object;)Z');
  @override
  void add($E element) => _addId(this, const jbooleanType(), [element]);

  static final _clearId = _class.instanceMethodId(r'clear', r'()V');
  void clear() => _clearId(this, const jvoidType(), []);

  static final _containsId =
      _class.instanceMethodId(r'contains', r'(Ljava/lang/Object;)Z');
  bool contains(JObject? element) {
    final elementRef = element?.reference ?? jNullReference;
    return _containsId(this, const jbooleanType(), [elementRef.pointer])!;
  }

  static final _getRangeId =
      _class.instanceMethodId(r'subList', r'(II)Ljava/util/List;');
  @override
  JList<$E> getRange(int start, int end) {
    RangeError.checkValidRange(start, end, length);
    return _getRangeId(
        this, $JList$Type$<$E>(E), [JValueInt(start), JValueInt(end)])!;
  }

  static final _indexOfId =
      _class.instanceMethodId(r'indexOf', r'(Ljava/lang/Object;)I');
  @override
  int indexOf(Object? element, [int start = 0]) {
    if (element is! JObject?) return -1;
    if (start < 0) start = 0;
    final elementRef = element?.reference ?? jNullReference;
    if (start == 0) {
      return _indexOfId(this, const jintType(), [elementRef.pointer])!;
    }
    return _indexOfId(
      getRange(start, length),
      const jintType(),
      [elementRef.pointer],
    )!;
  }

  static final _insertId =
      _class.instanceMethodId(r'add', r'(ILjava/lang/Object;)V');
  @override
  void insert(int index, $E element) {
    _insertId(this, const jvoidType(), [JValueInt(index), element]);
  }

  static final _insertAllId =
      _class.instanceMethodId(r'addAll', r'(ILjava/util/Collection;)Z');
  @override
  void insertAll(int index, Iterable<$E> iterable) {
    if (iterable is JObject) {
      final iterableRef = (iterable as JObject).reference;
      if (Jni.env.IsInstanceOf(
          iterableRef.pointer, _collectionClass.reference.pointer)) {
        _insertAllId(
          this,
          const jbooleanType(),
          [JValueInt(index), iterableRef.pointer],
        );
        return;
      }
    }
    super.insertAll(index, iterable);
  }

  static final _isEmptyId = _class.instanceMethodId(r'isEmpty', r'()Z');
  @override
  bool get isEmpty => _isEmptyId(this, const jbooleanType(), [])!;

  @override
  bool get isNotEmpty => !isEmpty;

  static final _iteratorId =
      _class.instanceMethodId(r'iterator', r'()Ljava/util/Iterator;');
  @override
  JIterator<$E> get iterator => _iteratorId(this, $JIterator$Type$<$E>(E), [])!;

  static final _lastIndexOfId =
      _class.instanceMethodId(r'lastIndexOf', r'(Ljava/lang/Object;)I');
  @override
  int lastIndexOf(Object? element, [int? start]) {
    if (element is! JObject?) return -1;
    if (start == null || start >= length) start = length - 1;
    final elementRef = element?.reference ?? jNullReference;
    if (start == length - 1) {
      return _lastIndexOfId(this, const jintType(), [elementRef.pointer]);
    }
    final range = getRange(0, start);
    final res = _lastIndexOfId(
      range,
      const jintType(),
      [elementRef.pointer],
    );
    range.release();
    return res;
  }

  static final _removeId =
      _class.instanceMethodId(r'remove', r'(Ljava/lang/Object;)Z');
  @override
  bool remove(Object? element) {
    if (element is! JObject?) return false;
    final elementRef = element?.reference ?? jNullReference;
    return _removeId(this, const jbooleanType(), [elementRef.pointer]);
  }

  static final _removeAtId =
      _class.instanceMethodId(r'remove', r'(I)Ljava/lang/Object;');
  @override
  $E removeAt(int index) {
    return _removeAtId(this, JObject.type, [JValueInt(index)])!;
  }

  @override
  void removeRange(int start, int end) {
    final range = getRange(start, end);
    range.clear();
    range.release();
  }

  @override
  JSet<$E> toSet() {
    return toJSet();
  }
}

final class _JListView<$E extends JObject?> with ListMixin<$E> {
  final JList<$E> jlist;

  _JListView(this.jlist);

  static final _class = JClass.forName(r'java/util/List');

  static final _sizeId = _class.instanceMethodId(r'size', r'()I');

  @override
  int get length => _sizeId(jlist, const jintType(), [])!;

  @override
  set length(int newLength) {
    RangeError.checkNotNegative(newLength);
    while (length < newLength) {
      add(null as $E);
    }
    while (newLength < length) {
      removeAt(length - 1);
    }
  }

  static final _getId =
      _class.instanceMethodId(r'get', r'(I)Ljava/lang/Object;');
  @override
  $E operator [](int index) {
    RangeError.checkValidIndex(index, this);
    return _getId(jlist, JObject.type, [JValueInt(index)]) as $E;
  }

  static final _setId = _class.instanceMethodId(
      r'set', r'(ILjava/lang/Object;)Ljava/lang/Object;');
  @override
  void operator []=(int index, $E value) {
    RangeError.checkValidIndex(index, this);
    _setId(jlist, JObject.type, [JValueInt(index), value]);
  }

  static final _addId =
      _class.instanceMethodId(r'add', r'(Ljava/lang/Object;)Z');
  @override
  void add($E element) {
    _addId(jlist, const jbooleanType(), [element]);
  }

  static final _collectionClass = JClass.forName('java/util/Collection');
  static final _addAllId =
      _class.instanceMethodId(r'addAll', r'(Ljava/util/Collection;)Z');
  @override
  void addAll(Iterable<$E> iterable) {
    if (iterable is JObject) {
      final iterableRef = (iterable as JObject).reference;
      if (Jni.env.IsInstanceOf(
          iterableRef.pointer, _collectionClass.reference.pointer)) {
        _addAllId(jlist, const jbooleanType(), [iterableRef.pointer]);
        return;
      }
    }
    return super.addAll(iterable);
  }

  static final _clearId = _class.instanceMethodId(r'clear', r'()V');
  @override
  void clear() {
    _clearId(jlist, const jvoidType(), []);
  }

  static final _containsId =
      _class.instanceMethodId(r'contains', r'(Ljava/lang/Object;)Z');
  @override
  bool contains(Object? element) {
    if (element is! JObject?) return false;
    final elementRef = element?.reference ?? jNullReference;
    return _containsId(jlist, const jbooleanType(), [elementRef.pointer])!;
  }

  static final _getRangeId =
      _class.instanceMethodId(r'subList', r'(II)Ljava/util/List;');
  @override
  JList<$E> getRange(int start, int end) {
    RangeError.checkValidRange(start, end, length);
    return _getRangeId(jlist, JObject.type, [JValueInt(start), JValueInt(end)])
        as JList<$E>;
  }

  static final _indexOfId =
      _class.instanceMethodId(r'indexOf', r'(Ljava/lang/Object;)I');
  @override
  int indexOf(Object? element, [int start = 0]) {
    if (element is! JObject?) return -1;
    if (start < 0) start = 0;
    final elementRef = element?.reference ?? jNullReference;
    if (start == 0) {
      return _indexOfId(jlist, const jintType(), [elementRef.pointer])!;
    }
    return _indexOfId(
      getRange(start, length),
      const jintType(),
      [elementRef.pointer],
    )!;
  }

  static final _insertId =
      _class.instanceMethodId(r'add', r'(ILjava/lang/Object;)V');
  @override
  void insert(int index, $E element) {
    _insertId(jlist, const jvoidType(), [JValueInt(index), element]);
  }

  static final _insertAllId =
      _class.instanceMethodId(r'addAll', r'(ILjava/util/Collection;)Z');
  @override
  void insertAll(int index, Iterable<$E> iterable) {
    if (iterable is JObject) {
      final iterableRef = (iterable as JObject).reference;
      if (Jni.env.IsInstanceOf(
          iterableRef.pointer, _collectionClass.reference.pointer)) {
        _insertAllId(
          this,
          const jbooleanType(),
          [JValueInt(index), iterableRef.pointer],
        );
        return;
      }
    }
    super.insertAll(index, iterable);
  }

  static final _isEmptyId = _class.instanceMethodId(r'isEmpty', r'()Z');
  @override
  bool get isEmpty => _isEmptyId(jlist, const jbooleanType(), [])!;

  @override
  bool get isNotEmpty => !isEmpty;

  static final _iteratorId =
      _class.instanceMethodId(r'iterator', r'()Ljava/util/Iterator;');
  @override
  JIterator<$E> get iterator =>
      _iteratorId(jlist, $JIterator$Type$<$E>(E), [])!;

  static final _lastIndexOfId =
      _class.instanceMethodId(r'lastIndexOf', r'(Ljava/lang/Object;)I');
  @override
  int lastIndexOf(Object? element, [int? start]) {
    if (element is! JObject?) return -1;
    if (start == null || start >= length) start = length - 1;
    final elementRef = element?.reference ?? jNullReference;
    if (start == length - 1) {
      return _lastIndexOfId(jlist, const jintType(), [elementRef.pointer]);
    }
    final range = getRange(0, start);
    final res = _lastIndexOfId(
      range,
      const jintType(),
      [elementRef.pointer],
    );
    range.release();
    return res;
  }

  static final _removeId =
      _class.instanceMethodId(r'remove', r'(Ljava/lang/Object;)Z');
  @override
  bool remove(Object? element) {
    if (element is! JObject?) return false;
    final elementRef = element?.reference ?? jNullReference;
    return _removeId(jlist, const jbooleanType(), [elementRef.pointer]);
  }

  static final _removeAtId =
      _class.instanceMethodId(r'remove', r'(I)Ljava/lang/Object;');
  @override
  $E removeAt(int index) {
    return _removeAtId(jlist, JObject.type, [JValueInt(index)])!;
  }

  @override
  void removeRange(int start, int end) {
    final range = getRange(start, end);
    range.clear();
    range.release();
  }

  @override
  JSet<$E> toSet() {
    return toJSet();
  }
}

extension ToJavaList<E extends JObject?> on Iterable<E> {
  JList<E> toJList() {
    final list = JList<E>.array();
    list.addAll(this);
    return list;
  }
}
