// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: unused_local_variable

// Objective C support is only available on mac.
@TestOn('mac-os')

import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:objective_c/objective_c.dart';
import 'package:objective_c/src/internal.dart' as internal_for_testing
    show blockHasRegisteredClosure;
import 'package:test/test.dart';

import '../test_utils.dart';
import 'block_annotation_bindings.dart';
import 'util.dart';

void main() {
  late final BlockAnnotationTestLibrary lib;

  group('Block annotations', () {
    setUpAll(() {
      // TODO(https://github.com/dart-lang/native/issues/1068): Remove this.
      DynamicLibrary.open('../objective_c/test/objective_c.dylib');
      final dylib = File('test/native_objc_test/block_annotation_test.dylib');
      verifySetupFile(dylib);
      lib =
          BlockAnnotationTestLibrary(DynamicLibrary.open(dylib.absolute.path));

      generateBindingsForCoverage('block_annotation');
    });

    test('ObjectProducer, defined Definition.objC, invoked Invocation.dart',
        () {
      final pool = lib.objc_autoreleasePoolPush();
      ObjCBlock<EmptyObject Function(Pointer<Void>)> blk =
          BlockAnnotationTest.newObjectProducer();
      EmptyObject? obj = blk(nullptr);
      final ptr = obj.pointer;
      lib.objc_autoreleasePoolPop(pool);
      doGC();
      expect(objectRetainCount(ptr), 1);
      expect(obj, isNotNull);
      obj = null;
      doGC();
      expect(objectRetainCount(ptr), 0);
    });

    test('ObjectProducer, defined Definition.objC, invoked Invocation.objCSync',
        () {
      final pool = lib.objc_autoreleasePoolPush();
      ObjCBlock<EmptyObject Function(Pointer<Void>)> blk =
          BlockAnnotationTest.newObjectProducer();
      EmptyObject? obj = BlockAnnotationTest.invokeObjectProducer_(blk);
      final ptr = obj.pointer;
      lib.objc_autoreleasePoolPop(pool);
      doGC();
      expect(objectRetainCount(ptr), 1);
      expect(obj, isNotNull);
      obj = null;
      doGC();
      expect(objectRetainCount(ptr), 0);
    });

    test(
        'ObjectProducer, defined Definition.fromFunction, invoked Invocation.dart',
        () {
      final pool = lib.objc_autoreleasePoolPush();
      ObjCBlock<EmptyObject Function(Pointer<Void>)> blk =
          ObjCBlock_EmptyObject_ffiVoid.fromFunction(
              (Pointer<Void> _) => EmptyObject.alloc().init());
      EmptyObject? obj = blk(nullptr);
      final ptr = obj.pointer;
      lib.objc_autoreleasePoolPop(pool);
      doGC();
      expect(objectRetainCount(ptr), 1);
      expect(obj, isNotNull);
      obj = null;
      doGC();
      expect(objectRetainCount(ptr), 0);
    });

    test(
        'ObjectProducer, defined Definition.fromFunction, invoked Invocation.objCSync',
        () {
      final pool = lib.objc_autoreleasePoolPush();
      ObjCBlock<EmptyObject Function(Pointer<Void>)> blk =
          ObjCBlock_EmptyObject_ffiVoid.fromFunction(
              (Pointer<Void> _) => EmptyObject.alloc().init());
      EmptyObject? obj = BlockAnnotationTest.invokeObjectProducer_(blk);
      final ptr = obj.pointer;
      lib.objc_autoreleasePoolPop(pool);
      doGC();
      expect(objectRetainCount(ptr), 1);
      expect(obj, isNotNull);
      obj = null;
      doGC();
      expect(objectRetainCount(ptr), 0);
    });

    test(
        'RetainedObjectProducer, defined Definition.objC, invoked Invocation.dart',
        () {
      final pool = lib.objc_autoreleasePoolPush();
      ObjCBlock<Retained<EmptyObject> Function(Pointer<Void>)> blk =
          ObjCBlock<Retained<EmptyObject> Function(Pointer<Void>)>(
              BlockAnnotationTest.newRetainedObjectProducer().pointer,
              retain: true,
              release: true);
      EmptyObject? obj = blk(nullptr);
      final ptr = obj.pointer;
      lib.objc_autoreleasePoolPop(pool);
      doGC();
      expect(objectRetainCount(ptr), 1);
      expect(obj, isNotNull);
      obj = null;
      doGC();
      expect(objectRetainCount(ptr), 0);
    });

    test(
        'RetainedObjectProducer, defined Definition.objC, invoked Invocation.objCSync',
        () {
      final pool = lib.objc_autoreleasePoolPush();
      ObjCBlock<Retained<EmptyObject> Function(Pointer<Void>)> blk =
          ObjCBlock<Retained<EmptyObject> Function(Pointer<Void>)>(
              BlockAnnotationTest.newRetainedObjectProducer().pointer,
              retain: true,
              release: true);
      EmptyObject? obj = BlockAnnotationTest.invokeRetainedObjectProducer_(
          ObjCBlock<EmptyObject Function(Pointer<Void>)>(blk.pointer,
              retain: true, release: true));
      final ptr = obj.pointer;
      lib.objc_autoreleasePoolPop(pool);
      doGC();
      expect(objectRetainCount(ptr), 1);
      expect(obj, isNotNull);
      obj = null;
      doGC();
      expect(objectRetainCount(ptr), 0);
    });

    test(
        'RetainedObjectProducer, defined Definition.fromFunction, invoked Invocation.dart',
        () {
      final pool = lib.objc_autoreleasePoolPush();
      ObjCBlock<Retained<EmptyObject> Function(Pointer<Void>)> blk =
          ObjCBlock_EmptyObject_ffiVoid1.fromFunction(
              (Pointer<Void> _) => EmptyObject.alloc().init());
      EmptyObject? obj = blk(nullptr);
      final ptr = obj.pointer;
      lib.objc_autoreleasePoolPop(pool);
      doGC();
      expect(objectRetainCount(ptr), 1);
      expect(obj, isNotNull);
      obj = null;
      doGC();
      expect(objectRetainCount(ptr), 0);
    });

    test(
        'RetainedObjectProducer, defined Definition.fromFunction, invoked Invocation.objCSync',
        () {
      final pool = lib.objc_autoreleasePoolPush();
      ObjCBlock<Retained<EmptyObject> Function(Pointer<Void>)> blk =
          ObjCBlock_EmptyObject_ffiVoid1.fromFunction(
              (Pointer<Void> _) => EmptyObject.alloc().init());
      EmptyObject? obj = BlockAnnotationTest.invokeRetainedObjectProducer_(
          ObjCBlock<EmptyObject Function(Pointer<Void>)>(blk.pointer,
              retain: true, release: true));
      final ptr = obj.pointer;
      lib.objc_autoreleasePoolPop(pool);
      doGC();
      expect(objectRetainCount(ptr), 1);
      expect(obj, isNotNull);
      obj = null;
      doGC();
      expect(objectRetainCount(ptr), 0);
    });

    test('BlockProducer, defined Definition.objC, invoked Invocation.dart', () {
      final pool = lib.objc_autoreleasePoolPush();
      ObjCBlock<DartEmptyBlock Function(Pointer<Void>)> blk =
          BlockAnnotationTest.newBlockProducer();
      DartEmptyBlock? obj = blk(nullptr);
      final ptr = obj.pointer;
      lib.objc_autoreleasePoolPop(pool);
      doGC();
      expect(blockRetainCount(ptr), 1);
      expect(obj, isNotNull);
      obj = null;
      doGC();
      expect(blockRetainCount(ptr), 0);
    });

    test('BlockProducer, defined Definition.objC, invoked Invocation.objCSync',
        () {
      final pool = lib.objc_autoreleasePoolPush();
      ObjCBlock<DartEmptyBlock Function(Pointer<Void>)> blk =
          BlockAnnotationTest.newBlockProducer();
      DartEmptyBlock? obj = BlockAnnotationTest.invokeBlockProducer_(blk);
      final ptr = obj.pointer;
      lib.objc_autoreleasePoolPop(pool);
      doGC();
      expect(blockRetainCount(ptr), 1);
      expect(obj, isNotNull);
      obj = null;
      doGC();
      expect(blockRetainCount(ptr), 0);
    });

    test(
        'BlockProducer, defined Definition.fromFunction, invoked Invocation.dart',
        () {
      final pool = lib.objc_autoreleasePoolPush();
      ObjCBlock<DartEmptyBlock Function(Pointer<Void>)> blk =
          ObjCBlock_EmptyBlock_ffiVoid.fromFunction(
              (Pointer<Void> _) => ObjCBlock_ffiVoid.fromFunction(() {}));
      DartEmptyBlock? obj = blk(nullptr);
      final ptr = obj.pointer;
      lib.objc_autoreleasePoolPop(pool);
      doGC();
      expect(blockRetainCount(ptr), 1);
      expect(obj, isNotNull);
      obj = null;
      doGC();
      expect(blockRetainCount(ptr), 0);
    });

    test(
        'BlockProducer, defined Definition.fromFunction, invoked Invocation.objCSync',
        () {
      final pool = lib.objc_autoreleasePoolPush();
      ObjCBlock<DartEmptyBlock Function(Pointer<Void>)> blk =
          ObjCBlock_EmptyBlock_ffiVoid.fromFunction(
              (Pointer<Void> _) => ObjCBlock_ffiVoid.fromFunction(() {}));
      DartEmptyBlock? obj = BlockAnnotationTest.invokeBlockProducer_(blk);
      final ptr = obj.pointer;
      lib.objc_autoreleasePoolPop(pool);
      doGC();
      expect(blockRetainCount(ptr), 1);
      expect(obj, isNotNull);
      obj = null;
      doGC();
      expect(blockRetainCount(ptr), 0);
    });

    test(
        'RetainedBlockProducer, defined Definition.objC, invoked Invocation.dart',
        () {
      final pool = lib.objc_autoreleasePoolPush();
      ObjCBlock<Retained<DartEmptyBlock> Function(Pointer<Void>)> blk =
          ObjCBlock<Retained<DartEmptyBlock> Function(Pointer<Void>)>(
              BlockAnnotationTest.newRetainedBlockProducer().pointer,
              retain: true,
              release: true);
      DartEmptyBlock? obj = blk(nullptr);
      final ptr = obj.pointer;
      lib.objc_autoreleasePoolPop(pool);
      doGC();
      expect(blockRetainCount(ptr), 1);
      expect(obj, isNotNull);
      obj = null;
      doGC();
      expect(blockRetainCount(ptr), 0);
    });

    test(
        'RetainedBlockProducer, defined Definition.objC, invoked Invocation.objCSync',
        () {
      final pool = lib.objc_autoreleasePoolPush();
      ObjCBlock<Retained<DartEmptyBlock> Function(Pointer<Void>)> blk =
          ObjCBlock<Retained<DartEmptyBlock> Function(Pointer<Void>)>(
              BlockAnnotationTest.newRetainedBlockProducer().pointer,
              retain: true,
              release: true);
      DartEmptyBlock? obj = BlockAnnotationTest.invokeRetainedBlockProducer_(
          ObjCBlock<DartEmptyBlock Function(Pointer<Void>)>(blk.pointer,
              retain: true, release: true));
      final ptr = obj.pointer;
      lib.objc_autoreleasePoolPop(pool);
      doGC();
      expect(blockRetainCount(ptr), 1);
      expect(obj, isNotNull);
      obj = null;
      doGC();
      expect(blockRetainCount(ptr), 0);
    });

    test(
        'RetainedBlockProducer, defined Definition.fromFunction, invoked Invocation.dart',
        () {
      final pool = lib.objc_autoreleasePoolPush();
      ObjCBlock<Retained<DartEmptyBlock> Function(Pointer<Void>)> blk =
          ObjCBlock_EmptyBlock_ffiVoid1.fromFunction(
              (Pointer<Void> _) => ObjCBlock_ffiVoid.fromFunction(() {}));
      DartEmptyBlock? obj = blk(nullptr);
      final ptr = obj.pointer;
      lib.objc_autoreleasePoolPop(pool);
      doGC();
      expect(blockRetainCount(ptr), 1);
      expect(obj, isNotNull);
      obj = null;
      doGC();
      expect(blockRetainCount(ptr), 0);
    });

    test(
        'RetainedBlockProducer, defined Definition.fromFunction, invoked Invocation.objCSync',
        () {
      final pool = lib.objc_autoreleasePoolPush();
      ObjCBlock<Retained<DartEmptyBlock> Function(Pointer<Void>)> blk =
          ObjCBlock_EmptyBlock_ffiVoid1.fromFunction(
              (Pointer<Void> _) => ObjCBlock_ffiVoid.fromFunction(() {}));
      DartEmptyBlock? obj = BlockAnnotationTest.invokeRetainedBlockProducer_(
          ObjCBlock<DartEmptyBlock Function(Pointer<Void>)>(blk.pointer,
              retain: true, release: true));
      final ptr = obj.pointer;
      lib.objc_autoreleasePoolPop(pool);
      doGC();
      expect(blockRetainCount(ptr), 1);
      expect(obj, isNotNull);
      obj = null;
      doGC();
      expect(blockRetainCount(ptr), 0);
    });
  });
}
