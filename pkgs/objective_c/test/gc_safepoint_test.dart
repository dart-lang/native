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
  final count = gcAndGetRetainCount(ptr);
  return count > 0;
}

void main() {
  group('object model', () {
    test('protocol object survives GC after build', () async {
      final builder = ObjCProtocolBuilder();
      final obj = builder.build(keepIsolateAlive: false);

      final raw = obj.ref.pointer;
      expect(objectRetainCount(raw), greaterThan(0));

      doGC();
      await Future<void>.delayed(Duration.zero);
      doGC();

      expect(objectRetainCount(raw), greaterThan(0));
      // Keeps obj live through the GC calls above. Without this, the JIT
      // optimizer drops obj from the GC stack map after raw is extracted,
      // causing it to be collected before the retain count check.
      expect(obj, isNotNull);
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
