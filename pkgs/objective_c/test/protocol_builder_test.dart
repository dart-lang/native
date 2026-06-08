// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')
library;

import 'dart:ffi';

import 'package:objective_c/objective_c.dart';
import 'package:objective_c/src/objective_c_bindings_generated.dart'
    show ObjCBlock_ffiVoid_ffiVoid_NSStream_NSStreamEvent;
import 'package:test/test.dart';

import 'util.dart';

@Native<Uint64 Function(Pointer<Void>)>(
  isLeaf: true,
  symbol: 'getBlockRetainCount',
)
external int _getBlockRetainCount(Pointer<Void> block);

// Directly exercises the blockRef extraction pattern from the production fix.
// Extract block.ref into a local `blockRef` (static type ObjCBlockRef, which
// transitively implements Finalizable). The Finalizable contract keeps blockRef
// live in the GC stack map across the non-leaf FFI safepoint below.
//
// Intentionally never-inlined so the JIT performs its own liveness analysis.
@pragma('vm:never-inline')
bool _gcAndCheckBlock() {
  final block = ObjCBlock_ffiVoid_ffiVoid_NSStream_NSStreamEvent.fromFunction(
    (_, stream, event) {},
    keepIsolateAlive: false,
  );
  final blockRef = block.ref;
  final ptr = blockRef.pointer;
  // Use callGCNowFromNative (non-leaf safepoint) to trigger GC, then check
  // the retain count via blockRetainCount, which reads the block ABI flags
  // field — the correct location for block retain counts on all architectures.
  callGCNowFromNative();
  return _getBlockRetainCount(ptr.cast()) > 0;
}

void main() {
  group('block wrapper not freed at GC safepoints', () {
    setUpAll(() {
      initGCInject();
      installGCInjectSwizzle();
    });

    tearDownAll(removeGCInjectSwizzle);

    // Diagnostic: verify that gc-now from native code actually triggers GC.
    // If this test fails, the GC-injection swizzle is a no-op and the
    // reproduction test below is not meaningful.
    test('gc-now from native code collects unreachable objects', () {
      if (!canDoGC) {
        markTestSkipped(
          'Dart_ExecuteInternalCommand unavailable — GC injection is a no-op.',
        );
        return;
      }
      expect(gcNowAvailableFromNative(), isTrue);

      WeakReference<Object>? weakRef;
      (() {
        final obj = Object();
        weakRef = WeakReference(obj);
      })();

      callGCNowFromNative();

      expect(weakRef!.target, isNull);
    });

    // Swizzle injects gc-now before ObjC retains the block. Without the
    // blockRef extraction fix, the optimizer marks `block` dead after its raw
    // pointer is extracted and GC drops the retain count to 0.
    // Run 1000 iterations to trigger JIT optimisation of implementMethod.
    test('block survives GC injected inside implementMethod '
        '(fails without blockRef extraction)', () {
      const kIterations = 1000;
      for (var i = 0; i < kIterations; i++) {
        final builder = ObjCProtocolBuilder();
        setGCInjectActive(true);
        NSStreamDelegate$Builder.stream_handleEvent_.implement(
          builder,
          (stream, event) {},
        );
        setGCInjectActive(false);
        // wasBlockFreedBeforeRetain() is sticky: stays true once set.
        if (wasBlockFreedBeforeRetain()) break;
      }

      expect(
        wasBlockFreedBeforeRetain(),
        isFalse,
        reason:
            'Block was prematurely released by GC before ObjC retained it. '
            'blockRef extraction in implementMethod is required (issue #3209).',
      );
    });

    test('block local NOT freed at non-leaf FFI safepoint', () {
      // Guaranteed to reproduce on iteration 1 with:
      //   dart --optimization-counter-threshold=0 test ...
      if (!canDoGC) {
        markTestSkipped(
          'Dart_ExecuteInternalCommand unavailable — gc-now is a no-op, '
          'test would pass vacuously.',
        );
        return;
      }
      const kIterations = 1000;
      for (var i = 0; i < kIterations; i++) {
        final survived = _gcAndCheckBlock();
        if (!survived) {
          fail(
            'Block wrapper was GC-collected at FFI safepoint on iteration $i. '
            'blockRef extraction in implementMethod required (issue #3209).',
          );
        }
      }
    });
  });

  group('builder NOT released during buildInstance '
      '(regression for production crash, same family as #3209)', () {
    setUpAll(() {
      initGCInject();
      installBuildInstanceSwizzle();
    });

    tearDownAll(removeBuildInstanceSwizzle);

    // Swizzle injects gc-now inside buildInstance:. Without ffigen extracting
    // the receiver's .ref into a Finalizable local before the FFI call (see
    // https://github.com/dart-lang/native/pull/3352), the AOT optimizer can
    // mark the wrapper dead immediately after pointer extraction; if GC runs
    // at the safepoint, the wrapper's Finalizer calls objc_release on the
    // builder, dealloc tombstones the ISA, and objc_msgSend crashes on the
    // now-dangling receiver. The swizzle uses CFRetain/CFRelease around the
    // gc-now so we observe the cause (a retain-count drop) instead of the
    // crash itself.
    //
    // Reproduces deterministically in AOT (`dart test -c exe`) on iteration 0
    // when the ffigen extraction is reverted. In JIT the bug is non-
    // deterministic, but the test still runs as a smoke check that the
    // swizzle infrastructure is wired up and no regression is observable
    // under 1000 iterations.
    test('builder survives GC injected inside buildInstance '
        '(fails in AOT without ffigen #3352 ref extraction)', () {
      if (!canDoGC) {
        markTestSkipped(
          'Dart_ExecuteInternalCommand unavailable — GC injection is a no-op.',
        );
        return;
      }
      const kIterations = 1000;
      for (var i = 0; i < kIterations; i++) {
        final builder = ObjCProtocolBuilder();
        // Drain transient wrappers created inside _createBuilder() (e.g. the
        // alloc() result that's a separate Dart wrapper for the same ObjC
        // object) before we enter the measurement window. Otherwise their
        // Finalizers can fire during the swizzled gc-now and report as a
        // release that isn't actually the receiver of buildInstance:.
        doGC();
        setGCInjectActive(true);
        final instance = builder.build(keepIsolateAlive: false);
        setGCInjectActive(false);
        // Touch instance so the optimizer cannot dead-store the whole call.
        if (instance.ref.pointer == nullptr) {
          fail('buildInstance returned nullptr on iteration $i.');
        }
        // wasBuilderReleasedDuringBuildInstance is sticky: stays true once set.
        if (wasBuilderReleasedDuringBuildInstance()) break;
      }

      expect(
        wasBuilderReleasedDuringBuildInstance(),
        isFalse,
        reason:
            'Builder was released by Dart finalizer during buildInstance '
            'call. The receiver-side .ref extraction generated by ffigen '
            'is required (analogous to issue #3209).',
      );
    });
  });
}
