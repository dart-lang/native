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
import 'plugin/generated_plugin.dart';
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
    throw UnsupportedError('Cannot derive library name: unsupported platform');
  }
}

/// Loads dartjni helper library.
DynamicLibrary _loadDartJniLibrary({String? dir, String baseName = 'dartjni'}) {
  var fileName = _getLibraryFileName(baseName);
  if (!Platform.isAndroid) {
    if (dir != null) {
      fileName = join(dir, fileName);
    }
    final file = File(fileName);
    if (!file.existsSync()) {
      throw HelperNotFoundError(fileName);
    }
  }
  try {
    return DynamicLibrary.open(fileName);
  } catch (_) {
    throw DynamicLibraryLoadError(fileName);
  }
}

/// Utilities to spawn and manage JNI.
abstract final class Jni {
  static final DynamicLibrary _dylib = _loadDartJniLibrary(dir: _dylibDir);
  static final JniBindings _bindings = JniBindings(_dylib);

  static final _classCache = _JClassCache();

  /// Store dylibDir if any was used.
  static String _dylibDir = join('build', 'jni_libs');

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

  /// Whether to capture the stack trace when an object is released.
  ///
  /// This is useful for debugging [DoubleReleaseError] and
  /// [UseAfterReleaseError].
  ///
  /// Defaults to `false`.
  static bool get captureStackTraceOnRelease =>
      _bindings.getCaptureStackTraceOnRelease() != 0;

  static set captureStackTraceOnRelease(bool value) =>
      _bindings.setCaptureStackTraceOnRelease(value ? 1 : 0);

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
    JniVersions jniVersion = JniVersions.VERSION_1_6,
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
    JniVersions jniVersion = JniVersions.VERSION_1_6,
  }) =>
      using((arena) {
        _dylibDir = dylibDir ?? _dylibDir;
        final jvmArgs = _createVMArgs(
          options: jvmOptions,
          classPath: classPath,
          version: jniVersion,
          dylibPath: dylibDir,
          ignoreUnrecognized: ignoreUnrecognized,
          allocator: arena,
        );
        final status = _bindings.SpawnJvm(jvmArgs);
        if (status == JniErrorCode.OK) {
          return true;
        } else if (status == JniErrorCode.SINGLETON_EXISTS) {
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
    JniVersions version = JniVersions.VERSION_1_6,
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
    args.ref.version = version.value;
    return args;
  }

  /// Returns pointer to current JNI JavaVM instance
  Pointer<JavaVM> getJavaVM() {
    return _bindings.JniGetJavaVM();
  }

  /// Finds the class from its [name].
  ///
  /// Uses the correct class loader on Android.
  /// Prefer this over `Jni.env.FindClass`.
  static JClassPtr findClass(String name) {
    return using((arena) => _bindings.JniFindClass(name.toNativeChars(arena)))
        .checkedClassRef;
  }

  /// Finds the class from its [name], using an internal LRU cache.
  ///
  /// This is preferred for repeated lookups of the same class, as it avoids
  /// repeated JNI calls.
  ///
  /// **Returns a new JGlobalReference** that the caller owns and must delete
  /// when done (via `DeleteGlobalRef` or by wrapping in `JGlobalReference`).
  /// Each call returns a distinct global reference, even for cache hits.
  ///
  /// The cache maintains its own global references internally. Deleting the
  /// returned reference does not invalidate the cache.
  ///
  /// **Note**: This API is deprecated for direct use. Prefer
  /// [JClass.forNameCached] which uses borrowed references to minimize
  /// GlobalRef count.
  static JClassPtr getCachedClass(String name) {
    final entry = _classCache.get(name);
    return Jni.env.NewGlobalRef(entry.globalRef.pointer);
  }

  /// Internal method to get cache entry for `BorrowedReference` creation.
  @internal
  static JClassCacheEntry getCachedClassEntry(String name) {
    _ensureBorrowedReferenceCallbacks();
    return _classCache.get(name);
  }

  static bool _callbacksSetup = false;

  static final _entryRegistry = <int, JClassCacheEntry>{};

  static void _ensureBorrowedReferenceCallbacks() {
    if (_callbacksSetup) return;
    _callbacksSetup = true;

    BorrowedReference.onBorrowCallback = (Pointer<Void> entryId) {
      final id = entryId.address;
      final entry = _entryRegistry[id]!;
      entry.borrowCount++;
    };

    BorrowedReference.onReleaseCallback = (Pointer<Void> entryId) {
      final id = entryId.address;
      final entry = _entryRegistry[id]!;
      entry.borrowCount--;
      if (entry.isEvicted && entry.borrowCount == 0) {
        entry.globalRef.release();
        _entryRegistry.remove(id);
      }
    };
  }

  /// Sets the capacity of the internal LRU class cache.
  ///
  /// If the new [size] is smaller than the current number of cached classes,
  /// the least recently used classes will be **immediately evicted** and
  /// their global references released (via `DeleteGlobalRef`).
  ///
  /// This does **not** affect references returned by prior [getCachedClass]
  /// calls. Those are owned by callers and remain valid until deleted.
  ///
  /// The cache is isolate-local, so this only affects the current isolate.
  static void setClassCacheSize(int size) {
    _classCache.capacity = size;
  }

  /// Throws an exception.
  // TODO(#561): Throw an actual `JThrowable`.
  @internal
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
  @internal
  static final env = GlobalJniEnv(_fetchGlobalEnv());

  /// Retrieves the global Android `ApplicationContext` associated with a
  /// Flutter engine.
  ///
  /// The `ApplicationContext` is a long-lived singleton tied to the
  /// application's lifecycle. It is safe to store and use from any thread.
  static JObject get androidApplicationContext {
    return JniPlugin.getApplicationContext();
  }

  /// Retrieves the current Android `Activity` associated with a Flutter engine.
  ///
  /// The `engineId` can be obtained from `PlatformDispatcher.instance.engineId`
  /// in Dart.
  ///
  /// **WARNING: This reference is volatile and must be used with care.**
  ///
  /// The Android `Activity` lifecycle is asynchronous. The `Activity` returned
  /// by this function can become `null` or stale (destroyed) at any moment,
  /// such as during screen rotation or when the app is backgrounded.
  ///
  /// To prevent native crashes, this function has two strict usage rules:
  ///
  /// 1. **Platform Thread Only**: It must *only* be called from the platform
  ///     thread.
  /// 2. **Synchronous Use Only**: The returned `JObject` must be used
  ///     immediately and synchronously, with no asynchronous gaps (`await`).
  ///
  /// Do not store the returned `JObject` in a field or local variable that
  /// persists across an `await`.
  ///
  /// ---
  ///
  /// ### Correct Usage (Synchronous, "Get-and-Use"):
  ///
  /// ```dart
  /// void safeCall() {
  ///   // This is safe because the `Activity` is retrieved and used
  ///   // in a single, unbroken, synchronous block.
  ///   final activity = Jni.androidActivity(engineId);
  ///   if (activity != null) {
  ///     someGeneratedApi.doSomething(activity);
  ///     activity.release();
  ///   }
  /// }
  /// ```
  ///
  /// ### **DANGEROUS** Usage (Asynchronous Gap):
  ///
  /// ```dart
  /// Future<void> dangerousCall() async {
  ///   // 1. Get the Activity (e.g., Activity "A")
  ///   final activity = Jni.androidActivity(engineId);
  ///
  ///   // 2. An `await` occurs. The main thread is freed.
  ///   //    While waiting, Android might destroy Activity "A" and create "B".
  ///   await someOtherFuture();
  ///
  ///   // 3. CRASH: The code resumes, but `activity` is now a stale
  ///   //    reference to the destroyed Activity "A".
  ///   if (activity != null) {
  ///     someGeneratedApi.doSomething(activity); // This will crash
  ///     activity.release();
  ///   }
  /// }
  /// ```
  static JObject? androidActivity(int engineId) {
    return JniPlugin.getActivity(engineId);
  }
}

/// Extensions for use by JNIgen generated code.
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

  static Pointer<T> Function<T extends NativeType>(String) get lookup =>
      Jni._dylib.lookup;
}

/// Used only inside `package:jni`.
@internal
extension InternalJniExtension on Jni {
  static Dart_FinalizableHandle newJObjectFinalizableHandle(
    Object object,
    Pointer<Void> reference,
    JObjectRefType refType,
  ) {
    ProtectedJniExtensions.ensureInitialized();
    return Jni._bindings
        .newJObjectFinalizableHandle(object, reference, refType);
  }

  static Dart_FinalizableHandle newBooleanFinalizableHandle(
    Object object,
    Pointer<Bool> reference,
  ) {
    ProtectedJniExtensions.ensureInitialized();
    return Jni._bindings.newBooleanFinalizableHandle(object, reference);
  }

  static Dart_FinalizableHandle newStackTraceFinalizableHandle(
    Object object,
    Pointer<Char> reference,
  ) {
    ProtectedJniExtensions.ensureInitialized();
    return Jni._bindings.newStackTraceFinalizableHandle(object, reference);
  }

  static void deleteFinalizableHandle(
      Dart_FinalizableHandle finalizableHandle, Object object) {
    ProtectedJniExtensions.ensureInitialized();
    Jni._bindings.deleteFinalizableHandle(finalizableHandle, object);
  }
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
  Pointer<Char> toNativeChars(Allocator allocator) {
    return toNativeUtf8(allocator: allocator).cast<Char>();
  }
}

/// Internal cache entry for JNI class references.
///
/// Tracks a single JNI global reference along with metadata for reference
/// counting and eviction.
@internal
class JClassCacheEntry {
  final String name;
  final JGlobalReference globalRef;
  int borrowCount = 0;
  bool isEvicted = false;

  JClassCacheEntry(this.name, this.globalRef) {
    // Register this entry for pointer-based callbacks
    Jni._entryRegistry[identityHashCode(this)] = this;
  }

  @internal
  Pointer<Void> get asPointer => Pointer.fromAddress(identityHashCode(this));
}

/// Internal LRU cache for JNI class references.
///
/// **GlobalRef Ownership Model:**
///
/// This cache is the **sole owner** of the JNI global references it stores.
/// Each cache entry contains exactly one [JGlobalReference] and tracks how
/// many wrappers are currently borrowing it via reference counting.
///
/// **Critical Lifecycle Rules:**
///
/// 1. **Cache owns GlobalRefs**: Each [JClassCacheEntry] contains a
///    [JGlobalReference] owned by the cache. The cache is responsible for
///    deleting it when the entry is evicted AND no wrappers are using it.
///
/// 2. **Callers borrow references**: [get] returns a cache entry that
///    wrappers use to create `BorrowedReference` instances. Each borrow
///    increments `borrowCount`, and each release decrements it.
///
/// 3. **Reference counting enables deterministic cleanup**: When an entry is
///    evicted, it's marked as `isEvicted = true`. The underlying GlobalRef is
///    deleted immediately if `borrowCount == 0`, or when the last borrower
///    releases (deterministic, not GC-dependent).
///
/// 4. **Minimal GlobalRef usage**: Only N GlobalRefs exist (where N = number of
///    distinct classes in use), regardless of wrapper count. This is the
///    primary benefit over duplication-based caching.
///
/// **Isolate-local**: Each isolate has its own cache instance. References
/// are not shared across isolates.
class _JClassCache {
  int _capacity = 256;
  final _map = <String, JClassCacheEntry>{};

  JClassCacheEntry get(String name) {
    var entry = _map[name];

    if (entry != null) {
      // Cache hit: Move entry to end for LRU tracking.
      _map.remove(name);
      _map[name] = entry;
      return entry;
    }

    // Cache miss: Load class and create new entry.
    final clsPtr = Jni.findClass(name);
    entry = JClassCacheEntry(name, JGlobalReference(clsPtr));

    // Evict LRU entry if at capacity.
    if (_map.length >= _capacity) {
      final keyToEvict = _map.keys.first;
      _evict(keyToEvict);
    }

    _map[name] = entry;
    return entry;
  }

  void _evict(String name) {
    final entry = _map.remove(name)!;
    entry.isEvicted = true;

    // Deterministic cleanup: If no active borrowers, delete immediately.
    if (entry.borrowCount == 0) {
      entry.globalRef.release();
    }
  }

  set capacity(int size) {
    _capacity = size;
    // Evict LRU entries immediately if new capacity is smaller.
    while (_map.length > _capacity) {
      final keyToEvict = _map.keys.first;
      _evict(keyToEvict);
    }
  }
}
