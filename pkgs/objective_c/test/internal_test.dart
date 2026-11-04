// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')
library;

import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:objective_c/objective_c.dart';
import 'package:objective_c/src/internal.dart'
    show getClass, isValidBlock, isValidObject;
import 'package:objective_c/src/objective_c_bindings_generated.dart'
    show ObjCBlock_ffiVoid_ffiVoid_NSStream_NSStreamEvent;
import 'package:objective_c/src/runtime_bindings_generated.dart'
    show NSConcreteGlobalBlock, NSConcreteStackBlock, getObjectClass;
import 'package:test/test.dart';

void main() {
  group('isValidObject', () {
    test('valid objects', () {
      final obj = NSObject();
      expect(isValidObject(obj.ref.pointer), isTrue);
      expect(isValidBlock(obj.ref.pointer.cast()), isFalse);

      final str = 'Hello'.toNSString();
      expect(isValidObject(str.ref.pointer), isTrue);
      expect(isValidBlock(str.ref.pointer.cast()), isFalse);

      final num = 123.toNSNumber();
      expect(isValidObject(num.ref.pointer), isTrue);
      expect(isValidBlock(num.ref.pointer.cast()), isFalse);
    });

    test('null pointer', () {
      expect(isValidObject(nullptr), isFalse);
      expect(isValidBlock(nullptr), isFalse);
    });

    test('zeroed memory', () {
      final ptr = calloc<Uint64>();
      expect(isValidObject(ptr.cast()), isFalse);
      expect(isValidBlock(ptr.cast()), isFalse);
      calloc.free(ptr);
    });

    test('block pointer', () {
      final block =
          ObjCBlock_ffiVoid_ffiVoid_NSStream_NSStreamEvent.fromFunction(
            (_, _, _) {},
          );
      expect(isValidBlock(block.ref.pointer), isTrue);
      expect(isValidObject(block.ref.pointer.cast()), isTrue);

      final obj = ObjCObject(
        block.ref.pointer.cast(),
        retain: true,
        release: true,
      );
      expect(obj.ref.pointer, block.ref.pointer.cast());

      final rawBlock = calloc<ObjCBlockImpl>();
      for (final isa in [
        Native.addressOf<Array<Pointer<Void>>>(NSConcreteGlobalBlock),
        Native.addressOf<Array<Pointer<Void>>>(NSConcreteStackBlock),
      ]) {
        rawBlock.ref.isa = isa.cast();
        expect(isValidBlock(rawBlock), isTrue);
        expect(isValidObject(rawBlock.cast()), isTrue);
      }
      calloc.free(rawBlock);
    });

    test('class pointer', () {
      final clazz = getClass('NSObject');
      expect(isValidObject(clazz), isTrue);
      expect(isValidObject(getObjectClass(clazz)), isTrue);

      final clazzObj = NSObject.class$();
      expect(isValidObject(clazzObj.ref.pointer), isTrue);
    });

    test('c string in heap memory', () {
      final strPtr = 'not an objc object'.toNativeUtf8();
      final res = isValidObject(strPtr.cast());
      calloc.free(strPtr);
      expect(res, isFalse);
    });

    test('garbage memory', () {
      final ptr = calloc<Uint64>();
      for (final val in [
        1,
        2,
        0x1234,
        0x12345678,
        0xdeadbeef,
        0xdeadbeefcafebabe,
        0xffffffffffffffff,
      ]) {
        ptr.value = val;
        expect(
          isValidObject(ptr.cast()),
          isFalse,
          reason: 'val: 0x${val.toRadixString(16)}',
        );
      }
      calloc.free(ptr);
    });

    test('unmapped pointer', () {
      for (final addr in [
        2,
        0x1234,
        0x12345678,
        0xdeadbeef,
        0xffffffffffffffff,
      ]) {
        expect(
          isValidObject(Pointer.fromAddress(addr)),
          isFalse,
          reason: 'addr: 0x${addr.toRadixString(16)}',
        );
        expect(
          isValidBlock(Pointer.fromAddress(addr)),
          isFalse,
          reason: 'addr: 0x${addr.toRadixString(16)}',
        );
      }
    });

    test('freed object', () {
      final obj = NSObject();
      final ptr = obj.ref.pointer;
      expect(isValidObject(ptr), isTrue);
      obj.ref.release();
      expect(isValidObject(ptr), isFalse);
    });
  });
}
