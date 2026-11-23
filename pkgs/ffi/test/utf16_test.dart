// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:test/test.dart';

const _isWasm = bool.fromEnvironment('dart.tool.dart2wasm');

List<int> _readCodeUnits(Pointer<Uint16> pointer, int length) => _isWasm
    ? [for (var i = 0; i < length; i++) pointer[i]]
    : pointer.asTypedList(length);

void main() {
  test('toUtf16 ASCII', () {
    final start = 'Hello World!\n';
    final converted = start.toNativeUtf16().cast<Uint16>();
    final end = _readCodeUnits(converted, start.codeUnits.length + 1);
    final matcher = equals(start.codeUnits.toList()..add(0));
    expect(end, matcher);
    calloc.free(converted);
  });

  test('toUtf16 emoji', () {
    final start = '😎';
    final converted = start.toNativeUtf16().cast();
    final length = start.codeUnits.length;
    final end = _readCodeUnits(converted.cast<Uint16>(), length + 1);
    final matcher = equals(start.codeUnits.toList()..add(0));
    expect(end, matcher);
    calloc.free(converted);
  });

  test('from Utf16 ASCII', () {
    final string = 'Hello World!\n';
    final utf16Pointer = string.toNativeUtf16();
    final stringAgain = utf16Pointer.toDartString();
    expect(stringAgain, string);
    calloc.free(utf16Pointer);
  });

  test('from Utf16 emoji', () {
    final string = '😎';
    final utf16Pointer = string.toNativeUtf16();
    final stringAgain = utf16Pointer.toDartString();
    expect(stringAgain, string);
    calloc.free(utf16Pointer);
  });

  test('zero bytes', () {
    final string = 'Hello\x00World!\n';
    final utf16Pointer = string.toNativeUtf16();
    final stringAgain = utf16Pointer.toDartString(length: 13);
    expect(stringAgain, string);
    calloc.free(utf16Pointer);
  });

  test('length', () {
    final string = 'Hello';
    final utf16Pointer = string.toNativeUtf16();
    expect(utf16Pointer.length, 5);
    calloc.free(utf16Pointer);
  });

  test('fromUtf8 with negative length', () {
    final string = 'Hello';
    final utf16 = string.toNativeUtf16();
    expect(() => utf16.toDartString(length: -1), throwsRangeError);
    calloc.free(utf16);
  });

  test('nullptr.toDartString()', () {
    final Pointer<Utf16> utf16 = nullptr;
    expect(utf16.toDartString, throwsUnsupportedError);
  });

  test('nullptr.length', () {
    final Pointer<Utf16> utf16 = nullptr;
    expect(() => utf16.length, throwsUnsupportedError);
  });
}
