// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:test/test.dart';

Pointer<Uint8> _bytesFromList(List<int> ints) {
  // ignore: omit_local_variable_types
  final Pointer<Uint8> ptr = calloc(ints.length);
  final list = ptr.asTypedList(ints.length);
  list.setAll(0, ints);
  return ptr;
}

void main() {
  test('toUtf8 ASCII', () {
    final start = 'Hello World!\n';
    final converted = start.toNativeUtf8().cast<Uint8>();
    final end = converted.asTypedList(start.length + 1);
    final matcher =
        equals([72, 101, 108, 108, 111, 32, 87, 111, 114, 108, 100, 33, 10, 0]);
    expect(end, matcher);
    calloc.free(converted);
  });

  test('fromUtf8 ASCII', () {
    final utf8 = _bytesFromList(
            [72, 101, 108, 108, 111, 32, 87, 111, 114, 108, 100, 33, 10, 0])
        .cast<Utf8>();
    final end = utf8.toDartString();
    expect(end, 'Hello World!\n');
  });

  test('toUtf8 emoji', () {
    final start = '😎👿💬';
    final converted = start.toNativeUtf8().cast<Utf8>();
    final length = converted.length;
    final end = converted.cast<Uint8>().asTypedList(length + 1);
    final matcher =
        equals([240, 159, 152, 142, 240, 159, 145, 191, 240, 159, 146, 172, 0]);
    expect(end, matcher);
    calloc.free(converted);
  });

  test('formUtf8 emoji', () {
    final utf8 = _bytesFromList(
            [240, 159, 152, 142, 240, 159, 145, 191, 240, 159, 146, 172, 0])
        .cast<Utf8>();
    final end = utf8.toDartString();
    expect(end, '😎👿💬');
  });

  test('fromUtf8 invalid', () {
    final utf8 = _bytesFromList([0x80, 0x00]).cast<Utf8>();
    expect(utf8.toDartString, throwsA(isFormatException));
  });

  test('fromUtf8 ASCII with length', () {
    final utf8 = _bytesFromList(
            [72, 101, 108, 108, 111, 32, 87, 111, 114, 108, 100, 33, 10, 0])
        .cast<Utf8>();
    final end = utf8.toDartString(length: 5);
    expect(end, 'Hello');
  });

  test('fromUtf8 emoji with length', () {
    final utf8 = _bytesFromList(
            [240, 159, 152, 142, 240, 159, 145, 191, 240, 159, 146, 172, 0])
        .cast<Utf8>();
    final end = utf8.toDartString(length: 4);
    expect(end, '😎');
  });

  test('fromUtf8 with zero length', () {
    final utf8 = _bytesFromList(
            [72, 101, 108, 108, 111, 32, 87, 111, 114, 108, 100, 33, 10, 0])
        .cast<Utf8>();
    final end = utf8.toDartString(length: 0);
    expect(end, '');
  });

  test('fromUtf8 with negative length', () {
    final utf8 = _bytesFromList(
            [72, 101, 108, 108, 111, 32, 87, 111, 114, 108, 100, 33, 10, 0])
        .cast<Utf8>();
    expect(() => utf8.toDartString(length: -1), throwsRangeError);
  });

  test('fromUtf8 with length and containing a zero byte', () {
    final utf8 = _bytesFromList(
            [72, 101, 108, 108, 111, 0, 87, 111, 114, 108, 100, 33, 10])
        .cast<Utf8>();
    final end = utf8.toDartString(length: 13);
    expect(end, 'Hello\x00World!\n');
  });

  test('length', () {
    final string = 'Hello';
    final utf8Pointer = string.toNativeUtf8();
    expect(utf8Pointer.length, 5);
    calloc.free(utf8Pointer);
  });

  test('nullptr.toDartString()', () {
    final Pointer<Utf8> utf8 = nullptr;
    expect(utf8.toDartString, throwsUnsupportedError);
  });

  test('nullptr.length', () {
    final Pointer<Utf8> utf8 = nullptr;
    expect(() => utf8.length, throwsUnsupportedError);
  });

  test('zero terminated', () {
    final string = 'Hello';
    final utf8Pointer = string.toNativeUtf8();
    final charPointer = utf8Pointer.cast<Char>();
    expect(charPointer[utf8Pointer.length], 0);
    calloc.free(utf8Pointer);
  });
}
