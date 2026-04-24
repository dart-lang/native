// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')
library;

import 'package:objective_c/objective_c.dart';
import 'package:objective_c/src/objective_c_bindings_generated.dart'
    show ObjCBlock_ffiVoid_ffiVoid_NSStream_NSStreamEvent;
import 'package:test/test.dart';

import 'util.dart';

// Checks that a protocol object built by ObjCProtocolBuilder.build() retains a
// positive retain count after GC. Intentionally never-inlined so the JIT
// performs its own liveness analysis on a proper synchronous stack frame.
// In an async state machine, Finalizable liveness across await points is
// unreliable: variables not referenced after a suspension point may be dropped
// from the GC root set, causing premature release on aggressively-optimising
// platforms (e.g. ARM64 CI).
@pragma('vm:never-inline')
bool _buildAndCheckProtocolObject() {
  final builder = ObjCProtocolBuilder();
  final obj = builder.build(keepIsolateAlive: false);
  // ObjCObjectRef is Finalizable. Because this function is never-inlined, the
  // JIT tracks ref in the GC stack map throughout the frame — including across
  // the non-leaf FFI safepoints inside doGC() and objectRetainCount().
  final ref = obj.ref;
  final raw = ref.pointer;
  doGC();
  return objectRetainCount(raw) > 0;
}

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
  return blockRetainCount(ptr) > 0;
}

void main() {
  group('object model', () {
    test('protocol object survives GC after build', () {
      if (!canDoGC) {
        markTestSkipped(
          'Dart_ExecuteInternalCommand unavailable — gc-now is a no-op.',
        );
        return;
      }
      expect(_buildAndCheckProtocolObject(), isTrue);
    });
  });

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
}
