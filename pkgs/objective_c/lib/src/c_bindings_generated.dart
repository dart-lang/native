// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Bindings for `src/objective_c.h` and `src/objective_c_runtime.h`.
// Regenerate bindings with `dart run ffigen --config ffigen_c.yaml`.

// ignore_for_file: always_specify_types
// ignore_for_file: camel_case_types
// ignore_for_file: non_constant_identifier_names

// AUTO GENERATED FILE, DO NOT EDIT.
//
// Generated by `package:ffigen`.
// ignore_for_file: type=lint
import 'dart:ffi' as ffi;

@ffi.Native<ffi.Pointer<ObjCSelector> Function(ffi.Pointer<ffi.Char>)>(
    symbol: "sel_registerName", isLeaf: true)
external ffi.Pointer<ObjCSelector> registerName(
  ffi.Pointer<ffi.Char> name,
);

@ffi.Native<ffi.Pointer<ObjCObject> Function(ffi.Pointer<ffi.Char>)>(
    symbol: "objc_getClass", isLeaf: true)
external ffi.Pointer<ObjCObject> getClass(
  ffi.Pointer<ffi.Char> name,
);

@ffi.Native<ffi.Pointer<ObjCObject> Function(ffi.Pointer<ObjCObject>)>(
    symbol: "objc_retain", isLeaf: true)
external ffi.Pointer<ObjCObject> objectRetain(
  ffi.Pointer<ObjCObject> object,
);

@ffi.Native<ffi.Void Function(ffi.Pointer<ObjCObject>)>(
    symbol: "objc_release", isLeaf: true)
external void objectRelease(
  ffi.Pointer<ObjCObject> object,
);

@ffi.Native<ffi.Void Function()>(symbol: "objc_msgSend")
external void msgSend();

@ffi.Native<ffi.Void Function()>(symbol: "objc_msgSend_fpret")
external void msgSendFpret();

@ffi.Native<ffi.Void Function()>(symbol: "objc_msgSend_stret")
external void msgSendStret();

@ffi.Native<ffi.Pointer<ffi.Void>>(symbol: "_NSConcreteGlobalBlock")
external final ffi.Pointer<ffi.Void> NSConcreteGlobalBlock;

@ffi.Native<ffi.Pointer<ObjCBlock> Function(ffi.Pointer<ObjCBlock>)>(
    symbol: "_Block_copy", isLeaf: true)
external ffi.Pointer<ObjCBlock> blockCopy(
  ffi.Pointer<ObjCBlock> object,
);

@ffi.Native<ffi.Void Function(ffi.Pointer<ObjCBlock>)>(
    symbol: "_Block_release", isLeaf: true)
external void blockRelease(
  ffi.Pointer<ObjCBlock> object,
);

final class _ObjCSelector extends ffi.Opaque {}

final class _ObjCObject extends ffi.Opaque {}

typedef ObjCSelector = _ObjCSelector;
typedef ObjCObject = _ObjCObject;

final class _ObjCBlockDesc extends ffi.Struct {
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

final class _ObjCBlock extends ffi.Struct {
  external ffi.Pointer<ffi.Void> isa;

  @ffi.Int()
  external int flags;

  @ffi.Int()
  external int reserved;

  external ffi.Pointer<ffi.Void> invoke;

  external ffi.Pointer<ObjCBlockDesc> descriptor;

  external ffi.Pointer<ffi.Void> target;
}

typedef ObjCBlockDesc = _ObjCBlockDesc;
typedef ObjCBlock = _ObjCBlock;
