// ignore_for_file: deprecated_member_use

// AUTO GENERATED FILE, DO NOT EDIT.
//
// Generated by `package:ffigen`.
// ignore_for_file: type=lint
import 'dart:ffi' as ffi;

/// Adds 2 integers.
@ffi.Native<ffi.Int Function(ffi.Int, ffi.Int)>(
    symbol: 'sum', assetId: 'package:ffinative_example/generated_bindings.dart')
external int sum(
  int a,
  int b,
);

/// Subtracts 2 integers.
@ffi.Native<ffi.Int Function(ffi.Int, ffi.Int)>(
    symbol: 'subtract',
    assetId: 'package:ffinative_example/generated_bindings.dart')
external int subtract(
  int a,
  int b,
);

/// Multiplies 2 integers, returns pointer to an integer,.
@ffi.Native<ffi.Pointer<ffi.Int> Function(ffi.Int, ffi.Int)>(
    symbol: 'multiply',
    assetId: 'package:ffinative_example/generated_bindings.dart')
external ffi.Pointer<ffi.Int> multiply(
  int a,
  int b,
);

/// Divides 2 integers, returns pointer to a float.
@ffi.Native<ffi.Pointer<ffi.Float> Function(ffi.Int, ffi.Int)>(
    symbol: 'divide',
    assetId: 'package:ffinative_example/generated_bindings.dart')
external ffi.Pointer<ffi.Float> divide(
  int a,
  int b,
);

/// Divides 2 floats, returns a pointer to double.
@ffi.Native<ffi.Pointer<ffi.Double> Function(ffi.Float, ffi.Float)>(
    symbol: 'dividePrecision',
    assetId: 'package:ffinative_example/generated_bindings.dart')
external ffi.Pointer<ffi.Double> dividePrecision(
  double a,
  double b,
);

@ffi.Array(10)
@ffi.Native<ffi.Array<ffi.Int>>()
external ffi.Array<ffi.Int> array;

/// Version of the native C library
@ffi.Native<ffi.Pointer<ffi.Char>>()
external final ffi.Pointer<ffi.Char> library_version;
const _SymbolAddresses addresses = _SymbolAddresses();

class _SymbolAddresses {
  const _SymbolAddresses();
  ffi.Pointer<ffi.NativeFunction<ffi.Int Function(ffi.Int, ffi.Int)>> get sum =>
      ffi.Native.addressOf(sum);
  ffi.Pointer<ffi.Pointer<ffi.Char>> get library_version =>
      ffi.Native.addressOf(library_version);
}
