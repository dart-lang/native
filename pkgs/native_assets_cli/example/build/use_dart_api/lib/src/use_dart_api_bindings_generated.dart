// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// AUTO GENERATED FILE, DO NOT EDIT.
//
// Generated by `package:ffigen`.
// ignore_for_file: type=lint
import 'dart:ffi' as ffi;

@ffi.Native<ffi.Int32 Function(ffi.Int32, ffi.Int32)>(symbol: 'add')
external int add(int a, int b);

@ffi.Native<ffi.IntPtr Function(ffi.Pointer<ffi.Void>)>(symbol: 'InitDartApiDL')
external int InitDartApiDL(ffi.Pointer<ffi.Void> data);

@ffi.Native<ffi.Pointer<ffi.Void> Function(ffi.Handle)>(
  symbol: 'NewPersistentHandle',
)
external ffi.Pointer<ffi.Void> NewPersistentHandle(
  Object non_persistent_handle,
);

@ffi.Native<ffi.Handle Function(ffi.Pointer<ffi.Void>)>(
  symbol: 'HandleFromPersistent',
)
external Object HandleFromPersistent(ffi.Pointer<ffi.Void> persistent_handle);
