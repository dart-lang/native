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
import 'package:objective_c/objective_c.dart';
import 'package:test/test.dart';
import '../test_utils.dart';
import 'isolate_bindings.dart';
import 'util.dart';

// TODO(https://github.com/dart-lang/coverage/issues/472): Delete this and use
// Isolate.run once the coverage bug is fixed.
Future<R> isolateRun<R>(FutureOr<R> computation()) async {
  FutureOr<R> Function()? comp = computation;
  Future<void> run(SendPort sendPort) async {
    sendPort.send(await comp!());
    comp = null;
    sendPort.send(null);
    Isolate.current.kill();
  }

  final port = ReceivePort();
  final queue = StreamQueue(port);
  final isolate = await Isolate.spawn(run, port.sendPort);
  final result = await queue.next as R;
  await queue.next; // Wait for isolate to release its reference to comp.
  port.close();
  return result;
}

void main() {
  group('isolate', () {
    setUpAll(() {
      // TODO(https://github.com/dart-lang/native/issues/1068): Remove this.
      DynamicLibrary.open('../objective_c/test/objective_c.dylib');
      final dylib = File('test/native_objc_test/isolate_test.dylib');
      verifySetupFile(dylib);
      DynamicLibrary.open(dylib.absolute.path);
      generateBindingsForCoverage('isolate');
    });

    // Runs on other isolate (can't use expect function).
    void sendingObjectTest(SendPort sendPort) async {
      final port = ReceivePort();
      final queue = StreamQueue(port);
      sendPort.send(port.sendPort);

      final sendable = await queue.next as Sendable;
      final oldValue = sendable.value;

      sendable.value = 456;
      sendPort.send(oldValue);
      port.close();

      // TODO(https://github.com/dart-lang/coverage/issues/472): Delete this.
      sendPort.send(null);
      Isolate.current.kill();
    }

    test('Sending object through a port', () async {
      Sendable? sendable = Sendable.new1();
      sendable.value = 123;

      final port = ReceivePort();
      final queue = StreamQueue(port);
      final isolate = await Isolate.spawn(sendingObjectTest, port.sendPort,
          onExit: port.sendPort);

      final sendPort = await queue.next as SendPort;
      sendPort.send(sendable);

      final oldValue = await queue.next;
      expect(oldValue, 123);
      expect(sendable.value, 456);

      final pointer = sendable.ref.pointer;
      expect(objectRetainCount(pointer), 1);

      expect(await queue.next, null); // onExit
      port.close();

      sendable = null;
      doGC();
      // TODO(https://github.com/dart-lang/coverage/issues/472): Re-enable.
      // expect(objectRetainCount(pointer), 0);
    });

    test('Capturing object in closure', () async {
      Sendable? sendable = Sendable.new1();
      sendable.value = 123;

      final oldValue = await isolateRun(() {
        final oldValue = sendable!.value;
        sendable!.value = 456;
        return oldValue;
      });

      expect(oldValue, 123);
      expect(sendable.value, 456);

      final pointer = sendable.ref.pointer;
      expect(objectRetainCount(pointer), 1);

      sendable = null;
      doGC();
      expect(objectRetainCount(pointer), 0);
    });

    // Runs on other isolate (can't use expect function).
    void sendingBlockTest(SendPort sendPort) async {
      final port = ReceivePort();
      final queue = StreamQueue(port);
      sendPort.send(port.sendPort);

      final block = await queue.next as ObjCBlock<Void Function(Int32)>;
      block(123);
      port.close();

      // TODO(https://github.com/dart-lang/coverage/issues/472): Delete this.
      sendPort.send(null);
      Isolate.current.kill();
    }

    test('Sending block through a port', () async {
      final completer = Completer<int>();
      ObjCBlock<Void Function(Int32)>? block =
          ObjCBlock_ffiVoid_Int32.listener((int value) {
        completer.complete(value);
      });

      final port = ReceivePort();
      final queue = StreamQueue(port);
      final isolate = await Isolate.spawn(sendingBlockTest, port.sendPort,
          onExit: port.sendPort);

      final sendPort = await queue.next as SendPort;
      sendPort.send(block);

      final value = await completer.future;
      expect(value, 123);

      final pointer = block.ref.pointer;
      expect(blockRetainCount(pointer), 1);

      expect(await queue.next, null); // onExit
      port.close();

      block = null;
      doGC();
      // TODO(https://github.com/dart-lang/coverage/issues/472): Re-enable.
      // expect(blockRetainCount(pointer), 0);
    });

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

      await isolateRun(() {
        block!(123);
      });
      final value = await completer.future;
      expect(value, 123);

      final pointer = block.ref.pointer;
      expect(blockRetainCount(pointer), 1);

      block = null;
      doGC();
      expect(blockRetainCount(pointer), 0);
    });

    test('Manual release across isolates', () async {
      final sendable = Sendable.new1();
      final pointer = sendable.ref.pointer;

      expect(objectRetainCount(pointer), 1);
      expect(sendable.ref.isReleased, isFalse);

      final (oldIsReleased, newIsReleased) = await isolateRun(() {
        final oldIsReleased = sendable.ref.isReleased;
        sendable!.ref.release();
        return (oldIsReleased, sendable.ref.isReleased);
      });

      expect(oldIsReleased, isFalse);
      expect(newIsReleased, isTrue);

      expect(sendable.ref.isReleased, isTrue);
      expect(objectRetainCount(pointer), 0);
    });

    test('Use after release and double release', () async {
      final sendable = Sendable.new1();
      sendable.value = 123;
      final pointer = sendable.ref.pointer;

      expect(sendable.ref.isReleased, isFalse);

      await isolateRun(() {
        sendable!.ref.release();
      });

      expect(sendable.ref.isReleased, isTrue);
      expect(() => sendable.value, throwsA(isA<UseAfterReleaseError>()));
      expect(() => sendable.ref.release(), throwsA(isA<DoubleReleaseError>()));
    });
  });
}
