// ignore_for_file: non_constant_identifier_names, camel_case_types

// AUTO GENERATED FILE, DO NOT EDIT.
//
// Generated by `package:ffigen`.
// ignore_for_file: type=lint
import 'dart:ffi' as ffi;

/// Bindings to `headers/base.h`.
class NativeLibraryBase {
  /// Holds the symbol lookup function.
  final ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
  _lookup;

  /// The symbols are looked up in [dynamicLibrary].
  NativeLibraryBase(ffi.DynamicLibrary dynamicLibrary)
    : _lookup = dynamicLibrary.lookup;

  /// The symbols are looked up with [lookup].
  NativeLibraryBase.fromLookup(
    ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName) lookup,
  ) : _lookup = lookup;

  void base_func1(BaseTypedef1 t1, BaseTypedef2 t2) {
    return _base_func1(t1, t2);
  }

  late final _base_func1Ptr =
      _lookup<
        ffi.NativeFunction<ffi.Void Function(BaseTypedef1, BaseTypedef2)>
      >('base_func1');
  late final _base_func1 = _base_func1Ptr
      .asFunction<void Function(BaseTypedef1, BaseTypedef2)>();
}

final class BaseStruct1 extends ffi.Struct {
  @ffi.Int()
  external int a;
}

final class BaseUnion1 extends ffi.Union {
  @ffi.Int()
  external int a;
}

final class BaseStruct2 extends ffi.Struct {
  @ffi.Int()
  external int a;
}

final class BaseUnion2 extends ffi.Union {
  @ffi.Int()
  external int a;
}

typedef BaseTypedef1 = BaseStruct1;
typedef BaseTypedef2 = BaseStruct2;
typedef BaseNativeTypedef1 = ffi.Int;
typedef DartBaseNativeTypedef1 = int;
typedef BaseNativeTypedef2 = BaseNativeTypedef1;
typedef BaseNativeTypedef3 = BaseNativeTypedef2;

enum BaseEnum {
  BASE_ENUM_1(0),
  BASE_ENUM_2(1);

  final int value;
  const BaseEnum(this.value);

  static BaseEnum fromValue(int value) => switch (value) {
    0 => BASE_ENUM_1,
    1 => BASE_ENUM_2,
    _ => throw ArgumentError("Unknown value for BaseEnum: $value"),
  };
}

const int BASE_MACRO_1 = 1;
