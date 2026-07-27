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
  group('NodeManager memory management', () {
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

    test('getNode() returns unowned pointer by default', () {
      final manager = NodeManager();
      final node = manager.getNode(100, nullptr);
      expect(node.getValue(), 100);

      // Wrapper is unowned by default, releaseOwnership throws StateError.
      expect(node.releaseOwnership, throwsStateError);
    });

    test('getNode() can take ownership via retainOwnership()', () {
      final counter = calloc<Int32>()..value = 0;
      final manager = NodeManager();
      final node = manager.getNode(100, counter.cast())..retainOwnership();
      expect(node.getValue(), 100);
      expect(counter.value, 0);

      node.dispose();
      expect(counter.value, 1);
      calloc.free(counter);
    });

    test('newNode() returns unowned by default, counter stays 0', () {
      final counter = calloc<Int32>()..value = 0;
      final manager = NodeManager();
      final node = manager.newNode(100, counter.cast());
      expect(node.getValue(), 100);

      // Wrapper is unowned, Dart will never call Node_delete automatically.
      // Counter must still be 0 because no finalizer was attached.
      expect(counter.value, 0);
      // Transfer ownership so the node can be cleaned up cleanly.
      node.retainOwnership();
      node.dispose();
      expect(counter.value, 1);
      calloc.free(counter);
    });

    test('getSingletonNode() returns unowned pointer', () {
      final counter = calloc<Int32>()..value = 0;
      final manager = NodeManager();
      final node = manager.getSingletonNode(200, counter.cast());
      expect(node.getValue(), 200);

      // Wrapper is unowned, releaseOwnership throws StateError.
      expect(node.releaseOwnership, throwsStateError);
      calloc.free(counter);
    });

    test('foo(node) passes pointer correctly', () {
      final counter = calloc<Int32>()..value = 0;
      final rawPtr = _rawNodeNew(42, counter.cast());
      final node = Node.fromPointer(rawPtr, takeOwnership: false);
      final manager = NodeManager();
      expect(manager.foo(node), 42);
      _rawNodeDelete(rawPtr);
      calloc.free(counter);
    });

    test('getValue(node) borrows argument without destroying it', () {
      final counter = calloc<Int32>()..value = 0;
      final rawPtr = _rawNodeNew(300, counter.cast());
      final node = Node.fromPointer(rawPtr, takeOwnership: false);
      final manager = NodeManager();
      expect(manager.getValue(node), 300);
      expect(counter.value, 0); // Still alive!
      _rawNodeDelete(rawPtr);
      calloc.free(counter);
    });

    test('takeNode(node) takes ownership and deletes C++ object', () {
      final counter = calloc<Int32>()..value = 0;
      final rawPtr = _rawNodeNew(400, counter.cast());
      final node = Node.fromPointer(rawPtr, takeOwnership: true);
      final manager = NodeManager();

      // Detach Dart finalizer and transfer ownership to C++.
      expect(manager.takeNode(node..releaseOwnership()), 400);

      // C++ takeNode deleted the node.
      expect(counter.value, 1);
      calloc.free(counter);
    });
  });
}
