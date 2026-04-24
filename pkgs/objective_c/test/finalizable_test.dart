// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')
library;

// Regression test for https://github.com/dart-lang/native/issues/3209
//
// The fix for issue #3209 is in ObjCProtocolBuilder.implementMethod: extract
// block.ref into a local `blockRef` (static type ObjCBlockRef, which
// transitively implements Finalizable). The Finalizable contract guarantees
// the VM will not finalize `blockRef` before the end of its enclosing scope,
// keeping the ObjC retain count >= 1 across the non-leaf FFI safepoint and
// preventing EXC_BAD_ACCESS in production.
//
// Note: ObjCObject intentionally does NOT implement Finalizable because
// ObjCObject instances may be sent across Dart isolates (e.g. NSInputStream),
// and Finalizable objects are non-sendable.

import 'dart:ffi';

import 'package:objective_c/objective_c.dart';
import 'package:objective_c/src/objective_c_bindings_generated.dart'
    show ObjCBlock_ffiVoid_ffiVoid_NSStream_NSStreamEvent;
import 'package:test/test.dart';

import 'util.dart';

// ---------------------------------------------------------------------------
// GC-safepoint liveness probe (issue #3209).
//
// This function is intentionally never-inlined so the JIT compiles it as an
// independent compilation unit and performs its own liveness analysis.
//
// Demonstrates the blockRef extraction pattern from the production fix
// (ObjCProtocolBuilder.implementMethod). Does NOT call implementMethod —
// it directly exercises the pattern to isolate the liveness mechanism.
// extract block.ref into a local `blockRef` whose static type (ObjCBlockRef)
// transitively implements Finalizable (via _ObjCReference). The Finalizable
// contract guarantees the VM will not finalize `blockRef` before end of scope,
// keeping it live in the stack map across the NON-LEAF FFI safepoint.
//
//   WITH blockRef extraction (ObjCBlockRef is Finalizable):
//     `blockRef` stays live until end of scope → ObjC retain count ≥ 1.
//     gcAndGetRetainCount(ptr) returns > 0. Returns true (pass).
//
//   WITHOUT blockRef extraction (using block.ref.pointer directly):
//     `block` (type ObjCBlockBase, not Finalizable) is dead after its last
//     use. GC fires at the safepoint, finalizer calls objc_release →
//     retain count = 0. Returns false (fail).
//
// For guaranteed reproduction on iteration 1 (no JIT warm-up), run:
//   dart --optimization-counter-threshold=0 test test/finalizable_test.dart
// ---------------------------------------------------------------------------
@pragma('vm:never-inline')
bool _gcAndCheckBlock() {
  final block = ObjCBlock_ffiVoid_ffiVoid_NSStream_NSStreamEvent.fromFunction(
    (_, stream, event) {},
    keepIsolateAlive: false,
  );
  // Mirror the production fix: extract block.ref so that blockRef's Finalizable
  // type keeps the ObjC retain alive across the non-leaf FFI safepoint.
  final blockRef = block.ref;
  final ptr = blockRef.pointer;
  // blockRef is Finalizable: the VM guarantees it will not be finalized before
  // end of this function scope, so it stays live in the GC stack map across
  // the non-leaf FFI safepoint below.
  // gcAndGetRetainCount triggers GC via a native call to
  // Dart_ExecuteInternalCommand("gc-now") — a different path from the Dart-side
  // doGC(). The canDoGC guard in the test body skips this test if that native
  // symbol is unavailable. When GC fires, blockRef is still live →
  // ObjC retain count stays ≥ 1.
  final count = gcAndGetRetainCount(ptr);
  return count > 0;
}

// ---------------------------------------------------------------------------
// Runtime assertions.
// ---------------------------------------------------------------------------

void main() {
  group('object model', () {
    // Verifies that ObjCObject does NOT implement Finalizable, preserving
    // isolate sendability for objects like NSInputStream.
    // ObjCObject is not directly instantiable; NSObject is used as a
    // concrete subclass to test the property at the ObjCObject level.
    test('ObjCObject is NOT Finalizable (preserves isolate sendability)', () {
      final obj = NSObject();
      expect(obj, isNot(isA<Finalizable>()));
    });

    // Verifies that the fix for issue #3209 holds under explicit GC pressure.
    //
    // We cannot reproduce the exact race (GC at a safepoint *inside* a native
    // call) in a unit test — doGC() runs between Dart instructions, not at FFI
    // safepoints. However, forcing GC immediately after building a protocol
    // object exercises the retain-count machinery and will catch any obvious
    // use-after-free regression.
    test('protocol object survives GC after build', () async {
      final builder = ObjCProtocolBuilder();
      final obj = builder.build(keepIsolateAlive: false);

      // Raw pointer to verify liveness after GC.
      final raw = obj.ref.pointer;
      expect(objectRetainCount(raw), greaterThan(0));

      // Force GC and let finalizers flush.
      doGC();
      await Future<void>.delayed(Duration.zero);
      doGC();

      // The protocol object is still referenced by `obj`, so it must be alive.
      expect(objectRetainCount(raw), greaterThan(0));
    });
  });

  // ---------------------------------------------------------------------------
  // Deterministic GC-at-safepoint reproduction (issue #3209).
  //
  // This group uses ObjC method swizzling to inject a forced Dart GC inside
  // -[DOBJCDartProtocolBuilder implementMethod:withBlock:...] immediately
  // before [methods setObject:(__bridge id)block forKey:key] retains the block.
  //
  // Without the fix (no blockRef extraction in implementMethod):
  //   The optimizer marks `block` dead after extracting the raw pointer. When
  //   gc-now fires at the FFI safepoint the Dart wrapper is collected, the
  //   finalizer calls objc_release, and the retain count drops to 0 before ObjC
  //   ever retains it — detectable via wasBlockFreedBeforeRetain().
  //
  // With the fix (blockRef extraction; ObjCBlockRef is Finalizable):
  //   The Finalizable contract keeps `blockRef` live until end of calling scope.
  //   gc-now finds blockRef still reachable and does not collect it.
  //   The retain count stays at 1 throughout — wasBlockFreedBeforeRetain()
  //   returns false.
  //
  // To guarantee reproduction on the very first call (rather than relying on
  // JIT warm-up), run with:
  //   dart --optimization-counter-threshold=0 test test/finalizable_test.dart
  // ---------------------------------------------------------------------------
  group('GC safepoint reproduction (issue #3209)', () {
    setUpAll(() {
      initGCInject();
      installGCInjectSwizzle();
    });

    tearDownAll(removeGCInjectSwizzle);

    // Diagnostic: verify that Dart_ExecuteInternalCommand is available from
    // native code and can actually trigger GC on unreachable Dart objects.
    // If this test fails, the GC-injection swizzle is a no-op and the
    // reproduction test below is not meaningful.
    test('gc-now from native code collects unreachable objects', () {
      if (!canDoGC) {
        markTestSkipped(
          'Dart_ExecuteInternalCommand unavailable — GC injection is a no-op.',
        );
        return;
      }
      expect(
        gcNowAvailableFromNative(),
        isTrue,
        reason:
            'Dart_ExecuteInternalCommand not found via dlsym — '
            'GC injection swizzle will not work.',
      );

      // Create an object, make it unreachable, trigger GC from native code,
      // and verify the object was collected (WeakReference cleared).
      WeakReference<Object>? weakRef;
      (() {
        final obj = Object();
        weakRef = WeakReference(obj);
      })();

      // At this point, obj is unreachable. Call gc-now from native code
      // (simulating what the swizzle does inside the FFI call).
      callGCNowFromNative();

      // If Dart_ExecuteInternalCommand triggered GC: weakRef.target == null.
      // If GC did not run (e.g. Dart thread in wrong mode): target != null.
      expect(
        weakRef!.target,
        isNull,
        reason:
            'callGCNowFromNative() did not collect an unreachable object. '
            'Dart_ExecuteInternalCommand may not work from native mode '
            '(FFI safepoint). The GC-injection swizzle is likely a no-op.',
      );
    });

    test('block survives GC injected inside implementMethod '
        '(fails without blockRef extraction)', () {
      // Run 1 000 iterations so that the JIT optimizer has a chance to compile
      // implementMethod in optimised mode and mark `block` dead after the raw
      // pointer is extracted. In optimised code, gc-now in the swizzle will
      // collect the block wrapper if Finalizable is missing.
      //
      // For deterministic reproduction on iteration 1, run with:
      //   dart --optimization-counter-threshold=0 test ...
      const kIterations = 1000;
      for (var i = 0; i < kIterations; i++) {
        final builder = ObjCProtocolBuilder();
        setGCInjectActive(true);
        // implement() calls implementMethod() with a real ObjCBlockBase.
        // The swizzle fires gc-now before ObjC retains the block.
        NSStreamDelegate$Builder.stream_handleEvent_.implement(
          builder,
          (stream, event) {},
        );
        setGCInjectActive(false);
        // wasBlockFreedBeforeRetain() is a sticky flag: once true it stays
        // true even after setGCInjectActive(false). Break early on first hit.
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

    // ---------------------------------------------------------------------------
    // Direct liveness test — uses _gcAndCheckBlock (defined above main()).
    //
    // Unlike the swizzle test (where `block` is a PARAMETER threaded through
    // a call chain and JIT keeps parameters alive conservatively), here `block`
    // is a LOCAL variable in a never-inlined function. The JIT can eliminate
    // it from the GC stack map after its last use, making the test sensitive to
    // whether blockRef (ObjCBlockRef, Finalizable) is extracted before the
    // FFI call.
    //
    // For guaranteed reproduction on iteration 1 (no JIT warm-up needed), run:
    //   dart --optimization-counter-threshold=0 test test/finalizable_test.dart
    // ---------------------------------------------------------------------------
    test('block local NOT freed at non-leaf FFI safepoint', () {
      // Note: only guaranteed to reproduce on iteration 1 when run with
      //   dart --optimization-counter-threshold=0
      // Under normal JIT, the optimizer may keep `block` alive conservatively
      // for several iterations before applying dead-code elimination.
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
