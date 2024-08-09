// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Provides an allocator that uses the malloc and free functions exported by emscripten.
library;

import 'dart:ffi' as ffi;
import 'dart:js_interop';

@ffi.Native<ffi.Pointer<ffi.Void> Function(ffi.Int)>(symbol: 'malloc')
external ffi.Pointer<ffi.Void> _wasmAllocate(
  int size,
);

@ffi.Native<ffi.Void Function(ffi.Pointer<ffi.Void>)>(symbol: 'free')
external void _wasmDeallocate(
  ffi.Pointer<ffi.Void> ptr,
);

class _WasmAllocator implements ffi.Allocator {
  @override
  ffi.Pointer<T> allocate<T extends ffi.NativeType>(
    int byteCount, {
    int? alignment,
  }) {
    return _wasmAllocate(byteCount).cast<T>();
  }

  @override
  void free(ffi.Pointer<ffi.NativeType> pointer) {
    _wasmDeallocate(pointer.cast());
  }
}

final calloc = _WasmAllocator();

@JS()
external int addFunction(JSExportedDartFunction fp, String signature);

@JS()
external void removeFunction(int index);
