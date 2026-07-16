// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:test/test.dart';

import '../test_utils.dart';
import 'memory_edge_cases_bindings.dart';

@Native<Pointer<Void> Function(Int, Pointer<Int>)>(
  symbol: 'Node_new',
  assetId: 'package:ffigen/cpp_test',
)
external Pointer<Void> _rawNodeNew(int value, Pointer<Int> counter);

@Native<Void Function(Pointer<Void>)>(
  symbol: 'Node_delete',
  assetId: 'package:ffigen/cpp_test',
)
external void _rawNodeDelete(Pointer<Void> self);

void main() {
  group('takeOwnership: false', () {
    // Test A - GC does not delete a non-owning wrapper.
    @pragma('vm:never-inline')
    void gcNonOwningInner(Pointer<Void> rawPtr, Pointer<Int32> counter) {
      final _ = Node.fromPointer(rawPtr, takeOwnership: false);
    }

    test('GC does not delete a non-owning wrapper', () {
      final counter = calloc<Int32>()..value = 0;
      final rawPtr = _rawNodeNew(55, counter.cast());
      gcNonOwningInner(rawPtr, counter);
      doGC();
      expect(counter.value, 0);
      _rawNodeDelete(rawPtr);
      calloc.free(counter);
    }, skip: !canDoGC);

    // Test B - retainOwnership() enables GC ownership.
    @pragma('vm:never-inline')
    void retainOwnershipInner(Pointer<Int32> counter) {
      final rawPtr = _rawNodeNew(66, counter.cast());
      final node = Node.fromPointer(rawPtr, takeOwnership: false);
      node.retainOwnership();
      expect(node, isNotNull);
    }

    test('retainOwnership() enables GC finalizer', () {
      final counter = calloc<Int32>()..value = 0;
      retainOwnershipInner(counter);
      doGC();
      expect(counter.value, 1);
      calloc.free(counter);
    }, skip: !canDoGC);

    // Test C - releaseOwnership() on a non-owning wrapper throws StateError.
    test('releaseOwnership() on non-owning wrapper throws StateError', () {
      final counter = calloc<Int32>()..value = 0;
      final rawPtr = _rawNodeNew(77, counter.cast());
      final node = Node.fromPointer(rawPtr, takeOwnership: false);
      expect(node.releaseOwnership, throwsStateError);
      _rawNodeDelete(rawPtr);
      calloc.free(counter);
    });
  });
}
