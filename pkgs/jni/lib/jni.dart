// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Package jni provides dart bindings for the Java Native Interface (JNI) on
/// Android and desktop platforms.
///
/// It's intended as a supplement to the jnigen tool, a Java wrapper generator
/// using JNI. The goal of this package is to provide sufficiently complete
/// and ergonomic access to underlying JNI APIs.
///
/// Therefore, some understanding of JNI is required to use this module.
///
/// ## Java VM
/// On Android, the existing JVM is used, a new JVM needs to be spawned on
/// flutter desktop & standalone targets.
///
/// ```dart
/// if (!Platform.isAndroid) {
///   // Spin up a JVM instance with custom classpath etc..
///   Jni.spawn(/* options */);
/// }
/// ```
///
/// ## Dart standalone support
/// On dart standalone target, we unfortunately have no mechanism to bundle
/// the wrapper libraries with the executable. Thus it needs to be explicitly
/// placed in a accessible directory and provided as an argument to Jni.spawn.
///
/// This module depends on a shared library written in C. Therefore on dart
/// standalone:
///
/// * Run `dart run jni:setup` to build the shared library. This command builds
/// all dependency libraries with native code (package:jni and jnigen-generated)
/// libraries if any.
///
/// The default output directory is build/jni_libs, which can be changed
/// using `-B` switch.
///
/// * Provide the location of library to `Jni.spawn` call.
///
/// ## JNIEnv
/// `GlobalJniEnv` type provides a thin wrapper over `JNIEnv*` which can be used
/// from across threads, and always returns JNI global references. This is
/// needed because Dart doesn't make guarantees about even the straight-line
/// code being scheduled on the same thread.
///
/// ## Debugging
/// Debugging JNI errors hard in general.
///
/// * On desktop platforms you can use JniEnv.ExceptionDescribe to print any
/// pending exception to stdout.
/// * On Android, things are slightly easier since CheckJNI is usually enabled
/// in debug builds. If you are not getting clear stack traces on JNI errors,
/// check the Android NDK page on how to enable CheckJNI using ADB.
/// * As a rule of thumb, when there's a NoClassDefFound / NoMethodFound error,
/// first check your class and method signatures for typos. Another common
/// reason for NoClassDefFound error is missing classes in classpath.

/// This library provides classes and functions for JNI interop from Dart.
library jni;

export 'dart:ffi' show nullptr;

export 'package:ffi/ffi.dart' show using, Arena;

export 'src/errors.dart';
export 'src/jarray.dart';
export 'src/jni.dart' hide ProtectedJniExtensions;
export 'src/jobject.dart';
export 'src/jreference.dart';
export 'src/jvalues.dart';
export 'src/lang/lang.dart';
export 'src/nio/nio.dart';
export 'src/third_party/generated_bindings.dart'
    hide JniBindings, JniEnv, JniEnv1, JniExceptionDetails;
export 'src/types.dart' hide referenceType;
export 'src/util/util.dart';
