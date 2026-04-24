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
    test('ObjCObject implements Finalizable', () {
      final obj = NSObject.new1();
      expect(obj, isA<Finalizable>());
    });
  });
}
