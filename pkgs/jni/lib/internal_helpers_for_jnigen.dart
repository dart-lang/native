// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// This library exports the methods meant for use by generated code only, and
/// not to be used directly.
library internal_helpers_for_jnigen;

import 'dart:ffi' as ffi;

export 'src/accessors.dart';
export 'src/jni.dart' show ProtectedJniExtensions;
export 'src/types.dart' show referenceType;
export 'src/jreference.dart';
export 'src/method_invocation.dart';

/// Temporary fix for the macOS arm64 varargs problem.
///
/// This integer type is Int32 on all architectures, other than macOS arm64.
/// Where it is Int64.
@ffi.AbiSpecificIntegerMapping({
  ffi.Abi.androidArm: ffi.Int32(),
  ffi.Abi.androidArm64: ffi.Int32(),
  ffi.Abi.androidIA32: ffi.Int32(),
  ffi.Abi.androidX64: ffi.Int32(),
  ffi.Abi.androidRiscv64: ffi.Int32(),
  ffi.Abi.fuchsiaArm64: ffi.Int32(),
  ffi.Abi.fuchsiaX64: ffi.Int32(),
  ffi.Abi.fuchsiaRiscv64: ffi.Int32(),
  ffi.Abi.iosArm: ffi.Int32(),
  ffi.Abi.iosArm64: ffi.Int32(),
  ffi.Abi.iosX64: ffi.Int32(),
  ffi.Abi.linuxArm: ffi.Int32(),
  ffi.Abi.linuxArm64: ffi.Int32(),
  ffi.Abi.linuxIA32: ffi.Int32(),
  ffi.Abi.linuxX64: ffi.Int32(),
  ffi.Abi.linuxRiscv32: ffi.Int32(),
  ffi.Abi.linuxRiscv64: ffi.Int32(),
  ffi.Abi.macosArm64: ffi.Int64(), // <-- Only this is different.
  ffi.Abi.macosX64: ffi.Int32(),
  ffi.Abi.windowsArm64: ffi.Int32(),
  ffi.Abi.windowsIA32: ffi.Int32(),
  ffi.Abi.windowsX64: ffi.Int32(),
})
final class $Int32 extends ffi.AbiSpecificInteger {
  const $Int32();
}
