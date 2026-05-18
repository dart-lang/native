// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')
import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:objective_c/objective_c.dart';
import 'package:objective_c/src/internal.dart'
    as internal_for_testing
    show blockHasRegisteredClosure;
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import '../test_utils.dart';
import 'block_annotation_test_bindings.dart';
import 'util.dart';

void main() {
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
      loadLibrary();
    });

    void objectProducerTest(EmptyObject producer()) {
      using((Arena arena) {
        final tracker = ReferenceTracker(arena);
        final pool = objc_autoreleasePoolPush();
        EmptyObject? obj = producer();
        tracker.track(obj);
        objc_autoreleasePoolPop(pool);
        doGC();
        expect(tracker.isAlive, true);
        expect(obj, isNotNull);
        obj = null;
        doGC();
        expect(tracker.isAlive, false);
      });
    }

    test('ObjectProducer, defined objC, invoked dart', () {
      objectProducerTest(() {
        ObjCBlock<EmptyObject Function(Pointer<Void>)> blk =
            BlockAnnotationTest.newObjectProducer();
        return blk(nullptr);
      });
    }, skip: !canDoGC);

    test('ObjectProducer, defined dart, invoked dart', () {
      objectProducerTest(() {
        ObjCBlock<EmptyObject Function(Pointer<Void>)> blk =
            ObjCBlock_EmptyObject_ffiVoid.fromFunction(
              (Pointer<Void> _) => EmptyObject.alloc().init(),
            );
        return blk(nullptr);
      });
    }, skip: !canDoGC);

    test('ObjectProducer, defined dart, invoked objC', () {
      objectProducerTest(() {
        ObjCBlock<EmptyObject Function(Pointer<Void>)> blk =
            ObjCBlock_EmptyObject_ffiVoid.fromFunction(
              (Pointer<Void> _) => EmptyObject.alloc().init(),
            );
        return BlockAnnotationTest.invokeObjectProducer(blk);
      });
    }, skip: !canDoGC);

    test('RetainedObjectProducer, defined objC, invoked dart', () {
      objectProducerTest(() {
        ObjCBlock<Retained<EmptyObject> Function(Pointer<Void>)> blk =
            ObjCBlock<Retained<EmptyObject> Function(Pointer<Void>)>(
              BlockAnnotationTest.newRetainedObjectProducer().ref.pointer,
              retain: true,
              release: true,
            );
        return blk(nullptr);
      });
    }, skip: !canDoGC);

    test('RetainedObjectProducer, defined dart, invoked dart', () {
      objectProducerTest(() {
        ObjCBlock<Retained<EmptyObject> Function(Pointer<Void>)> blk =
            ObjCBlock_EmptyObject_ffiVoid$1.fromFunction(
              (Pointer<Void> _) => EmptyObject.alloc().init(),
            );
        return blk(nullptr);
      });
    }, skip: !canDoGC);

    test('RetainedObjectProducer, defined dart, invoked objC', () {
      objectProducerTest(() {
        ObjCBlock<Retained<EmptyObject> Function(Pointer<Void>)> blk =
            ObjCBlock_EmptyObject_ffiVoid$1.fromFunction(
              (Pointer<Void> _) => EmptyObject.alloc().init(),
            );
        return BlockAnnotationTest.invokeRetainedObjectProducer(
          ObjCBlock<EmptyObject Function(Pointer<Void>)>(
            blk.ref.pointer,
            retain: true,
            release: true,
          ),
        );
      });
    }, skip: !canDoGC);

    test('ObjectReceiver, defined objC, invoked dart', () {
      objectProducerTest(() {
        ObjCBlock<EmptyObject Function(Pointer<Void>, EmptyObject)> blk =
            BlockAnnotationTest.newObjectReceiver();
        return blk(nullptr, EmptyObject.alloc().init());
      });
    }, skip: !canDoGC);

    test('ObjectReceiver, defined dart, invoked dart', () {
      objectProducerTest(() {
        ObjCBlock<EmptyObject Function(Pointer<Void>, EmptyObject)> blk =
            ObjCBlock_EmptyObject_ffiVoid_EmptyObject.fromFunction(
              (Pointer<Void> _, EmptyObject obj) => obj,
            );
        return blk(nullptr, EmptyObject.alloc().init());
      });
    }, skip: !canDoGC);

    test('ObjectReceiver, defined dart, invoked objC', () {
      objectProducerTest(() {
        ObjCBlock<EmptyObject Function(Pointer<Void>, EmptyObject)> blk =
            ObjCBlock_EmptyObject_ffiVoid_EmptyObject.fromFunction(
              (Pointer<Void> _, EmptyObject obj) => obj,
            );
        return BlockAnnotationTest.invokeObjectReceiver(blk);
      });
    }, skip: !canDoGC);

    test('ConsumedObjectReceiver, defined objC, invoked dart', () {
      objectProducerTest(() {
        ObjCBlock<EmptyObject Function(Pointer<Void>, Consumed<EmptyObject>)>
        blk =
            ObjCBlock<
              EmptyObject Function(Pointer<Void>, Consumed<EmptyObject>)
            >(
              BlockAnnotationTest.newConsumedObjectReceiver().ref.pointer,
              retain: true,
              release: true,
            );
        return blk(nullptr, EmptyObject.alloc().init());
      });
    }, skip: !canDoGC);

    test('ConsumedObjectReceiver, defined dart, invoked dart', () {
      objectProducerTest(() {
        ObjCBlock<EmptyObject Function(Pointer<Void>, Consumed<EmptyObject>)>
        blk = ObjCBlock_EmptyObject_ffiVoid_EmptyObject$1.fromFunction(
          (Pointer<Void> _, EmptyObject obj) => obj,
        );
        return blk(nullptr, EmptyObject.alloc().init());
      });
    }, skip: !canDoGC);

    test('ConsumedObjectReceiver, defined dart, invoked objC', () {
      objectProducerTest(() {
        ObjCBlock<EmptyObject Function(Pointer<Void>, Consumed<EmptyObject>)>
        blk = ObjCBlock_EmptyObject_ffiVoid_EmptyObject$1.fromFunction(
          (Pointer<Void> _, EmptyObject obj) => obj,
        );
        return BlockAnnotationTest.invokeConsumedObjectReceiver(
          ObjCBlock<EmptyObject Function(Pointer<Void>, EmptyObject)>(
            blk.ref.pointer,
            retain: true,
            release: true,
          ),
        );
      });
    }, skip: !canDoGC);

    Future<void> objectListenerTest(
      void Function(Completer<EmptyObject>) producer,
    ) async {
      Completer<EmptyObject>? completer = Completer<EmptyObject>();
      producer(completer);
      EmptyObject? obj = await completer.future;

      await using((arena) async {
        final tracker = ReferenceTracker(arena);
        final pool = objc_autoreleasePoolPush();
        tracker.track(obj!);
        objc_autoreleasePoolPop(pool);
        doGC();
        expect(tracker.isAlive, true);
        expect(obj, isNotNull);

        obj = null;
        completer = null;
        doGC();
        await Future<void>.delayed(const Duration(milliseconds: 100));
        doGC();
        expect(tracker.isAlive, false);
      });
    }

    test('ObjectListener, defined dart, invoked dart', () async {
      await objectListenerTest((Completer<EmptyObject> completer) {
        ObjCBlock<Void Function(Pointer<Void>, EmptyObject)> blk =
            ObjCBlock_ffiVoid_ffiVoid_EmptyObject.listener(
              (Pointer<Void> _, EmptyObject obj) => completer.complete(obj),
            );
        blk(nullptr, EmptyObject.alloc().init());
      });
    }, skip: !canDoGC);

    test('ObjectListener, defined dart, invoked objC sync', () async {
      await objectListenerTest((Completer<EmptyObject> completer) {
        ObjCBlock<Void Function(Pointer<Void>, EmptyObject)> blk =
            ObjCBlock_ffiVoid_ffiVoid_EmptyObject.listener(
              (Pointer<Void> _, EmptyObject obj) => completer.complete(obj),
            );
        BlockAnnotationTest.invokeObjectListenerSync(blk);
      });
    }, skip: !canDoGC);

    test('ObjectListener, defined dart, invoked objC async', () async {
      await objectListenerTest((Completer<EmptyObject> completer) {
        ObjCBlock<Void Function(Pointer<Void>, EmptyObject)> blk =
            ObjCBlock_ffiVoid_ffiVoid_EmptyObject.listener(
              (Pointer<Void> _, EmptyObject obj) => completer.complete(obj),
            );
        final thread = BlockAnnotationTest.invokeObjectListenerAsync(blk);
        thread.start();
      });
    }, skip: !canDoGC);

    // TODO(https://github.com/dart-lang/native/issues/1505): Fix this case.
    /*test('ConsumedObjectListener, defined dart, invoked dart', () async {
      await objectListenerTest((Completer<EmptyObject> completer) {
        ObjCBlock<Void Function(Pointer<Void>, Consumed<EmptyObject>)> blk =
            ObjCBlock_ffiVoid_ffiVoid_EmptyObject$1.listener(
                (Pointer<Void> _, EmptyObject obj) => completer.complete(obj));
        blk(nullptr, EmptyObject.alloc().init());
      });
    }, skip: !canDoGC);*/

    test('ConsumedObjectListener, defined dart, invoked objC sync', () async {
      await objectListenerTest((Completer<EmptyObject> completer) {
        ObjCBlock<Void Function(Pointer<Void>, Consumed<EmptyObject>)> blk =
            ObjCBlock_ffiVoid_ffiVoid_EmptyObject$1.listener(
              (Pointer<Void> _, EmptyObject obj) => completer.complete(obj),
            );
        BlockAnnotationTest.invokeObjectListenerSync(
          ObjCBlock<Void Function(Pointer<Void>, EmptyObject)>(
            blk.ref.pointer,
            retain: true,
            release: true,
          ),
        );
      });
    }, skip: !canDoGC);

    test('ConsumedObjectListener, defined dart, invoked objC async', () async {
      await objectListenerTest((Completer<EmptyObject> completer) {
        ObjCBlock<Void Function(Pointer<Void>, Consumed<EmptyObject>)> blk =
            ObjCBlock_ffiVoid_ffiVoid_EmptyObject$1.listener(
              (Pointer<Void> _, EmptyObject obj) => completer.complete(obj),
            );
        final thread = BlockAnnotationTest.invokeObjectListenerAsync(
          ObjCBlock<Void Function(Pointer<Void>, EmptyObject)>(
            blk.ref.pointer,
            retain: true,
            release: true,
          ),
        );
        thread.start();
      });
    }, skip: !canDoGC);

    void blockProducerTest(DartEmptyBlock producer()) {
      using((Arena arena) {
        final tracker = ReferenceTracker(arena);
        final pool = objc_autoreleasePoolPush();
        DartEmptyBlock? obj = producer();
        tracker.track(
          ObjCObject(obj.ref.pointer.cast(), retain: false, release: false),
        );
        doGC();
        expect(tracker.isAlive, true);
        expect(obj, isNotNull);

        obj = null;
        objc_autoreleasePoolPop(pool);
        doGC();
        expect(tracker.isAlive, false);
      });
    }

    test('BlockProducer, defined objC, invoked dart', () {
      blockProducerTest(() {
        ObjCBlock<DartEmptyBlock Function(Pointer<Void>)> blk =
            BlockAnnotationTest.newBlockProducer();
        final temp = blk(nullptr);
        ObjCObject(temp.ref.pointer.cast(), retain: true, release: true);
        return temp;
      });
    }, skip: !canDoGC);

    test('BlockProducer, defined dart, invoked dart', () {
      blockProducerTest(() {
        ObjCBlock<DartEmptyBlock Function(Pointer<Void>)> blk =
            ObjCBlock_EmptyBlock_ffiVoid.fromFunction(
              (Pointer<Void> _) => ObjCBlock_ffiVoid.fromFunction(() {}),
            );
        return blk(nullptr);
      });
    }, skip: !canDoGC);

    test('BlockProducer, defined dart, invoked objC', () {
      blockProducerTest(() {
        ObjCBlock<DartEmptyBlock Function(Pointer<Void>)> blk =
            ObjCBlock_EmptyBlock_ffiVoid.fromFunction(
              (Pointer<Void> _) => ObjCBlock_ffiVoid.fromFunction(() {}),
            );
        return BlockAnnotationTest.invokeBlockProducer(blk);
      });
    }, skip: !canDoGC);

    test('RetainedBlockProducer, defined objC, invoked dart', () {
      blockProducerTest(() {
        ObjCBlock<Retained<DartEmptyBlock> Function(Pointer<Void>)> blk =
            ObjCBlock<Retained<DartEmptyBlock> Function(Pointer<Void>)>(
              BlockAnnotationTest.newRetainedBlockProducer().ref.pointer,
              retain: true,
              release: true,
            );
        return blk(nullptr);
      });
    }, skip: !canDoGC);

    test('RetainedBlockProducer, defined dart, invoked dart', () {
      blockProducerTest(() {
        ObjCBlock<Retained<DartEmptyBlock> Function(Pointer<Void>)> blk =
            ObjCBlock_EmptyBlock_ffiVoid$1.fromFunction(
              (Pointer<Void> _) => ObjCBlock_ffiVoid.fromFunction(() {}),
            );
        return blk(nullptr);
      });
    }, skip: !canDoGC);

    test('RetainedBlockProducer, defined dart, invoked objC', () {
      blockProducerTest(() {
        ObjCBlock<Retained<DartEmptyBlock> Function(Pointer<Void>)> blk =
            ObjCBlock_EmptyBlock_ffiVoid$1.fromFunction(
              (Pointer<Void> _) => ObjCBlock_ffiVoid.fromFunction(() {}),
            );
        return BlockAnnotationTest.invokeRetainedBlockProducer(
          ObjCBlock<DartEmptyBlock Function(Pointer<Void>)>(
            blk.ref.pointer,
            retain: true,
            release: true,
          ),
        );
      });
    }, skip: !canDoGC);
  });
}
