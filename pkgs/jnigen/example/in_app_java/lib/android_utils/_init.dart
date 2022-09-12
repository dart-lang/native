import "dart:ffi";
import "package:jni/internal_helpers_for_jnigen.dart";

final Pointer<T> Function<T extends NativeType>(String sym) jniLookup =
    ProtectedJniExtensions.initGeneratedLibrary("android_utils");
