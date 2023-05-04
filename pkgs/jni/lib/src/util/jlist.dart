// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';
import 'dart:ffi';

import 'package:jni/src/util/jset.dart';

import '../accessors.dart';
import '../jni.dart';
import '../jobject.dart';
import '../jvalues.dart';
import '../third_party/generated_bindings.dart';
import '../types.dart';
import 'jiterator.dart';

class JListType<$E extends JObject> extends JObjType<JList<$E>> {
  final JObjType<$E> E;

  const JListType(
    this.E,
  );

  @override
  String get signature => r"Ljava/util/List;";

  @override
  JList<$E> fromRef(JObjectPtr ref) => JList.fromRef(E, ref);

  @override
  JObjType get superType => const JObjectType();

  @override
  final superCount = 1;

  @override
  int get hashCode => Object.hash(JListType, E);

  @override
  bool operator ==(Object other) {
    return other.runtimeType == JListType && other is JListType && E == other.E;
  }
}

class JList<$E extends JObject> extends JObject with ListMixin<$E> {
  @override
  // ignore: overridden_fields
  late final JObjType<JList> $type = type(E);

  final JObjType<$E> E;

  JList.fromRef(
    this.E,
    JObjectPtr ref,
  ) : super.fromRef(ref);

  static final _class = Jni.findJClass(r"java/util/List");

  /// The type which includes information such as the signature of this class.
  static JListType<$E> type<$E extends JObject>(
    JObjType<$E> E,
  ) {
    return JListType(
      E,
    );
  }

  static final _arrayListClassRef = Jni.findJClass(r"java/util/ArrayList");
  static final _ctorId = Jni.accessors
      .getMethodIDOf(_arrayListClassRef.reference, r"<init>", r"()V");
  JList.array(this.E)
      : super.fromRef(Jni.accessors.newObjectWithArgs(
            _arrayListClassRef.reference, _ctorId, []).object);

  static final _sizeId =
      Jni.accessors.getMethodIDOf(_class.reference, r"size", r"()I");
  @override
  int get length => Jni.accessors
      .callMethodWithArgs(reference, _sizeId, JniCallType.intType, []).integer;

  @override
  set length(int newLength) {
    RangeError.checkNotNegative(newLength);
    while (length < newLength) {
      add(E.fromRef(nullptr));
    }
    while (newLength < length) {
      removeAt(length - 1);
    }
  }

  static final _getId = Jni.accessors
      .getMethodIDOf(_class.reference, r"get", r"(I)Ljava/lang/Object;");
  @override
  $E operator [](int index) {
    RangeError.checkValidIndex(index, this);
    return E.fromRef(Jni.accessors.callMethodWithArgs(
        reference, _getId, JniCallType.objectType, [JValueInt(index)]).object);
  }

  static final _setId = Jni.accessors.getMethodIDOf(
      _class.reference, r"set", r"(ILjava/lang/Object;)Ljava/lang/Object;");
  @override
  void operator []=(int index, $E value) {
    RangeError.checkValidIndex(index, this);
    E.fromRef(Jni.accessors.callMethodWithArgs(reference, _setId,
        JniCallType.objectType, [JValueInt(index), value.reference]).object);
  }

  static final _addId = Jni.accessors
      .getMethodIDOf(_class.reference, r"add", r"(Ljava/lang/Object;)Z");
  @override
  void add($E element) {
    Jni.accessors.callMethodWithArgs(
        reference, _addId, JniCallType.voidType, [element.reference]).check();
  }

  static final _collectionClass = Jni.findJClass("java/util/Collection");
  static final _addAllId = Jni.accessors
      .getMethodIDOf(_class.reference, r"addAll", r"(Ljava/util/Collection;)Z");
  @override
  void addAll(Iterable<$E> iterable) {
    if (iterable is JObject &&
        Jni.env.IsInstanceOf(
            (iterable as JObject).reference, _collectionClass.reference)) {
      Jni.accessors.callMethodWithArgs(reference, _addAllId,
          JniCallType.booleanType, [(iterable as JObject).reference]).boolean;
      return;
    }
    return super.addAll(iterable);
  }

  static final _clearId =
      Jni.accessors.getMethodIDOf(_class.reference, r"clear", r"()V");
  @override
  void clear() {
    Jni.accessors.callMethodWithArgs(
        reference, _clearId, JniCallType.voidType, []).check();
  }

  static final _containsId = Jni.accessors
      .getMethodIDOf(_class.reference, r"contains", r"(Ljava/lang/Object;)Z");
  @override
  bool contains(Object? element) {
    if (element is! JObject) return false;
    return Jni.accessors.callMethodWithArgs(reference, _containsId,
        JniCallType.booleanType, [element.reference]).boolean;
  }

  static final _getRangeId = Jni.accessors
      .getMethodIDOf(_class.reference, r"subList", r"(II)Ljava/util/List;");
  @override
  JList<$E> getRange(int start, int end) {
    RangeError.checkValidRange(start, end, this.length);
    return JListType(E).fromRef(
      Jni.accessors.callMethodWithArgs(reference, _getRangeId,
          JniCallType.objectType, [JValueInt(start), JValueInt(end)]).object,
    );
  }

  static final _indexOfId = Jni.accessors
      .getMethodIDOf(_class.reference, r"indexOf", r"(Ljava/lang/Object;)I");
  @override
  int indexOf(Object? element, [int start = 0]) {
    if (element is! JObject) return -1;
    if (start < 0) start = 0;
    if (start == 0) {
      return Jni.accessors.callMethodWithArgs(reference, _indexOfId,
          JniCallType.intType, [element.reference]).integer;
    }
    return Jni.accessors.callMethodWithArgs(
      getRange(start, length).reference,
      _indexOfId,
      JniCallType.intType,
      [element.reference],
    ).integer;
  }

  static final _insertId = Jni.accessors
      .getMethodIDOf(_class.reference, r"add", r"(ILjava/lang/Object;)V");
  @override
  void insert(int index, $E element) {
    Jni.accessors.callMethodWithArgs(reference, _insertId, JniCallType.voidType,
        [JValueInt(index), element.reference]).check();
  }

  static final _insertAllId = Jni.accessors.getMethodIDOf(
      _class.reference, r"addAll", r"(ILjava/util/Collection;)Z");
  @override
  void insertAll(int index, Iterable<$E> iterable) {
    if (iterable is JObject &&
        Jni.env.IsInstanceOf(
            (iterable as JObject).reference, _collectionClass.reference)) {
      Jni.accessors.callMethodWithArgs(
          reference,
          _insertAllId,
          JniCallType.booleanType,
          [JValueInt(index), (iterable as JObject).reference]);
      return;
    }
    super.insertAll(index, iterable);
  }

  static final _isEmptyId =
      Jni.accessors.getMethodIDOf(_class.reference, r"isEmpty", r"()Z");
  @override
  bool get isEmpty => Jni.accessors.callMethodWithArgs(
      reference, _isEmptyId, JniCallType.booleanType, []).boolean;

  @override
  bool get isNotEmpty => !isEmpty;

  static final _iteratorId = Jni.accessors
      .getMethodIDOf(_class.reference, r"iterator", r"()Ljava/util/Iterator;");
  @override
  JIterator<$E> get iterator =>
      JIteratorType(E).fromRef(Jni.accessors.callMethodWithArgs(
          reference, _iteratorId, JniCallType.objectType, []).object);

  static final _lastIndexOfId = Jni.accessors.getMethodIDOf(
      _class.reference, r"lastIndexOf", r"(Ljava/lang/Object;)I");
  @override
  int lastIndexOf(Object? element, [int? start]) {
    if (element is! JObject) return -1;
    if (start == null || start >= this.length) start = this.length - 1;
    if (start == this.length - 1) {
      return Jni.accessors.callMethodWithArgs(reference, _lastIndexOfId,
          JniCallType.intType, [element.reference]).integer;
    }
    final range = getRange(start, length);
    final res = Jni.accessors.callMethodWithArgs(
      range.reference,
      _lastIndexOfId,
      JniCallType.intType,
      [element.reference],
    ).integer;
    range.delete();
    return res;
  }

  static final _removeId = Jni.accessors
      .getMethodIDOf(_class.reference, r"remove", r"(Ljava/lang/Object;)Z");
  @override
  bool remove(Object? element) {
    if (element is! JObject) return false;
    return Jni.accessors.callMethodWithArgs(reference, _removeId,
        JniCallType.booleanType, [element.reference]).boolean;
  }

  static final _removeAtId = Jni.accessors
      .getMethodIDOf(_class.reference, r"remove", r"(I)Ljava/lang/Object;");
  @override
  $E removeAt(int index) {
    return E.fromRef(Jni.accessors.callMethodWithArgs(reference, _removeAtId,
        JniCallType.objectType, [JValueInt(index)]).object);
  }

  @override
  void removeRange(int start, int end) {
    final range = getRange(start, end);
    range.clear();
    range.delete();
  }

  @override
  JSet<$E> toSet() {
    return toJSet(E);
  }

  static final _hashCodeId =
      Jni.accessors.getMethodIDOf(_class.reference, r"hashCode", r"()I");
  @override
  int get hashCode => Jni.accessors.callMethodWithArgs(
      reference, _hashCodeId, JniCallType.intType, []).integer;

  static final _equalsId = Jni.accessors
      .getMethodIDOf(_class.reference, r"equals", r"(Ljava/lang/Object;)Z");
  @override
  bool operator ==(Object other) {
    if (other is! JObject) return false;
    return Jni.accessors.callMethodWithArgs(reference, _equalsId,
        JniCallType.booleanType, [other.reference]).boolean;
  }
}

extension ToJavaList<E extends JObject> on Iterable<E> {
  JList<E> toJList(JObjType<E> type) {
    final list = JList.array(type);
    list.addAll(this);
    return list;
  }
}
