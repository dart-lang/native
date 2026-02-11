// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:ffi/ffi.dart';

import 'jni.dart';
import 'jobject.dart';
import 'jreference.dart';
import 'types.dart';

part 'primitive_jarrays.dart';

final class _$JArray$Type$<E extends JObject?> extends JType<JArray<E>> {
  _$JArray$Type$(JType<E> elementType)
      : signature = '[${elementType.signature}';

  @override
  final String signature;
}

extension type JArray<E extends JObject?>._(JObject _$this) implements JObject {
  /// The type which includes information such as the signature of this class.
  static JType<JArray<E>> type<E extends JObject?>(JType<E> innerType) =>
      _$JArray$Type$<E>(innerType);

  /// Creates a [JArray] of the given length from the given [elementType].
  ///
  /// The [length] must be a non-negative integer.
  static JArray<E?> withLength<E extends JObject?>(
      JType<E> elementType, int length) {
    RangeError.checkNotNegative(length);
    return _newArray<E>(elementType.jClass, length);
  }

  static JArray<$E> _newArray<$E extends JObject?>(JClass jClass, int length,
      [$E? fill]) {
    final classRef = jClass.reference;
    final fillRef = fill?.reference ?? jNullReference;
    final array = JObject.fromReference(
      JGlobalReference(Jni.env.NewObjectArray(
        length,
        classRef.pointer,
        fillRef.pointer,
      )),
    ) as JArray<$E>;
    classRef.release();
    return array;
  }

  /// Creates a [JArray] of the given length with [fill] at each position.
  ///
  /// The [length] must be a non-negative integer.
  static JArray<$E> filled<$E extends JObject>(int length, $E fill,
      {JType<$E>? elementType}) {
    RangeError.checkNotNegative(length);
    final jClass = elementType == null ? fill.jClass : elementType.jClass;
    return _newArray<$E>(jClass, length, fill);
  }

  /// Creates a [JArray] from `elements`.
  static JArray<$E> of<$E extends JObject?>(
      JType<$E> elementType, Iterable<$E> elements) {
    return _newArray<$E>(elementType.jClass, elements.length)
      ..setRange(0, elements.length, elements);
  }

  /// The number of elements in this array.
  int get length => Jni.env.GetArrayLength(reference.pointer);

  E _elementAt(int index) {
    RangeError.checkValidIndex(index, this);
    final pointer = Jni.env.GetObjectArrayElement(reference.pointer, index);
    if (pointer == nullptr) {
      return null as E;
    }
    return JObject.fromReference(JGlobalReference(pointer)) as E;
  }

  E operator [](int index) {
    return _elementAt(index);
  }

  void operator []=(int index, E value) {
    RangeError.checkValidIndex(index, this);
    final valueRef = value?.reference ?? jNullReference;
    Jni.env.SetObjectArrayElement(reference.pointer, index, valueRef.pointer);
  }

  void setRange(int start, int end, Iterable<E> iterable, [int skipCount = 0]) {
    RangeError.checkValidRange(start, end, length);
    final rangeLength = end - start;
    final it = iterable.skip(skipCount).take(rangeLength);
    for (final (index, element) in it.indexed) {
      this[index] = element;
    }
  }
}

final class _JArrayListView<E extends JObject?>
    with ListMixin<E>, NonGrowableListMixin<E> {
  final JArray<E> _jarray;

  _JArrayListView(this._jarray);

  @override
  int get length => _jarray.length;

  @override
  E operator [](int index) {
    return _jarray[index];
  }

  @override
  void operator []=(int index, E value) {
    _jarray[index] = value;
  }
}

extension JArrayToList<E extends JObject?> on JArray<E> {
  /// Returns a [List] view into this array.
  ///
  /// Any changes to this list will reflect in the original array as well.
  List<E> get asDartList => _JArrayListView<E>(this);
}

void _allocate<T extends NativeType>(
  int byteCount,
  void Function(Pointer<T> ptr) use,
) {
  using((arena) {
    final ptr = arena.allocate<T>(byteCount);
    use(ptr);
  }, malloc);
}

extension on Allocator {
  Pointer<NativeFinalizerFunction>? get _nativeFree {
    return switch (this) {
      malloc => malloc.nativeFree,
      calloc => calloc.nativeFree,
      _ => null,
    };
  }
}
