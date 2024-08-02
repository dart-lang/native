// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigenpad/src/header_parser/calloc.dart';
import 'package:ffigenpad/src/header_parser/utils.dart';
import 'dart:ffi' as ffi;
import 'package:ffigenpad/src/header_parser/clang_bindings/clang_bindings.dart';

void main() {
  final index = clang_createIndex(1, 1);
  final filename = "./test.c".toNativeUint8();
  final args = ["-v"];
  final argsPointer = calloc<ffi.Pointer<ffi.Uint8>>(args.length);
  for (int i = 0; i < args.length; i++) {
    argsPointer[i] = args[i].toNativeUint8();
  }
  final translationUnit = clang_parseTranslationUnit(
    index,
    filename,
    argsPointer,
    1,
    ffi.nullptr,
    0,
    0,
  );
  final root = clang_getTranslationUnitCursor_wrap(translationUnit);
  root.printAst();
  calloc.free(root);
  clang_disposeTranslationUnit(translationUnit);
  clang_disposeIndex(index);
}
