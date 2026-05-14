// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// All @Native bindings in this file live in the package's native asset dylib.
@DefaultAsset('package:objective_c/objective_c.dylib')
library;

import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:native_test_helpers/native_test_helpers.dart';
import 'package:objective_c/objective_c.dart';
import 'package:objective_c/src/c_bindings_generated.dart' as c;

final _executeInternalCommand = () {
  try {
    return DynamicLibrary.process()
        .lookup<NativeFunction<Void Function(Pointer<Char>, Pointer<Void>)>>(
          'Dart_ExecuteInternalCommand',
        )
        .asFunction<void Function(Pointer<Char>, Pointer<Void>)>();
    // ignore: avoid_catching_errors
  } on ArgumentError {
    return null;
  }
}();

bool canDoGC = _executeInternalCommand != null;

void doGC() {
  final gcNow = 'gc-now'.toNativeUtf8();
  _executeInternalCommand!(gcNow.cast(), nullptr);
  calloc.free(gcNow);
}

@Native<Pointer<c.ObjCObjectImpl> Function(Pointer<Bool>)>(
  symbol: 'createDisposableTrackerObject',
)
external Pointer<c.ObjCObjectImpl> _createDisposableTrackerObject(
  Pointer<Bool> isAlive,
);

@Native<Void Function(Pointer<Void>, Pointer<c.ObjCObjectImpl>)>(
  symbol: 'setAssociatedDisposableTrackerObject',
)
external void _setAssociatedDisposableTrackerObject(
  Pointer<Void> host,
  Pointer<c.ObjCObjectImpl> disposable,
);

class ReferenceTracker {
  final Pointer<Bool> isAlivePtr;

  ReferenceTracker(Arena arena) : this._(arena, arena<Bool>()..value = true);

  ReferenceTracker._(Arena arena, this.isAlivePtr);

  bool get isAlive => isAlivePtr.value;

  void track(Pointer<Void> hostPtr) {
    final disposablePtr = _createDisposableTrackerObject(isAlivePtr);
    final disposableObj = ObjCObject(
      disposablePtr.cast(),
      retain: false,
      release: true,
    );
    _setAssociatedDisposableTrackerObject(
      hostPtr,
      disposableObj.ref.pointer.cast(),
    );
  }
}

String pkgDir = findPackageRoot('objective_c').toFilePath();

// ---------------------------------------------------------------------------
// Block retain count (from util.c: getBlockRetainCount).
// ---------------------------------------------------------------------------

@Native<Uint64 Function(Pointer<Void>)>(
  isLeaf: true,
  symbol: 'getBlockRetainCount',
)
external int _getBlockRetainCount(Pointer<Void> block);

int blockRetainCount(Pointer<c.ObjCBlockImpl> block) =>
    _getBlockRetainCount(block.cast());

// ---------------------------------------------------------------------------
// GC injection helpers (from gc_inject.m) — only available on macOS.
// ---------------------------------------------------------------------------

@Native<Void Function()>(isLeaf: true, symbol: 'initGCInject')
external void initGCInject();

@Native<Void Function()>(isLeaf: true, symbol: 'installGCInjectSwizzle')
external void installGCInjectSwizzle();

@Native<Void Function()>(isLeaf: true, symbol: 'removeGCInjectSwizzle')
external void removeGCInjectSwizzle();

@Native<Void Function(Bool)>(isLeaf: true, symbol: 'setGCInjectActive')
external void setGCInjectActive(bool active);

@Native<Bool Function()>(isLeaf: true, symbol: 'wasBlockFreedBeforeRetain')
external bool wasBlockFreedBeforeRetain();

@Native<Bool Function()>(isLeaf: true, symbol: 'gcNowAvailableFromNative')
external bool gcNowAvailableFromNative();

// Must NOT be isLeaf: the native side calls Dart_ExecuteInternalCommand which
// requires the Dart thread to be at a proper native-mode safepoint.
@Native<Void Function()>(symbol: 'callGCNowFromNative')
external void callGCNowFromNative();
