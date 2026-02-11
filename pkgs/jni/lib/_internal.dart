// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: invalid_export_of_internal_element

/// This library exports the methods meant for use by generated code only, and
/// not to be used directly.
library;

import 'dart:ffi' as ffi show Int32;
import 'dart:ffi' hide Int32;

// Exporting all the necessary bits for the generated bindings.
export 'dart:ffi'
    show
        Double,
        Int64,
        NativeFunction,
        NativeFunctionPointer,
        NativePort,
        Pointer,
        VarArgs,
        Void,
        nullptr;
export 'dart:isolate' show RawReceivePort, ReceivePort;

export 'package:meta/meta.dart' show internal;

export 'src/accessors.dart';
export 'src/jni.dart' show ProtectedJniExtensions;
export 'src/jobject.dart' show $JObject$Type$;
export 'src/jreference.dart';
export 'src/kotlin.dart'
    show coroutineSingletonsClass, failureExceptionField, result$FailureClass;
export 'src/lang/jboolean.dart';
export 'src/lang/jbyte.dart';
export 'src/lang/jcharacter.dart';
export 'src/lang/jdouble.dart';
export 'src/lang/jfloat.dart';
export 'src/lang/jinteger.dart';
export 'src/lang/jlong.dart';
export 'src/lang/jnumber.dart';
export 'src/lang/jshort.dart';
export 'src/lang/jstring.dart';
export 'src/method_invocation.dart';
export 'src/nio/jbuffer.dart';
export 'src/nio/jbyte_buffer.dart';
export 'src/third_party/generated_bindings.dart'
    show JFieldIDPtr, JMethodIDPtr, JObjectPtr, JThrowablePtr, JniResult;
export 'src/types.dart' show JTypeBase;
export 'src/util/jiterator.dart';
export 'src/util/jlist.dart';
export 'src/util/jmap.dart';
export 'src/util/jset.dart';

/// Temporary fix for the macOS arm64 varargs problem.
///
/// This integer type is `Int32` on all architectures, other than macOS arm64.
/// Where it is `Int64`.
@AbiSpecificIntegerMapping({
  Abi.androidArm: ffi.Int32(),
  Abi.androidArm64: ffi.Int32(),
  Abi.androidIA32: ffi.Int32(),
  Abi.androidX64: ffi.Int32(),
  Abi.androidRiscv64: ffi.Int32(),
  Abi.fuchsiaArm64: ffi.Int32(),
  Abi.fuchsiaX64: ffi.Int32(),
  Abi.fuchsiaRiscv64: ffi.Int32(),
  Abi.iosArm: ffi.Int32(),
  Abi.iosArm64: ffi.Int32(),
  Abi.iosX64: ffi.Int32(),
  Abi.linuxArm: ffi.Int32(),
  Abi.linuxArm64: ffi.Int32(),
  Abi.linuxIA32: ffi.Int32(),
  Abi.linuxX64: ffi.Int32(),
  Abi.linuxRiscv32: ffi.Int32(),
  Abi.linuxRiscv64: ffi.Int32(),
  Abi.macosArm64: Int64(), // <-- Only this is different.
  Abi.macosX64: ffi.Int32(),
  Abi.windowsArm64: ffi.Int32(),
  Abi.windowsIA32: ffi.Int32(),
  Abi.windowsX64: ffi.Int32(),
})
final class Int32 extends AbiSpecificInteger {
  const Int32();
}
