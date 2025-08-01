// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// AUTO GENERATED FILE, DO NOT EDIT.
//
// Generated by `package:ffigen`.
// ignore_for_file: type=lint
import 'dart:ffi' as ffi;

class Bindings {
  /// Holds the symbol lookup function.
  final ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
  _lookup;

  /// The symbols are looked up in [dynamicLibrary].
  Bindings(ffi.DynamicLibrary dynamicLibrary) : _lookup = dynamicLibrary.lookup;

  /// The symbols are looked up with [lookup].
  Bindings.fromLookup(
    ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName) lookup,
  ) : _lookup = lookup;

  ffi.Pointer<SomeStruct> someFunc(ffi.Pointer<ffi.Pointer<SomeStruct>> some) {
    return _someFunc(some);
  }

  late final _someFuncPtr =
      _lookup<
        ffi.NativeFunction<
          ffi.Pointer<SomeStruct> Function(ffi.Pointer<ffi.Pointer<SomeStruct>>)
        >
      >('someFunc');
  late final _someFunc = _someFuncPtr
      .asFunction<
        ffi.Pointer<SomeStruct> Function(ffi.Pointer<ffi.Pointer<SomeStruct>>)
      >();
}

final class SomeStruct extends ffi.Struct {
  @ffi.Int32()
  external int a;

  @ffi.Double()
  external double b;

  @ffi.Uint8()
  external int c;
}
