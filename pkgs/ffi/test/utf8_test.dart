// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:ffi/ffi.dart';

Pointer<Uint8> _bytesFromList(List<int> ints) {
  final Pointer<Uint8> ptr = allocate(count: ints.length);
  final Uint8List list = ptr.asTypedList(ints.length);
  list.setAll(0, ints);
  return ptr;
}

main() {
  test("toUtf8 ASCII", () {
    final String start = "Hello World!\n";
    final Pointer<Uint8> converted = Utf8.toUtf8(start).cast();
    final Uint8List end = converted.asTypedList(start.length + 1);
    final matcher =
        equals([72, 101, 108, 108, 111, 32, 87, 111, 114, 108, 100, 33, 10, 0]);
    expect(end, matcher);
    free(converted);
  });

  test("fromUtf8 ASCII", () {
    final Pointer<Utf8> utf8 = _bytesFromList(
        [72, 101, 108, 108, 111, 32, 87, 111, 114, 108, 100, 33, 10, 0]).cast();
    final String end = Utf8.fromUtf8(utf8);
    expect(end, "Hello World!\n");
  });

  test("toUtf8 emoji", () {
    final String start = "😎👿💬";
    final Pointer<Utf8> converted = Utf8.toUtf8(start).cast();
    final int length = Utf8.strlen(converted);
    final Uint8List end = converted.cast<Uint8>().asTypedList(length + 1);
    final matcher =
        equals([240, 159, 152, 142, 240, 159, 145, 191, 240, 159, 146, 172, 0]);
    expect(end, matcher);
    free(converted);
  });

  test("formUtf8 emoji", () {
    final Pointer<Utf8> utf8 = _bytesFromList(
        [240, 159, 152, 142, 240, 159, 145, 191, 240, 159, 146, 172, 0]).cast();
    final String end = Utf8.fromUtf8(utf8);
    expect(end, "😎👿💬");
  });

  test("fromUtf8 invalid", () {
    final Pointer<Utf8> utf8 = _bytesFromList([0x80, 0x00]).cast();
    expect(() => Utf8.fromUtf8(utf8), throwsA(isFormatException));
  });
}
