// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Bindings for `src/objective_c.h` and `src/objective_c_runtime.h`.
// Regenerate bindings with `dart run tool/generate_code.dart`.

// ignore_for_file: always_specify_types
// ignore_for_file: camel_case_types
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: unused_element
// coverage:ignore-file

// AUTO GENERATED FILE, DO NOT EDIT.
//
// Generated by `package:ffigen`.
// ignore_for_file: type=lint
@ffi.DefaultAsset('objective_c.framework/objective_c')
library;

import 'dart:ffi' as ffi;

@ffi.Array.multi([32])
@ffi.Native<ffi.Array<ffi.Pointer<ffi.Void>>>(symbol: '_NSConcreteAutoBlock')
external ffi.Array<ffi.Pointer<ffi.Void>> NSConcreteAutoBlock;

@ffi.Array.multi([32])
@ffi.Native<ffi.Array<ffi.Pointer<ffi.Void>>>(
    symbol: '_NSConcreteFinalizingBlock')
external ffi.Array<ffi.Pointer<ffi.Void>> NSConcreteFinalizingBlock;

@ffi.Array.multi([32])
@ffi.Native<ffi.Array<ffi.Pointer<ffi.Void>>>(symbol: '_NSConcreteGlobalBlock')
external ffi.Array<ffi.Pointer<ffi.Void>> NSConcreteGlobalBlock;

@ffi.Array.multi([32])
@ffi.Native<ffi.Array<ffi.Pointer<ffi.Void>>>(symbol: '_NSConcreteMallocBlock')
external ffi.Array<ffi.Pointer<ffi.Void>> NSConcreteMallocBlock;

@ffi.Array.multi([32])
@ffi.Native<ffi.Array<ffi.Pointer<ffi.Void>>>(symbol: '_NSConcreteStackBlock')
external ffi.Array<ffi.Pointer<ffi.Void>> NSConcreteStackBlock;

@ffi.Native<
    ffi.Bool Function(
        ffi.Pointer<ObjCObject>,
        ffi.Pointer<ObjCSelector>,
        ffi.Pointer<ffi.Void>,
        ffi.Pointer<ffi.Char>)>(symbol: 'class_addMethod', isLeaf: true)
external bool addMethod(
  ffi.Pointer<ObjCObject> cls,
  ffi.Pointer<ObjCSelector> name,
  ffi.Pointer<ffi.Void> imp,
  ffi.Pointer<ffi.Char> types,
);

@ffi.Native<
    ffi.Pointer<ObjCObject> Function(
        ffi.Pointer<ObjCObject>,
        ffi.Pointer<ffi.Char>,
        ffi.Size)>(symbol: 'objc_allocateClassPair', isLeaf: true)
external ffi.Pointer<ObjCObject> allocateClassPair(
  ffi.Pointer<ObjCObject> superclass,
  ffi.Pointer<ffi.Char> name,
  int extraBytes,
);

@ffi.Native<ffi.Void Function(ffi.Pointer<ffi.Void>)>(
    symbol: 'DOBJC_awaitWaiter')
external void awaitWaiter(
  ffi.Pointer<ffi.Void> waiter,
);

@ffi.Native<ffi.Pointer<ObjCObject> Function(ffi.Pointer<ObjCObject>)>(
    symbol: 'objc_retainBlock', isLeaf: true)
external ffi.Pointer<ObjCObject> blockRetain(
  ffi.Pointer<ObjCObject> object,
);

@ffi.Native<
        ffi.Pointer<ffi.Pointer<ObjCObject>> Function(
            ffi.Pointer<ffi.UnsignedInt>)>(
    symbol: 'objc_copyClassList', isLeaf: true)
external ffi.Pointer<ffi.Pointer<ObjCObject>> copyClassList(
  ffi.Pointer<ffi.UnsignedInt> count,
);

@ffi.Native<ffi.Void Function(Dart_FinalizableHandle, ffi.Handle)>(
    symbol: 'DOBJC_deleteFinalizableHandle')
external void deleteFinalizableHandle(
  Dart_FinalizableHandle handle,
  Object owner,
);

@ffi.Native<ffi.Void Function(ffi.Pointer<ObjCBlockImpl>)>(
    symbol: 'DOBJC_disposeObjCBlockWithClosure')
external void disposeObjCBlockWithClosure(
  ffi.Pointer<ObjCBlockImpl> block,
);

@ffi.Native<ffi.Pointer<DOBJC_Context> Function(ffi.Pointer<DOBJC_Context>)>(
    symbol: 'DOBJC_fillContext', isLeaf: true)
external ffi.Pointer<DOBJC_Context> fillContext(
  ffi.Pointer<DOBJC_Context> context,
);

@ffi.Native<ffi.Pointer<ObjCObject> Function(ffi.Pointer<ffi.Char>)>(
    symbol: 'objc_getClass', isLeaf: true)
external ffi.Pointer<ObjCObject> getClass(
  ffi.Pointer<ffi.Char> name,
);

@ffi.Native<
    ObjCMethodDesc Function(
        ffi.Pointer<ObjCProtocol>,
        ffi.Pointer<ObjCSelector>,
        ffi.Bool,
        ffi.Bool)>(symbol: 'protocol_getMethodDescription', isLeaf: true)
external ObjCMethodDesc getMethodDescription(
  ffi.Pointer<ObjCProtocol> protocol,
  ffi.Pointer<ObjCSelector> sel,
  bool isRequiredMethod,
  bool isInstanceMethod,
);

@ffi.Native<ffi.Pointer<ffi.Char> Function(ffi.Pointer<ObjCSelector>)>(
    symbol: 'sel_getName', isLeaf: true)
external ffi.Pointer<ffi.Char> getName(
  ffi.Pointer<ObjCSelector> sel,
);

@ffi.Native<ffi.Pointer<ObjCObject> Function(ffi.Pointer<ObjCObject>)>(
    symbol: 'object_getClass', isLeaf: true)
external ffi.Pointer<ObjCObject> getObjectClass(
  ffi.Pointer<ObjCObject> object,
);

/// Returns the MacOS/iOS version we're running on.
@ffi.Native<_Version Function()>(symbol: 'DOBJC_getOsVesion', isLeaf: true)
external _Version getOsVesion();

@ffi.Native<ffi.Pointer<ObjCProtocol> Function(ffi.Pointer<ffi.Char>)>(
    symbol: 'objc_getProtocol', isLeaf: true)
external ffi.Pointer<ObjCProtocol> getProtocol(
  ffi.Pointer<ffi.Char> name,
);

@ffi.Native<ffi.Pointer<ffi.Char> Function(ffi.Pointer<ObjCProtocol>)>(
    symbol: 'protocol_getName', isLeaf: true)
external ffi.Pointer<ffi.Char> getProtocolName(
  ffi.Pointer<ObjCProtocol> proto,
);

@ffi.Native<ffi.IntPtr Function(ffi.Pointer<ffi.Void>)>(
    symbol: 'DOBJC_initializeApi', isLeaf: true)
external int initializeApi(
  ffi.Pointer<ffi.Void> data,
);

@ffi.Native<ffi.Bool Function(ffi.Pointer<ObjCBlockImpl>)>(
    symbol: 'DOBJC_isValidBlock', isLeaf: true)
external bool isValidBlock(
  ffi.Pointer<ObjCBlockImpl> block,
);

@ffi.Native<ffi.Void Function()>(symbol: 'objc_msgSend')
external void msgSend();

@ffi.Native<ffi.Void Function()>(symbol: 'objc_msgSend_fpret')
external void msgSendFpret();

@ffi.Native<ffi.Void Function()>(symbol: 'objc_msgSend_stret')
external void msgSendStret();

@ffi.Native<ffi.Pointer<ffi.Bool> Function(ffi.Handle)>(
    symbol: 'DOBJC_newFinalizableBool')
external ffi.Pointer<ffi.Bool> newFinalizableBool(
  Object owner,
);

@ffi.Native<
        Dart_FinalizableHandle Function(ffi.Handle, ffi.Pointer<ObjCObject>)>(
    symbol: 'DOBJC_newFinalizableHandle')
external Dart_FinalizableHandle newFinalizableHandle(
  Object owner,
  ffi.Pointer<ObjCObject> object,
);

@ffi.Native<ffi.Pointer<ffi.Void> Function()>(
    symbol: 'DOBJC_newWaiter', isLeaf: true)
external ffi.Pointer<ffi.Void> newWaiter();

@ffi.Native<ffi.Pointer<ObjCObject> Function(ffi.Pointer<ObjCObject>)>(
    symbol: 'objc_autorelease', isLeaf: true)
external ffi.Pointer<ObjCObject> objectAutorelease(
  ffi.Pointer<ObjCObject> object,
);

@ffi.Native<ffi.Void Function(ffi.Pointer<ObjCObject>)>(
    symbol: 'objc_release', isLeaf: true)
external void objectRelease(
  ffi.Pointer<ObjCObject> object,
);

@ffi.Native<ffi.Pointer<ObjCObject> Function(ffi.Pointer<ObjCObject>)>(
    symbol: 'objc_retain', isLeaf: true)
external ffi.Pointer<ObjCObject> objectRetain(
  ffi.Pointer<ObjCObject> object,
);

@ffi.Native<ffi.Void Function(ffi.Pointer<ObjCObject>)>(
    symbol: 'objc_registerClassPair', isLeaf: true)
external void registerClassPair(
  ffi.Pointer<ObjCObject> cls,
);

@ffi.Native<ffi.Pointer<ObjCSelector> Function(ffi.Pointer<ffi.Char>)>(
    symbol: 'sel_registerName', isLeaf: true)
external ffi.Pointer<ObjCSelector> registerName(
  ffi.Pointer<ffi.Char> name,
);

@ffi.Native<
    ffi.Void Function(
        ffi.Pointer<
            ffi.NativeFunction<ffi.Void Function(ffi.Pointer<ffi.Void>)>>,
        ffi.Pointer<ffi.Void>)>(symbol: 'DOBJC_runOnMainThread', isLeaf: true)
external void runOnMainThread(
  ffi.Pointer<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<ffi.Void>)>> fn,
  ffi.Pointer<ffi.Void> arg,
);

@ffi.Native<ffi.Void Function(ffi.Pointer<ffi.Void>)>(
    symbol: 'DOBJC_signalWaiter', isLeaf: true)
external void signalWaiter(
  ffi.Pointer<ffi.Void> waiter,
);

final class DOBJC_Context extends ffi.Struct {
  @ffi.Int64()
  external int version;

  external ffi.Pointer<ffi.NativeFunction<ffi.Pointer<ffi.Void> Function()>>
      newWaiter;

  external ffi
      .Pointer<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<ffi.Void>)>>
      awaitWaiter;

  external ffi
      .Pointer<ffi.NativeFunction<ffi.Pointer<_Dart_Isolate> Function()>>
      currentIsolate;

  external ffi.Pointer<
          ffi.NativeFunction<ffi.Void Function(ffi.Pointer<_Dart_Isolate>)>>
      enterIsolate;

  external ffi.Pointer<ffi.NativeFunction<ffi.Void Function()>> exitIsolate;

  external ffi.Pointer<ffi.NativeFunction<ffi.Int64 Function()>> getMainPortId;

  external ffi.Pointer<ffi.NativeFunction<ffi.Bool Function(ffi.Int64)>>
      getCurrentThreadOwnsIsolate;
}

typedef Dart_FinalizableHandle = ffi.Pointer<Dart_FinalizableHandle_>;

final class Dart_FinalizableHandle_ extends ffi.Opaque {}

const int ILLEGAL_PORT = 0;

final class ObjCBlockDesc extends ffi.Struct {
  @ffi.UnsignedLong()
  external int reserved;

  @ffi.UnsignedLong()
  external int size;

  external ffi.Pointer<
          ffi.NativeFunction<
              ffi.Void Function(
                  ffi.Pointer<ffi.Void> dst, ffi.Pointer<ffi.Void> src)>>
      copy_helper;

  external ffi
      .Pointer<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<ffi.Void> src)>>
      dispose_helper;

  external ffi.Pointer<ffi.Char> signature;
}

final class ObjCBlockImpl extends ffi.Struct {
  external ffi.Pointer<ffi.Void> isa;

  @ffi.Int()
  external int flags;

  @ffi.Int()
  external int reserved;

  external ffi.Pointer<ffi.Void> invoke;

  external ffi.Pointer<ObjCBlockDesc> descriptor;

  external ffi.Pointer<ffi.Void> target;

  @ffi.Int64()
  external int dispose_port;
}

final class ObjCMethodDesc extends ffi.Struct {
  external ffi.Pointer<ObjCSelector> name;

  external ffi.Pointer<ffi.Char> types;
}

final class ObjCObject extends ffi.Opaque {}

final class ObjCProtocol extends ffi.Opaque {}

final class ObjCSelector extends ffi.Opaque {}

final class _Dart_Isolate extends ffi.Opaque {}

final class _Version extends ffi.Struct {
  @ffi.Int()
  external int major;

  @ffi.Int()
  external int minor;

  @ffi.Int()
  external int patch;
}
