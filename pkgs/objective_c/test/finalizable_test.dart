// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')
library;

// Regression test for https://github.com/dart-lang/native/issues/3209
//
// ObjCObject and ObjCBlockBase must implement Finalizable so that the Dart
// compiler keeps local variables of those types alive across FFI safepoints.
// Without this, a GC event during a native call can fire before ObjC retains
// the pointer, causing EXC_BAD_ACCESS in production.

import 'dart:ffi';

import 'package:objective_c/objective_c.dart';
import 'package:test/test.dart';

import 'util.dart';

// ---------------------------------------------------------------------------
// Compile-time assertions (enforced by dart analyze).
//
// If _ObjCRefHolder ever loses `implements Finalizable`, these functions will
// produce a static type error, catching the regression before tests even run.
// ---------------------------------------------------------------------------

void _requireFinalizable(Finalizable _) {}

// ignore: unused_element
void _checkObjCObjectIsFinalizable(ObjCObject o) => _requireFinalizable(o);

// ignore: unused_element
void _checkObjCBlockBaseIsFinalizable(ObjCBlockBase b) =>
    _requireFinalizable(b);

// ---------------------------------------------------------------------------
// Runtime assertions.
// ---------------------------------------------------------------------------

void main() {
  group('Finalizable', () {
    // Verifies at runtime that ObjCObject instances carry the Finalizable
    // interface. This complements the compile-time check above: together they
    // ensure both the static type and the runtime type are correct.
    test('ObjCObject implements Finalizable', () {
      final obj = NSObject();
      expect(obj, isA<Finalizable>());
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
}
