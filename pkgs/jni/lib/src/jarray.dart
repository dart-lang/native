// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: unnecessary_cast, overridden_fields

import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:meta/meta.dart';

import 'jni.dart';
import 'jobject.dart';
import 'jreference.dart';
import 'third_party/generated_bindings.dart';
import 'types.dart';

final class JArrayNullableType<E extends JObject?>
    extends JObjType<JArray<E>?> {
  @internal
  final JObjType<E> elementType;

  @internal
  const JArrayNullableType(this.elementType);

  @internal
  @override
  String get signature => '[${elementType.signature}';

  @internal
  @override
  JArray<E>? fromReference(JReference reference) =>
      reference.isNull ? null : JArray<E>.fromReference(elementType, reference);

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

final class JArrayType<E extends JObject?> extends JObjType<JArray<E>> {
  @internal
  final JObjType<E> elementType;

  @internal
  const JArrayType(this.elementType);

  @internal
  @override
  String get signature => '[${elementType.signature}';

  @internal
  @override
  JArray<E> fromReference(JReference reference) =>
      JArray<E>.fromReference(elementType, reference);

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

class JArray<E extends JObject?> extends JObject with Iterable<E> {
  @internal
  final JObjType<E> elementType;

  @internal
  @override
  final JArrayType<E> $type;

  /// The type which includes information such as the signature of this class.
  static JArrayType<E> type<E extends JObject?>(JObjType<E> innerType) =>
      JArrayType<E>(innerType);

  /// The type which includes information such as the signature of this class.
  static JArrayNullableType<E> nullableType<E extends JObject?>(
          JObjType<E> innerType) =>
      JArrayNullableType<E>(innerType);

  /// Construct a new [JArray] with [reference] as its underlying reference.
  JArray.fromReference(this.elementType, JReference reference)
      : $type = type<E>(elementType),
        super.fromReference(reference);

  /// Creates a [JArray] of the given length from the given [elementType].
  ///
  /// The [length] must be a non-negative integer.
  /// For objects, [elementType] must be a nullable type as this constructor
  /// initializes all elements with `null`.
  factory JArray(JObjType<E> elementType, int length) {
    RangeError.checkNotNegative(length);
    if (!elementType.isNullable) {
      throw ArgumentError.value(
          elementType,
          'elementType',
          'Element type of JArray must be nullable when constructed with a '
              'length (because the elements will be initialized to null).\n\n'
              'Try using .nullableType instead');
    }
    return _newArray<E>(elementType, length);
  }

  static JArray<$E> _newArray<$E extends JObject?>(
      JObjType<$E> elementType, int length,
      [$E? fill]) {
    final classRef = elementType.jClass.reference;
    final fillRef = fill?.reference ?? jNullReference;
    final array = JArray<$E>.fromReference(
      elementType,
      JGlobalReference(Jni.env.NewObjectArray(
        length,
        classRef.pointer,
        fillRef.pointer,
      )),
    );
    classRef.release();
    return array;
  }

  /// Creates a [JArray] of the given length with [fill] at each position.
  ///
  /// The [length] must be a non-negative integer.
  static JArray<$E> filled<$E extends JObject>(int length, $E fill,
      {JObjType<$E>? E}) {
    RangeError.checkNotNegative(length);
    E ??= fill.$type as JObjType<$E>;
    return _newArray<$E>(E, length, fill);
  }

  /// Creates a [JArray] from `elements`.
  static JArray<$E> of<$E extends JObject?>(
      JObjType<$E> elementType, Iterable<$E> elements) {
    return _newArray<$E>(elementType, elements.length)
      ..setRange(0, elements.length, elements);
  }

  /// The number of elements in this array.
  @override
  late final length = Jni.env.GetArrayLength(reference.pointer);

  @override
  E elementAt(int index) {
    RangeError.checkValidIndex(index, this);
    final pointer = Jni.env.GetObjectArrayElement(reference.pointer, index);
    if (pointer == nullptr) {
      return null as E;
    }
    return (elementType as JObjType<E>)
        .fromReference(JGlobalReference(pointer));
  }

  E operator [](int index) {
    return elementAt(index);
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

  @override
  Iterator<E> get iterator => _JArrayIterator(this);
}

class _JArrayIterator<E> implements Iterator<E> {
  final Iterable<E> _iterable;
  final int _length;
  int _index;
  E? _current;

  _JArrayIterator(Iterable<E> iterable)
      : _iterable = iterable,
        _length = iterable.length,
        _index = 0;

  @override
  E get current => _current as E;

  @override
  @pragma('vm:prefer-inline')
  bool moveNext() {
    final length = _iterable.length;
    if (_length != length) {
      throw ConcurrentModificationError(_iterable);
    }
    if (_index >= length) {
      _current = null;
      return false;
    }
    _current = _iterable.elementAt(_index);
    _index++;
    return true;
  }
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

final class JBooleanArrayNullableType extends JObjType<JBooleanArray?> {
  @internal
  const JBooleanArrayNullableType();

  @internal
  @override
  String get signature => '[Z';

  @internal
  @override
  JBooleanArray? fromReference(JReference reference) =>
      reference.isNull ? null : JBooleanArray.fromReference(reference);

  @internal
  @override
  JObjType get superType => const JObjectNullableType();

  @internal
  @override
  JObjType<JBooleanArray?> get nullableType => this;

  @internal
  @override
  final int superCount = 1;

  @override
  int get hashCode => (JBooleanArrayNullableType).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == JBooleanArrayNullableType &&
        other is JBooleanArrayNullableType;
  }
}

final class JBooleanArrayType extends JObjType<JBooleanArray> {
  @internal
  const JBooleanArrayType();

  @internal
  @override
  String get signature => '[Z';

  @internal
  @override
  JBooleanArray fromReference(JReference reference) =>
      JBooleanArray.fromReference(reference);

  @internal
  @override
  JObjType get superType => const JObjectType();

  @internal
  @override
  JObjType<JBooleanArray?> get nullableType =>
      const JBooleanArrayNullableType();

  @internal
  @override
  final int superCount = 1;

  @override
  int get hashCode => (JBooleanArrayType).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == JBooleanArrayType && other is JBooleanArrayType;
  }
}

class JBooleanArray extends JObject with Iterable<bool> {
  @internal
  @override
  final JBooleanArrayType $type;

  /// The type which includes information such as the signature of this class.
  static const type = JBooleanArrayType();

  /// The type which includes information such as the signature of this class.
  static const nullableType = JBooleanArrayNullableType();

  /// Construct a new [JBooleanArray] with [reference] as its underlying
  /// reference.
  JBooleanArray.fromReference(super.reference)
      : $type = type,
        super.fromReference();

  /// Creates a [JBooleanArray] of the given [length].
  ///
  /// The [length] must be a non-negative integer.
  factory JBooleanArray(int length) {
    RangeError.checkNotNegative(length);
    return JBooleanArray.fromReference(
      JGlobalReference(Jni.env.NewBooleanArray(length)),
    );
  }

  /// The number of elements in this array.
  @override
  late final length = Jni.env.GetArrayLength(reference.pointer);

  @override
  bool elementAt(int index) {
    RangeError.checkValidIndex(index, this);
    return Jni.env.GetBooleanArrayElement(reference.pointer, index);
  }

  bool operator [](int index) {
    return elementAt(index);
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

  @override
  Iterator<bool> get iterator => _JArrayIterator(this);
}

final class JByteArrayNullableType extends JObjType<JByteArray?> {
  @internal
  const JByteArrayNullableType();

  @internal
  @override
  String get signature => '[B';

  @internal
  @override
  JByteArray? fromReference(JReference reference) =>
      reference.isNull ? null : JByteArray.fromReference(reference);

  @internal
  @override
  JObjType get superType => const JObjectNullableType();

  @internal
  @override
  JObjType<JByteArray?> get nullableType => this;

  @internal
  @override
  final int superCount = 1;

  @override
  int get hashCode => (JByteArrayNullableType).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == JByteArrayNullableType &&
        other is JByteArrayNullableType;
  }
}

final class JByteArrayType extends JObjType<JByteArray> {
  @internal
  const JByteArrayType();

  @internal
  @override
  String get signature => '[B';

  @internal
  @override
  JByteArray fromReference(JReference reference) =>
      JByteArray.fromReference(reference);

  @internal
  @override
  JObjType get superType => const JObjectType();

  @internal
  @override
  JObjType<JByteArray?> get nullableType => const JByteArrayNullableType();

  @internal
  @override
  final int superCount = 1;

  @override
  int get hashCode => (JByteArrayType).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == JByteArrayType && other is JByteArrayType;
  }
}

/// A fixed-length array of Java [`Byte`](https://docs.oracle.com/en/java/javase/17/docs/api/java.base/java/lang/Byte.html).
///
/// Integers stored in the list are truncated to their low eight bits,
/// interpreted as a signed 8-bit two's complement integer with values in the
/// range -128 to +127.
///
/// Java equivalent of [Int8List].
class JByteArray extends JObject with Iterable<int> {
  @internal
  @override
  final JByteArrayType $type;

  /// The type which includes information such as the signature of this class.
  static const type = JByteArrayType();

  /// The type which includes information such as the signature of this class.
  static const nullableType = JByteArrayNullableType();

  /// Construct a new [JByteArray] with [reference] as its underlying
  /// reference.
  JByteArray.fromReference(super.reference)
      : $type = type,
        super.fromReference();

  /// Creates a [JByteArray] containing all `elements`.
  ///
  /// The [Iterator] of elements provides the order of the elements.
  ///
  /// Elements outside of the range -128 to +127 are truncated to their low
  /// eight bits and interpreted as signed 8-bit two's complement integers.
  factory JByteArray.from(Iterable<int> elements) {
    return JByteArray(elements.length)..setRange(0, elements.length, elements);
  }

  /// Creates a [JByteArray] of the given [length].
  ///
  /// The [length] must be a non-negative integer.
  factory JByteArray(int length) {
    RangeError.checkNotNegative(length);
    return JByteArray.fromReference(
        JGlobalReference(Jni.env.NewByteArray(length)));
  }

  /// The number of elements in this array.
  @override
  late final length = Jni.env.GetArrayLength(reference.pointer);

  @override
  int elementAt(int index) {
    RangeError.checkValidIndex(index, this);
    return Jni.env.GetByteArrayElement(reference.pointer, index);
  }

  int operator [](int index) {
    return elementAt(index);
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

  @override
  Iterator<int> get iterator => _JArrayIterator(this);
}

final class JCharArrayNullableType extends JObjType<JCharArray?> {
  @internal
  const JCharArrayNullableType();

  @internal
  @override
  String get signature => '[C';

  @internal
  @override
  JCharArray? fromReference(JReference reference) =>
      reference.isNull ? null : JCharArray.fromReference(reference);

  @internal
  @override
  JObjType get superType => const JObjectNullableType();

  @internal
  @override
  JObjType<JCharArray?> get nullableType => this;

  @internal
  @override
  final int superCount = 1;

  @override
  int get hashCode => (JCharArrayNullableType).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == JCharArrayNullableType &&
        other is JCharArrayNullableType;
  }
}

final class JCharArrayType extends JObjType<JCharArray> {
  @internal
  const JCharArrayType();

  @internal
  @override
  String get signature => '[C';

  @internal
  @override
  JCharArray fromReference(JReference reference) =>
      JCharArray.fromReference(reference);

  @internal
  @override
  JObjType get superType => const JObjectType();

  @internal
  @override
  JObjType<JCharArray?> get nullableType => const JCharArrayNullableType();

  @internal
  @override
  final int superCount = 1;

  @override
  int get hashCode => (JCharArrayType).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == JCharArrayType && other is JCharArrayType;
  }
}

/// `JCharArray` is a 16-bit integer array.
///
/// Due to variable length encoding, the  number of code units is not equal to
/// the number of characters.
class JCharArray extends JObject with Iterable<int> {
  @internal
  @override
  final JCharArrayType $type;

  /// The type which includes information such as the signature of this class.
  static const type = JCharArrayType();

  /// The type which includes information such as the signature of this class.
  static const nullableType = JCharArrayNullableType();

  /// Construct a new [JCharArray] with [reference] as its underlying
  /// reference.
  JCharArray.fromReference(super.reference)
      : $type = type,
        super.fromReference();

  /// Creates a [JCharArray] of the given [length].
  ///
  /// The [length] must be a non-negative integer.
  factory JCharArray(int length) {
    RangeError.checkNotNegative(length);
    return JCharArray.fromReference(
        JGlobalReference(Jni.env.NewCharArray(length)));
  }

  /// The number of elements in this array.
  @override
  late final length = Jni.env.GetArrayLength(reference.pointer);

  @override
  int elementAt(int index) {
    RangeError.checkValidIndex(index, this);
    return Jni.env.GetCharArrayElement(reference.pointer, index);
  }

  int operator [](int index) {
    return elementAt(index);
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

  @override
  Iterator<int> get iterator => _JArrayIterator(this);
}

final class JShortArrayNullableType extends JObjType<JShortArray?> {
  @internal
  const JShortArrayNullableType();

  @internal
  @override
  String get signature => '[S';

  @internal
  @override
  JShortArray? fromReference(JReference reference) =>
      reference.isNull ? null : JShortArray.fromReference(reference);

  @internal
  @override
  JObjType get superType => const JObjectNullableType();

  @internal
  @override
  JObjType<JShortArray?> get nullableType => this;

  @internal
  @override
  final int superCount = 1;

  @override
  int get hashCode => (JShortArrayNullableType).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == JShortArrayNullableType &&
        other is JShortArrayNullableType;
  }
}

final class JShortArrayType extends JObjType<JShortArray> {
  @internal
  const JShortArrayType();

  @internal
  @override
  String get signature => '[S';

  @internal
  @override
  JShortArray fromReference(JReference reference) =>
      JShortArray.fromReference(reference);

  @internal
  @override
  JObjType get superType => const JObjectType();

  @internal
  @override
  JObjType<JShortArray?> get nullableType => const JShortArrayNullableType();

  @internal
  @override
  final int superCount = 1;

  @override
  int get hashCode => (JShortArrayType).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == JShortArrayType && other is JShortArrayType;
  }
}

class JShortArray extends JObject with Iterable<int> {
  @internal
  @override
  final JShortArrayType $type;

  /// The type which includes information such as the signature of this class.
  static const type = JShortArrayType();

  /// The type which includes information such as the signature of this class.
  static const nullableType = JShortArrayNullableType();

  /// Construct a new [JShortArray] with [reference] as its underlying
  /// reference.
  JShortArray.fromReference(super.reference)
      : $type = type,
        super.fromReference();

  /// Creates a [JShortArray] of the given [length].
  ///
  /// The [length] must be a non-negative integer.
  factory JShortArray(int length) {
    RangeError.checkNotNegative(length);
    return JShortArray.fromReference(
        JGlobalReference(Jni.env.NewShortArray(length)));
  }

  /// The number of elements in this array.
  @override
  late final length = Jni.env.GetArrayLength(reference.pointer);

  @override
  int elementAt(int index) {
    RangeError.checkValidIndex(index, this);
    return Jni.env.GetShortArrayElement(reference.pointer, index);
  }

  int operator [](int index) {
    return elementAt(index);
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

  @override
  Iterator<int> get iterator => _JArrayIterator(this);
}

final class JIntArrayNullableType extends JObjType<JIntArray?> {
  @internal
  const JIntArrayNullableType();

  @internal
  @override
  String get signature => '[I';

  @internal
  @override
  JIntArray? fromReference(JReference reference) =>
      reference.isNull ? null : JIntArray.fromReference(reference);

  @internal
  @override
  JObjType get superType => const JObjectNullableType();

  @internal
  @override
  JObjType<JIntArray?> get nullableType => this;

  @internal
  @override
  final int superCount = 1;

  @override
  int get hashCode => (JIntArrayNullableType).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == JIntArrayNullableType &&
        other is JIntArrayNullableType;
  }
}

final class JIntArrayType extends JObjType<JIntArray> {
  @internal
  const JIntArrayType();

  @internal
  @override
  String get signature => '[I';

  @internal
  @override
  JIntArray fromReference(JReference reference) =>
      JIntArray.fromReference(reference);

  @internal
  @override
  JObjType get superType => const JObjectType();

  @internal
  @override
  JObjType<JIntArray?> get nullableType => const JIntArrayNullableType();

  @internal
  @override
  final int superCount = 1;

  @override
  int get hashCode => (JIntArrayType).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == JIntArrayType && other is JIntArrayType;
  }
}

class JIntArray extends JObject with Iterable<int> {
  @internal
  @override
  final JIntArrayType $type;

  /// The type which includes information such as the signature of this class.
  static const type = JIntArrayType();

  /// The type which includes information such as the signature of this class.
  static const nullableType = JIntArrayNullableType();

  /// Construct a new [JIntArray] with [reference] as its underlying
  /// reference.
  JIntArray.fromReference(super.reference)
      : $type = type,
        super.fromReference();

  /// Creates a [JIntArray] of the given [length].
  ///
  /// The [length] must be a non-negative integer.
  factory JIntArray(int length) {
    RangeError.checkNotNegative(length);
    return JIntArray.fromReference(
        JGlobalReference(Jni.env.NewIntArray(length)));
  }

  /// The number of elements in this array.
  @override
  late final length = Jni.env.GetArrayLength(reference.pointer);

  @override
  int elementAt(int index) {
    RangeError.checkValidIndex(index, this);
    return Jni.env.GetIntArrayElement(reference.pointer, index);
  }

  int operator [](int index) {
    return elementAt(index);
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

  @override
  Iterator<int> get iterator => _JArrayIterator(this);
}

final class JLongArrayNullableType extends JObjType<JLongArray?> {
  @internal
  const JLongArrayNullableType();

  @internal
  @override
  String get signature => '[J';

  @internal
  @override
  JLongArray? fromReference(JReference reference) =>
      reference.isNull ? null : JLongArray.fromReference(reference);

  @internal
  @override
  JObjType get superType => const JObjectNullableType();

  @internal
  @override
  JObjType<JLongArray?> get nullableType => this;

  @internal
  @override
  final int superCount = 1;

  @override
  int get hashCode => (JLongArrayNullableType).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == JLongArrayNullableType &&
        other is JLongArrayNullableType;
  }
}

final class JLongArrayType extends JObjType<JLongArray> {
  @internal
  const JLongArrayType();

  @internal
  @override
  String get signature => '[J';

  @internal
  @override
  JLongArray fromReference(JReference reference) =>
      JLongArray.fromReference(reference);

  @internal
  @override
  JObjType get superType => const JObjectType();

  @internal
  @override
  JObjType<JLongArray?> get nullableType => const JLongArrayNullableType();

  @internal
  @override
  final int superCount = 1;

  @override
  int get hashCode => (JLongArrayType).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == JLongArrayType && other is JLongArrayType;
  }
}

class JLongArray extends JObject with Iterable<int> {
  @internal
  @override
  final JLongArrayType $type;

  /// The type which includes information such as the signature of this class.
  static const type = JLongArrayType();

  /// The type which includes information such as the signature of this class.
  static const nullableType = JLongArrayNullableType();

  /// Construct a new [JLongArray] with [reference] as its underlying
  /// reference.
  JLongArray.fromReference(super.reference)
      : $type = type,
        super.fromReference();

  /// Creates a [JLongArray] of the given [length].
  ///
  /// The [length] must be a non-negative integer.
  factory JLongArray(int length) {
    RangeError.checkNotNegative(length);
    return JLongArray.fromReference(
        JGlobalReference(Jni.env.NewLongArray(length)));
  }

  /// The number of elements in this array.
  @override
  late final length = Jni.env.GetArrayLength(reference.pointer);

  @override
  int elementAt(int index) {
    RangeError.checkValidIndex(index, this);
    return Jni.env.GetLongArrayElement(reference.pointer, index);
  }

  int operator [](int index) {
    return elementAt(index);
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

  @override
  Iterator<int> get iterator => _JArrayIterator(this);
}

final class JFloatArrayNullableType extends JObjType<JFloatArray?> {
  @internal
  const JFloatArrayNullableType();

  @internal
  @override
  String get signature => '[F';

  @internal
  @override
  JFloatArray? fromReference(JReference reference) =>
      reference.isNull ? null : JFloatArray.fromReference(reference);

  @internal
  @override
  JObjType get superType => const JObjectNullableType();

  @internal
  @override
  JObjType<JFloatArray?> get nullableType => this;

  @internal
  @override
  final int superCount = 1;

  @override
  int get hashCode => (JFloatArrayNullableType).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == JFloatArrayNullableType &&
        other is JFloatArrayNullableType;
  }
}

final class JFloatArrayType extends JObjType<JFloatArray> {
  @internal
  const JFloatArrayType();

  @internal
  @override
  String get signature => '[F';

  @internal
  @override
  JFloatArray fromReference(JReference reference) =>
      JFloatArray.fromReference(reference);

  @internal
  @override
  JObjType get superType => const JObjectType();

  @internal
  @override
  JObjType<JFloatArray?> get nullableType => const JFloatArrayNullableType();

  @internal
  @override
  final int superCount = 1;

  @override
  int get hashCode => (JFloatArrayType).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == JFloatArrayType && other is JFloatArrayType;
  }
}

class JFloatArray extends JObject with Iterable<double> {
  @internal
  @override
  final JFloatArrayType $type;

  /// The type which includes information such as the signature of this class.
  static const type = JFloatArrayType();

  /// The type which includes information such as the signature of this class.
  static const nullableType = JFloatArrayNullableType();

  /// Construct a new [JFloatArray] with [reference] as its underlying
  /// reference.
  JFloatArray.fromReference(super.reference)
      : $type = type,
        super.fromReference();

  /// Creates a [JFloatArray] of the given [length].
  ///
  /// The [length] must be a non-negative integer.
  factory JFloatArray(int length) {
    RangeError.checkNotNegative(length);
    return JFloatArray.fromReference(
        JGlobalReference(Jni.env.NewFloatArray(length)));
  }

  /// The number of elements in this array.
  @override
  late final length = Jni.env.GetArrayLength(reference.pointer);

  @override
  double elementAt(int index) {
    RangeError.checkValidIndex(index, this);
    return Jni.env.GetFloatArrayElement(reference.pointer, index);
  }

  double operator [](int index) {
    return elementAt(index);
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

  @override
  Iterator<double> get iterator => _JArrayIterator(this);
}

final class JDoubleArrayNullableType extends JObjType<JDoubleArray?> {
  @internal
  const JDoubleArrayNullableType();

  @internal
  @override
  String get signature => '[D';

  @internal
  @override
  JDoubleArray? fromReference(JReference reference) =>
      reference.isNull ? null : JDoubleArray.fromReference(reference);

  @internal
  @override
  JObjType get superType => const JObjectNullableType();

  @internal
  @override
  JObjType<JDoubleArray?> get nullableType => this;

  @internal
  @override
  final int superCount = 1;

  @override
  int get hashCode => (JDoubleArrayNullableType).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == JDoubleArrayNullableType &&
        other is JDoubleArrayNullableType;
  }
}

final class JDoubleArrayType extends JObjType<JDoubleArray> {
  @internal
  const JDoubleArrayType();

  @internal
  @override
  String get signature => '[D';

  @internal
  @override
  JDoubleArray fromReference(JReference reference) =>
      JDoubleArray.fromReference(reference);

  @internal
  @override
  JObjType get superType => const JObjectType();

  @internal
  @override
  JObjType<JDoubleArray?> get nullableType => const JDoubleArrayNullableType();

  @internal
  @override
  final int superCount = 1;

  @override
  int get hashCode => (JDoubleArrayType).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == JDoubleArrayType && other is JDoubleArrayType;
  }
}

class JDoubleArray extends JObject with Iterable<double> {
  @internal
  @override
  final JDoubleArrayType $type;

  /// The type which includes information such as the signature of this class.
  static const type = JDoubleArrayType();

  /// The type which includes information such as the signature of this class.
  static const nullableType = JDoubleArrayNullableType();

  /// Construct a new [JDoubleArray] with [reference] as its underlying
  /// reference.
  JDoubleArray.fromReference(super.reference)
      : $type = type,
        super.fromReference();

  /// Creates a [JDoubleArray] of the given [length].
  ///
  /// The [length] must be a non-negative integer.
  factory JDoubleArray(int length) {
    RangeError.checkNotNegative(length);
    return JDoubleArray.fromReference(
        JGlobalReference(Jni.env.NewDoubleArray(length)));
  }

  /// The number of elements in this array.
  @override
  late final length = Jni.env.GetArrayLength(reference.pointer);

  @override
  double elementAt(int index) {
    RangeError.checkValidIndex(index, this);
    return Jni.env.GetDoubleArrayElement(reference.pointer, index);
  }

  double operator [](int index) {
    return elementAt(index);
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

  @override
  Iterator<double> get iterator => _JArrayIterator(this);
}
