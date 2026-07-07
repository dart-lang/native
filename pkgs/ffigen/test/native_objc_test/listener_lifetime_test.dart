// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')
library;

import 'dart:async';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:objective_c/objective_c.dart';
import 'package:test/test.dart';

import '../test_utils.dart';
import 'listener_lifetime_test_bindings.dart';
import 'util.dart';

void main() {
  group('listener lifetime', () {
    // Regression tests for https://github.com/dart-lang/native/issues/3265:
    // invoking a listener block after its owner isolate shut down used to hit
    // a deleted NativeCallable and abort the process.

    // Creates a listener block in a short-lived isolate, stores it in
    // [tester], and returns after that isolate has fully shut down.
    Future<void> storeListenerFromDeadIsolate(
      ListenerLifetimeTester tester,
    ) async {
      await Isolate.run(() {
        tester.storedListener = ObjCBlock_ffiVoid_NSObject.listener((
          NSObject obj,
        ) {
          // Never runs; the owner isolate is dead when the block is invoked.
        }, keepIsolateAlive: false);
      });
      // Give the dead isolate's ports time to fully close.
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }

    test('invoking after the owner isolate died is a safe no-op', () async {
      await using((arena) async {
        final tester = ListenerLifetimeTester();
        await storeListenerFromDeadIsolate(tester);

        final blockTracker = ReferenceTracker(arena);
        final argTracker = ReferenceTracker(arena);

        NSObject? arg = NSObject();
        argTracker.track(arg);

        // The property getter and the invocation autorelease references to
        // the block, so scope them to a pool to make the tracker assertions
        // below deterministic.
        autoReleasePool(() {
          blockTracker.trackBlock(tester.storedListener);

          // Previously aborted the process; now a safe no-op that releases
          // the args.
          tester.invokeStoredWithArg(arg!);
        });

        arg = null;
        doGC();
        expect(argTracker.isAlive, false);

        // The block is still retained by the tester. Releasing that reference
        // must free it, even though its dispose port belongs to the dead
        // isolate.
        expect(blockTracker.isAlive, true);
        tester.clearStored();
        doGC();
        expect(blockTracker.isAlive, false);
      });
    }, skip: !canDoGC);

    test('invoking from another thread after the owner died is safe', () async {
      await using((arena) async {
        final tester = ListenerLifetimeTester();
        await storeListenerFromDeadIsolate(tester);

        final argTracker = ReferenceTracker(arena);
        NSObject? arg = NSObject();
        argTracker.track(arg);

        tester.invokeStoredOnNewThreadWithArg(arg);

        arg = null;
        doGC();
        expect(argTracker.isAlive, false);
      });
    }, skip: !canDoGC);

    test('repeated invocations after the owner died clean up '
        'exactly once', () async {
      await using((arena) async {
        final tester = ListenerLifetimeTester();
        await storeListenerFromDeadIsolate(tester);

        final trackers = <ReferenceTracker>[];
        for (var i = 0; i < 100; ++i) {
          final tracker = ReferenceTracker(arena);
          NSObject? arg = NSObject();
          tracker.track(arg);
          tester.invokeStoredWithArg(arg);
          arg = null;
          trackers.add(tracker);
        }

        doGC();
        for (final tracker in trackers) {
          // A double release would have crashed above; a missed release shows
          // up here as a still-alive arg.
          expect(tracker.isAlive, false);
        }
      });
    }, skip: !canDoGC);

    test('invocations are delivered in order', () async {
      final received = <int>[];
      final done = Completer<void>();
      final block = ObjCBlock_ffiVoid_Int32.listener((int value) {
        received.add(value);
        if (received.length == 1000) done.complete();
      });

      ListenerLifetimeTester.invoke(block, times: 1000);

      await done.future;
      expect(received, List.generate(1000, (i) => i));
    });

    test('struct-by-value args are delivered intact', () async {
      final done = Completer<(int, int)>();
      final block = ObjCBlock_ffiVoid_NSRange.listener((NSRange range) {
        done.complete((range.location, range.length));
      });

      ListenerLifetimeTester.invokeRange(block, location: 123, length: 456);

      final (location, length) = await done.future;
      expect(location, 123);
      expect(length, 456);
    });

    test('object args are delivered and adopted while the owner '
        'is alive', () async {
      await using((arena) async {
        final argTracker = ReferenceTracker(arena);
        final done = Completer<void>();

        final tester = ListenerLifetimeTester();
        tester.storedListener = ObjCBlock_ffiVoid_NSObject.listener((
          NSObject obj,
        ) {
          done.complete();
        });

        NSObject? arg = NSObject();
        argTracker.track(arg);
        tester.invokeStoredOnNewThreadWithArg(arg);
        await done.future;

        arg = null;
        tester.clearStored();
        doGC();
        expect(argTracker.isAlive, false);
      });
    }, skip: !canDoGC);
  });
}
