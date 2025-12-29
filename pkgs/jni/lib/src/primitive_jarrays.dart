// AUTO GENERATED. DO NOT EDIT!
//
// To regenerate, run `dart run tool/generate_primtive_arrays.dart`

part of 'jarray.dart';

final class _$JBooleanArray$Type$ extends JType<JBooleanArray> {
  const _$JBooleanArray$Type$();

  @override
  String get signature => '[Z';
}

/// A fixed-length array of Java Boolean.
///
/// Java equivalent of [Uint8List].
extension type JBooleanArray._(JObject _$this) implements JObject {
  /// The type which includes information such as the signature of this class.
  static const JType<JBooleanArray> type = _$JBooleanArray$Type$();

  /// Creates a [JBooleanArray] of the given [length].
  ///
  /// The [length] must be a non-negative integer.
  factory JBooleanArray(int length) {
    RangeError.checkNotNegative(length);
    return JObject.fromReference(
      JGlobalReference(Jni.env.NewBooleanArray(length)),
    ) as JBooleanArray;
  }

  /// The number of elements in this array.
  int get length => Jni.env.GetArrayLength(reference.pointer);

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
    final buffer = allocator<Uint8>(rangeLength);
    Jni.env
        .GetBooleanArrayRegion(reference.pointer, start, rangeLength, buffer);
    return buffer.asTypedList(rangeLength, finalizer: allocator._nativeFree);
  }

  void setRange(int start, int end, Iterable<bool> iterable,
      [int skipCount = 0]) {
    RangeError.checkValidRange(start, end, length);
    final rangeLength = end - start;
    _allocate<Uint8>(sizeOf<Uint8>() * rangeLength, (ptr) {
      ptr
          .asTypedList(rangeLength)
          .setRange(0, rangeLength, iterable.map((e) => e ? 1 : 0), skipCount);
      Jni.env.SetBooleanArrayRegion(reference.pointer, start, rangeLength, ptr);
    });
  }
}

final class _JBooleanArrayListView
    with ListMixin<bool>, NonGrowableListMixin<bool> {
  final JBooleanArray _jarray;

  _JBooleanArrayListView(this._jarray);

  @override
  int get length => _jarray.length;

  @override
  bool operator [](int index) {
    return _jarray[index];
  }

  @override
  void operator []=(int index, bool value) {
    _jarray[index] = value;
  }
}

extension JBooleanArrayToList on JBooleanArray {
  /// Returns a [List] view into this array.
  ///
  /// Any changes to this list will reflect in the original array as well.
  List<bool> get asDartList => _JBooleanArrayListView(this);
}

final class _$JByteArray$Type$ extends JType<JByteArray> {
  const _$JByteArray$Type$();

  @override
  String get signature => '[B';
}

/// A fixed-length array of Java Byte.
///
/// Integers stored in the list are truncated to their low eight bits
/// interpreted as a signed 8-bit two's complement integer with values in the
/// range -128 to +127.
///
/// Java equivalent of [Int8List].
extension type JByteArray._(JObject _$this) implements JObject {
  /// The type which includes information such as the signature of this class.
  static const JType<JByteArray> type = _$JByteArray$Type$();

  /// Creates a [JByteArray] of the given [length].
  ///
  /// The [length] must be a non-negative integer.
  factory JByteArray(int length) {
    RangeError.checkNotNegative(length);
    return JObject.fromReference(
      JGlobalReference(Jni.env.NewByteArray(length)),
    ) as JByteArray;
  }

  /// The number of elements in this array.
  int get length => Jni.env.GetArrayLength(reference.pointer);

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
    final buffer = allocator<Int8>(rangeLength);
    Jni.env.GetByteArrayRegion(reference.pointer, start, rangeLength, buffer);
    return buffer.asTypedList(rangeLength, finalizer: allocator._nativeFree);
  }

  void setRange(int start, int end, Iterable<int> iterable,
      [int skipCount = 0]) {
    RangeError.checkValidRange(start, end, length);
    final rangeLength = end - start;
    _allocate<Int8>(sizeOf<Int8>() * rangeLength, (ptr) {
      ptr
          .asTypedList(rangeLength)
          .setRange(0, rangeLength, iterable, skipCount);
      Jni.env.SetByteArrayRegion(reference.pointer, start, rangeLength, ptr);
    });
  }
}

final class _JByteArrayListView with ListMixin<int>, NonGrowableListMixin<int> {
  final JByteArray _jarray;

  _JByteArrayListView(this._jarray);

  @override
  int get length => _jarray.length;

  @override
  int operator [](int index) {
    return _jarray[index];
  }

  @override
  void operator []=(int index, int value) {
    _jarray[index] = value;
  }
}

extension JByteArrayToList on JByteArray {
  /// Returns a [List] view into this array.
  ///
  /// Any changes to this list will reflect in the original array as well.
  List<int> get asDartList => _JByteArrayListView(this);
}

final class _$JCharArray$Type$ extends JType<JCharArray> {
  const _$JCharArray$Type$();

  @override
  String get signature => '[C';
}

/// A fixed-length array of Java Char.
///
/// Integers stored in the list are truncated to their low 16 bits
/// interpreted as an unsigned 16-bit integer with values in the
/// range 0 to +65535.
///
/// Java equivalent of [Uint16List].
extension type JCharArray._(JObject _$this) implements JObject {
  /// The type which includes information such as the signature of this class.
  static const JType<JCharArray> type = _$JCharArray$Type$();

  /// Creates a [JCharArray] of the given [length].
  ///
  /// The [length] must be a non-negative integer.
  factory JCharArray(int length) {
    RangeError.checkNotNegative(length);
    return JObject.fromReference(
      JGlobalReference(Jni.env.NewCharArray(length)),
    ) as JCharArray;
  }

  /// The number of elements in this array.
  int get length => Jni.env.GetArrayLength(reference.pointer);

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
    final buffer = allocator<Uint16>(rangeLength);
    Jni.env.GetCharArrayRegion(reference.pointer, start, rangeLength, buffer);
    return buffer.asTypedList(rangeLength, finalizer: allocator._nativeFree);
  }

  void setRange(int start, int end, Iterable<int> iterable,
      [int skipCount = 0]) {
    RangeError.checkValidRange(start, end, length);
    final rangeLength = end - start;
    _allocate<Uint16>(sizeOf<Uint16>() * rangeLength, (ptr) {
      ptr
          .asTypedList(rangeLength)
          .setRange(0, rangeLength, iterable, skipCount);
      Jni.env.SetCharArrayRegion(reference.pointer, start, rangeLength, ptr);
    });
  }
}

final class _JCharArrayListView with ListMixin<int>, NonGrowableListMixin<int> {
  final JCharArray _jarray;

  _JCharArrayListView(this._jarray);

  @override
  int get length => _jarray.length;

  @override
  int operator [](int index) {
    return _jarray[index];
  }

  @override
  void operator []=(int index, int value) {
    _jarray[index] = value;
  }
}

extension JCharArrayToList on JCharArray {
  /// Returns a [List] view into this array.
  ///
  /// Any changes to this list will reflect in the original array as well.
  List<int> get asDartList => _JCharArrayListView(this);
}

final class _$JShortArray$Type$ extends JType<JShortArray> {
  const _$JShortArray$Type$();

  @override
  String get signature => '[S';
}

/// A fixed-length array of Java Short.
///
/// Integers stored in the list are truncated to their low 16 bits
/// interpreted as a signed 16-bit two's complement integer with values in the
/// range -32768 to +32767.
///
/// Java equivalent of [Int16List].
extension type JShortArray._(JObject _$this) implements JObject {
  /// The type which includes information such as the signature of this class.
  static const JType<JShortArray> type = _$JShortArray$Type$();

  /// Creates a [JShortArray] of the given [length].
  ///
  /// The [length] must be a non-negative integer.
  factory JShortArray(int length) {
    RangeError.checkNotNegative(length);
    return JObject.fromReference(
      JGlobalReference(Jni.env.NewShortArray(length)),
    ) as JShortArray;
  }

  /// The number of elements in this array.
  int get length => Jni.env.GetArrayLength(reference.pointer);

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
    final buffer = allocator<Int16>(rangeLength);
    Jni.env.GetShortArrayRegion(reference.pointer, start, rangeLength, buffer);
    return buffer.asTypedList(rangeLength, finalizer: allocator._nativeFree);
  }

  void setRange(int start, int end, Iterable<int> iterable,
      [int skipCount = 0]) {
    RangeError.checkValidRange(start, end, length);
    final rangeLength = end - start;
    _allocate<Int16>(sizeOf<Int16>() * rangeLength, (ptr) {
      ptr
          .asTypedList(rangeLength)
          .setRange(0, rangeLength, iterable, skipCount);
      Jni.env.SetShortArrayRegion(reference.pointer, start, rangeLength, ptr);
    });
  }
}

final class _JShortArrayListView
    with ListMixin<int>, NonGrowableListMixin<int> {
  final JShortArray _jarray;

  _JShortArrayListView(this._jarray);

  @override
  int get length => _jarray.length;

  @override
  int operator [](int index) {
    return _jarray[index];
  }

  @override
  void operator []=(int index, int value) {
    _jarray[index] = value;
  }
}

extension JShortArrayToList on JShortArray {
  /// Returns a [List] view into this array.
  ///
  /// Any changes to this list will reflect in the original array as well.
  List<int> get asDartList => _JShortArrayListView(this);
}

final class _$JIntArray$Type$ extends JType<JIntArray> {
  const _$JIntArray$Type$() : super('[I');
}

/// A fixed-length array of Java Int.
///
/// Integers stored in the list are truncated to their low 32 bits
/// interpreted as a signed 32-bit two's complement integer with values in the
/// range -2147483648 to +2147483647.
///
/// Java equivalent of [Int32List].
extension type JIntArray._(JObject _$this) implements JObject {
  /// The type which includes information such as the signature of this class.
  static const JType<JIntArray> type = _$JIntArray$Type$();

  /// Creates a [JIntArray] of the given [length].
  ///
  /// The [length] must be a non-negative integer.
  factory JIntArray(int length) {
    RangeError.checkNotNegative(length);
    return JObject.fromReference(
      JGlobalReference(Jni.env.NewIntArray(length)),
    ) as JIntArray;
  }

  /// The number of elements in this array.
  int get length => Jni.env.GetArrayLength(reference.pointer);

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
    final buffer = allocator<Int32>(rangeLength);
    Jni.env.GetIntArrayRegion(reference.pointer, start, rangeLength, buffer);
    return buffer.asTypedList(rangeLength, finalizer: allocator._nativeFree);
  }

  void setRange(int start, int end, Iterable<int> iterable,
      [int skipCount = 0]) {
    RangeError.checkValidRange(start, end, length);
    final rangeLength = end - start;
    _allocate<Int32>(sizeOf<Int32>() * rangeLength, (ptr) {
      ptr
          .asTypedList(rangeLength)
          .setRange(0, rangeLength, iterable, skipCount);
      Jni.env.SetIntArrayRegion(reference.pointer, start, rangeLength, ptr);
    });
  }
}

final class _JIntArrayListView with ListMixin<int>, NonGrowableListMixin<int> {
  final JIntArray _jarray;

  _JIntArrayListView(this._jarray);

  @override
  int get length => _jarray.length;

  @override
  int operator [](int index) {
    return _jarray[index];
  }

  @override
  void operator []=(int index, int value) {
    _jarray[index] = value;
  }
}

extension JIntArrayToList on JIntArray {
  /// Returns a [List] view into this array.
  ///
  /// Any changes to this list will reflect in the original array as well.
  List<int> get asDartList => _JIntArrayListView(this);
}

final class _$JLongArray$Type$ extends JType<JLongArray> {
  const _$JLongArray$Type$();

  @override
  String get signature => '[J';
}

/// A fixed-length array of Java Long.
///
/// Integers stored in the list are truncated to their low 64 bits
/// interpreted as a signed 64-bit two's complement integer with values in the
/// range -9223372036854775808 to +9223372036854775807.
///
/// Java equivalent of [Int64List].
extension type JLongArray._(JObject _$this) implements JObject {
  /// The type which includes information such as the signature of this class.
  static const JType<JLongArray> type = _$JLongArray$Type$();

  /// Creates a [JLongArray] of the given [length].
  ///
  /// The [length] must be a non-negative integer.
  factory JLongArray(int length) {
    RangeError.checkNotNegative(length);
    return JObject.fromReference(
      JGlobalReference(Jni.env.NewLongArray(length)),
    ) as JLongArray;
  }

  /// The number of elements in this array.
  int get length => Jni.env.GetArrayLength(reference.pointer);

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
    final buffer = allocator<Int64>(rangeLength);
    Jni.env.GetLongArrayRegion(reference.pointer, start, rangeLength, buffer);
    return buffer.asTypedList(rangeLength, finalizer: allocator._nativeFree);
  }

  void setRange(int start, int end, Iterable<int> iterable,
      [int skipCount = 0]) {
    RangeError.checkValidRange(start, end, length);
    final rangeLength = end - start;
    _allocate<Int64>(sizeOf<Int64>() * rangeLength, (ptr) {
      ptr
          .asTypedList(rangeLength)
          .setRange(0, rangeLength, iterable, skipCount);
      Jni.env.SetLongArrayRegion(reference.pointer, start, rangeLength, ptr);
    });
  }
}

final class _JLongArrayListView with ListMixin<int>, NonGrowableListMixin<int> {
  final JLongArray _jarray;

  _JLongArrayListView(this._jarray);

  @override
  int get length => _jarray.length;

  @override
  int operator [](int index) {
    return _jarray[index];
  }

  @override
  void operator []=(int index, int value) {
    _jarray[index] = value;
  }
}

extension JLongArrayToList on JLongArray {
  /// Returns a [List] view into this array.
  ///
  /// Any changes to this list will reflect in the original array as well.
  List<int> get asDartList => _JLongArrayListView(this);
}

final class _$JFloatArray$Type$ extends JType<JFloatArray> {
  const _$JFloatArray$Type$();

  @override
  String get signature => '[F';
}

/// A fixed-length array of Java Float.
///
/// Java equivalent of [Float32List].
extension type JFloatArray._(JObject _$this) implements JObject {
  /// The type which includes information such as the signature of this class.
  static const JType<JFloatArray> type = _$JFloatArray$Type$();

  /// Creates a [JFloatArray] of the given [length].
  ///
  /// The [length] must be a non-negative integer.
  factory JFloatArray(int length) {
    RangeError.checkNotNegative(length);
    return JObject.fromReference(
      JGlobalReference(Jni.env.NewFloatArray(length)),
    ) as JFloatArray;
  }

  /// The number of elements in this array.
  int get length => Jni.env.GetArrayLength(reference.pointer);

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
    final buffer = allocator<Float>(rangeLength);
    Jni.env.GetFloatArrayRegion(reference.pointer, start, rangeLength, buffer);
    return buffer.asTypedList(rangeLength, finalizer: allocator._nativeFree);
  }

  void setRange(int start, int end, Iterable<double> iterable,
      [int skipCount = 0]) {
    RangeError.checkValidRange(start, end, length);
    final rangeLength = end - start;
    _allocate<Float>(sizeOf<Float>() * rangeLength, (ptr) {
      ptr
          .asTypedList(rangeLength)
          .setRange(0, rangeLength, iterable, skipCount);
      Jni.env.SetFloatArrayRegion(reference.pointer, start, rangeLength, ptr);
    });
  }
}

final class _JFloatArrayListView
    with ListMixin<double>, NonGrowableListMixin<double> {
  final JFloatArray _jarray;

  _JFloatArrayListView(this._jarray);

  @override
  int get length => _jarray.length;

  @override
  double operator [](int index) {
    return _jarray[index];
  }

  @override
  void operator []=(int index, double value) {
    _jarray[index] = value;
  }
}

extension JFloatArrayToList on JFloatArray {
  /// Returns a [List] view into this array.
  ///
  /// Any changes to this list will reflect in the original array as well.
  List<double> get asDartList => _JFloatArrayListView(this);
}

final class _$JDoubleArray$Type$ extends JType<JDoubleArray> {
  const _$JDoubleArray$Type$();

  @override
  String get signature => '[D';
}

/// A fixed-length array of Java Double.
///
/// Java equivalent of [Float64List].
extension type JDoubleArray._(JObject _$this) implements JObject {
  /// The type which includes information such as the signature of this class.
  static const JType<JDoubleArray> type = _$JDoubleArray$Type$();

  /// Creates a [JDoubleArray] of the given [length].
  ///
  /// The [length] must be a non-negative integer.
  factory JDoubleArray(int length) {
    RangeError.checkNotNegative(length);
    return JObject.fromReference(
      JGlobalReference(Jni.env.NewDoubleArray(length)),
    ) as JDoubleArray;
  }

  /// The number of elements in this array.
  int get length => Jni.env.GetArrayLength(reference.pointer);

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
    final buffer = allocator<Double>(rangeLength);
    Jni.env.GetDoubleArrayRegion(reference.pointer, start, rangeLength, buffer);
    return buffer.asTypedList(rangeLength, finalizer: allocator._nativeFree);
  }

  void setRange(int start, int end, Iterable<double> iterable,
      [int skipCount = 0]) {
    RangeError.checkValidRange(start, end, length);
    final rangeLength = end - start;
    _allocate<Double>(sizeOf<Double>() * rangeLength, (ptr) {
      ptr
          .asTypedList(rangeLength)
          .setRange(0, rangeLength, iterable, skipCount);
      Jni.env.SetDoubleArrayRegion(reference.pointer, start, rangeLength, ptr);
    });
  }
}

final class _JDoubleArrayListView
    with ListMixin<double>, NonGrowableListMixin<double> {
  final JDoubleArray _jarray;

  _JDoubleArrayListView(this._jarray);

  @override
  int get length => _jarray.length;

  @override
  double operator [](int index) {
    return _jarray[index];
  }

  @override
  void operator []=(int index, double value) {
    _jarray[index] = value;
  }
}

extension JDoubleArrayToList on JDoubleArray {
  /// Returns a [List] view into this array.
  ///
  /// Any changes to this list will reflect in the original array as well.
  List<double> get asDartList => _JDoubleArrayListView(this);
}
