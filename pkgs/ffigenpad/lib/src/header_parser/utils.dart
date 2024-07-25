// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import "dart:ffi" as ffi;
import 'package:ffigenpad/src/header_parser/malloc.dart';

import 'clang_bindings/clang_bindings.dart' as clang_types;
import 'dart:convert' as convert;
import 'dart:js_interop';

/// dart interop for emscripten's addFunction
@JS()
external int addFunction(JSExportedDartFunction func, String signature);

extension CXStringExt on ffi.Pointer<clang_types.CXString> {
  void dispose() {
    clang_types.clang_disposeString_wrap(this);
  }

  /// Converts CXString to dart string and disposes CXString.
  String toStringAndDispose() {
    final codeUnits = clang_types.clang_getCString_wrap(this);
    List<int> output = [];
    int length = 0;
    while (codeUnits[length] != 0) {
      output.add(codeUnits[length]);
      length++;
    }
    dispose();
    return convert.utf8.decode(output);
  }
}

extension StringUtf8Pointer on String {
  /// Converts string into an array of bytes and allocates it in WASM memory
  ffi.Pointer<ffi.Uint8> toNativeUint8() {
    final units = convert.utf8.encode(this);
    final result = malloc<ffi.Uint8>(units.length + 1);
    for (int i = 0; i < units.length; i++) {
      result[i] = units[i];
    }
    result[units.length] = 0;
    return result;
  }
}
