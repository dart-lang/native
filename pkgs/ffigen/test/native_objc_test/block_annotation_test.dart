// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: unused_local_variable

// Objective C support is only available on mac.
@TestOn('mac-os')

import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:objective_c/objective_c.dart';
import 'package:test/test.dart';

import '../test_utils.dart';
import 'block_annotation_bindings.dart';
import 'util.dart';

void main() {
  late final BlockAnnotationTestLibrary lib;

  group('Block annotations', () {
    // Due to https://github.com/dart-lang/native/issues/1490 we can't directly
    // codegen blocks that return retain or consume args. Instead we create them
    // by writing a protocol with methods that retain or consume. Since
    // protocol methods are implemented as blocks, this implicitly generates
    // blocks with the same signatures. Unfortunately this means there's an
    // extra void* arg that we don't use, but we can just ignore it.
    //
    // This is also why the ObjC block creation functions need casts to the
    // correct block type.

    setUpAll(() {
      // TODO(https://github.com/dart-lang/native/issues/1068): Remove this.
      DynamicLibrary.open('../objective_c/test/objective_c.dylib');
      final dylib = File('test/native_objc_test/block_annotation_test.dylib');
      verifySetupFile(dylib);
      lib =
          BlockAnnotationTestLibrary(DynamicLibrary.open(dylib.absolute.path));

      generateBindingsForCoverage('block_annotation');
    });

    Future<void> objectProducerTest(EmptyObject producer()) async {
      final pool = lib.objc_autoreleasePoolPush();
      EmptyObject? obj = producer();
      final ptr = obj.ref.pointer;
      lib.objc_autoreleasePoolPop(pool);
      await doGC();
      expect(objectRetainCount(ptr), 1);
      expect(obj, isNotNull);
      obj = null;
      await doGC();
      expect(objectRetainCount(ptr), 0);
    }

    test('ObjectProducer, defined objC, invoked dart', () async {
      await objectProducerTest(() {
        ObjCBlock<EmptyObject Function(Pointer<Void>)> blk =
            BlockAnnotationTest.newObjectProducer();
        return blk(nullptr);
      });
    });

    test('ObjectProducer, defined dart, invoked dart', () async {
      await objectProducerTest(() {
        ObjCBlock<EmptyObject Function(Pointer<Void>)> blk =
            ObjCBlock_EmptyObject_ffiVoid.fromFunction(
                (Pointer<Void> _) => EmptyObject.alloc().init());
        return blk(nullptr);
      });
    });

    test('ObjectProducer, defined dart, invoked objC', () async {
      await objectProducerTest(() {
        ObjCBlock<EmptyObject Function(Pointer<Void>)> blk =
            ObjCBlock_EmptyObject_ffiVoid.fromFunction(
                (Pointer<Void> _) => EmptyObject.alloc().init());
        return BlockAnnotationTest.invokeObjectProducer_(blk);
      });
    });

    test('RetainedObjectProducer, defined objC, invoked dart', () async {
      await objectProducerTest(() {
        ObjCBlock<Retained<EmptyObject> Function(Pointer<Void>)> blk =
            ObjCBlock<Retained<EmptyObject> Function(Pointer<Void>)>(
                BlockAnnotationTest.newRetainedObjectProducer().ref.pointer,
                retain: true,
                release: true);
        return blk(nullptr);
      });
    });

    test('RetainedObjectProducer, defined dart, invoked dart', () async {
      await objectProducerTest(() {
        ObjCBlock<Retained<EmptyObject> Function(Pointer<Void>)> blk =
            ObjCBlock_EmptyObject_ffiVoid1.fromFunction(
                (Pointer<Void> _) => EmptyObject.alloc().init());
        return blk(nullptr);
      });
    });

    test('RetainedObjectProducer, defined dart, invoked objC', () async {
      await objectProducerTest(() {
        ObjCBlock<Retained<EmptyObject> Function(Pointer<Void>)> blk =
            ObjCBlock_EmptyObject_ffiVoid1.fromFunction(
                (Pointer<Void> _) => EmptyObject.alloc().init());
        return BlockAnnotationTest.invokeRetainedObjectProducer_(
            ObjCBlock<EmptyObject Function(Pointer<Void>)>(blk.ref.pointer,
                retain: true, release: true));
      });
    });

    test('ObjectReceiver, defined objC, invoked dart', () async {
      await objectProducerTest(() {
        ObjCBlock<EmptyObject Function(Pointer<Void>, EmptyObject)> blk =
            BlockAnnotationTest.newObjectReceiver();
        return blk(nullptr, EmptyObject.alloc().init());
      });
    });

    test('ObjectReceiver, defined dart, invoked dart', () async {
      await objectProducerTest(() {
        ObjCBlock<EmptyObject Function(Pointer<Void>, EmptyObject)> blk =
            ObjCBlock_EmptyObject_ffiVoid_EmptyObject.fromFunction(
                (Pointer<Void> _, EmptyObject obj) => obj);
        return blk(nullptr, EmptyObject.alloc().init());
      });
    });

    test('ObjectReceiver, defined dart, invoked objC', () async {
      await objectProducerTest(() {
        ObjCBlock<EmptyObject Function(Pointer<Void>, EmptyObject)> blk =
            ObjCBlock_EmptyObject_ffiVoid_EmptyObject.fromFunction(
                (Pointer<Void> _, EmptyObject obj) => obj);
        return BlockAnnotationTest.invokeObjectReceiver_(blk);
      });
    });

    test('ConsumedObjectReceiver, defined objC, invoked dart', () async {
      await objectProducerTest(() {
        ObjCBlock<EmptyObject Function(Pointer<Void>, Consumed<EmptyObject>)>
            blk = ObjCBlock<
                    EmptyObject Function(Pointer<Void>, Consumed<EmptyObject>)>(
                BlockAnnotationTest.newConsumedObjectReceiver().ref.pointer,
                retain: true,
                release: true);
        return blk(nullptr, EmptyObject.alloc().init());
      });
    });

    test('ConsumedObjectReceiver, defined dart, invoked dart', () async {
      await objectProducerTest(() {
        ObjCBlock<EmptyObject Function(Pointer<Void>, Consumed<EmptyObject>)>
            blk = ObjCBlock_EmptyObject_ffiVoid_EmptyObject1.fromFunction(
                (Pointer<Void> _, EmptyObject obj) => obj);
        return blk(nullptr, EmptyObject.alloc().init());
      });
    });

    test('ConsumedObjectReceiver, defined dart, invoked objC', () async {
      await objectProducerTest(() {
        ObjCBlock<EmptyObject Function(Pointer<Void>, Consumed<EmptyObject>)>
            blk = ObjCBlock_EmptyObject_ffiVoid_EmptyObject1.fromFunction(
                (Pointer<Void> _, EmptyObject obj) => obj);
        return BlockAnnotationTest.invokeConsumedObjectReceiver_(
            ObjCBlock<EmptyObject Function(Pointer<Void>, EmptyObject)>(
                blk.ref.pointer,
                retain: true,
                release: true));
      });
    });

    Future<void> objectListenerTest(
        void Function(Completer<EmptyObject>) producer) async {
      final pool = lib.objc_autoreleasePoolPush();
      Completer<EmptyObject>? completer = Completer<EmptyObject>();
      producer(completer);
      EmptyObject? obj = await completer.future;
      final ptr = obj.ref.pointer;
      lib.objc_autoreleasePoolPop(pool);
      await doGC();
      expect(objectRetainCount(ptr), 1);
      expect(obj, isNotNull);
      obj = null;
      completer = null;
      await doGC();
      await Future<void>.delayed(Duration.zero); // Let dispose message arrive.
      await doGC();
      expect(objectRetainCount(ptr), 0);
    }

    test('ObjectListener, defined dart, invoked dart', () async {
      await objectListenerTest((Completer<EmptyObject> completer) {
        ObjCBlock<Void Function(Pointer<Void>, EmptyObject)> blk =
            ObjCBlock_ffiVoid_ffiVoid_EmptyObject.listener(
                (Pointer<Void> _, EmptyObject obj) => completer.complete(obj));
        blk(nullptr, EmptyObject.alloc().init());
      });
    });

    test('ObjectListener, defined dart, invoked objC sync', () async {
      await objectListenerTest((Completer<EmptyObject> completer) {
        ObjCBlock<Void Function(Pointer<Void>, EmptyObject)> blk =
            ObjCBlock_ffiVoid_ffiVoid_EmptyObject.listener(
                (Pointer<Void> _, EmptyObject obj) => completer.complete(obj));
        BlockAnnotationTest.invokeObjectListenerSync_(blk);
      });
    });

    test('ObjectListener, defined dart, invoked objC async', () async {
      await objectListenerTest((Completer<EmptyObject> completer) {
        ObjCBlock<Void Function(Pointer<Void>, EmptyObject)> blk =
            ObjCBlock_ffiVoid_ffiVoid_EmptyObject.listener(
                (Pointer<Void> _, EmptyObject obj) => completer.complete(obj));
        final thread = BlockAnnotationTest.invokeObjectListenerAsync_(blk);
        thread.start();
      });
    });

    // TODO(https://github.com/dart-lang/native/issues/1505): Fix this case.
    /*test('ConsumedObjectListener, defined dart, invoked dart', () async {
      await objectListenerTest((Completer<EmptyObject> completer) {
        ObjCBlock<Void Function(Pointer<Void>, Consumed<EmptyObject>)> blk =
            ObjCBlock_ffiVoid_ffiVoid_EmptyObject1.listener(
                (Pointer<Void> _, EmptyObject obj) => completer.complete(obj));
        blk(nullptr, EmptyObject.alloc().init());
      });
    });*/

    test('ConsumedObjectListener, defined dart, invoked objC sync', () async {
      await objectListenerTest((Completer<EmptyObject> completer) {
        ObjCBlock<Void Function(Pointer<Void>, Consumed<EmptyObject>)> blk =
            ObjCBlock_ffiVoid_ffiVoid_EmptyObject1.listener(
                (Pointer<Void> _, EmptyObject obj) => completer.complete(obj));
        BlockAnnotationTest.invokeObjectListenerSync_(
            ObjCBlock<Void Function(Pointer<Void>, EmptyObject)>(
                blk.ref.pointer,
                retain: true,
                release: true));
      });
    });

    test('ConsumedObjectListener, defined dart, invoked objC async', () async {
      await objectListenerTest((Completer<EmptyObject> completer) {
        ObjCBlock<Void Function(Pointer<Void>, Consumed<EmptyObject>)> blk =
            ObjCBlock_ffiVoid_ffiVoid_EmptyObject1.listener(
                (Pointer<Void> _, EmptyObject obj) => completer.complete(obj));
        final thread = BlockAnnotationTest.invokeObjectListenerAsync_(
            ObjCBlock<Void Function(Pointer<Void>, EmptyObject)>(
                blk.ref.pointer,
                retain: true,
                release: true));
        thread.start();
      });
    });

    Future<void> blockProducerTest(DartEmptyBlock producer()) async {
      final pool = lib.objc_autoreleasePoolPush();
      DartEmptyBlock? obj = producer();
      final ptr = obj.ref.pointer;
      lib.objc_autoreleasePoolPop(pool);
      await doGC();
      expect(blockRetainCount(ptr), 1);
      expect(obj, isNotNull);
      obj = null;
      await doGC();
      expect(blockRetainCount(ptr), 0);
    }

    test('BlockProducer, defined objC, invoked dart', () async {
      await blockProducerTest(() {
        ObjCBlock<DartEmptyBlock Function(Pointer<Void>)> blk =
            BlockAnnotationTest.newBlockProducer();
        return blk(nullptr);
      });
    });

    test('BlockProducer, defined dart, invoked dart', () async {
      await blockProducerTest(() {
        ObjCBlock<DartEmptyBlock Function(Pointer<Void>)> blk =
            ObjCBlock_EmptyBlock_ffiVoid.fromFunction(
                (Pointer<Void> _) => ObjCBlock_ffiVoid.fromFunction(() {}));
        return blk(nullptr);
      });
    });

    test('BlockProducer, defined dart, invoked objC', () async {
      await blockProducerTest(() {
        ObjCBlock<DartEmptyBlock Function(Pointer<Void>)> blk =
            ObjCBlock_EmptyBlock_ffiVoid.fromFunction(
                (Pointer<Void> _) => ObjCBlock_ffiVoid.fromFunction(() {}));
        return BlockAnnotationTest.invokeBlockProducer_(blk);
      });
    });

    test('RetainedBlockProducer, defined objC, invoked dart', () async {
      await blockProducerTest(() {
        ObjCBlock<Retained<DartEmptyBlock> Function(Pointer<Void>)> blk =
            ObjCBlock<Retained<DartEmptyBlock> Function(Pointer<Void>)>(
                BlockAnnotationTest.newRetainedBlockProducer().ref.pointer,
                retain: true,
                release: true);
        return blk(nullptr);
      });
    });

    test('RetainedBlockProducer, defined dart, invoked dart', () async {
      await blockProducerTest(() {
        ObjCBlock<Retained<DartEmptyBlock> Function(Pointer<Void>)> blk =
            ObjCBlock_EmptyBlock_ffiVoid1.fromFunction(
                (Pointer<Void> _) => ObjCBlock_ffiVoid.fromFunction(() {}));
        return blk(nullptr);
      });
    });

    test('RetainedBlockProducer, defined dart, invoked objC', () async {
      await blockProducerTest(() {
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
