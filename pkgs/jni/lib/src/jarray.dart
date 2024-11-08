// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: unnecessary_cast, overridden_fields

part of 'types.dart';

final class JArrayNullableType<E> extends JObjType<JArray<E>?> {
  @internal
  final JArrayElementType<E> elementType;

  @internal
  const JArrayNullableType(this.elementType);

  @internal
  @override
  String get signature => '[${elementType.signature}';

  @internal
  @override
  JArray<E>? fromReference(JReference reference) =>
      reference.isNull ? null : JArray.fromReference(elementType, reference);

  @internal
  @override
  JObjType get superType => const JObjectNullableType();

  @internal
  @override
  JObjType<JArray<E>?> get nullableType => this;

  @internal
  @override
  final int superCount = 1;

  @override
  int get hashCode => Object.hash(JArrayNullableType, elementType);

  @override
  bool operator ==(Object other) {
    return other.runtimeType == (JArrayNullableType<E>) &&
        other is JArrayNullableType<E> &&
        elementType == other.elementType;
  }
}

final class JArrayType<E> extends JObjType<JArray<E>> {
  @internal
  final JArrayElementType<E> elementType;

  @internal
  const JArrayType(this.elementType);

  @internal
  @override
  String get signature => '[${elementType.signature}';

  @internal
  @override
  JArray<E> fromReference(JReference reference) =>
      JArray.fromReference(elementType, reference);

  @internal
  @override
  JObjType get superType => const JObjectType();

  @internal
  @override
  JObjType<JArray<E>?> get nullableType => JArrayNullableType<E>(elementType);

  @internal
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
  @internal
  final JArrayElementType<E> elementType;

  @internal
  @override
  final JArrayType<E> $type;

  /// The type which includes information such as the signature of this class.
  static JArrayType<E> type<E>(JArrayElementType<E> innerType) =>
      JArrayType(innerType);

  /// Construct a new [JArray] with [reference] as its underlying reference.
  JArray.fromReference(this.elementType, JReference reference)
      : $type = type(elementType),
        super.fromReference(reference);

  /// Creates a [JArray] of the given length from the given [elementType].
  ///
  /// The [length] must be a non-negative integer.
  factory JArray(JArrayElementType<E> elementType, int length) {
    return elementType._newArray(length);
  }

  /// Creates a [JArray] of the given length with [fill] at each position.
  ///
  /// The [length] must be a non-negative integer.
  static JArray<$E> filled<$E extends JObject>(int length, $E fill,
      {JObjType<$E>? E}) {
    RangeError.checkNotNegative(length);
    E ??= fill.$type as JObjType<$E>;
    return E._newArray(length, fill);
  }

  int? _length;

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
    RangeError.checkValidIndex(index, this);
    return Jni.env.GetBooleanArrayElement(reference.pointer, index);
  }

  void operator []=(int index, bool value) {
    RangeError.checkValidIndex(index, this);
    Jni.env.SetBooleanArrayElement(reference.pointer, index, value);
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
    RangeError.checkValidIndex(index, this);
    return Jni.env.GetByteArrayElement(reference.pointer, index);
  }

  void operator []=(int index, int value) {
    RangeError.checkValidIndex(index, this);
    Jni.env.SetByteArrayElement(reference.pointer, index, value);
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
    RangeError.checkValidIndex(index, this);
    return Jni.env.GetCharArrayElement(reference.pointer, index);
  }

  void operator []=(int index, int value) {
    RangeError.checkValidIndex(index, this);
    Jni.env.SetCharArrayElement(reference.pointer, index, value);
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
    RangeError.checkValidIndex(index, this);
    return Jni.env.GetShortArrayElement(reference.pointer, index);
  }

  void operator []=(int index, int value) {
    RangeError.checkValidIndex(index, this);
    Jni.env.SetShortArrayElement(reference.pointer, index, value);
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
    RangeError.checkValidIndex(index, this);
    return Jni.env.GetIntArrayElement(reference.pointer, index);
  }

  void operator []=(int index, int value) {
    RangeError.checkValidIndex(index, this);
    Jni.env.SetIntArrayElement(reference.pointer, index, value);
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
    RangeError.checkValidIndex(index, this);
    return Jni.env.GetLongArrayElement(reference.pointer, index);
  }

  void operator []=(int index, int value) {
    RangeError.checkValidIndex(index, this);
    Jni.env.SetLongArrayElement(reference.pointer, index, value);
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
    RangeError.checkValidIndex(index, this);
    return Jni.env.GetFloatArrayElement(reference.pointer, index);
  }

  void operator []=(int index, double value) {
    RangeError.checkValidIndex(index, this);
    Jni.env.SetFloatArrayElement(reference.pointer, index, value);
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
    RangeError.checkValidIndex(index, this);
    return Jni.env.GetDoubleArrayElement(reference.pointer, index);
  }

  void operator []=(int index, double value) {
    RangeError.checkValidIndex(index, this);
    Jni.env.SetDoubleArrayElement(reference.pointer, index, value);
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

extension ObjectArray<T extends JObject?> on JArray<T> {
  T operator [](int index) {
    RangeError.checkValidIndex(index, this);
    return (elementType as JObjType<T>).fromReference(JGlobalReference(
        Jni.env.GetObjectArrayElement(reference.pointer, index)));
  }

  void operator []=(int index, T value) {
    RangeError.checkValidIndex(index, this);
    final valueRef = value?.reference ?? jNullReference;
    Jni.env.SetObjectArrayElement(reference.pointer, index, valueRef.pointer);
  }

  void setRange(int start, int end, Iterable<T> iterable, [int skipCount = 0]) {
    RangeError.checkValidRange(start, end, length);
    final rangeLength = end - start;
    final it = iterable.skip(skipCount).take(rangeLength);
    for (final (index, element) in it.indexed) {
      this[index] = element;
    }
  }
}
