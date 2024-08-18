// ignore_for_file: camel_case_types, non_constant_identifier_names

// AUTO GENERATED FILE, DO NOT EDIT.
//
// Generated by `package:ffigen`.
// ignore_for_file: type=lint
import 'dart:ffi' as ffi;

/// Native tests.
class NativeLibrary {
  /// Holds the symbol lookup function.
  final ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
      _lookup;

  /// The symbols are looked up in [dynamicLibrary].
  NativeLibrary(ffi.DynamicLibrary dynamicLibrary)
      : _lookup = dynamicLibrary.lookup;

  /// The symbols are looked up with [lookup].
  NativeLibrary.fromLookup(
      ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
          lookup)
      : _lookup = lookup;

  bool Function1Bool(
    bool x,
  ) {
    return _Function1Bool(
      x,
    );
  }

  late final _Function1BoolPtr =
      _lookup<ffi.NativeFunction<ffi.Bool Function(ffi.Bool)>>('Function1Bool');
  late final _Function1Bool =
      _Function1BoolPtr.asFunction<bool Function(bool)>();

  int Function1Uint8(
    int x,
  ) {
    return _Function1Uint8(
      x,
    );
  }

  late final _Function1Uint8Ptr =
      _lookup<ffi.NativeFunction<ffi.Uint8 Function(ffi.Uint8)>>(
          'Function1Uint8');
  late final _Function1Uint8 =
      _Function1Uint8Ptr.asFunction<int Function(int)>();

  int Function1Uint16(
    int x,
  ) {
    return _Function1Uint16(
      x,
    );
  }

  late final _Function1Uint16Ptr =
      _lookup<ffi.NativeFunction<ffi.Uint16 Function(ffi.Uint16)>>(
          'Function1Uint16');
  late final _Function1Uint16 =
      _Function1Uint16Ptr.asFunction<int Function(int)>();

  int Function1Uint32(
    int x,
  ) {
    return _Function1Uint32(
      x,
    );
  }

  late final _Function1Uint32Ptr =
      _lookup<ffi.NativeFunction<ffi.Uint32 Function(ffi.Uint32)>>(
          'Function1Uint32');
  late final _Function1Uint32 =
      _Function1Uint32Ptr.asFunction<int Function(int)>();

  int Function1Uint64(
    int x,
  ) {
    return _Function1Uint64(
      x,
    );
  }

  late final _Function1Uint64Ptr =
      _lookup<ffi.NativeFunction<ffi.Uint64 Function(ffi.Uint64)>>(
          'Function1Uint64');
  late final _Function1Uint64 =
      _Function1Uint64Ptr.asFunction<int Function(int)>();

  int Function1Int8(
    int x,
  ) {
    return _Function1Int8(
      x,
    );
  }

  late final _Function1Int8Ptr =
      _lookup<ffi.NativeFunction<ffi.Int8 Function(ffi.Int8)>>('Function1Int8');
  late final _Function1Int8 = _Function1Int8Ptr.asFunction<int Function(int)>();

  int Function1Int16(
    int x,
  ) {
    return _Function1Int16(
      x,
    );
  }

  late final _Function1Int16Ptr =
      _lookup<ffi.NativeFunction<ffi.Int16 Function(ffi.Int16)>>(
          'Function1Int16');
  late final _Function1Int16 =
      _Function1Int16Ptr.asFunction<int Function(int)>();

  int Function1Int32(
    int x,
  ) {
    return _Function1Int32(
      x,
    );
  }

  late final _Function1Int32Ptr =
      _lookup<ffi.NativeFunction<ffi.Int32 Function(ffi.Int32)>>(
          'Function1Int32');
  late final _Function1Int32 =
      _Function1Int32Ptr.asFunction<int Function(int)>();

  int Function1Int64(
    int x,
  ) {
    return _Function1Int64(
      x,
    );
  }

  late final _Function1Int64Ptr =
      _lookup<ffi.NativeFunction<ffi.Int64 Function(ffi.Int64)>>(
          'Function1Int64');
  late final _Function1Int64 =
      _Function1Int64Ptr.asFunction<int Function(int)>();

  int Function1IntPtr(
    int x,
  ) {
    return _Function1IntPtr(
      x,
    );
  }

  late final _Function1IntPtrPtr =
      _lookup<ffi.NativeFunction<ffi.IntPtr Function(ffi.IntPtr)>>(
          'Function1IntPtr');
  late final _Function1IntPtr =
      _Function1IntPtrPtr.asFunction<int Function(int)>();

  int Function1UintPtr(
    int x,
  ) {
    return _Function1UintPtr(
      x,
    );
  }

  late final _Function1UintPtrPtr =
      _lookup<ffi.NativeFunction<ffi.UintPtr Function(ffi.UintPtr)>>(
          'Function1UintPtr');
  late final _Function1UintPtr =
      _Function1UintPtrPtr.asFunction<int Function(int)>();

  double Function1Float(
    double x,
  ) {
    return _Function1Float(
      x,
    );
  }

  late final _Function1FloatPtr =
      _lookup<ffi.NativeFunction<ffi.Float Function(ffi.Float)>>(
          'Function1Float');
  late final _Function1Float =
      _Function1FloatPtr.asFunction<double Function(double)>();

  double Function1Double(
    double x,
  ) {
    return _Function1Double(
      x,
    );
  }

  late final _Function1DoublePtr =
      _lookup<ffi.NativeFunction<ffi.Double Function(ffi.Double)>>(
          'Function1Double');
  late final _Function1Double =
      _Function1DoublePtr.asFunction<double Function(double)>();

  ffi.Pointer<Struct1> getStruct1() {
    return _getStruct1();
  }

  late final _getStruct1Ptr =
      _lookup<ffi.NativeFunction<ffi.Pointer<Struct1> Function()>>(
          'getStruct1');
  late final _getStruct1 =
      _getStruct1Ptr.asFunction<ffi.Pointer<Struct1> Function()>();

  Struct3 Function1StructReturnByValue(
    int a,
    int b,
    int c,
  ) {
    return _Function1StructReturnByValue(
      a,
      b,
      c,
    );
  }

  late final _Function1StructReturnByValuePtr =
      _lookup<ffi.NativeFunction<Struct3 Function(ffi.Int, ffi.Int, ffi.Int)>>(
          'Function1StructReturnByValue');
  late final _Function1StructReturnByValue = _Function1StructReturnByValuePtr
      .asFunction<Struct3 Function(int, int, int)>();

  int Function1StructPassByValue(
    Struct3 sum_a_b_c,
  ) {
    return _Function1StructPassByValue(
      sum_a_b_c,
    );
  }

  late final _Function1StructPassByValuePtr =
      _lookup<ffi.NativeFunction<ffi.Int Function(Struct3)>>(
          'Function1StructPassByValue');
  late final _Function1StructPassByValue =
      _Function1StructPassByValuePtr.asFunction<int Function(Struct3)>();

  Enum1 funcWithEnum1(
    Enum1 value,
  ) {
    return Enum1.fromValue(_funcWithEnum1(
      value.value,
    ));
  }

  late final _funcWithEnum1Ptr =
      _lookup<ffi.NativeFunction<ffi.UnsignedInt Function(ffi.UnsignedInt)>>(
          'funcWithEnum1');
  late final _funcWithEnum1 = _funcWithEnum1Ptr.asFunction<int Function(int)>();

  int funcWithEnum2(
    int value,
  ) {
    return _funcWithEnum2(
      value,
    );
  }

  late final _funcWithEnum2Ptr =
      _lookup<ffi.NativeFunction<ffi.UnsignedInt Function(ffi.UnsignedInt)>>(
          'funcWithEnum2');
  late final _funcWithEnum2 = _funcWithEnum2Ptr.asFunction<int Function(int)>();

  StructWithEnums getStructWithEnums() {
    return _getStructWithEnums();
  }

  late final _getStructWithEnumsPtr =
      _lookup<ffi.NativeFunction<StructWithEnums Function()>>(
          'getStructWithEnums');
  late final _getStructWithEnums =
      _getStructWithEnumsPtr.asFunction<StructWithEnums Function()>();
}

final class Struct1 extends ffi.Struct {
  @ffi.Int8()
  external int a;

  @ffi.Array.multi([3, 1, 2])
  external ffi.Array<ffi.Array<ffi.Array<ffi.Int32>>> data;
}

final class Struct3 extends ffi.Struct {
  @ffi.Int()
  external int a;

  @ffi.Int()
  external int b;

  @ffi.Int()
  external int c;
}

enum Enum1 {
  enum1Value1(0),
  enum1Value2(1),
  enum1Value3(2);

  final int value;
  const Enum1(this.value);

  static Enum1 fromValue(int value) => switch (value) {
        0 => enum1Value1,
        1 => enum1Value2,
        2 => enum1Value3,
        _ => throw ArgumentError("Unknown value for Enum1: $value"),
      };
}

abstract class Enum2 {
  static const enum2Value1 = 0;
  static const enum2Value2 = 1;
  static const enum2Value3 = 2;
}

final class StructWithEnums extends ffi.Struct {
  @ffi.UnsignedInt()
  external int _enum1;

  Enum1 get enum1 => Enum1.fromValue(_enum1);

  @ffi.Array.multi([5])
  external ffi.Array<ffi.UnsignedInt> enum1Array;

  external ffi.Pointer<ffi.UnsignedInt> enum1Pointer;

  @ffi.UnsignedInt()
  external int enum2;

  @ffi.Array.multi([5])
  external ffi.Array<ffi.UnsignedInt> enum2Array;

  external ffi.Pointer<ffi.UnsignedInt> enum2Pointer;
}
