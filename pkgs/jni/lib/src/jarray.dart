// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: unnecessary_cast, overridden_fields

import 'dart:ffi';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:ffi/ffi.dart';
import 'package:jni/internal_helpers_for_jnigen.dart';
import 'package:jni/src/third_party/generated_bindings.dart';

import 'jni.dart';
import 'jobject.dart';
import 'types.dart';

final class JArrayType<E> extends JObjType<JArray<E>> {
  final JType<E> elementType;

  const JArrayType(this.elementType);

  @override
  String get signature => '[${elementType.signature}';

  @override
  JArray<E> fromReference(JReference reference) =>
      JArray.fromReference(elementType, reference);

  @override
  JObjType get superType => const JObjectType();

  @override
  final int superCount = 1;

  @override
  int get hashCode => Object.hash(JArrayType, elementType);

  @override
  bool operator ==(Object other) {
    return other.runtimeType == (JArrayType<E>) &&
        other is JArrayType<E> &&
        elementType == other.elementType;
  }
}

class JArray<E> extends JObject {
  final JType<E> elementType;

  @override
  late final JArrayType<E> $type = type(elementType) as JArrayType<E>;

  /// The type which includes information such as the signature of this class.
  static JObjType<JArray<T>> type<T>(JType<T> innerType) =>
      JArrayType(innerType);

  /// Construct a new [JArray] with [reference] as its underlying reference.
  JArray.fromReference(this.elementType, JReference reference)
      : super.fromReference(reference);

  /// Creates a [JArray] of the given length from the given [elementType].
  ///
  /// The [length] must be a non-negative integer.
  factory JArray(JType<E> elementType, int length) {
    const primitiveCallTypes = {
      'B': JniCallType.byteType,
      'Z': JniCallType.booleanType,
      'C': JniCallType.charType,
      'S': JniCallType.shortType,
      'I': JniCallType.intType,
      'J': JniCallType.longType,
      'F': JniCallType.floatType,
      'D': JniCallType.doubleType,
    };
    if (!primitiveCallTypes.containsKey(elementType.signature) &&
        elementType is JObjType) {
      final clazz = (elementType as JObjType).jClass;
      final array = JArray<E>.fromReference(
        elementType,
        JGlobalReference(
          Jni.accessors
              .newObjectArray(length, clazz.reference.pointer, nullptr)
              .objectPointer,
        ),
      );
      clazz.release();
      return array;
    }
    return JArray.fromReference(
      elementType,
      JGlobalReference(
        Jni.accessors
            .newPrimitiveArray(
                length, primitiveCallTypes[elementType.signature]!)
            .objectPointer,
      ),
    );
  }

  /// Creates a [JArray] of the given length with [fill] at each position.
  ///
  /// The [length] must be a non-negative integer.
  static JArray<$E> filled<$E extends JObject>(int length, $E fill,
      {JObjType<$E>? E}) {
    RangeError.checkNotNegative(length);
    E ??= fill.$type as JObjType<$E>;
    final clazz = E.jClass;
    final array = JArray<$E>.fromReference(
      E,
      JGlobalReference(Jni.accessors
          .newObjectArray(
              length, clazz.reference.pointer, fill.reference.pointer)
          .objectPointer),
    );
    clazz.release();
    return array;
  }

  int? _length;

  JniResult _elementAt(int index, int type) {
    RangeError.checkValidIndex(index, this);
    return Jni.accessors.getArrayElement(reference.pointer, index, type);
  }

  /// The number of elements in this array.
  int get length {
    return _length ??= Jni.env.GetArrayLength(reference.pointer);
  }
}

extension NativeArray<E extends JPrimitive> on JArray<E> {
  void _allocate<T extends NativeType>(
    int byteCount,
    void Function(Pointer<T> ptr) use,
  ) {
    using((arena) {
      final ptr = arena.allocate<T>(byteCount);
      use(ptr);
    }, malloc);
  }
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

extension BoolArray on JArray<jboolean> {
  bool operator [](int index) {
    return _elementAt(index, JniCallType.booleanType).boolean;
  }

  void operator []=(int index, bool value) {
    RangeError.checkValidIndex(index, this);
    Jni.accessors
        .setBooleanArrayElement(reference.pointer, index, value ? 1 : 0);
  }

  Uint8List getRange(int start, int end, {Allocator allocator = malloc}) {
    RangeError.checkValidRange(start, end, length);
    final rangeLength = end - start;
    final buffer = allocator<JBooleanMarker>(rangeLength);
    Jni.env
        .GetBooleanArrayRegion(reference.pointer, start, rangeLength, buffer);
    return buffer.asTypedList(rangeLength, finalizer: allocator._nativeFree);
  }

  void setRange(int start, int end, Iterable<bool> iterable,
      [int skipCount = 0]) {
    RangeError.checkValidRange(start, end, length);
    final rangeLength = end - start;
    _allocate<JBooleanMarker>(sizeOf<JBooleanMarker>() * rangeLength, (ptr) {
      ptr
          .asTypedList(rangeLength)
          .setRange(0, rangeLength, iterable.map((e) => e ? 1 : 0), skipCount);
      Jni.env.SetBooleanArrayRegion(reference.pointer, start, rangeLength, ptr);
    });
  }
}

extension ByteArray on JArray<jbyte> {
  int operator [](int index) {
    return _elementAt(index, JniCallType.byteType).byte;
  }

  void operator []=(int index, int value) {
    RangeError.checkValidIndex(index, this);
    Jni.accessors.setByteArrayElement(reference.pointer, index, value).check();
  }

  Int8List getRange(int start, int end, {Allocator allocator = malloc}) {
    RangeError.checkValidRange(start, end, length);
    final rangeLength = end - start;
    final buffer = allocator<JByteMarker>(rangeLength);
    Jni.env.GetByteArrayRegion(reference.pointer, start, rangeLength, buffer);
    return buffer.asTypedList(rangeLength, finalizer: allocator._nativeFree);
  }

  void setRange(int start, int end, Iterable<int> iterable,
      [int skipCount = 0]) {
    RangeError.checkValidRange(start, end, length);
    final rangeLength = end - start;
    _allocate<JByteMarker>(sizeOf<JByteMarker>() * rangeLength, (ptr) {
      ptr
          .asTypedList(rangeLength)
          .setRange(0, rangeLength, iterable, skipCount);
      Jni.env.SetByteArrayRegion(reference.pointer, start, rangeLength, ptr);
    });
  }
}

/// `JArray<jchar>` is a 16-bit integer array.
///
/// Due to variable length encoding, the  number of code units is not equal to
/// the number of characters.
extension CharArray on JArray<jchar> {
  int operator [](int index) {
    return _elementAt(index, JniCallType.charType).char;
  }

  void operator []=(int index, int value) {
    RangeError.checkValidIndex(index, this);
    Jni.accessors.setCharArrayElement(reference.pointer, index, value).check();
  }

  Uint16List getRange(int start, int end, {Allocator allocator = malloc}) {
    RangeError.checkValidRange(start, end, length);
    final rangeLength = end - start;
    final buffer = allocator<JCharMarker>(rangeLength);
    Jni.env.GetCharArrayRegion(reference.pointer, start, rangeLength, buffer);
    return buffer.asTypedList(rangeLength, finalizer: allocator._nativeFree);
  }

  void setRange(int start, int end, Iterable<int> iterable,
      [int skipCount = 0]) {
    RangeError.checkValidRange(start, end, length);
    final rangeLength = end - start;
    _allocate<JCharMarker>(sizeOf<JCharMarker>() * rangeLength, (ptr) {
      ptr
          .asTypedList(rangeLength)
          .setRange(0, rangeLength, iterable, skipCount);
      Jni.env.SetCharArrayRegion(reference.pointer, start, rangeLength, ptr);
    });
  }
}

extension ShortArray on JArray<jshort> {
  int operator [](int index) {
    return _elementAt(index, JniCallType.shortType).short;
  }

  void operator []=(int index, int value) {
    RangeError.checkValidIndex(index, this);
    Jni.accessors.setShortArrayElement(reference.pointer, index, value).check();
  }

  Int16List getRange(int start, int end, {Allocator allocator = malloc}) {
    RangeError.checkValidRange(start, end, length);
    final rangeLength = end - start;
    final buffer = allocator<JShortMarker>(rangeLength);
    Jni.env.GetShortArrayRegion(reference.pointer, start, rangeLength, buffer);
    return buffer.asTypedList(rangeLength, finalizer: allocator._nativeFree);
  }

  void setRange(int start, int end, Iterable<int> iterable,
      [int skipCount = 0]) {
    RangeError.checkValidRange(start, end, length);
    final rangeLength = end - start;
    _allocate<JShortMarker>(sizeOf<JShortMarker>() * rangeLength, (ptr) {
      ptr
          .asTypedList(rangeLength)
          .setRange(0, rangeLength, iterable, skipCount);
      Jni.env.SetShortArrayRegion(reference.pointer, start, rangeLength, ptr);
    });
  }
}

extension IntArray on JArray<jint> {
  int operator [](int index) {
    return _elementAt(index, JniCallType.intType).integer;
  }

  void operator []=(int index, int value) {
    RangeError.checkValidIndex(index, this);
    Jni.accessors.setIntArrayElement(reference.pointer, index, value).check();
  }

  Int32List getRange(int start, int end, {Allocator allocator = malloc}) {
    RangeError.checkValidRange(start, end, length);
    final rangeLength = end - start;
    final buffer = allocator<JIntMarker>(rangeLength);
    Jni.env.GetIntArrayRegion(reference.pointer, start, rangeLength, buffer);
    return buffer.asTypedList(rangeLength, finalizer: allocator._nativeFree);
  }

  void setRange(int start, int end, Iterable<int> iterable,
      [int skipCount = 0]) {
    RangeError.checkValidRange(start, end, length);
    final rangeLength = end - start;
    _allocate<JIntMarker>(sizeOf<JIntMarker>() * rangeLength, (ptr) {
      ptr
          .asTypedList(rangeLength)
          .setRange(0, rangeLength, iterable, skipCount);
      Jni.env.SetIntArrayRegion(reference.pointer, start, rangeLength, ptr);
    });
  }
}

extension LongArray on JArray<jlong> {
  int operator [](int index) {
    return _elementAt(index, JniCallType.longType).long;
  }

  void operator []=(int index, int value) {
    RangeError.checkValidIndex(index, this);
    Jni.accessors.setLongArrayElement(reference.pointer, index, value).check();
  }

  Int64List getRange(int start, int end, {Allocator allocator = malloc}) {
    RangeError.checkValidRange(start, end, length);
    final rangeLength = end - start;
    final buffer = allocator<JLongMarker>(rangeLength);
    Jni.env.GetLongArrayRegion(reference.pointer, start, rangeLength, buffer);
    return buffer.asTypedList(rangeLength, finalizer: allocator._nativeFree);
  }

  void setRange(int start, int end, Iterable<int> iterable,
      [int skipCount = 0]) {
    RangeError.checkValidRange(start, end, length);
    final rangeLength = end - start;
    _allocate<JLongMarker>(sizeOf<JLongMarker>() * rangeLength, (ptr) {
      ptr
          .asTypedList(rangeLength)
          .setRange(0, rangeLength, iterable, skipCount);
      Jni.env.SetLongArrayRegion(reference.pointer, start, rangeLength, ptr);
    });
  }
}

extension FloatArray on JArray<jfloat> {
  double operator [](int index) {
    return _elementAt(index, JniCallType.floatType).float;
  }

  void operator []=(int index, double value) {
    RangeError.checkValidIndex(index, this);
    Jni.accessors.setFloatArrayElement(reference.pointer, index, value).check();
  }

  Float32List getRange(int start, int end, {Allocator allocator = malloc}) {
    RangeError.checkValidRange(start, end, length);
    final rangeLength = end - start;
    final buffer = allocator<JFloatMarker>(rangeLength);
    Jni.env.GetFloatArrayRegion(reference.pointer, start, rangeLength, buffer);
    return buffer.asTypedList(rangeLength, finalizer: allocator._nativeFree);
  }

  void setRange(int start, int end, Iterable<double> iterable,
      [int skipCount = 0]) {
    RangeError.checkValidRange(start, end, length);
    final rangeLength = end - start;
    _allocate<JFloatMarker>(sizeOf<JFloatMarker>() * rangeLength, (ptr) {
      ptr
          .asTypedList(rangeLength)
          .setRange(0, rangeLength, iterable, skipCount);
      Jni.env.SetFloatArrayRegion(reference.pointer, start, rangeLength, ptr);
    });
  }
}

extension DoubleArray on JArray<jdouble> {
  double operator [](int index) {
    return _elementAt(index, JniCallType.doubleType).doubleFloat;
  }

  void operator []=(int index, double value) {
    RangeError.checkValidIndex(index, this);
    Jni.accessors
        .setDoubleArrayElement(reference.pointer, index, value)
        .check();
  }

  Float64List getRange(int start, int end, {Allocator allocator = malloc}) {
    RangeError.checkValidRange(start, end, length);
    final rangeLength = end - start;
    final buffer = allocator<JDoubleMarker>(rangeLength);
    Jni.env.GetDoubleArrayRegion(reference.pointer, start, rangeLength, buffer);
    return buffer.asTypedList(rangeLength, finalizer: allocator._nativeFree);
  }

  void setRange(int start, int end, Iterable<double> iterable,
      [int skipCount = 0]) {
    RangeError.checkValidRange(start, end, length);
    final rangeLength = end - start;
    _allocate<JDoubleMarker>(sizeOf<JDoubleMarker>() * rangeLength, (ptr) {
      ptr
          .asTypedList(rangeLength)
          .setRange(0, rangeLength, iterable, skipCount);
      Jni.env.SetDoubleArrayRegion(reference.pointer, start, rangeLength, ptr);
    });
  }
}

extension ObjectArray<T extends JObject> on JArray<T> {
  T operator [](int index) {
    return (elementType as JObjType<T>).fromReference(JGlobalReference(
        _elementAt(index, JniCallType.objectType).objectPointer));
  }

  void operator []=(int index, T value) {
    RangeError.checkValidIndex(index, this);
    Jni.env.SetObjectArrayElement(
        reference.pointer, index, value.reference.pointer);
  }

  void setRange(int start, int end, Iterable<T> iterable, [int skipCount = 0]) {
    RangeError.checkValidRange(start, end, length);
    final rangeLength = end - start;
    final it = iterable.skip(skipCount).take(rangeLength);
    it.forEachIndexed((index, element) {
      this[index] = element;
    });
  }
}
