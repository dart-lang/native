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

  group('unique_ptr memory management', () {
    test('makeNode() returns owned Node (takeOwnership: true)', () {
      final counter = calloc<Int32>()..value = 0;
      final manager = NodeManager();
      final node = manager.makeNode(42, counter.cast());

      expect(node.getValue(), 42);
      expect(counter.value, 0); // not destroyed yet

      node.dispose();
      expect(counter.value, 1); // destructor called on dispose
      calloc.free(counter);
    });

    test('makeNode() Node is GC-destroyed automatically', () {
      final counter = calloc<Int32>()..value = 0;

      @pragma('vm:never-inline')
      void inner() {
        final manager = NodeManager();
        // ignore: unused_local_variable
        final _ = manager.makeNode(99, counter.cast());
      }

      inner();
      doGC();
      expect(counter.value, 1);
      calloc.free(counter);
    }, skip: !canDoGC);

    test('makeNode() cannot call retainOwnership() again (already owned)', () {
      final counter = calloc<Int32>()..value = 0;
      final manager = NodeManager();
      final node = manager.makeNode(1, counter.cast());
      expect(node.retainOwnership, throwsStateError);
      node.dispose();
      calloc.free(counter);
    });

    test(
      'consumeNode() transfers ownership, destroys object, returns value',
      () {
        final counter = calloc<Int32>()..value = 0;
        final manager = NodeManager();
        final node = manager.makeNode(77, counter.cast());
        expect(counter.value, 0); // not yet destroyed

        final val = manager.consumeNode(node);
        expect(val, 77);
        expect(counter.value, 1); // unique_ptr destructor fired inside C++
        calloc.free(counter);
      },
    );

    test('consumeNode() invalidates the Dart wrapper', () {
      final counter = calloc<Int32>()..value = 0;
      final manager = NodeManager();
      final node = manager.makeNode(55, counter.cast());

      manager.consumeNode(node);

      // Wrapper must be in disposed state after transfer.
      expect(node.getValue, throwsStateError);
      calloc.free(counter);
    });

    test('double consumeNode() throws StateError on second call', () {
      final counter = calloc<Int32>()..value = 0;
      final manager = NodeManager();
      final node = manager.makeNode(33, counter.cast());

      manager.consumeNode(node); // first call: succeeds
      expect(
        () => manager.consumeNode(node),
        throwsStateError,
      ); // second call: wrapper is nullptr
      calloc.free(counter);
    });

    test('consumeNode() with non-owning wrapper throws StateError', () {
      final counter = calloc<Int32>()..value = 0;
      final rawPtr = _rawNodeNew(111, counter.cast());
      final node = Node.fromPointer(rawPtr, takeOwnership: false);
      final manager = NodeManager();

      expect(() => manager.consumeNode(node), throwsStateError);

      // Wrapper must be unmodified after the failed call.
      expect(node.getValue(), 111);
      expect(counter.value, 0);

      _rawNodeDelete(rawPtr);
      calloc.free(counter);
    });

    test('consumeNode() with already-disposed wrapper throws StateError', () {
      final counter = calloc<Int32>()..value = 0;
      final manager = NodeManager();
      final node = manager.makeNode(222, counter.cast());

      node.dispose();
      expect(counter.value, 1); // already destroyed by dispose()

      expect(() => manager.consumeNode(node), throwsStateError);
      calloc.free(counter);
    });

    test('retainOwnership() then consumeNode() works correctly', () {
      final counter = calloc<Int32>()..value = 0;
      final rawPtr = _rawNodeNew(333, counter.cast());
      final node = Node.fromPointer(rawPtr, takeOwnership: false)
        ..retainOwnership();

      final manager = NodeManager();
      final val = manager.consumeNode(node); // should succeed

      expect(val, 333);
      expect(counter.value, 1); // C++ destroyed it inside consumeNode
      // Dart wrapper is now invalid.
      expect(node.getValue, throwsStateError);
      calloc.free(counter);
    });

    test(
      'Constructor taking std::unique_ptr transfers ownership correctly',
      () {
        final counter = calloc<Int32>()..value = 0;
        final manager = NodeManager();
        final node = manager.makeNode(444, counter.cast());

        final container = NodeContainer(node);
        expect(container.getValue(), 444);
        // node was transferred, so node wrapper is now disposed
        expect(node.getValue, throwsStateError);

        container.dispose();
        expect(
          counter.value,
          1,
        ); // C++ destroyed Node when container was destroyed
        calloc.free(counter);
      },
    );

    test('Constructor taking std::unique_ptr with non-owning wrapper '
        'throws StateError', () {
      final counter = calloc<Int32>()..value = 0;
      final rawPtr = _rawNodeNew(555, counter.cast());
      final node = Node.fromPointer(rawPtr, takeOwnership: false);

      expect(() => NodeContainer(node), throwsStateError);
      expect(node.getValue(), 555);

      _rawNodeDelete(rawPtr);
      calloc.free(counter);
    });
  });
}
