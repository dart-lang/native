// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';
import 'dart:isolate';

import 'package:ffi/ffi.dart';

import 'c_bindings_generated.dart' as c;

/// Only for use by ffigen bindings.
Pointer<c.ObjCSelector> registerName(String name) {
  final cstr = name.toNativeUtf8();
  final sel = c.registerName(cstr.cast());
  calloc.free(cstr);
  return sel;
}

/// Only for use by ffigen bindings.
Pointer<c.ObjCObject> getClass(String name) {
  final cstr = name.toNativeUtf8();
  final clazz = c.getClass(cstr.cast());
  calloc.free(cstr);
  if (clazz == nullptr) {
    throw Exception('Failed to load Objective-C class: $name');
  }
  return clazz;
}

/// Only for use by ffigen bindings.
final msgSendPointer =
    Native.addressOf<NativeFunction<Void Function()>>(c.msgSend);

/// Only for use by ffigen bindings.
final msgSendFpretPointer =
    Native.addressOf<NativeFunction<Void Function()>>(c.msgSendFpret);

/// Only for use by ffigen bindings.
final msgSendStretPointer =
    Native.addressOf<NativeFunction<Void Function()>>(c.msgSendStret);

/// Only for use by ffigen bindings.
final useMsgSendVariants =
    Abi.current() == Abi.iosX64 || Abi.current() == Abi.macosX64;

class _ObjCFinalizable<T extends NativeType> implements Finalizable {
  final Pointer<T> _ptr;
  bool _pendingRelease;

  _ObjCFinalizable(this._ptr, {required bool retain, required bool release})
      : _pendingRelease = release {
    if (retain) {
      _retain(_ptr.cast());
    }
    if (release) {
      _finalizer.attach(this, _ptr.cast(), detach: this);
    }
  }

  /// Releases the reference to the underlying ObjC object held by this wrapper.
  /// Throws a StateError if this wrapper doesn't currently hold a reference.
  void release() {
    if (_pendingRelease) {
      _pendingRelease = false;
      _release(_ptr.cast());
      _finalizer.detach(this);
    } else {
      throw StateError(
          'Released an ObjC object that was unowned or already released.');
    }
  }

  @override
  bool operator ==(Object other) {
    return other is _ObjCFinalizable && _ptr == other._ptr;
  }

  @override
  int get hashCode => _ptr.hashCode;

  /// Return a pointer to this object.
  Pointer<T> get pointer => _ptr;

  /// Retain a reference to this object and then return the pointer. This
  /// reference must be released when you are done with it. If you wrap this
  /// reference in another object, make sure to release it but not retain it:
  /// `castFromPointer(lib, pointer, retain: false, release: true)`
  Pointer<T> retainAndReturnPointer() {
    _retain(_ptr.cast());
    return _ptr;
  }

  NativeFinalizer get _finalizer => throw UnimplementedError();
  void _retain(Pointer<T> ptr) => throw UnimplementedError();
  void _release(Pointer<T> ptr) => throw UnimplementedError();
}

/// Only for use by ffigen bindings.
class ObjCObjectBase extends _ObjCFinalizable<c.ObjCObject> {
  ObjCObjectBase(super.ptr, {required super.retain, required super.release});

  static final _objectFinalizer = NativeFinalizer(
      Native.addressOf<NativeFunction<Void Function(Pointer<c.ObjCObject>)>>(
              c.objectRelease)
          .cast());

  @override
  NativeFinalizer get _finalizer => _objectFinalizer;

  @override
  void _retain(Pointer<c.ObjCObject> ptr) {
    assert(c.isValidObject(ptr));
    c.objectRetain(ptr);
  }

  @override
  void _release(Pointer<c.ObjCObject> ptr) {
    assert(c.isValidObject(ptr));
    c.objectRelease(ptr);
  }
}

/// Only for use by ffigen bindings.
class ObjCBlockBase extends _ObjCFinalizable<c.ObjCBlock> {
  ObjCBlockBase(super.ptr, {required super.retain, required super.release});

  static final _blockFinalizer = NativeFinalizer(
      Native.addressOf<NativeFunction<Void Function(Pointer<Void>)>>(
              c.blockRelease));

  @override
  NativeFinalizer get _finalizer => _blockFinalizer;

  @override
  void _retain(Pointer<c.ObjCBlock> ptr) {
    assert(c.isValidBlock(ptr));
    c.blockCopy(ptr.cast());
  }

  @override
  void _release(Pointer<c.ObjCBlock> ptr) {
    assert(c.isValidBlock(ptr));
    c.blockRelease(ptr.cast());
  }
}

Pointer<c.ObjCBlockDesc> _newBlockDesc(
    Pointer<NativeFunction<Void Function(Pointer<c.ObjCBlock>)>>
        disposeHelper) {
  final desc = calloc.allocate<c.ObjCBlockDesc>(sizeOf<c.ObjCBlockDesc>());
  desc.ref.reserved = 0;
  desc.ref.size = sizeOf<c.ObjCBlock>();
  desc.ref.copy_helper = nullptr;
  desc.ref.dispose_helper = disposeHelper.cast();
  desc.ref.signature = nullptr;
  return desc;
}

final _pointerBlockDesc = _newBlockDesc(nullptr);
final _closureBlockDesc = _newBlockDesc(
    Native.addressOf<NativeFunction<Void Function(Pointer<c.ObjCBlock>)>>(
        c.disposeObjCBlockWithClosure));

Pointer<c.ObjCBlock> _newBlock(Pointer<Void> invoke, Pointer<Void> target,
    Pointer<c.ObjCBlockDesc> descriptor, int disposePort, int flags) {
  final b = calloc.allocate<c.ObjCBlock>(sizeOf<c.ObjCBlock>());
  b.ref.isa = Native.addressOf<Array<Pointer<Void>>>(c.NSConcreteGlobalBlock).cast();
  b.ref.flags = flags;
  b.ref.reserved = 0;
  b.ref.invoke = invoke;
  b.ref.target = target;
  b.ref.dispose_port = disposePort;
  b.ref.descriptor = descriptor;
  assert(c.isValidBlock(b));
  final copy = c.blockCopy(b.cast()).cast<c.ObjCBlock>();
  calloc.free(b);
  assert(copy.ref.isa == Native.addressOf<Array<Pointer<Void>>>(c.NSConcreteMallocBlock).cast());
  assert(c.isValidBlock(copy));
  return copy;
}

const int _blockHasCopyDispose = 1 << 25;

/// Only for use by ffigen bindings.
Pointer<c.ObjCBlock> newClosureBlock(Pointer<Void> invoke, Function fn) =>
    _newBlock(invoke, _registerBlockClosure(fn), _closureBlockDesc,
        _blockClosureDisposer.sendPort.nativePort, _blockHasCopyDispose);

/// Only for use by ffigen bindings.
Pointer<c.ObjCBlock> newPointerBlock(
        Pointer<Void> invoke, Pointer<Void> target) =>
    _newBlock(invoke, target, _pointerBlockDesc, 0, 0);

final _blockClosureRegistry = <int, Function>{};

int _blockClosureRegistryLastId = 0;

final _blockClosureDisposer = () {
  c.Dart_InitializeApiDL(NativeApi.initializeApiDLData);
  return RawReceivePort((dynamic msg) {
    final id = msg as int;
    assert(_blockClosureRegistry.containsKey(id));
    _blockClosureRegistry.remove(id);
  }, "ObjCBlockClosureDisposer")
    ..keepIsolateAlive = false;
}();

Pointer<Void> _registerBlockClosure(Function closure) {
  ++_blockClosureRegistryLastId;
  assert(!_blockClosureRegistry.containsKey(_blockClosureRegistryLastId));
  _blockClosureRegistry[_blockClosureRegistryLastId] = closure;
  return Pointer<Void>.fromAddress(_blockClosureRegistryLastId);
}

/// Only for use by ffigen bindings.
Function getBlockClosure(Pointer<c.ObjCBlock> block) {
  int id = block.ref.target.address;
  assert(_blockClosureRegistry.containsKey(id));
  return _blockClosureRegistry[id]!;
}

// Not exported by ../objective_c.dart, because it's only for testing.
bool blockHasRegisteredClosure(Pointer<c.ObjCBlock> block) =>
    _blockClosureRegistry.containsKey(block.ref.target.address);
