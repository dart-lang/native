// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';
import 'package:ffigenpad/src/header_parser/malloc.dart';
import 'clang_bindings/clang_bindings.dart' as clang;
import 'dart:convert' as convert;
import 'dart:js_interop';

export 'package:ffigen/src/header_parser/utils.dart'
    show
        commentPrefix,
        nesting,
        removeRawCommentMarkups,
        Stack,
        IncrementalNamer,
        Macro;

/// dart interop for emscripten's addFunction
@JS()
external int addFunction(JSExportedDartFunction func, String signature);

extension CXSourceRangeExt on Pointer<clang.CXSourceRange> {
  void dispose() {
    malloc.free(this);
  }
}

extension CXCursorExt on Pointer<clang.CXCursor> {
  /// Returns the kind int from [clang.CXCursorKind].
  int kind() {
    return clang.clang_getCursorKind_wrap(this).index;
  }

  /// Name of the cursor (E.g function name, Struct name, Parameter name).
  String spelling() {
    return clang.clang_getCursorSpelling_wrap(this).toStringAndDispose();
  }

  /// Spelling for a [clang.CXCursorKind], useful for debug purposes.
  String kindSpelling() {
    return clang
        .clang_getCursorKindSpelling_wrap(clang.clang_getCursorKind_wrap(this))
        .toStringAndDispose();
  }

  /// Type associated with the pointer if any. Type will have kind
  /// [clang.CXTypeKind.CXType_Invalid] otherwise.
  Pointer<clang.CXType> type() {
    return clang.clang_getCursorType_wrap(this);
  }

  /// Determine whether the given cursor
  /// represents an anonymous record declaration.
  bool isAnonymousRecordDecl() {
    return clang.clang_Cursor_isAnonymousRecordDecl_wrap(this) == 1;
  }
}

extension CXStringExt on Pointer<clang.CXString> {
  void dispose() {
    clang.clang_disposeString_wrap(this);
  }

  /// Converts CXString to dart string and disposes CXString.
  String toStringAndDispose() {
    final codeUnits = clang.clang_getCString_wrap(this);
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

extension CXTypeExt on Pointer<clang.CXType> {
  String spelling() {
    return clang.clang_getTypeSpelling_wrap(this).toStringAndDispose();
  }

  int alignment() {
    return clang.clang_Type_getAlignOf_wrap(this);
  }

  bool get isConstQualified {
    return clang.clang_isConstQualifiedType_wrap(this) != 0;
  }
}

extension StringUtf8Pointer on String {
  /// Converts string into an array of bytes and allocates it in WASM memory
  Pointer<Uint8> toNativeUint8() {
    final units = convert.utf8.encode(this);
    final result = malloc<Uint8>(units.length + 1);
    for (int i = 0; i < units.length; i++) {
      result[i] = units[i];
    }
    result[units.length] = 0;
    return result;
  }
}

/// Converts a [List<String>] to [Pointer<Pointer<Uint8>>].
Pointer<Pointer<Uint8>> createDynamicStringArray(List<String> list) {
  final nativeCmdArgs = malloc<Pointer<Uint8>>(list.length);

  for (var i = 0; i < list.length; i++) {
    nativeCmdArgs[i] = list[i].toNativeUint8();
  }

  return nativeCmdArgs;
}

extension DynamicCStringArray on Pointer<Pointer<Uint8>> {
  // Properly disposes a Pointer<Pointer<Uint8>, ensure that sure length is
  // correct.
  void dispose(int length) {
    for (var i = 0; i < length; i++) {
      malloc.free(this[i]);
    }
    malloc.free(this);
  }
}
