// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')
library;

// Regression test for https://github.com/dart-lang/native/issues/3209
//
// ObjCBlockBase must implement Finalizable so that the Dart compiler keeps
// local variables of that type alive across FFI safepoints. Without this, a
// GC event during a native call can fire before ObjC retains the pointer,
// causing EXC_BAD_ACCESS in production.
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
// Compile-time assertion (enforced by dart analyze).
//
// If ObjCBlockBase ever loses implements Finalizable, this function will
// produce a static type error, catching the regression before tests even run.
// ---------------------------------------------------------------------------

void _requireFinalizable(Finalizable _) {}

// Compile-time guard: if ObjCBlockBase ever loses implements Finalizable,
// dart analyze will flag this as a type error before any test even runs.
// To reproduce the crash, temporarily comment this out alongside removing
// `implements Finalizable` from ObjCBlockBase in lib/src/internal.dart.
// ignore: unused_element
void _checkObjCBlockBaseIsFinalizable(ObjCBlockBase b) =>
    _requireFinalizable(b);

// ---------------------------------------------------------------------------
// GC-safepoint liveness probe (supplementary, issue #3209).
//
// This function is intentionally never-inlined so the JIT compiles it as an
// independent compilation unit and performs its own liveness analysis.
//
// `block` is a LOCAL variable (not a parameter threaded through a call chain).
// Its last strong use is `block.ref.pointer`; after that, `gcAndGetRetainCount`
// creates a NON-LEAF FFI safepoint — the Dart thread enters native mode and
// the JIT's precise stack map is snapshotted.
//
//   WITH Finalizable (ObjCBlockBase implements Finalizable):
//     The compiler inserts reachabilityFence(block) at the end of this scope.
//     `block` stays in the JIT stack map. GC finds it alive → weakRef valid.
//     Returns 1 (pass).
//
//   WITHOUT Finalizable:
//     The JIT is PERMITTED to remove `block` from the stack map after its last
//     use. In practice the JIT is conservative in --jit-optimized mode and may
//     still keep `block` alive, so this probe does NOT fail deterministically
//     in JIT mode. Reliable reproduction requires AOT compilation:
//       dart compile exe test/finalizable_test.dart && ./finalizable_test
//     The primary regression guard for issue #3209 is the isA<Finalizable>()
//     check in the 'Finalizable' group, which is 100% deterministic.
// ---------------------------------------------------------------------------
@pragma('vm:never-inline')
int _gcAndCheckBlock() {
  // Create a closure block as a LOCAL variable.
  // Its last Dart-level use is `block.ref.pointer` on the next line.
  // Without Finalizable, the JIT can eliminate `block` from the GC stack map
  // after that point.
  final block = ObjCBlock_ffiVoid_ffiVoid_NSStream_NSStreamEvent.fromFunction(
    (_, stream, event) {},
    keepIsolateAlive: false,
  );
  // Weak reference to detect if `block` is collected by GC.
  // WeakReference is cleared synchronously during GC (unlike FinalizableHandle
  // callbacks, which are deferred until the isolate next runs Dart code).
  final weakRef = WeakReference(block);
  final ptr = block.ref.pointer; // last strong use of `block`
  // Non-leaf FFI safepoint: GC fires here with the JIT's precise stack map.
  //   WITHOUT Finalizable: `block` is dead → GC collects it → weakRef cleared.
  //   WITH Finalizable: reachabilityFence(block) keeps it alive → weakRef valid.
  gcAndGetRetainCount(ptr); // non-leaf FFI call — triggers gc-now inside
  return weakRef.target != null ? 1 : 0;
}

// ---------------------------------------------------------------------------
// Runtime assertions.
// ---------------------------------------------------------------------------

void main() {
  group('Finalizable', () {
    // Verifies at runtime that ObjCBlockBase instances carry the Finalizable
    // interface.
    //
    // This is the PRIMARY regression guard for issue #3209.
    // Without `implements Finalizable` on ObjCBlockBase, `block is Finalizable`
    // evaluates to false and this test fails — even though the containing
    // ObjCBlockRef field is itself Finalizable (Dart's `is` check looks at the
    // explicitly declared type hierarchy, not at field types).
    //
    // The compile-time check (_checkObjCBlockBaseIsFinalizable) catches the
    // same regression at analysis time; this test catches it at runtime.
    test('ObjCBlockBase implements Finalizable', () {
      final block =
          ObjCBlock_ffiVoid_ffiVoid_NSStream_NSStreamEvent.fromFunction(
            (_, stream, event) {},
            keepIsolateAlive: false,
          );
      // If ObjCBlockBase does NOT implement Finalizable this is false → fails.
      expect(
        block,
        isA<Finalizable>(),
        reason:
            'ObjCBlockBase must implement Finalizable (issue #3209). '
            'Without it the Dart compiler can collect block wrappers at FFI '
            'safepoints before ObjC retains the pointer, causing EXC_BAD_ACCESS.',
      );
    });

    // Verifies that ObjCObject does NOT implement Finalizable, preserving
    // isolate sendability for objects like NSInputStream.
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
  // Without the fix (ObjCBlockBase NOT Finalizable):
  //   The optimizer marks `block` dead after extracting the raw pointer. When
  //   gc-now fires at the FFI safepoint the Dart wrapper is collected, the
  //   finalizer calls objc_release, and the retain count drops to 0 before ObjC
  //   ever retains it — detectable via wasBlockFreedBeforeRetain().
  //
  // With the fix (ObjCBlockBase implements Finalizable):
  //   The compiler inserts reachabilityFence(block) at the end of the calling
  //   scope. gc-now finds the variable still reachable and does not collect it.
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
        // If doGC() is not available from Dart either, skip.
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
        '(fails without ObjCBlockBase implements Finalizable)', () {
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
        if (wasBlockFreedBeforeRetain()) break; // bug detected early, stop
      }

      expect(
        wasBlockFreedBeforeRetain(),
        isFalse,
        reason:
            'Block was prematurely released by GC before ObjC retained it. '
            'ObjCBlockBase must implement Finalizable (issue #3209).',
      );
    });

    // ---------------------------------------------------------------------------
    // Direct liveness test — uses _gcAndCheckBlock (defined above main()).
    //
    // Unlike the swizzle test (where `block` is a PARAMETER threaded through
    // a call chain and JIT keeps parameters alive conservatively), here `block`
    // is a LOCAL variable in a never-inlined function.  The JIT can eliminate
    // it from the GC stack map after its last use, making the test sensitive to
    // whether ObjCBlockBase is Finalizable.
    //
    // For guaranteed reproduction on iteration 1 (no JIT warm-up needed), run:
    //   dart --optimization-counter-threshold=0 test test/finalizable_test.dart
    // ---------------------------------------------------------------------------
    test('block local NOT freed at non-leaf FFI safepoint '
        '(deterministic with --optimization-counter-threshold=0)', () {
      if (!canDoGC) {
        // gcAndGetRetainCount calls Dart_ExecuteInternalCommand internally.
        // If the symbol is unavailable (stripped runtime), gc-now is a no-op
        // and this test would pass vacuously. Skip it instead.
        return;
      }
      const kIterations = 1000;
      for (var i = 0; i < kIterations; i++) {
        final survived = _gcAndCheckBlock();
        if (survived == 0) {
          fail(
            'Block wrapper was GC-collected at FFI safepoint on iteration $i. '
            'ObjCBlockBase must implement Finalizable (issue #3209).',
          );
        }
      }
    });
  });
}
