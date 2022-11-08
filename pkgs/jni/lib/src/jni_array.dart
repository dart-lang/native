// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: unnecessary_cast

part of 'jni_object.dart';

class JniArray<E> extends JniObject {
  /// The type which includes information such as the signature of this class.
  static JniType<JniArray<T>> type<T>(JniType<T> innerType) =>
      _JniArrayType(innerType);

  /// Construct a new [JniArray] with [reference] as its underlying reference.
  JniArray.fromRef(JArray reference) : super.fromRef(reference);

  JniArray(JniType<E> typeClass, int length)
      : super.fromRef(
          (typeClass._type == JniCallType.objectType)
              ? _accessors
                  .newObjectArray(
                      length, typeClass._getClass().reference, nullptr)
                  .checkedRef
              : _accessors
                  .newPrimitiveArray(length, typeClass._type)
                  .checkedRef,
        );

  int? _length;

  JniResult elementAt(int index, int type) {
    RangeError.checkValidIndex(index, this);
    return _accessors.getArrayElement(reference, index, type);
  }

  /// The number of elements in this array.
  int get length {
    return _length ??= _env.GetArrayLength(reference);
  }
}

extension NativeJniArray<E extends NativeType> on JniArray<E> {
  void _allocate(int size, void Function(Pointer<E> ptr) use) {
    using((arena) {
      final ptr = arena.allocate<E>(size);
      use(ptr);
    }, malloc);
  }
}

extension BoolJniArray on JniArray<JBoolean> {
  bool operator [](int index) {
    return elementAt(index, JniCallType.booleanType).boolean;
  }

  void operator []=(int index, bool value) {
    RangeError.checkValidIndex(index, this);
    _allocate(sizeOf<JBoolean>(), (ptr) {
      ptr.value = value ? 1 : 0;
      _env.SetBooleanArrayRegion(reference, index, 1, ptr);
    });
  }

  void setRange(int start, int end, Iterable<bool> iterable,
      [int skipCount = 0]) {
    RangeError.checkValidRange(start, end, length);
    final size = end - start;
    final it = iterable.skip(skipCount).take(size);
    _allocate(sizeOf<JBoolean>() * size, (ptr) {
      it.forEachIndexed((index, element) {
        ptr[index] = element ? 1 : 0;
      });
      _env.SetBooleanArrayRegion(reference, start, size, ptr);
    });
  }
}

extension ByteJniArray on JniArray<JByte> {
  int operator [](int index) {
    return elementAt(index, JniCallType.byteType).byte;
  }

  void operator []=(int index, int value) {
    RangeError.checkValidIndex(index, this);
    _allocate(sizeOf<JByte>(), (ptr) {
      ptr.value = value;
      _env.SetByteArrayRegion(reference, index, 1, ptr);
    });
  }

  void setRange(int start, int end, Iterable<int> iterable,
      [int skipCount = 0]) {
    RangeError.checkValidRange(start, end, length);
    final size = end - start;
    final it = iterable.skip(skipCount).take(size);
    _allocate(sizeOf<JByte>() * size, (ptr) {
      it.forEachIndexed((index, element) {
        ptr[index] = element;
      });
      _env.SetByteArrayRegion(reference, start, size, ptr);
    });
  }
}

extension CharJniArray on JniArray<JChar> {
  String operator [](int index) {
    return String.fromCharCode(
      elementAt(index, JniCallType.charType).char,
    );
  }

  void operator []=(int index, String value) {
    RangeError.checkValidIndex(index, this);
    _allocate(sizeOf<JChar>(), (ptr) {
      ptr.value = value.codeUnits.first;
      _env.SetCharArrayRegion(reference, index, 1, ptr);
    });
  }

  void setRange(int start, int end, Iterable<String> iterable,
      [int skipCount = 0]) {
    RangeError.checkValidRange(start, end, length);
    final size = end - start;
    final it = iterable.skip(skipCount).take(size);
    _allocate(sizeOf<JChar>() * size, (ptr) {
      it.forEachIndexed((index, element) {
        ptr[index] = element.codeUnits.first;
      });
      _env.SetCharArrayRegion(reference, start, size, ptr);
    });
  }
}

extension ShortJniArray on JniArray<JShort> {
  int operator [](int index) {
    return elementAt(index, JniCallType.shortType).short;
  }

  void operator []=(int index, int value) {
    RangeError.checkValidIndex(index, this);
    _allocate(sizeOf<JShort>(), (ptr) {
      ptr.value = value;
      _env.SetShortArrayRegion(reference, index, 1, ptr);
    });
  }

  void setRange(int start, int end, Iterable<int> iterable,
      [int skipCount = 0]) {
    RangeError.checkValidRange(start, end, length);
    final size = end - start;
    final it = iterable.skip(skipCount).take(size);
    _allocate(sizeOf<JShort>() * size, (ptr) {
      it.forEachIndexed((index, element) {
        ptr[index] = element;
      });
      _env.SetShortArrayRegion(reference, start, size, ptr);
    });
  }
}

extension IntJniArray on JniArray<JInt> {
  int operator [](int index) {
    return elementAt(index, JniCallType.intType).integer;
  }

  void operator []=(int index, int value) {
    RangeError.checkValidIndex(index, this);
    _allocate(sizeOf<JInt>(), (ptr) {
      ptr.value = value;
      _env.SetIntArrayRegion(reference, index, 1, ptr);
    });
  }

  void setRange(int start, int end, Iterable<int> iterable,
      [int skipCount = 0]) {
    RangeError.checkValidRange(start, end, length);
    final size = end - start;
    final it = iterable.skip(skipCount).take(size);
    _allocate(sizeOf<JInt>() * size, (ptr) {
      it.forEachIndexed((index, element) {
        ptr[index] = element;
      });
      _env.SetIntArrayRegion(reference, start, size, ptr);
    });
  }
}

extension LongJniArray on JniArray<JLong> {
  int operator [](int index) {
    return elementAt(index, JniCallType.longType).long;
  }

  void operator []=(int index, int value) {
    RangeError.checkValidIndex(index, this);
    _allocate(sizeOf<JLong>(), (ptr) {
      ptr.value = value;
      _env.SetLongArrayRegion(reference, index, 1, ptr);
    });
  }

  void setRange(int start, int end, Iterable<int> iterable,
      [int skipCount = 0]) {
    RangeError.checkValidRange(start, end, length);
    final size = end - start;
    final it = iterable.skip(skipCount).take(size);
    _allocate(sizeOf<JLong>() * size, (ptr) {
      it.forEachIndexed((index, element) {
        ptr[index] = element;
      });
      _env.SetLongArrayRegion(reference, start, size, ptr);
    });
  }
}

extension FloatJniArray on JniArray<JFloat> {
  double operator [](int index) {
    return elementAt(index, JniCallType.floatType).float;
  }

  void operator []=(int index, double value) {
    RangeError.checkValidIndex(index, this);
    _allocate(sizeOf<JFloat>(), (ptr) {
      ptr.value = value;
      _env.SetFloatArrayRegion(reference, index, 1, ptr);
    });
  }

  void setRange(int start, int end, Iterable<double> iterable,
      [int skipCount = 0]) {
    RangeError.checkValidRange(start, end, length);
    final size = end - start;
    final it = iterable.skip(skipCount).take(size);
    _allocate(sizeOf<JFloat>() * size, (ptr) {
      it.forEachIndexed((index, element) {
        ptr[index] = element;
      });
      _env.SetFloatArrayRegion(reference, start, size, ptr);
    });
  }
}

extension DoubleJniArray on JniArray<JDouble> {
  double operator [](int index) {
    return elementAt(index, JniCallType.doubleType).doubleFloat;
  }

  void operator []=(int index, double value) {
    RangeError.checkValidIndex(index, this);
    _allocate(sizeOf<JDouble>(), (ptr) {
      ptr.value = value;
      _env.SetDoubleArrayRegion(reference, index, 1, ptr);
    });
  }

  void setRange(int start, int end, Iterable<double> iterable,
      [int skipCount = 0]) {
    RangeError.checkValidRange(start, end, length);
    final size = end - start;
    final it = iterable.skip(skipCount).take(size);
    _allocate(sizeOf<JDouble>() * size, (ptr) {
      it.forEachIndexed((index, element) {
        ptr[index] = element;
      });
      _env.SetDoubleArrayRegion(reference, start, size, ptr);
    });
  }
}

extension ObjectJniArray<T extends JniObject> on JniArray<T> {
  JniObject operator [](int index) {
    return JniObject.fromRef(elementAt(index, JniCallType.objectType).object);
  }

  void operator []=(int index, JniObject value) {
    RangeError.checkValidIndex(index, this);
    _env.SetObjectArrayElement(reference, index, value.reference);
  }

  void setRange(int start, int end, Iterable<JniObject> iterable,
      [int skipCount = 0]) {
    RangeError.checkValidRange(start, end, length);
    final size = end - start;
    final it = iterable.skip(skipCount).take(size);
    it.forEachIndexed((index, element) {
      this[index] = element;
    });
  }
}

extension ArrayJniArray<T> on JniArray<JniArray<T>> {
  JniArray<T> operator [](int index) {
    return JniArray<T>.fromRef(elementAt(index, JniCallType.objectType).object);
  }

  void operator []=(int index, JniArray<T> value) {
    (this as JniArray<JniObject>)[index] = value;
  }
}

extension StringJniArray on JniArray<JniString> {
  JniString operator [](int index) {
    return JniString.fromRef(elementAt(index, JniCallType.objectType).object);
  }

  void operator []=(int index, JniString value) {
    (this as JniArray<JniObject>)[index] = value;
  }
}
