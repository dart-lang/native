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
// of _ObjCReference's constructor, and we have to have an owner to attach the
// Dart_FinalizableHandle to. Ideally _ObjCReference would be the owner.
@pragma('vm:deeply-immutable')
final class _FinalizablePointer<T extends NativeType> implements Finalizable {
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

c.Dart_FinalizableHandle _newFinalizableHandle(
    _FinalizablePointer finalizable) {
  _ensureDartAPI();
  return c.newFinalizableHandle(finalizable, finalizable.ptr.cast());
}

Pointer<Bool> _newFinalizableBool(Object owner) {
  _ensureDartAPI();
  return c.newFinalizableBool(owner);
}

@pragma('vm:deeply-immutable')
abstract final class _ObjCReference<T extends NativeType>
    implements Finalizable {
  final _FinalizablePointer<T> _finalizable;
  final c.Dart_FinalizableHandle? _ptrFinalizableHandle;
  final Pointer<Bool> _isReleased;

  _ObjCReference(this._finalizable,
      {required bool retain, required bool release})
      : _ptrFinalizableHandle =
            release ? _newFinalizableHandle(_finalizable) : null,
        _isReleased = _newFinalizableBool(_finalizable) {
    assert(_isValid(_finalizable.ptr));
    if (retain) {
      _retain(_finalizable.ptr);
    }
  }

  bool get isReleased => _isReleased.value;

  void _release(void Function(Pointer<c.ObjCObject>) releaser) {
    if (isReleased) {
      throw DoubleReleaseError();
    }
    assert(_isValid(_finalizable.ptr));
    if (_ptrFinalizableHandle != null) {
      c.deleteFinalizableHandle(_ptrFinalizableHandle, _finalizable);
      releaser(_finalizable.ptr.cast());
    }
    _isReleased.value = true;
  }

  void release() => _release(c.objectRelease);

  Pointer<T> autorelease() {
    _release(c.objectAutorelease);
    return _finalizable.ptr;
  }

  @override
  bool operator ==(Object other) =>
      other is _ObjCReference && _finalizable.ptr == other._finalizable.ptr;

  @override
  int get hashCode => _finalizable.ptr.hashCode;

  Pointer<T> get pointer {
    if (isReleased) {
      throw UseAfterReleaseError();
    }
    assert(_isValid(_finalizable.ptr));
    return _finalizable.ptr;
  }

  Pointer<T> retainAndReturnPointer() {
    final ptr = pointer;
    _retain(ptr);
    return ptr;
  }

  Pointer<T> retainAndAutorelease() {
    final ptr = pointer;
    _retain(ptr);
    c.objectAutorelease(ptr.cast());
    return ptr;
  }

  void _retain(Pointer<T> ptr);
  bool _isValid(Pointer<T> ptr);
}

// Wrapper around _ObjCObjectRef/_ObjCBlockRef. This is needed because
// deeply-immutable classes must be final, but the ffigen bindings need to
// extend ObjCObjectBase/ObjCBlockBase.
class _ObjCRefHolder<T extends NativeType, Ref extends _ObjCReference<T>> {
  final Ref _ref;

  _ObjCRefHolder(this._ref);

  /// Whether this wrapper object has released its reference to the native ObjC
  /// object. Once released, you may not use this wrapper anymore.
  bool get isReleased => _ref.isReleased;

  /// Releases the reference to the underlying ObjC object held by this wrapper.
  /// Throws a StateError if this wrapper doesn't currently hold a reference.
  /// Once released, you may not use this wrapper anymore.
  void release() => _ref.release();

  /// Autoreleases the reference to the underlying ObjC object held by this
  /// wrapper. The reference will be released when the current autorelease pool
  /// is destroyed. Throws a StateError if this wrapper doesn't currently hold a
  /// reference. Once autoreleased, you may not use this wrapper anymore.
  Pointer<T> autorelease() => _ref.autorelease();

  /// Returns a pointer to the native ObjC object.
  Pointer<T> get pointer => _ref.pointer;

  /// Retain a reference to this object and then return the pointer. This
  /// reference must be released when you are done with it. If you wrap this
  /// reference in another object, make sure to release it but not retain it:
  /// `castFromPointer(lib, pointer, retain: false, release: true)`
  Pointer<T> retainAndReturnPointer() => _ref.retainAndReturnPointer();

  /// Retain a reference to this object, then autorelease that reference, then
  /// return the pointer. The reference will be released when the current
  /// autorelease pool is destroyed.
  Pointer<T> retainAndAutorelease() => _ref.retainAndAutorelease();

  @override
  bool operator ==(Object other) =>
      other is _ObjCRefHolder && _ref == other._ref;

  @override
  int get hashCode => _ref.hashCode;
}

@pragma('vm:deeply-immutable')
final class _ObjCObjectRef extends _ObjCReference<c.ObjCObject> {
  _ObjCObjectRef(Pointer<c.ObjCObject> ptr,
      {required super.retain, required super.release})
      : super(_FinalizablePointer(ptr));

  @override
  void _retain(Pointer<c.ObjCObject> ptr) => c.objectRetain(ptr);

  @override
  bool _isValid(Pointer<c.ObjCObject> ptr) => _isValidObject(ptr);
}

/// Only for use by ffigen bindings.
class ObjCObjectBase extends _ObjCRefHolder<c.ObjCObject, _ObjCObjectRef> {
  ObjCObjectBase(Pointer<c.ObjCObject> ptr,
      {required bool retain, required bool release})
      : super(_ObjCObjectRef(ptr, retain: retain, release: release));
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

@pragma('vm:deeply-immutable')
final class _ObjCBlockRef extends _ObjCReference<c.ObjCBlockImpl> {
  _ObjCBlockRef(Pointer<c.ObjCBlockImpl> ptr,
      {required super.retain, required super.release})
      : super(_FinalizablePointer(ptr));

  @override
  void _retain(Pointer<c.ObjCBlockImpl> ptr) => c.blockRetain(ptr.cast());

  @override
  bool _isValid(Pointer<c.ObjCBlockImpl> ptr) => c.isValidBlock(ptr);
}

/// Only for use by ffigen bindings.
class ObjCBlockBase extends _ObjCRefHolder<c.ObjCBlockImpl, _ObjCBlockRef> {
  ObjCBlockBase(Pointer<c.ObjCBlockImpl> ptr,
      {required bool retain, required bool release})
      : super(_ObjCBlockRef(ptr, retain: retain, release: release));
}

Pointer<c.ObjCBlockDesc> _newBlockDesc(
    Pointer<NativeFunction<Void Function(Pointer<c.ObjCBlockImpl>)>>
        disposeHelper) {
  final desc = calloc.allocate<c.ObjCBlockDesc>(sizeOf<c.ObjCBlockDesc>());
  desc.ref.reserved = 0;
  desc.ref.size = sizeOf<c.ObjCBlockImpl>();
  desc.ref.copy_helper = nullptr;
  desc.ref.dispose_helper = disposeHelper.cast();
  desc.ref.signature = nullptr;
  return desc;
}

final _pointerBlockDesc = _newBlockDesc(nullptr);
final _closureBlockDesc = _newBlockDesc(
    Native.addressOf<NativeFunction<Void Function(Pointer<c.ObjCBlockImpl>)>>(
        c.disposeObjCBlockWithClosure));

Pointer<c.ObjCBlockImpl> _newBlock(Pointer<Void> invoke, Pointer<Void> target,
    Pointer<c.ObjCBlockDesc> descriptor, int disposePort, int flags) {
  final b = calloc.allocate<c.ObjCBlockImpl>(sizeOf<c.ObjCBlockImpl>());
  b.ref.isa =
      Native.addressOf<Array<Pointer<Void>>>(c.NSConcreteGlobalBlock).cast();
  b.ref.flags = flags;
  b.ref.reserved = 0;
  b.ref.invoke = invoke;
  b.ref.target = target;
  b.ref.dispose_port = disposePort;
  b.ref.descriptor = descriptor;
  assert(c.isValidBlock(b));
  final copy = c.blockRetain(b.cast()).cast<c.ObjCBlockImpl>();
  calloc.free(b);
  assert(copy.ref.isa ==
      Native.addressOf<Array<Pointer<Void>>>(c.NSConcreteMallocBlock).cast());
  assert(c.isValidBlock(copy));
  return copy;
}

const int _blockHasCopyDispose = 1 << 25;

/// Only for use by ffigen bindings.
Pointer<c.ObjCBlockImpl> newClosureBlock(Pointer<Void> invoke, Function fn) =>
    _newBlock(invoke, _registerBlockClosure(fn), _closureBlockDesc,
        _blockClosureDisposer.sendPort.nativePort, _blockHasCopyDispose);

/// Only for use by ffigen bindings.
Pointer<c.ObjCBlockImpl> newPointerBlock(
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
Function getBlockClosure(Pointer<c.ObjCBlockImpl> block) {
  var id = block.ref.target.address;
  assert(_blockClosureRegistry.containsKey(id));
  return _blockClosureRegistry[id]!;
}

// Not exported by ../objective_c.dart, because they're only for testing.
bool blockHasRegisteredClosure(Pointer<c.ObjCBlockImpl> block) =>
    _blockClosureRegistry.containsKey(block.ref.target.address);
bool isValidBlock(Pointer<c.ObjCBlockImpl> block) => c.isValidBlock(block);
bool isValidClass(Pointer<c.ObjCObject> clazz) => _isValidClass(clazz);
bool isValidObject(Pointer<c.ObjCObject> object) => _isValidObject(object);
