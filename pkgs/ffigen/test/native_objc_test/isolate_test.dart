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

      final pointer = sendable.pointer;
      expect(objectRetainCount(pointer), 1);

      expect(await queue.next, null); // onExit
      port.close();

      sendable = null;
      doGC();
      expect(objectRetainCount(pointer), 0);
    });

    test('Capturing object in closure', () async {
      Sendable? sendable = Sendable.new1();
      sendable.value = 123;

      final oldValue = await Isolate.run(() {
        final oldValue = sendable!.value;
        sendable!.value = 456;
        return oldValue;
      });

      expect(oldValue, 123);
      expect(sendable.value, 456);

      final pointer = sendable.pointer;
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

      final pointer = block.pointer;
      expect(blockRetainCount(pointer), 1);

      expect(await queue.next, null); // onExit
      port.close();

      block = null;
      doGC();
      expect(blockRetainCount(pointer), 0);
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

      await Isolate.run(() {
        block!(123);
      });
      final value = await completer.future;
      expect(value, 123);

      final pointer = block.pointer;
      expect(blockRetainCount(pointer), 1);

      block = null;
      doGC();
      expect(blockRetainCount(pointer), 0);
    });

    test('Manual release across isolates', () async {
      final sendable = Sendable.new1();
      final pointer = sendable.pointer;

      expect(objectRetainCount(pointer), 1);
      expect(sendable.isReleased, isFalse);

      final (oldIsReleased, newIsReleased) = await Isolate.run(() {
        final oldIsReleased = sendable.isReleased;
        sendable!.release();
        return (oldIsReleased, sendable.isReleased);
      });

      expect(oldIsReleased, isFalse);
      expect(newIsReleased, isTrue);

      expect(sendable.isReleased, isTrue);
      expect(objectRetainCount(pointer), 0);
    });

    test('Use after release and double release', () async {
      final sendable = Sendable.new1();
      sendable.value = 123;
      final pointer = sendable.pointer;

      expect(sendable.isReleased, isFalse);

      await Isolate.run(() {
        sendable!.release();
      });

      expect(sendable.isReleased, isTrue);
      expect(() => sendable.value, throwsA(isA<UseAfterReleaseError>()));
      expect(() => sendable.release(), throwsA(isA<DoubleReleaseError>()));
    });
  });
}
