// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: unnecessary_cast, overridden_fields

import 'dart:ffi';

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
    int size,
    void Function(Pointer<T> ptr) use,
  ) {
    using((arena) {
      final ptr = arena.allocate<T>(size);
      use(ptr);
    }, malloc);
  }
}

extension BoolArray on JArray<jboolean> {
  bool operator [](int index) {
    return _elementAt(index, JniCallType.booleanType).boolean;
  }

  void operator []=(int index, bool value) {
    RangeError.checkValidIndex(index, this);
    _allocate<JBooleanMarker>(sizeOf<JBooleanMarker>(), (ptr) {
      ptr.value = value ? 1 : 0;
      Jni.env.SetBooleanArrayRegion(reference.pointer, index, 1, ptr);
    });
  }

  void setRange(int start, int end, Iterable<bool> iterable,
      [int skipCount = 0]) {
    RangeError.checkValidRange(start, end, length);
    final size = end - start;
    final it = iterable.skip(skipCount).take(size);
    _allocate<JBooleanMarker>(sizeOf<JBooleanMarker>() * size, (ptr) {
      it.forEachIndexed((index, element) {
        ptr[index] = element ? 1 : 0;
      });
      Jni.env.SetBooleanArrayRegion(reference.pointer, start, size, ptr);
    });
  }
}

extension ByteArray on JArray<jbyte> {
  int operator [](int index) {
    return _elementAt(index, JniCallType.byteType).byte;
  }

  void operator []=(int index, int value) {
    RangeError.checkValidIndex(index, this);
    _allocate<JByteMarker>(sizeOf<JByteMarker>(), (ptr) {
      ptr.value = value;
      Jni.env.SetByteArrayRegion(reference.pointer, index, 1, ptr);
    });
  }

  void setRange(int start, int end, Iterable<int> iterable,
      [int skipCount = 0]) {
    RangeError.checkValidRange(start, end, length);
    final size = end - start;
    final it = iterable.skip(skipCount).take(size);
    _allocate<JByteMarker>(sizeOf<JByteMarker>() * size, (ptr) {
      it.forEachIndexed((index, element) {
        ptr[index] = element;
      });
      Jni.env.SetByteArrayRegion(reference.pointer, start, size, ptr);
    });
  }
}

extension CharArray on JArray<jchar> {
  String operator [](int index) {
    return String.fromCharCode(
      _elementAt(index, JniCallType.charType).char,
    );
  }

  void operator []=(int index, String value) {
    RangeError.checkValidIndex(index, this);
    _allocate<JCharMarker>(sizeOf<JCharMarker>(), (ptr) {
      ptr.value = value.codeUnits.first;
      Jni.env.SetCharArrayRegion(reference.pointer, index, 1, ptr);
    });
  }

  void setRange(int start, int end, Iterable<String> iterable,
      [int skipCount = 0]) {
    RangeError.checkValidRange(start, end, length);
    final size = end - start;
    final it = iterable.skip(skipCount).take(size);
    _allocate<JCharMarker>(sizeOf<JCharMarker>() * size, (ptr) {
      it.forEachIndexed((index, element) {
        ptr[index] = element.codeUnits.first;
      });
      Jni.env.SetCharArrayRegion(reference.pointer, start, size, ptr);
    });
  }
}

extension ShortArray on JArray<jshort> {
  int operator [](int index) {
    return _elementAt(index, JniCallType.shortType).short;
  }

  void operator []=(int index, int value) {
    RangeError.checkValidIndex(index, this);
    _allocate<JShortMarker>(sizeOf<JShortMarker>(), (ptr) {
      ptr.value = value;
      Jni.env.SetShortArrayRegion(reference.pointer, index, 1, ptr);
    });
  }

  void setRange(int start, int end, Iterable<int> iterable,
      [int skipCount = 0]) {
    RangeError.checkValidRange(start, end, length);
    final size = end - start;
    final it = iterable.skip(skipCount).take(size);
    _allocate<JShortMarker>(sizeOf<JShortMarker>() * size, (ptr) {
      it.forEachIndexed((index, element) {
        ptr[index] = element;
      });
      Jni.env.SetShortArrayRegion(reference.pointer, start, size, ptr);
    });
  }
}

extension IntArray on JArray<jint> {
  int operator [](int index) {
    return _elementAt(index, JniCallType.intType).integer;
  }

  void operator []=(int index, int value) {
    RangeError.checkValidIndex(index, this);
    _allocate<JIntMarker>(sizeOf<JIntMarker>(), (ptr) {
      ptr.value = value;
      Jni.env.SetIntArrayRegion(reference.pointer, index, 1, ptr);
    });
  }

  void setRange(int start, int end, Iterable<int> iterable,
      [int skipCount = 0]) {
    RangeError.checkValidRange(start, end, length);
    final size = end - start;
    final it = iterable.skip(skipCount).take(size);
    _allocate<JIntMarker>(sizeOf<JIntMarker>() * size, (ptr) {
      it.forEachIndexed((index, element) {
        ptr[index] = element;
      });
      Jni.env.SetIntArrayRegion(reference.pointer, start, size, ptr);
    });
  }
}

extension LongArray on JArray<jlong> {
  int operator [](int index) {
    return _elementAt(index, JniCallType.longType).long;
  }

  void operator []=(int index, int value) {
    RangeError.checkValidIndex(index, this);
    _allocate<JLongMarker>(sizeOf<JLongMarker>(), (ptr) {
      ptr.value = value;
      Jni.env.SetLongArrayRegion(reference.pointer, index, 1, ptr);
    });
  }

  void setRange(int start, int end, Iterable<int> iterable,
      [int skipCount = 0]) {
    RangeError.checkValidRange(start, end, length);
    final size = end - start;
    final it = iterable.skip(skipCount).take(size);
    _allocate<JLongMarker>(sizeOf<JLongMarker>() * size, (ptr) {
      it.forEachIndexed((index, element) {
        ptr[index] = element;
      });
      Jni.env.SetLongArrayRegion(reference.pointer, start, size, ptr);
    });
  }
}

extension FloatArray on JArray<jfloat> {
  double operator [](int index) {
    return _elementAt(index, JniCallType.floatType).float;
  }

  void operator []=(int index, double value) {
    RangeError.checkValidIndex(index, this);
    _allocate<JFloatMarker>(sizeOf<JFloatMarker>(), (ptr) {
      ptr.value = value;
      Jni.env.SetFloatArrayRegion(reference.pointer, index, 1, ptr);
    });
  }

  void setRange(int start, int end, Iterable<double> iterable,
      [int skipCount = 0]) {
    RangeError.checkValidRange(start, end, length);
    final size = end - start;
    final it = iterable.skip(skipCount).take(size);
    _allocate<JFloatMarker>(sizeOf<JFloatMarker>() * size, (ptr) {
      it.forEachIndexed((index, element) {
        ptr[index] = element;
      });
      Jni.env.SetFloatArrayRegion(reference.pointer, start, size, ptr);
    });
  }
}

extension DoubleArray on JArray<jdouble> {
  double operator [](int index) {
    return _elementAt(index, JniCallType.doubleType).doubleFloat;
  }

  void operator []=(int index, double value) {
    RangeError.checkValidIndex(index, this);
    _allocate<JDoubleMarker>(sizeOf<JDoubleMarker>(), (ptr) {
      ptr.value = value;
      Jni.env.SetDoubleArrayRegion(reference.pointer, index, 1, ptr);
    });
  }

  void setRange(int start, int end, Iterable<double> iterable,
      [int skipCount = 0]) {
    RangeError.checkValidRange(start, end, length);
    final size = end - start;
    final it = iterable.skip(skipCount).take(size);
    _allocate<JDoubleMarker>(sizeOf<JDoubleMarker>() * size, (ptr) {
      it.forEachIndexed((index, element) {
        ptr[index] = element;
      });
      Jni.env.SetDoubleArrayRegion(reference.pointer, start, size, ptr);
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
    final size = end - start;
    final it = iterable.skip(skipCount).take(size);
    it.forEachIndexed((index, element) {
      this[index] = element;
    });
  }
}
