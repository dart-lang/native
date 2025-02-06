// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:meta/meta.dart' show internal;
import 'package:path/path.dart';

import 'accessors.dart';
import 'errors.dart';
import 'jobject.dart';
import 'jreference.dart';
import 'third_party/generated_bindings.dart';
import 'types.dart';

String _getLibraryFileName(String base) {
  if (Platform.isLinux || Platform.isAndroid) {
    return 'lib$base.so';
  } else if (Platform.isWindows) {
    return '$base.dll';
  } else if (Platform.isMacOS) {
    return 'lib$base.dylib';
  } else {
    throw UnsupportedError('cannot derive library name: unsupported platform');
  }
}

/// Load Dart-JNI Helper library.
///
/// If path is provided, it's used to load the library.
/// Else just the platform-specific filename is passed to DynamicLibrary.open
DynamicLibrary _loadDartJniLibrary({String? dir, String baseName = 'dartjni'}) {
  final fileName = _getLibraryFileName(baseName);
  final libPath = (dir != null) ? join(dir, fileName) : fileName;
  try {
    final dylib = DynamicLibrary.open(libPath);
    return dylib;
  } catch (_) {
    throw HelperNotFoundError(libPath);
  }
}

/// Utilities to spawn and manage JNI.
abstract final class Jni {
  static final DynamicLibrary _dylib = _loadDartJniLibrary(dir: _dylibDir);
  static final JniBindings _bindings = JniBindings(_dylib);

  /// Store dylibDir if any was used.
  static String? _dylibDir;

  /// Sets the directory where dynamic libraries are looked for.
  /// On dart standalone, call this in new isolate before doing
  /// any JNI operation.
  ///
  /// (The reason is that dylibs need to be loaded in every isolate.
  /// On flutter it's done by library. On dart standalone we don't
  /// know the library path.)
  static void setDylibDir({required String dylibDir}) {
    if (!Platform.isAndroid) {
      _dylibDir = dylibDir;
    }
  }

  /// Spawn an instance of JVM using JNI. This method should be called at the
  /// beginning of the program with appropriate options, before other isolates
  /// are spawned.
  ///
  /// [dylibDir] is path of the directory where the wrapper library is found.
  /// This parameter needs to be passed manually on __Dart standalone target__,
  /// since we have no reliable way to bundle it with the package.
  ///
  /// [jvmOptions], [ignoreUnrecognized], & [jniVersion] are passed to the JVM.
  /// Strings in [classPath], if any, are used to construct an additional
  /// JVM option of the form "-Djava.class.path={paths}".
  static void spawn({
    String? dylibDir,
    List<String> jvmOptions = const [],
    List<String> classPath = const [],
    bool ignoreUnrecognized = false,
    int jniVersion = JniVersions.JNI_VERSION_1_6,
  }) {
    final status = spawnIfNotExists(
      dylibDir: dylibDir,
      jvmOptions: jvmOptions,
      classPath: classPath,
      ignoreUnrecognized: ignoreUnrecognized,
      jniVersion: jniVersion,
    );
    if (status == false) {
      throw JniVmExistsError();
    }
  }

  /// Same as [spawn] but if a JVM exists, returns silently instead of
  /// throwing [JniVmExistsError].
  ///
  /// If the options are different than that of existing VM, the existing VM's
  /// options will remain in effect.
  static bool spawnIfNotExists({
    String? dylibDir,
    List<String> jvmOptions = const [],
    List<String> classPath = const [],
    bool ignoreUnrecognized = false,
    int jniVersion = JniVersions.JNI_VERSION_1_6,
  }) =>
      using((arena) {
        _dylibDir = dylibDir;
        final jvmArgs = _createVMArgs(
          options: jvmOptions,
          classPath: classPath,
          version: jniVersion,
          dylibPath: dylibDir,
          ignoreUnrecognized: ignoreUnrecognized,
          allocator: arena,
        );
        final status = _bindings.SpawnJvm(jvmArgs);
        if (status == JniErrorCode.JNI_OK) {
          return true;
        } else if (status == DART_JNI_SINGLETON_EXISTS) {
          return false;
        } else {
          throw JniError.of(status);
        }
      });

  static Pointer<JavaVMInitArgs> _createVMArgs({
    List<String> options = const [],
    List<String> classPath = const [],
    String? dylibPath,
    bool ignoreUnrecognized = false,
    int version = JniVersions.JNI_VERSION_1_6,
    required Allocator allocator,
  }) {
    final args = allocator<JavaVMInitArgs>();
    if (options.isNotEmpty || classPath.isNotEmpty) {
      final count = options.length +
          (dylibPath != null ? 1 : 0) +
          (classPath.isNotEmpty ? 1 : 0);
      final optsPtr = (count != 0) ? allocator<JavaVMOption>(count) : nullptr;
      args.ref.options = optsPtr;
      for (var i = 0; i < options.length; i++) {
        (optsPtr + i).ref.optionString = options[i].toNativeChars(allocator);
      }
      if (dylibPath != null) {
        (optsPtr + count - 1 - (classPath.isNotEmpty ? 1 : 0))
                .ref
                .optionString =
            '-Djava.library.path=$dylibPath'.toNativeChars(allocator);
      }
      if (classPath.isNotEmpty) {
        final classPathString = classPath.join(Platform.isWindows ? ';' : ':');
        (optsPtr + count - 1).ref.optionString =
            '-Djava.class.path=$classPathString'.toNativeChars(allocator);
      }
      args.ref.nOptions = count;
    }
    args.ref.ignoreUnrecognized = ignoreUnrecognized ? 1 : 0;
    args.ref.version = version;
    return args;
  }

  /// Returns pointer to current JNI JavaVM instance
  Pointer<JavaVM> getJavaVM() {
    return _bindings.GetJavaVM();
  }

  /// Finds the class from its [name].
  ///
  /// Uses the correct class loader on Android.
  /// Prefer this over `Jni.env.FindClass`.
  static JClassPtr findClass(String name) {
    return using((arena) => _bindings.FindClass(name.toNativeChars(arena)))
        .checkedClassRef;
  }

  /// Throws an exception.
  // TODO(#561): Throw an actual `JThrowable`.
  static void throwException(JThrowablePtr exception) {
    final details = _bindings.GetExceptionDetails(exception);
    final env = Jni.env;
    final message = env.toDartString(details.message);
    final stacktrace = env.toDartString(details.stacktrace);
    env.DeleteGlobalRef(exception);
    env.DeleteGlobalRef(details.message);
    env.DeleteGlobalRef(details.stacktrace);
    throw JniException(message, stacktrace);
  }

  /// Returns the instance of [GlobalJniEnvStruct], which is an abstraction over
  /// JNIEnv without the same-thread restriction.
  static Pointer<GlobalJniEnvStruct> _fetchGlobalEnv() {
    final env = _bindings.GetGlobalEnv();
    if (env == nullptr) {
      throw NoJvmInstanceError();
    }
    return env;
  }

  /// Points to a process-wide shared instance of [GlobalJniEnv].
  ///
  /// It provides an indirection over [JniEnv] so that it can be used from
  /// any thread, and always returns global object references.
  static final env = GlobalJniEnv(_fetchGlobalEnv());

  /// Returns current application context on Android.
  static JReference getCachedApplicationContext() {
    return JGlobalReference(_bindings.GetApplicationContext());
  }

  /// Returns current activity.
  static JReference getCurrentActivity() =>
      JGlobalReference(_bindings.GetCurrentActivity());

  /// Get the initial classLoader of the application.
  ///
  /// This is especially useful on Android, where
  /// JNI threads cannot access application classes using
  /// the usual `JniEnv.FindClass` method.
  static JReference getApplicationClassLoader() =>
      JGlobalReference(_bindings.GetClassLoader());
}

/// Extensions for use by `jnigen` generated code.
@internal
extension ProtectedJniExtensions on Jni {
  static bool _initialized = false;

  /// Initializes DartApiDL used for Continuations and interface implementation.
  static void ensureInitialized() {
    if (!_initialized) {
      assert(NativeApi.majorVersion == 2);
      assert(NativeApi.minorVersion >= 3);
      final result = Jni._bindings.InitDartApiDL(NativeApi.initializeApiDLData);
      _initialized = result == 0;
      assert(_initialized);
    }
  }

  static int getCurrentIsolateId() {
    return Jni._bindings.GetCurrentIsolateId();
  }

  static final _jThrowableClass = JClass.forName('java/lang/Throwable');

  /// Returns a new DartException.
  static Pointer<Void> newDartException(Object exception) {
    JObjectPtr? cause;
    if (exception is JObject) {
      final exceptionRef = exception.reference;
      if (Jni.env.IsInstanceOf(
          exceptionRef.pointer, _jThrowableClass.reference.pointer)) {
        cause = exceptionRef.pointer;
      }
    }
    return Jni._bindings
        .DartException__ctor(
            Jni.env.toJStringPtr(exception.toString()), cause ?? nullptr)
        .objectPointer;
  }

  /// Returns a new PortContinuation.
  static JReference newPortContinuation(ReceivePort port) {
    ensureInitialized();
    return JGlobalReference(
      Jni._bindings
          .PortContinuation__ctor(port.sendPort.nativePort)
          .objectPointer,
    );
  }

  /// Returns the result of a callback.
  static void returnResult(
      Pointer<CallbackResult> result, JObjectPtr object) async {
    // The result is `nullptr` when the callback is a listener.
    if (result != nullptr) {
      Jni._bindings.resultFor(result, object);
    }
  }

  static Dart_FinalizableHandle newJObjectFinalizableHandle(
    Object object,
    Pointer<Void> reference,
    int refType,
  ) {
    ensureInitialized();
    return Jni._bindings
        .newJObjectFinalizableHandle(object, reference, refType);
  }

  static Dart_FinalizableHandle newBooleanFinalizableHandle(
    Object object,
    Pointer<Bool> reference,
  ) {
    ensureInitialized();
    return Jni._bindings.newBooleanFinalizableHandle(object, reference);
  }

  static void deleteFinalizableHandle(
      Dart_FinalizableHandle finalizableHandle, Object object) {
    ensureInitialized();
    Jni._bindings.deleteFinalizableHandle(finalizableHandle, object);
  }

  static Pointer<T> Function<T extends NativeType>(String) get lookup =>
      Jni._dylib.lookup;
}

extension AdditionalEnvMethods on GlobalJniEnv {
  /// Convenience method for converting a [JStringPtr] to dart string.
  /// if [releaseOriginal] is specified, jstring passed will be deleted using
  /// DeleteGlobalRef.
  String toDartString(JStringPtr jstringPtr, {bool releaseOriginal = false}) {
    if (jstringPtr == nullptr) {
      throw JNullError();
    }
    final chars = GetStringChars(jstringPtr, nullptr);
    if (chars == nullptr) {
      throw ArgumentError('Not a valid jstring pointer.');
    }
    final length = GetStringLength(jstringPtr);
    final result = chars.cast<Utf16>().toDartString(length: length);
    ReleaseStringChars(jstringPtr, chars);
    if (releaseOriginal) {
      DeleteGlobalRef(jstringPtr);
    }
    return result;
  }

  /// Returns a new [JStringPtr] from contents of [s].
  JStringPtr toJStringPtr(String s) => using((arena) {
        final utf = s.toNativeUtf16(allocator: arena).cast<Uint16>();
        final result = NewString(utf, s.length);
        if (utf == nullptr) {
          throw JniException(
              'Fatal: cannot convert string to Java string: $s', '');
        }
        return result;
      });
}

@internal
extension StringMethodsForJni on String {
  /// Returns a Utf-8 encoded `Pointer<Char>` with contents same as this string.
  Pointer<Char> toNativeChars(Allocator allocator) {
    return toNativeUtf8(allocator: allocator).cast<Char>();
  }
}
