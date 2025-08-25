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
export 'src/jarray.dart'
    show
        $JArray$NullableType$,
        $JArray$Type$,
        $JBooleanArray$NullableType$,
        $JBooleanArray$Type$,
        $JByteArray$NullableType$,
        $JByteArray$Type$,
        $JCharArray$NullableType$,
        $JCharArray$Type$,
        $JDoubleArray$NullableType$,
        $JDoubleArray$Type$,
        $JFloatArray$NullableType$,
        $JFloatArray$Type$,
        $JIntArray$NullableType$,
        $JIntArray$Type$,
        $JLongArray$NullableType$,
        $JLongArray$Type$,
        $JShortArray$NullableType$,
        $JShortArray$Type$;
export 'src/jni.dart' show ProtectedJniExtensions;
export 'src/jobject.dart' show $JObject$NullableType$, $JObject$Type$;
export 'src/jreference.dart';
export 'src/kotlin.dart'
    show coroutineSingletonsClass, failureExceptionField, result$FailureClass;
export 'src/lang/jboolean.dart' show $JBoolean$NullableType$, $JBoolean$Type$;
export 'src/lang/jbyte.dart' show $JByte$NullableType$, $JByte$Type$;
export 'src/lang/jcharacter.dart'
    show $JCharacter$NullableType$, $JCharacter$Type$;
export 'src/lang/jdouble.dart' show $JDouble$NullableType$, $JDouble$Type$;
export 'src/lang/jfloat.dart' show $JFloat$NullableType$, $JFloat$Type$;
export 'src/lang/jinteger.dart' show $JInteger$NullableType$, $JInteger$Type$;
export 'src/lang/jlong.dart' show $JLong$NullableType$, $JLong$Type$;
export 'src/lang/jnumber.dart' show $JNumber$NullableType$, $JNumber$Type$;
export 'src/lang/jshort.dart' show $JShort$NullableType$, $JShort$Type$;
export 'src/lang/jstring.dart' show $JString$NullableType$, $JString$Type$;
export 'src/method_invocation.dart';
export 'src/nio/jbuffer.dart' show $JBuffer$NullableType$, $JBuffer$Type$;
export 'src/nio/jbyte_buffer.dart'
    show $JByteBuffer$NullableType$, $JByteBuffer$Type$;
export 'src/third_party/generated_bindings.dart'
    show
        Dart_FinalizableHandle,
        JFieldIDPtr,
        JMethodIDPtr,
        JObjectPtr,
        JThrowablePtr,
        JniResult;
export 'src/types.dart' show JTypeBase, lowestCommonSuperType, referenceType;
export 'src/util/jiterator.dart'
    show $JIterator$NullableType$, $JIterator$Type$;
export 'src/util/jlist.dart' show $JList$NullableType$, $JList$Type$;
export 'src/util/jmap.dart' show $JMap$NullableType$, $JMap$Type$;
export 'src/util/jset.dart' show $JSet$NullableType$, $JSet$Type$;

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
