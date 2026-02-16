// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: unnecessary_cast, overridden_fields

import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:meta/meta.dart' show internal;

import 'jni.dart';
import 'jobject.dart';
import 'jreference.dart';
import 'third_party/generated_bindings.dart';
import 'types.dart';

@internal
final class $JArray$NullableType$<E extends JObject?>
    extends JType<JArray<E>?> {
  final JType<E> elementType;

  const $JArray$NullableType$(this.elementType);

  @override
  String get signature => '[${elementType.signature}';

  @override
  JArray<E>? fromReference(JReference reference) =>
      reference.isNull ? null : JArray<E>.fromReference(elementType, reference);

  @override
  JType get superType => const $JObject$NullableType$();

  @override
  JType<JArray<E>?> get nullableType => this;

  @override
  final int superCount = 1;

  @override
  int get hashCode => Object.hash($JArray$NullableType$, elementType);

  @override
  bool operator ==(Object other) {
    return other.runtimeType == ($JArray$NullableType$<E>) &&
        other is $JArray$NullableType$<E> &&
        elementType == other.elementType;
  }
}

@internal
final class $JArray$Type$<E extends JObject?> extends JType<JArray<E>> {
  final JType<E> elementType;

  const $JArray$Type$(this.elementType);

  @override
  String get signature => '[${elementType.signature}';

  @override
  JArray<E> fromReference(JReference reference) =>
      JArray<E>.fromReference(elementType, reference);

  @override
  JType get superType => const $JObject$Type$();

  @override
  JType<JArray<E>?> get nullableType => $JArray$NullableType$<E>(elementType);

  @override
  final int superCount = 1;

  @override
  int get hashCode => Object.hash($JArray$Type$, elementType);

  @override
  bool operator ==(Object other) {
    return other.runtimeType == ($JArray$Type$<E>) &&
        other is $JArray$Type$<E> &&
        elementType == other.elementType;
  }
}

class JArray<E extends JObject?> extends JObject with Iterable<E> {
  final JType<E> elementType;

  @internal
  @override
  final JType<JArray<E>> $type;

  /// The type which includes information such as the signature of this class.
  static JType<JArray<E>> type<E extends JObject?>(JType<E> innerType) =>
      $JArray$Type$<E>(innerType);

  /// The type which includes information such as the signature of this class.
  static JType<JArray<E>?> nullableType<E extends JObject?>(
    JType<E> innerType,
  ) => $JArray$NullableType$<E>(innerType);

  /// Construct a new [JArray] with [reference] as its underlying reference.
  JArray.fromReference(this.elementType, JReference reference)
    : $type = type<E>(elementType),
      super.fromReference(reference);

  /// Creates a [JArray] of the given length from the given [elementType].
  ///
  /// The [length] must be a non-negative integer.
  /// For objects, [elementType] must be a nullable type as this constructor
  /// initializes all elements with `null`.
  factory JArray(JType<E> elementType, int length) {
    RangeError.checkNotNegative(length);
    if (!elementType.isNullable) {
      throw ArgumentError.value(
        elementType,
        'elementType',
        'Element type of JArray must be nullable when constructed with a '
            'length (because the elements will be initialized to null).\n\n'
            'Try using .nullableType instead',
      );
    }
    return _newArray<E>(elementType, length);
  }

  static JArray<$E> _newArray<$E extends JObject?>(
    JType<$E> elementType,
    int length, [
    $E? fill,
  ]) {
    final classRef = elementType.jClass.reference;
    final fillRef = fill?.reference ?? jNullReference;
    final array = JArray<$E>.fromReference(
      elementType,
      JGlobalReference(
        Jni.env.NewObjectArray(length, classRef.pointer, fillRef.pointer),
      ),
    );
    classRef.release();
    return array;
  }

  /// Creates a [JArray] of the given length with [fill] at each position.
  ///
  /// The [length] must be a non-negative integer.
  static JArray<$E> filled<$E extends JObject>(
    int length,
    $E fill, {
    JType<$E>? E,
  }) {
    RangeError.checkNotNegative(length);
    E ??= fill.$type as JType<$E>;
    return _newArray<$E>(E, length, fill);
  }

  /// Creates a [JArray] from `elements`.
  static JArray<$E> of<$E extends JObject?>(
    JType<$E> elementType,
    Iterable<$E> elements,
  ) {
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
    return (elementType as JType<E>).fromReference(JGlobalReference(pointer));
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

@internal
final class $JBooleanArray$NullableType$ extends JType<JBooleanArray?> {
  const $JBooleanArray$NullableType$();

  @override
  String get signature => '[Z';

  @override
  JBooleanArray? fromReference(JReference reference) =>
      reference.isNull ? null : JBooleanArray.fromReference(reference);

  @override
  JType get superType => const $JObject$NullableType$();

  @override
  JType<JBooleanArray?> get nullableType => this;

  @override
  final int superCount = 1;

  @override
  int get hashCode => ($JBooleanArray$NullableType$).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == $JBooleanArray$NullableType$ &&
        other is $JBooleanArray$NullableType$;
  }
}

@internal
final class $JBooleanArray$Type$ extends JType<JBooleanArray> {
  const $JBooleanArray$Type$();

  @override
  String get signature => '[Z';

  @override
  JBooleanArray fromReference(JReference reference) =>
      JBooleanArray.fromReference(reference);

  @override
  JType get superType => const $JObject$Type$();

  @override
  JType<JBooleanArray?> get nullableType =>
      const $JBooleanArray$NullableType$();

  @override
  final int superCount = 1;

  @override
  int get hashCode => ($JBooleanArray$Type$).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == $JBooleanArray$Type$ &&
        other is $JBooleanArray$Type$;
  }
}

class JBooleanArray extends JObject with Iterable<bool> {
  @internal
  @override
  final JType<JBooleanArray> $type;

  /// The type which includes information such as the signature of this class.
  static const JType<JBooleanArray> type = $JBooleanArray$Type$();

  /// The type which includes information such as the signature of this class.
  static const JType<JBooleanArray?> nullableType =
      $JBooleanArray$NullableType$();

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
    Jni.env.GetBooleanArrayRegion(
      reference.pointer,
      start,
      rangeLength,
      buffer,
    );
    return buffer.asTypedList(rangeLength, finalizer: allocator._nativeFree);
  }

  void setRange(
    int start,
    int end,
    Iterable<bool> iterable, [
    int skipCount = 0,
  ]) {
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

@internal
final class $JByteArray$NullableType$ extends JType<JByteArray?> {
  const $JByteArray$NullableType$();

  @override
  String get signature => '[B';

  @override
  JByteArray? fromReference(JReference reference) =>
      reference.isNull ? null : JByteArray.fromReference(reference);

  @override
  JType get superType => const $JObject$NullableType$();

  @override
  JType<JByteArray?> get nullableType => this;

  @override
  final int superCount = 1;

  @override
  int get hashCode => ($JByteArray$NullableType$).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == $JByteArray$NullableType$ &&
        other is $JByteArray$NullableType$;
  }
}

@internal
final class $JByteArray$Type$ extends JType<JByteArray> {
  const $JByteArray$Type$();

  @override
  String get signature => '[B';

  @override
  JByteArray fromReference(JReference reference) =>
      JByteArray.fromReference(reference);

  @override
  JType get superType => const $JObject$Type$();

  @override
  JType<JByteArray?> get nullableType => const $JByteArray$NullableType$();

  @override
  final int superCount = 1;

  @override
  int get hashCode => ($JByteArray$Type$).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == $JByteArray$Type$ && other is $JByteArray$Type$;
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
  final JType<JByteArray> $type;

  /// The type which includes information such as the signature of this class.
  static const JType<JByteArray> type = $JByteArray$Type$();

  /// The type which includes information such as the signature of this class.
  static const JType<JByteArray?> nullableType = $JByteArray$NullableType$();

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
      JGlobalReference(Jni.env.NewByteArray(length)),
    );
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

  void setRange(
    int start,
    int end,
    Iterable<int> iterable, [
    int skipCount = 0,
  ]) {
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

@internal
final class $JCharArray$NullableType$ extends JType<JCharArray?> {
  const $JCharArray$NullableType$();

  @override
  String get signature => '[C';

  @override
  JCharArray? fromReference(JReference reference) =>
      reference.isNull ? null : JCharArray.fromReference(reference);

  @override
  JType get superType => const $JObject$NullableType$();

  @override
  JType<JCharArray?> get nullableType => this;

  @override
  final int superCount = 1;

  @override
  int get hashCode => ($JCharArray$NullableType$).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == $JCharArray$NullableType$ &&
        other is $JCharArray$NullableType$;
  }
}

@internal
final class $JCharArray$Type$ extends JType<JCharArray> {
  const $JCharArray$Type$();

  @override
  String get signature => '[C';

  @override
  JCharArray fromReference(JReference reference) =>
      JCharArray.fromReference(reference);

  @override
  JType get superType => const $JObject$Type$();

  @override
  JType<JCharArray?> get nullableType => const $JCharArray$NullableType$();

  @override
  final int superCount = 1;

  @override
  int get hashCode => ($JCharArray$Type$).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == $JCharArray$Type$ && other is $JCharArray$Type$;
  }
}

/// `JCharArray` is a 16-bit integer array.
///
/// Due to variable length encoding, the  number of code units is not equal to
/// the number of characters.
class JCharArray extends JObject with Iterable<int> {
  @internal
  @override
  final JType<JCharArray> $type;

  /// The type which includes information such as the signature of this class.
  static const JType<JCharArray> type = $JCharArray$Type$();

  /// The type which includes information such as the signature of this class.
  static const JType<JCharArray?> nullableType = $JCharArray$NullableType$();

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
      JGlobalReference(Jni.env.NewCharArray(length)),
    );
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

  void setRange(
    int start,
    int end,
    Iterable<int> iterable, [
    int skipCount = 0,
  ]) {
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

@internal
final class $JShortArray$NullableType$ extends JType<JShortArray?> {
  const $JShortArray$NullableType$();

  @override
  String get signature => '[S';

  @override
  JShortArray? fromReference(JReference reference) =>
      reference.isNull ? null : JShortArray.fromReference(reference);

  @override
  JType get superType => const $JObject$NullableType$();

  @override
  JType<JShortArray?> get nullableType => this;

  @override
  final int superCount = 1;

  @override
  int get hashCode => ($JShortArray$NullableType$).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == $JShortArray$NullableType$ &&
        other is $JShortArray$NullableType$;
  }
}

@internal
final class $JShortArray$Type$ extends JType<JShortArray> {
  const $JShortArray$Type$();

  @override
  String get signature => '[S';

  @override
  JShortArray fromReference(JReference reference) =>
      JShortArray.fromReference(reference);

  @override
  JType get superType => const $JObject$Type$();

  @override
  JType<JShortArray?> get nullableType => const $JShortArray$NullableType$();

  @override
  final int superCount = 1;

  @override
  int get hashCode => ($JShortArray$Type$).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == $JShortArray$Type$ &&
        other is $JShortArray$Type$;
  }
}

class JShortArray extends JObject with Iterable<int> {
  @internal
  @override
  final JType<JShortArray> $type;

  /// The type which includes information such as the signature of this class.
  static const JType<JShortArray> type = $JShortArray$Type$();

  /// The type which includes information such as the signature of this class.
  static const JType<JShortArray?> nullableType = $JShortArray$NullableType$();

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
      JGlobalReference(Jni.env.NewShortArray(length)),
    );
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

  void setRange(
    int start,
    int end,
    Iterable<int> iterable, [
    int skipCount = 0,
  ]) {
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

@internal
final class $JIntArray$NullableType$ extends JType<JIntArray?> {
  const $JIntArray$NullableType$();

  @override
  String get signature => '[I';

  @override
  JIntArray? fromReference(JReference reference) =>
      reference.isNull ? null : JIntArray.fromReference(reference);

  @override
  JType get superType => const $JObject$NullableType$();

  @override
  JType<JIntArray?> get nullableType => this;

  @override
  final int superCount = 1;

  @override
  int get hashCode => ($JIntArray$NullableType$).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == $JIntArray$NullableType$ &&
        other is $JIntArray$NullableType$;
  }
}

@internal
final class $JIntArray$Type$ extends JType<JIntArray> {
  const $JIntArray$Type$();

  @override
  String get signature => '[I';

  @override
  JIntArray fromReference(JReference reference) =>
      JIntArray.fromReference(reference);

  @override
  JType get superType => const $JObject$Type$();

  @override
  JType<JIntArray?> get nullableType => const $JIntArray$NullableType$();

  @override
  final int superCount = 1;

  @override
  int get hashCode => ($JIntArray$Type$).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == $JIntArray$Type$ && other is $JIntArray$Type$;
  }
}

class JIntArray extends JObject with Iterable<int> {
  @internal
  @override
  final JType<JIntArray> $type;

  /// The type which includes information such as the signature of this class.
  static const JType<JIntArray> type = $JIntArray$Type$();

  /// The type which includes information such as the signature of this class.
  static const JType<JIntArray?> nullableType = $JIntArray$NullableType$();

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
      JGlobalReference(Jni.env.NewIntArray(length)),
    );
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

  void setRange(
    int start,
    int end,
    Iterable<int> iterable, [
    int skipCount = 0,
  ]) {
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

@internal
final class $JLongArray$NullableType$ extends JType<JLongArray?> {
  const $JLongArray$NullableType$();

  @override
  String get signature => '[J';

  @override
  JLongArray? fromReference(JReference reference) =>
      reference.isNull ? null : JLongArray.fromReference(reference);

  @override
  JType get superType => const $JObject$NullableType$();

  @override
  JType<JLongArray?> get nullableType => this;

  @override
  final int superCount = 1;

  @override
  int get hashCode => ($JLongArray$NullableType$).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == $JLongArray$NullableType$ &&
        other is $JLongArray$NullableType$;
  }
}

@internal
final class $JLongArray$Type$ extends JType<JLongArray> {
  const $JLongArray$Type$();

  @override
  String get signature => '[J';

  @override
  JLongArray fromReference(JReference reference) =>
      JLongArray.fromReference(reference);

  @override
  JType get superType => const $JObject$Type$();

  @override
  JType<JLongArray?> get nullableType => const $JLongArray$NullableType$();

  @override
  final int superCount = 1;

  @override
  int get hashCode => ($JLongArray$Type$).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == $JLongArray$Type$ && other is $JLongArray$Type$;
  }
}

class JLongArray extends JObject with Iterable<int> {
  @internal
  @override
  final JType<JLongArray> $type;

  /// The type which includes information such as the signature of this class.
  static const JType<JLongArray> type = $JLongArray$Type$();

  /// The type which includes information such as the signature of this class.
  static const JType<JLongArray?> nullableType = $JLongArray$NullableType$();

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
      JGlobalReference(Jni.env.NewLongArray(length)),
    );
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

  void setRange(
    int start,
    int end,
    Iterable<int> iterable, [
    int skipCount = 0,
  ]) {
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

@internal
final class $JFloatArray$NullableType$ extends JType<JFloatArray?> {
  const $JFloatArray$NullableType$();

  @override
  String get signature => '[F';

  @override
  JFloatArray? fromReference(JReference reference) =>
      reference.isNull ? null : JFloatArray.fromReference(reference);

  @override
  JType get superType => const $JObject$NullableType$();

  @override
  JType<JFloatArray?> get nullableType => this;

  @override
  final int superCount = 1;

  @override
  int get hashCode => ($JFloatArray$NullableType$).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == $JFloatArray$NullableType$ &&
        other is $JFloatArray$NullableType$;
  }
}

@internal
final class $JFloatArray$Type$ extends JType<JFloatArray> {
  const $JFloatArray$Type$();

  @override
  String get signature => '[F';

  @override
  JFloatArray fromReference(JReference reference) =>
      JFloatArray.fromReference(reference);

  @override
  JType get superType => const $JObject$Type$();

  @override
  JType<JFloatArray?> get nullableType => const $JFloatArray$NullableType$();

  @override
  final int superCount = 1;

  @override
  int get hashCode => ($JFloatArray$Type$).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == $JFloatArray$Type$ &&
        other is $JFloatArray$Type$;
  }
}

class JFloatArray extends JObject with Iterable<double> {
  @internal
  @override
  final JType<JFloatArray> $type;

  /// The type which includes information such as the signature of this class.
  static const JType<JFloatArray> type = $JFloatArray$Type$();

  /// The type which includes information such as the signature of this class.
  static const JType<JFloatArray?> nullableType = $JFloatArray$NullableType$();

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
      JGlobalReference(Jni.env.NewFloatArray(length)),
    );
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

  void setRange(
    int start,
    int end,
    Iterable<double> iterable, [
    int skipCount = 0,
  ]) {
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

@internal
final class $JDoubleArray$NullableType$ extends JType<JDoubleArray?> {
  const $JDoubleArray$NullableType$();

  @override
  String get signature => '[D';

  @override
  JDoubleArray? fromReference(JReference reference) =>
      reference.isNull ? null : JDoubleArray.fromReference(reference);

  @override
  JType get superType => const $JObject$NullableType$();

  @override
  JType<JDoubleArray?> get nullableType => this;

  @override
  final int superCount = 1;

  @override
  int get hashCode => ($JDoubleArray$NullableType$).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == $JDoubleArray$NullableType$ &&
        other is $JDoubleArray$NullableType$;
  }
}

@internal
final class $JDoubleArray$Type$ extends JType<JDoubleArray> {
  const $JDoubleArray$Type$();

  @override
  String get signature => '[D';

  @override
  JDoubleArray fromReference(JReference reference) =>
      JDoubleArray.fromReference(reference);

  @override
  JType get superType => const $JObject$Type$();

  @override
  JType<JDoubleArray?> get nullableType => const $JDoubleArray$NullableType$();

  @override
  final int superCount = 1;

  @override
  int get hashCode => ($JDoubleArray$Type$).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == $JDoubleArray$Type$ &&
        other is $JDoubleArray$Type$;
  }
}

class JDoubleArray extends JObject with Iterable<double> {
  @internal
  @override
  final JType<JDoubleArray> $type;

  /// The type which includes information such as the signature of this class.
  static const JType<JDoubleArray> type = $JDoubleArray$Type$();

  /// The type which includes information such as the signature of this class.
  static const JType<JDoubleArray?> nullableType =
      $JDoubleArray$NullableType$();

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
      JGlobalReference(Jni.env.NewDoubleArray(length)),
    );
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

  void setRange(
    int start,
    int end,
    Iterable<double> iterable, [
    int skipCount = 0,
  ]) {
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
