// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:path/path.dart';

import 'errors.dart';
import 'jobject.dart';
import 'third_party/generated_bindings.dart';
import 'jvalues.dart';
import 'accessors.dart';

String _getLibraryFileName(String base) {
  if (Platform.isLinux || Platform.isAndroid) {
    return "lib$base.so";
  } else if (Platform.isWindows) {
    return "$base.dll";
  } else if (Platform.isMacOS) {
    return "lib$base.dylib";
  } else {
    throw UnsupportedError("cannot derive library name: unsupported platform");
  }
}

/// Load Dart-JNI Helper library.
///
/// If path is provided, it's used to load the library.
/// Else just the platform-specific filename is passed to DynamicLibrary.open
DynamicLibrary _loadDartJniLibrary({String? dir, String baseName = "dartjni"}) {
  final fileName = _getLibraryFileName(baseName);
  final libPath = (dir != null) ? join(dir, fileName) : fileName;
  try {
    final dylib = DynamicLibrary.open(libPath);
    return dylib;
  } on Error {
    throw HelperNotFoundError(libPath);
  }
}

/// Utilities to spawn and manage JNI.
abstract class Jni {
  static final DynamicLibrary _dylib = _loadDartJniLibrary(dir: _dylibDir);
  static final JniBindings _bindings = JniBindings(_dylib);
  static final _getJniEnvFn = _dylib.lookup<Void>('GetJniEnv');
  static final _getJniContextFn = _dylib.lookup<Void>('GetJniContextPtr');

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
    _dylibDir = dylibDir;
  }

  /// Initializes DartApiDL used for Continuations and interface implementation.
  static void initDLApi() {
    assert(NativeApi.majorVersion == 2);
    assert(NativeApi.minorVersion >= 3);
    final result = _bindings.InitDartApiDL(NativeApi.initializeApiDLData);
    assert(result == 0);
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
  /// throwing [JvmExistsError].
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
      for (int i = 0; i < options.length; i++) {
        optsPtr.elementAt(i).ref.optionString =
            options[i].toNativeChars(allocator);
      }
      if (dylibPath != null) {
        optsPtr
                .elementAt(count - 1 - (classPath.isNotEmpty ? 1 : 0))
                .ref
                .optionString =
            "-Djava.library.path=$dylibPath".toNativeChars(allocator);
      }
      if (classPath.isNotEmpty) {
        final classPathString = classPath.join(Platform.isWindows ? ';' : ":");
        optsPtr.elementAt(count - 1).ref.optionString =
            "-Djava.class.path=$classPathString".toNativeChars(allocator);
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

  static final accessors = JniAccessors(_bindings.GetAccessors());

  /// Returns current application context on Android.
  static JObjectPtr getCachedApplicationContext() {
    return _bindings.GetApplicationContext();
  }

  /// Returns current activity
  static JObjectPtr getCurrentActivity() => _bindings.GetCurrentActivity();

  /// Get the initial classLoader of the application.
  ///
  /// This is especially useful on Android, where
  /// JNI threads cannot access application classes using
  /// the usual `JniEnv.FindClass` method.
  static JObjectPtr getApplicationClassLoader() => _bindings.GetClassLoader();

  /// Returns class reference found through system-specific mechanism
  static JClassPtr findClass(String qualifiedName) => using((arena) {
        final cls = accessors.getClass(qualifiedName.toNativeChars(arena));
        return cls.checkedClassRef;
      });

  /// Returns class for [qualifiedName] found by platform-specific mechanism,
  /// wrapped in a [JClass].
  static JClass findJClass(String qualifiedName) =>
      JClass.fromRef(findClass(qualifiedName));

  /// Constructs an instance of class with given arguments.
  ///
  /// Use it when one instance is needed, but the constructor or class aren't
  /// required themselves.
  static JObject newInstance(
      String qualifiedName, String ctorSignature, List<dynamic> args) {
    final cls = findJClass(qualifiedName);
    final ctor = cls.getCtorID(ctorSignature);
    final obj = cls.newInstance(ctor, args);
    cls.release();
    return obj;
  }

  /// Converts passed arguments to JValue array.
  ///
  /// long, bool, double and JObject types are converted out of the box.
  /// Wrap values in types such as [JValueInt] to convert to other primitive
  /// types such as `int`, `short` and `char`.
  static Pointer<JValue> jvalues(List<dynamic> args,
      {Allocator allocator = calloc}) {
    return toJValues(args, allocator: allocator);
  }

  /// Returns the value of static field identified by [fieldName] & [signature].
  ///
  /// See [JObject.getField] for more explanations about [callType] and [T].
  static T retrieveStaticField<T>(
      String className, String fieldName, String signature,
      [int? callType]) {
    final cls = findJClass(className);
    final result = cls.getStaticFieldByName<T>(fieldName, signature, callType);
    cls.release();
    return result;
  }

  /// Calls static method identified by [methodName] and [signature]
  /// on [className] with [args] as and [callType].
  ///
  /// For more explanation on [args] and [callType], see [JObject.getField]
  /// and [JObject.callMethod] respectively.
  static T invokeStaticMethod<T>(
      String className, String methodName, String signature, List<dynamic> args,
      [int? callType]) {
    final cls = findJClass(className);
    final result =
        cls.callStaticMethodByName<T>(methodName, signature, args, callType);
    cls.release();
    return result;
  }
}

typedef _SetJniGettersNativeType = Void Function(Pointer<Void>, Pointer<Void>);
typedef _SetJniGettersDartType = void Function(Pointer<Void>, Pointer<Void>);

/// Extensions for use by `jnigen` generated code.
extension ProtectedJniExtensions on Jni {
  static Pointer<T> Function<T extends NativeType>(String) initGeneratedLibrary(
      String name) {
    var path = _getLibraryFileName(name);
    if (Jni._dylibDir != null) {
      path = join(Jni._dylibDir!, path);
    }
    final dl = DynamicLibrary.open(path);
    final setJniGetters =
        dl.lookupFunction<_SetJniGettersNativeType, _SetJniGettersDartType>(
            'setJniGetters');
    setJniGetters(Jni._getJniContextFn, Jni._getJniEnvFn);
    final lookup = dl.lookup;
    return lookup;
  }

  /// Returns a new DartException.
  static JObjectPtr newDartException(String message) {
    return Jni._bindings
        .DartException__ctor(Jni.env.toJStringPtr(message))
        .object;
  }

  /// Returns a new PortContinuation.
  static JObjectPtr newPortContinuation(ReceivePort port) {
    return Jni._bindings
        .PortContinuation__ctor(port.sendPort.nativePort)
        .object;
  }

  /// Returns a new PortProxy for a class with the given [binaryName].
  static JObjectPtr newPortProxy(
      String binaryName,
      ReceivePort port,
      Pointer<
              NativeFunction<
                  Pointer<Void> Function(Uint64, Pointer<Void>, Pointer<Void>)>>
          functionPtr) {
    return Jni._bindings
        .PortProxy__newInstance(
          Jni.env.toJStringPtr(binaryName),
          port.sendPort.nativePort,
          functionPtr.address,
        )
        .object;
  }

  /// Returns the result of a callback..
  static void returnResult(
      Pointer<CallbackResult> result, JObjectPtr object) async {
    Jni._bindings.resultFor(result, object);
  }
}

extension AdditionalEnvMethods on GlobalJniEnv {
  /// Convenience method for converting a [JStringPtr]
  /// to dart string.
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
    final result = chars.cast<Utf16>().toDartString();
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
          throw 'Fatal: cannot convert string to Java string: $s';
        }
        return result;
      });

  /// Deletes all references in [refs].
  void deleteAllRefs(List<JObjectPtr> refs) {
    for (final ref in refs) {
      DeleteGlobalRef(ref);
    }
  }
}

extension StringMethodsForJni on String {
  /// Returns a Utf-8 encoded Pointer<Char> with contents same as this string.
  Pointer<Char> toNativeChars([Allocator allocator = malloc]) {
    return toNativeUtf8(allocator: allocator).cast<Char>();
  }
}

extension CharPtrMethodsForJni on Pointer<Char> {
  /// Same as calling `cast<Utf8>` followed by `toDartString`.
  String toDartString() {
    return cast<Utf8>().toDartString();
  }
}
