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

    void objectProducerTest(EmptyObject producer()) {
      final pool = lib.objc_autoreleasePoolPush();
      EmptyObject? obj = producer();
      final ptr = obj.ref.pointer;
      lib.objc_autoreleasePoolPop(pool);
      doGC();
      expect(objectRetainCount(ptr), 1);
      expect(obj, isNotNull);
      obj = null;
      doGC();
      expect(objectRetainCount(ptr), 0);
    }

    test('ObjectProducer, defined objC, invoked dart', () {
      objectProducerTest(() {
        ObjCBlock<EmptyObject Function(Pointer<Void>)> blk =
            BlockAnnotationTest.newObjectProducer();
        return blk(nullptr);
      });
    });

    test('ObjectProducer, defined fromFunction, invoked dart', () {
      objectProducerTest(() {
        ObjCBlock<EmptyObject Function(Pointer<Void>)> blk =
            ObjCBlock_EmptyObject_ffiVoid.fromFunction(
                (Pointer<Void> _) => EmptyObject.alloc().init());
        return blk(nullptr);
      });
    });

    test('ObjectProducer, defined fromFunction, invoked objCSync', () {
      objectProducerTest(() {
        ObjCBlock<EmptyObject Function(Pointer<Void>)> blk =
            ObjCBlock_EmptyObject_ffiVoid.fromFunction(
                (Pointer<Void> _) => EmptyObject.alloc().init());
        return BlockAnnotationTest.invokeObjectProducer_(blk);
      });
    });

    test('RetainedObjectProducer, defined objC, invoked dart', () {
      objectProducerTest(() {
        ObjCBlock<Retained<EmptyObject> Function(Pointer<Void>)> blk =
            ObjCBlock<Retained<EmptyObject> Function(Pointer<Void>)>(
                BlockAnnotationTest.newRetainedObjectProducer().ref.pointer,
                retain: true,
                release: true);
        return blk(nullptr);
      });
    });

    test('RetainedObjectProducer, defined fromFunction, invoked dart', () {
      objectProducerTest(() {
        ObjCBlock<Retained<EmptyObject> Function(Pointer<Void>)> blk =
            ObjCBlock_EmptyObject_ffiVoid1.fromFunction(
                (Pointer<Void> _) => EmptyObject.alloc().init());
        return blk(nullptr);
      });
    });

    test('RetainedObjectProducer, defined fromFunction, invoked objCSync', () {
      objectProducerTest(() {
        ObjCBlock<Retained<EmptyObject> Function(Pointer<Void>)> blk =
            ObjCBlock_EmptyObject_ffiVoid1.fromFunction(
                (Pointer<Void> _) => EmptyObject.alloc().init());
        return BlockAnnotationTest.invokeRetainedObjectProducer_(
            ObjCBlock<EmptyObject Function(Pointer<Void>)>(blk.ref.pointer,
                retain: true, release: true));
      });
    });

    void blockProducerTest(DartEmptyBlock producer()) {
      final pool = lib.objc_autoreleasePoolPush();
      DartEmptyBlock? obj = producer();
      final ptr = obj.ref.pointer;
      lib.objc_autoreleasePoolPop(pool);
      doGC();
      expect(blockRetainCount(ptr), 1);
      expect(obj, isNotNull);
      obj = null;
      doGC();
      expect(blockRetainCount(ptr), 0);
    }

    test('BlockProducer, defined objC, invoked dart', () {
      blockProducerTest(() {
        ObjCBlock<DartEmptyBlock Function(Pointer<Void>)> blk =
            BlockAnnotationTest.newBlockProducer();
        return blk(nullptr);
      });
    });

    test('BlockProducer, defined fromFunction, invoked dart', () {
      blockProducerTest(() {
        ObjCBlock<DartEmptyBlock Function(Pointer<Void>)> blk =
            ObjCBlock_EmptyBlock_ffiVoid.fromFunction(
                (Pointer<Void> _) => ObjCBlock_ffiVoid.fromFunction(() {}));
        return blk(nullptr);
      });
    });

    test('BlockProducer, defined fromFunction, invoked objCSync', () {
      blockProducerTest(() {
        ObjCBlock<DartEmptyBlock Function(Pointer<Void>)> blk =
            ObjCBlock_EmptyBlock_ffiVoid.fromFunction(
                (Pointer<Void> _) => ObjCBlock_ffiVoid.fromFunction(() {}));
        return BlockAnnotationTest.invokeBlockProducer_(blk);
      });
    });

    test('RetainedBlockProducer, defined objC, invoked dart', () {
      blockProducerTest(() {
        ObjCBlock<Retained<DartEmptyBlock> Function(Pointer<Void>)> blk =
            ObjCBlock<Retained<DartEmptyBlock> Function(Pointer<Void>)>(
                BlockAnnotationTest.newRetainedBlockProducer().ref.pointer,
                retain: true,
                release: true);
        return blk(nullptr);
      });
    });

    test('RetainedBlockProducer, defined fromFunction, invoked dart', () {
      blockProducerTest(() {
        ObjCBlock<Retained<DartEmptyBlock> Function(Pointer<Void>)> blk =
            ObjCBlock_EmptyBlock_ffiVoid1.fromFunction(
                (Pointer<Void> _) => ObjCBlock_ffiVoid.fromFunction(() {}));
        return blk(nullptr);
      });
    });

    test('RetainedBlockProducer, defined fromFunction, invoked objCSync', () {
      blockProducerTest(() {
        ObjCBlock<Retained<DartEmptyBlock> Function(Pointer<Void>)> blk =
            ObjCBlock_EmptyBlock_ffiVoid1.fromFunction(
                (Pointer<Void> _) => ObjCBlock_ffiVoid.fromFunction(() {}));
        return BlockAnnotationTest.invokeRetainedBlockProducer_(
            ObjCBlock<DartEmptyBlock Function(Pointer<Void>)>(blk.ref.pointer,
                retain: true, release: true));
      });
    });
  });
}
