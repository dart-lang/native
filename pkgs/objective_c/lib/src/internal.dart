// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';
import 'dart:isolate';

import 'package:ffi/ffi.dart';

import 'c_bindings_generated.dart' as c;
import 'objective_c_bindings_generated.dart' as objc;

final class UseAfterReleaseError extends StateError {
  UseAfterReleaseError() : super('Use after release error');
}

final class DoubleReleaseError extends StateError {
  DoubleReleaseError() : super('Double release error');
}

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
Pointer<c.ObjCProtocol> getProtocol(String name) {
  final cstr = name.toNativeUtf8();
  final clazz = c.getProtocol(cstr.cast());
  calloc.free(cstr);
  if (clazz == nullptr) {
    throw Exception('Failed to load Objective-C protocol: $name');
  }
  return clazz;
}

/// Only for use by ffigen bindings.
objc.NSMethodSignature getProtocolMethodSignature(
  Pointer<c.ObjCProtocol> protocol,
  Pointer<c.ObjCSelector> sel, {
  required bool isRequired,
  required bool isInstanceMethod,
}) {
  final sig =
      c.getMethodDescription(protocol, sel, isRequired, isInstanceMethod).types;
  if (sig == nullptr) {
    throw Exception('Failed to load method of Objective-C protocol');
  }
  final sigObj = objc.NSMethodSignature.signatureWithObjCTypes_(sig);
  if (sigObj == null) {
    throw Exception(
        'Failed to construct signature for Objective-C protocol method');
  }
  return sigObj;
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

// _FinalizablePointer exists because we can't access `this` in the initializers
// of _ObjCFinalizable's constructor, and we have to have an owner to attach the
// Dart_FinalizableHandle to. Ideally _ObjCFinalizable would be the owner.
@pragma('vm:deeply-immutable')
class _FinalizablePointer<T extends NativeType> implements Finalizable {
  final Pointer<T> ptr;
  _FinalizablePointer(this.ptr);
}

bool _dartAPIInitialized = false;
void _ensureDartAPI() {
  if (!_dartAPIInitialized) {
    _dartAPIInitialized = true;
    c.Dart_InitializeApiDL(NativeApi.initializeApiDLData);
  }
}

c.Dart_FinalizableHandle newFinalizableHandle(_FinalizablePointer finalizable) {
  _ensureDartAPI();
  return c.newFinalizableHandle(finalizable, finalizable.ptr.cast());
}

Pointer<Bool> newFinalizableBool(Object owner) {
  _ensureDartAPI();
  return c.newFinalizableBool(owner);
}

// QUESTION: Do _FinalizablePointer and _ObjCFinalizable still need to implement
// Finalizable, now that they're not using NativeFinalizer?
@pragma('vm:deeply-immutable')
class _ObjCFinalizable<T extends NativeType> implements Finalizable {
  final _FinalizablePointer<T> _finalizable;
  final c.Dart_FinalizableHandle? _ptrFinalizableHandle;
  final Pointer<Bool> _isReleased;

  _ObjCFinalizable(this._finalizable,
      {required bool retain, required bool release})
      : _ptrFinalizableHandle =
            release ? newFinalizableHandle(_finalizable) : null,
        _isReleased = newFinalizableBool(_finalizable) {
    if (retain) {
      _retain(_finalizable.ptr);
    }
  }

  bool get isReleased => _isReleased.value;

  /// Releases the reference to the underlying ObjC object held by this wrapper.
  /// Throws a StateError if this wrapper doesn't currently hold a reference.
  void release() {
    if (isReleased) {
      throw DoubleReleaseError();
    }
    if (_ptrFinalizableHandle != null) {
      c.deleteFinalizableHandle(_ptrFinalizableHandle, this);
    }
    _isReleased.value = true;
    _release(_finalizable.ptr);
  }

  @override
  bool operator ==(Object other) {
    return other is _ObjCFinalizable && _finalizable.ptr == other._finalizable.ptr;
  }

  @override
  int get hashCode => _finalizable.ptr.hashCode;

  /// Return a pointer to this object.
  Pointer<T> get pointer {
    if (isReleased) {
      throw UseAfterReleaseError();
    }
    return _finalizable.ptr;
  }

  /// Retain a reference to this object and then return the pointer. This
  /// reference must be released when you are done with it. If you wrap this
  /// reference in another object, make sure to release it but not retain it:
  /// `castFromPointer(lib, pointer, retain: false, release: true)`
  Pointer<T> retainAndReturnPointer() {
    _retain(_finalizable.ptr);
    return _finalizable.ptr;
  }

  void _retain(Pointer<T> ptr) => throw UnimplementedError();
  void _release(Pointer<T> ptr) => throw UnimplementedError();
}

/// Only for use by ffigen bindings.
@pragma('vm:deeply-immutable')
class ObjCObjectBase extends _ObjCFinalizable<c.ObjCObject> {
  ObjCObjectBase(
      Pointer<c.ObjCObject> ptr,
      {required super.retain, required super.release}) :
          super(_FinalizablePointer(ptr));

  @override
  void _retain(Pointer<c.ObjCObject> ptr) {
    assert(_isValidObject(ptr));
    c.objectRetain(ptr);
  }

  @override
  void _release(Pointer<c.ObjCObject> ptr) {
    assert(_isValidObject(ptr));
    c.objectRelease(ptr);
  }
}

// Returns whether the object is valid and live. The pointer must point to
// readable memory, or be null. May (rarely) return false positives.
bool _isValidObject(Pointer<c.ObjCObject> ptr) {
  if (ptr == nullptr) return false;
  return _isValidClass(c.getObjectClass(ptr));
}

final _allClasses = <Pointer<c.ObjCObject>>{};

bool _isValidClass(Pointer<c.ObjCObject> clazz) {
  if (_allClasses.contains(clazz)) return true;

  // If the class is missing from the list, it either means we haven't created
  // the set yet, or more classes have been loaded since we created the set, or
  // the class is actually invalid. To rule out the first two cases, rebulid the
  // set then try again. This is expensive, but only happens if asserts are
  // enabled, and only happens more than O(1) times if there are actually
  // invalid objects in use, which shouldn't happen in correct code.
  final countPtr = calloc<UnsignedInt>();
  final classList = c.copyClassList(countPtr);
  final count = countPtr.value;
  calloc.free(countPtr);
  _allClasses.clear();
  for (var i = 0; i < count; ++i) {
    _allClasses.add(classList[i]);
  }
  calloc.free(classList);

  return _allClasses.contains(clazz);
}

/// Only for use by ffigen bindings.
@pragma('vm:deeply-immutable')
class ObjCBlockBase extends _ObjCFinalizable<c.ObjCBlock> {
  ObjCBlockBase(
      Pointer<c.ObjCBlock> ptr,
      {required super.retain, required super.release}) :
          super(_FinalizablePointer(ptr));

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
  b.ref.isa =
      Native.addressOf<Array<Pointer<Void>>>(c.NSConcreteGlobalBlock).cast();
  b.ref.flags = flags;
  b.ref.reserved = 0;
  b.ref.invoke = invoke;
  b.ref.target = target;
  b.ref.dispose_port = disposePort;
  b.ref.descriptor = descriptor;
  assert(c.isValidBlock(b));
  final copy = c.blockCopy(b.cast()).cast<c.ObjCBlock>();
  calloc.free(b);
  assert(copy.ref.isa ==
      Native.addressOf<Array<Pointer<Void>>>(c.NSConcreteMallocBlock).cast());
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
  _ensureDartAPI();
  return RawReceivePort((dynamic msg) {
    final id = msg as int;
    assert(_blockClosureRegistry.containsKey(id));
    _blockClosureRegistry.remove(id);
  }, 'ObjCBlockClosureDisposer')
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
  var id = block.ref.target.address;
  assert(_blockClosureRegistry.containsKey(id));
  return _blockClosureRegistry[id]!;
}

// Not exported by ../objective_c.dart, because they're only for testing.
bool blockHasRegisteredClosure(Pointer<c.ObjCBlock> block) =>
    _blockClosureRegistry.containsKey(block.ref.target.address);
bool isValidBlock(Pointer<c.ObjCBlock> block) => c.isValidBlock(block);
bool isValidClass(Pointer<c.ObjCObject> clazz) => _isValidClass(clazz);
bool isValidObject(Pointer<c.ObjCObject> object) => _isValidObject(object);
