// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')
import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

import 'package:async/async.dart';
import 'package:ffi/ffi.dart';
import 'package:objective_c/objective_c.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';
import '../test_utils.dart';
import 'isolate_test_bindings.dart';
import 'util.dart';

void main() {
  group('isolate', () {
    setUpAll(() {
      loadLibrary();
    });

    // Runs on other isolate (can't use expect function).
    void sendingObjectTest(SendPort sendPort) async {
      loadLibrary();
      final port = ReceivePort();
      final queue = StreamQueue(port);
      sendPort.send(port.sendPort);

      final sendable = await queue.next as Sendable;
      final oldValue = sendable.value;

      sendable.value = 456;
      sendPort.send(oldValue);
      port.close();
    }

    test('Sending object through a port', () async {
      final arena = Arena();
      try {
        final tracker = ReferenceTracker(arena);
        Sendable? sendable = Sendable();
        sendable.value = 123;
        tracker.track(sendable);

        final port = ReceivePort();
        final queue = StreamQueue(port);
        final isolate = await Isolate.spawn(
          sendingObjectTest,
          port.sendPort,
          onExit: port.sendPort,
        );

        final sendPort = await queue.next as SendPort;
        sendPort.send(sendable);

        final oldValue = await queue.next;
        expect(oldValue, 123);
        expect(sendable.value, 456);

        expect(tracker.isAlive, true);

        expect(await queue.next, null); // onExit
        port.close();

        sendable = null;
        doGC();
        expect(tracker.isAlive, false);
      } finally {
        arena.releaseAll();
      }
    }, skip: !canDoGC);

    test('Capturing object in closure', () async {
      final arena = Arena();
      try {
        final tracker = ReferenceTracker(arena);
        Sendable? sendable = Sendable();
        sendable.value = 123;
        tracker.track(sendable);

        final oldValue = await Isolate.run(() {
          loadLibrary();
          final oldValue = sendable!.value;
          sendable!.value = 456;
          return oldValue;
        });

        expect(oldValue, 123);
        expect(sendable.value, 456);

        expect(tracker.isAlive, true);

        sendable = null;
        doGC();
        expect(tracker.isAlive, false);
      } finally {
        arena.releaseAll();
      }
    }, skip: !canDoGC);

    // Runs on other isolate (can't use expect function).
    void sendingBlockTest(SendPort sendPort) async {
      loadLibrary();
      final port = ReceivePort();
      final queue = StreamQueue(port);
      sendPort.send(port.sendPort);

      final block = await queue.next as ObjCBlock<Void Function(Int32)>;
      block(123);
      port.close();
    }

    test('Sending block through a port', () async {
      final completer = Completer<int>();
      ObjCBlock<Void Function(Int32)>? block = ObjCBlock_ffiVoid_Int32.listener(
        (int value) {
          completer.complete(value);
        },
      );

      final arena = Arena();
      try {
        final tracker = ReferenceTracker(arena);
        tracker.track(
          ObjCObject(block!.ref.pointer.cast(), retain: false, release: false),
        );

        final port = ReceivePort();
        final queue = StreamQueue(port);
        final isolate = await Isolate.spawn(
          sendingBlockTest,
          port.sendPort,
          onExit: port.sendPort,
        );

        final sendPort = await queue.next as SendPort;
        sendPort.send(block);

        final value = await completer.future;
        expect(value, 123);

        expect(tracker.isAlive, true);

        expect(await queue.next, null); // onExit
        port.close();

        block = null;
        doGC();
        expect(tracker.isAlive, false);
      } finally {
        arena.releaseAll();
      }
    }, skip: !canDoGC);

    ObjCBlock<Void Function(Int32)> makeBlock(Completer<int> completer) {
      // Creating this block in a separate function to make sure completer is
      // not captured in Isolate.run's lambda.
      return ObjCBlock_ffiVoid_Int32.listener((int value) {
        completer.complete(value);
      });
    }

    test('Capturing block in closure', () async {
      final completer = Completer<int>();
      ObjCBlock<Void Function(Int32)>? block = makeBlock(completer);

      final arena = Arena();
      try {
        final tracker = ReferenceTracker(arena);
        tracker.track(
          ObjCObject(block.ref.pointer.cast(), retain: false, release: false),
        );

        await Isolate.run(() {
          loadLibrary();
          block!(123);
        });
        final value = await completer.future;
        expect(value, 123);

        expect(tracker.isAlive, true);

        block = null;
        doGC();
        expect(tracker.isAlive, false);
      } finally {
        arena.releaseAll();
      }
    }, skip: !canDoGC);

    test('Manual release across isolates', () async {
      final arena = Arena();
      try {
        final tracker = ReferenceTracker(arena);
        Sendable? sendable = Sendable();
        tracker.track(sendable);

        expect(tracker.isAlive, true);
        expect(sendable!.ref.isReleased, isFalse);

        final (oldIsReleased, newIsReleased) = await Isolate.run(() {
          loadLibrary();
          final oldIsReleased = sendable!.ref.isReleased;
          sendable!.ref.release();
          return (oldIsReleased, sendable!.ref.isReleased);
        });

        expect(oldIsReleased, isFalse);
        expect(newIsReleased, isTrue);

        expect(sendable!.ref.isReleased, isTrue);
        sendable = null;
        doGC();
        expect(tracker.isAlive, false);
      } finally {
        arena.releaseAll();
      }
    });

    test('Use after release and double release', () async {
      final sendable = Sendable();
      sendable.value = 123;

      expect(sendable.ref.isReleased, isFalse);

      await Isolate.run(() {
        loadLibrary();
        sendable!.ref.release();
      });

      expect(sendable.ref.isReleased, isTrue);
      expect(() => sendable.value, throwsA(isA<UseAfterReleaseError>()));
      expect(() => sendable.ref.release(), throwsA(isA<DoubleReleaseError>()));
    });
  });
}
