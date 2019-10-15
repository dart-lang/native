// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:ffi/ffi.dart';

main() {
  test("toUtf16 ASCII", () {
    final String start = "Hello World!\n";
    final Pointer<Uint16> converted = Utf16.toUtf16(start).cast();
    final Uint16List end = converted.asTypedList(start.codeUnits.length + 1);
    final matcher = equals(start.codeUnits.toList()..add(0));
    expect(end, matcher);
    free(converted);
  });

  test("toUtf16 emoji", () {
    final String start = "😎";
    final Pointer<Utf16> converted = Utf16.toUtf16(start).cast();
    final int length = start.codeUnits.length;
    final Uint16List end = converted.cast<Uint16>().asTypedList(length + 1);
    final matcher = equals(start.codeUnits.toList()..add(0));
    expect(end, matcher);
    free(converted);
  });
}
