// AUTO GENERATED FILE, DO NOT EDIT.
//
// Generated by `package:ffigen`.
// ignore_for_file: type=lint
import 'dart:ffi' as ffi;

enum Simple {
  A0(0);

  final int value;
  const Simple(this.value);

  static Simple fromValue(int value) => switch (value) {
        0 => A0,
        _ => throw ArgumentError("Unknown value for Simple: $value"),
      };
}

enum SimpleWithNegative {
  B0(0),
  B1(-1000);

  final int value;
  const SimpleWithNegative(this.value);

  static SimpleWithNegative fromValue(int value) => switch (value) {
        0 => B0,
        -1000 => B1,
        _ =>
          throw ArgumentError("Unknown value for SimpleWithNegative: $value"),
      };
}

enum PositiveIntOverflow {
  C0(-2147483607);

  final int value;
  const PositiveIntOverflow(this.value);

  static PositiveIntOverflow fromValue(int value) => switch (value) {
        -2147483607 => C0,
        _ =>
          throw ArgumentError("Unknown value for PositiveIntOverflow: $value"),
      };
}

enum ExplicitType {
  E0(0),
  E1(1);

  final int value;
  const ExplicitType(this.value);

  static ExplicitType fromValue(int value) => switch (value) {
        0 => E0,
        1 => E1,
        _ => throw ArgumentError("Unknown value for ExplicitType: $value"),
      };
}

enum ExplicitTypeWithOverflow {
  F0(0),
  F1(-32727);

  final int value;
  const ExplicitTypeWithOverflow(this.value);

  static ExplicitTypeWithOverflow fromValue(int value) => switch (value) {
        0 => F0,
        -32727 => F1,
        _ => throw ArgumentError(
            "Unknown value for ExplicitTypeWithOverflow: $value"),
      };
}

final class Test extends ffi.Struct {
  @ffi.UnsignedInt()
  external int simple;

  external ffi.Pointer<ffi.Int> simpleWithNegative;

  @ffi.Array.multi([5])
  external ffi.Array<ffi.Int16> explicitType;

  @ffi.UnsignedInt()
  external int simpleWithAnonymousEnum;

  @ffi.Int()
  external int simpleNegativeWithAnonymousEnum;

  @ffi.Int8()
  external int explicitTypeWithAnonymousEnum;

  @ffi.Int()
  external int positiveIntOverflow;

  @ffi.Uint16()
  external int explicitTypeWithOverflow;
}

const int ANONYMOUS1 = 0;

const int ANONYMOUS2 = -1000;

const int ANONYMOUS3 = 0;
