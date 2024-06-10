// ignore_for_file: non_constant_identifier_names, camel_case_types

// AUTO GENERATED FILE, DO NOT EDIT.
//
// Generated by `package:ffigen`.
// ignore_for_file: type=lint
import 'dart:ffi' as ffi;
import 'package:shared_bindings/generated/base_gen.dart' as imp1;

/// Bindings to `headers/a.h` with shared definitions from `headers/base.h`.
class NativeLibraryASharedB {
  /// Holds the symbol lookup function.
  final ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
      _lookup;

  /// The symbols are looked up in [dynamicLibrary].
  NativeLibraryASharedB(ffi.DynamicLibrary dynamicLibrary)
      : _lookup = dynamicLibrary.lookup;

  /// The symbols are looked up with [lookup].
  NativeLibraryASharedB.fromLookup(
      ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
          lookup)
      : _lookup = lookup;

  void a_func1() {
    return _a_func1();
  }

  late final _a_func1Ptr =
      _lookup<ffi.NativeFunction<ffi.Void Function()>>('a_func1');
  late final _a_func1 = _a_func1Ptr.asFunction<void Function()>();

  void a_func2(
    imp1.BaseStruct2 s,
    imp1.BaseUnion2 u,
    imp1.BaseTypedef2 t,
  ) {
    return _a_func2(
      s,
      u,
      t,
    );
  }

  late final _a_func2Ptr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(imp1.BaseStruct2, imp1.BaseUnion2,
              imp1.BaseTypedef2)>>('a_func2');
  late final _a_func2 = _a_func2Ptr.asFunction<
      void Function(imp1.BaseStruct2, imp1.BaseUnion2, imp1.BaseTypedef2)>();
}

final class A_Struct1 extends ffi.Struct {
  @ffi.Int()
  external int a;
}

final class A_Union1 extends ffi.Union {
  @ffi.Int()
  external int a;
}

enum A_Enum {
  A_ENUM_1(0),
  A_ENUM_2(1);

  final int value;
  const A_Enum(this.value);

  static A_Enum fromValue(int value) => switch (value) {
        0 => A_ENUM_1,
        1 => A_ENUM_2,
        _ => throw ArgumentError("Invalid value for A_Enum: $value"),
      };
}

const int BASE_MACRO_1 = 1;

const int A_MACRO_1 = 1;
