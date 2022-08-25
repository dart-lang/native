import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:path/path.dart';

import 'third_party/jni_bindings_generated.dart';
import 'extensions.dart';
import 'jvalues.dart';

import 'jni_object.dart';
import 'jni_class.dart';
import 'jni_exceptions.dart';

part 'direct_methods_generated.dart';

String _getLibraryFileName(String base) {
  if (Platform.isLinux || Platform.isAndroid) {
    return "lib$base.so";
  } else if (Platform.isWindows) {
    return "$base.dll";
  } else if (Platform.isMacOS) {
    return "$base.framework/$base";
  } else {
    throw UnsupportedError("cannot derive library name: unsupported platform");
  }
}

/// Load Dart-JNI Helper library.
///
/// If path is provided, it's used to load the library.
/// Else just the platform-specific filename is passed to DynamicLibrary.open
DynamicLibrary _loadJniHelpersLibrary(
    {String? dir, String baseName = "dartjni"}) {
  final fileName = _getLibraryFileName(baseName);
  final libPath = (dir != null) ? join(dir, fileName) : fileName;
  try {
    final dylib = DynamicLibrary.open(libPath);
    return dylib;
  } on Error {
    throw HelperNotFoundException(libPath);
  }
}

/// Jni represents a single running JNI instance.
///
/// It provides convenience functions for looking up and invoking functions
/// without several FFI conversions.
///
/// You can also get access to instance of underlying JavaVM and JniEnv, and
/// then use them in a way similar to JNI C++ API.
class Jni {
  final JniBindings _bindings;

  Jni._(DynamicLibrary library, [this._helperDir])
      : _bindings = JniBindings(library),
        _getJniEnvFn = library.lookup<Void>('GetJniEnv'),
        _getJniContextFn = library.lookup<Void>('GetJniContext');

  static Jni? _instance;

  /// Stores helperDir if any was used.
  final String? _helperDir;

  /// Returns the existing Jni object.
  ///
  /// If not running on Android and no Jni is spawned
  /// using Jni.spawn(), throws an exception.
  ///
  /// On Dart standalone, when calling for the first time from
  /// a new isolate, make sure to pass the library path.
  final Pointer<Void> _getJniEnvFn, _getJniContextFn;

  static Jni getInstance() {
    if (_instance == null) {
      final dylib = _loadJniHelpersLibrary();
      final inst = Jni._(dylib);
      if (inst.getJavaVM() == nullptr) {
        throw StateError("Fatal: No JVM associated with this process!"
            " Did you call Jni.spawn?");
      }
      // If no error, save this singleton.
      _instance = inst;
    }
    return _instance!;
  }

  /// Initialize instance from custom helper library path.
  ///
  /// On dart standalone, call this in new isolate before
  /// doing getInstance().
  ///
  /// (The reason is that dylibs need to be loaded in every isolate.
  /// On flutter it's done by library. On dart standalone we don't
  /// know the library path.)
  static void load({required String helperDir}) {
    if (_instance != null) {
      throw StateError('Fatal: a JNI instance already exists in this isolate');
    }
    final inst = Jni._(_loadJniHelpersLibrary(dir: helperDir), helperDir);
    if (inst.getJavaVM() == nullptr) {
      throw StateError("Fatal: No JVM associated with this process");
    }
    _instance = inst;
  }

  /// Spawn an instance of JVM using JNI.
  /// This instance will be returned by future calls to [getInstance]
  ///
  /// [helperDir] is path of the directory where the wrapper library is found.
  /// This parameter needs to be passed manually on __Dart standalone target__,
  /// since we have no reliable way to bundle it with the package.
  ///
  /// [jvmOptions], [ignoreUnrecognized], & [jniVersion] are passed to the JVM.
  /// Strings in [classPath], if any, are used to construct an additional
  /// JVM option of the form "-Djava.class.path={paths}".
  static Jni spawn({
    String? helperDir,
    int logLevel = JniLogLevel.JNI_INFO,
    List<String> jvmOptions = const [],
    List<String> classPath = const [],
    bool ignoreUnrecognized = false,
    int jniVersion = JNI_VERSION_1_6,
  }) {
    if (_instance != null) {
      throw UnsupportedError("Currently only 1 VM is supported.");
    }
    final dylib = _loadJniHelpersLibrary(dir: helperDir);
    final inst = Jni._(dylib, helperDir);
    _instance = inst;
    inst._bindings.SetJNILogging(logLevel);
    final jArgs = _createVMArgs(
      options: jvmOptions,
      classPath: classPath,
      version: jniVersion,
      ignoreUnrecognized: ignoreUnrecognized,
    );
    inst._bindings.SpawnJvm(jArgs);
    _freeVMArgs(jArgs);
    return inst;
  }

  static Pointer<JavaVMInitArgs> _createVMArgs({
    List<String> options = const [],
    List<String> classPath = const [],
    bool ignoreUnrecognized = false,
    int version = JNI_VERSION_1_6,
  }) {
    final args = calloc<JavaVMInitArgs>();
    if (options.isNotEmpty || classPath.isNotEmpty) {
      final count = options.length + (classPath.isNotEmpty ? 1 : 0);

      final optsPtr = (count != 0) ? calloc<JavaVMOption>(count) : nullptr;
      args.ref.options = optsPtr;
      for (int i = 0; i < options.length; i++) {
        optsPtr.elementAt(i).ref.optionString = options[i].toNativeChars();
      }
      if (classPath.isNotEmpty) {
        final classPathString = classPath.join(Platform.isWindows ? ';' : ":");
        optsPtr.elementAt(count - 1).ref.optionString =
            "-Djava.class.path=$classPathString".toNativeChars();
      }
      args.ref.nOptions = count;
    }
    args.ref.ignoreUnrecognized = ignoreUnrecognized ? 1 : 0;
    args.ref.version = version;
    return args;
  }

  static void _freeVMArgs(Pointer<JavaVMInitArgs> argPtr) {
    final nOptions = argPtr.ref.nOptions;
    final options = argPtr.ref.options;
    if (nOptions != 0) {
      for (var i = 0; i < nOptions; i++) {
        calloc.free(options.elementAt(i).ref.optionString);
      }
      calloc.free(argPtr.ref.options);
    }
    calloc.free(argPtr);
  }

  /// Returns pointer to current JNI JavaVM instance
  Pointer<JavaVM> getJavaVM() {
    return _bindings.GetJavaVM();
  }

  /// Returns JniEnv* associated with current thread.
  ///
  /// Do not reuse JniEnv between threads, it's only valid
  /// in the thread it is obtained.
  Pointer<JniEnv> getEnv() {
    return _bindings.GetJniEnv();
  }

  void setJniLogging(int loggingLevel) {
    _bindings.SetJNILogging(loggingLevel);
  }

  /// Returns current application context on Android.
  JObject getCachedApplicationContext() {
    return _bindings.GetApplicationContext();
  }

  /// Returns current activity
  JObject getCurrentActivity() {
    return _bindings.GetCurrentActivity();
  }

  /// Get the initial classLoader of the application.
  ///
  /// This is especially useful on Android, where
  /// JNI threads cannot access application classes using
  /// the usual `JniEnv.FindClass` method.
  JObject getApplicationClassLoader() {
    return _bindings.GetClassLoader();
  }

  /// Returns class reference found through system-specific mechanism
  JClass findClass(String qualifiedName) {
    final nameChars = qualifiedName.toNativeChars();
    final cls = _bindings.LoadClass(nameChars);
    calloc.free(nameChars);
    if (cls == nullptr) {
      getEnv().checkException();
    }
    return cls;
  }

  /// Returns class for [qualifiedName] found by platform-specific mechanism,
  /// wrapped in a `JniClass`.
  JniClass findJniClass(String qualifiedName) {
    return JniClass.of(getEnv(), findClass(qualifiedName));
  }

  /// Constructs an instance of class with given args.
  ///
  /// Use it when you only need one instance, but not the actual class
  /// nor any constructor / static methods.
  JniObject newInstance(
      String qualifiedName, String ctorSignature, List<dynamic> args) {
    final cls = findJniClass(qualifiedName);
    final ctor = cls.getMethodID("<init>", ctorSignature);
    final obj = cls.newObject(ctor, args);
    cls.delete();
    return obj;
  }

  /// Wraps a JObject ref in a JniObject.
  /// The original ref is stored in JniObject, and
  /// deleted with the latter's [delete] method.
  ///
  /// It takes the ownership of the jobject so that it can be used like this:
  ///
  /// ```dart
  /// final result = jni.wrap(long_expr_returning_jobject)
  /// ```
  JniObject wrap(JObject obj) {
    return JniObject.of(getEnv(), obj, nullptr);
  }

  /// Wraps a JObject ref in a JniObject.
  /// The original ref is stored in JniObject, and
  /// deleted with the latter's [delete] method.
  JniClass wrapClass(JClass cls) {
    return JniClass.of(getEnv(), cls);
  }

  Pointer<T> Function<T extends NativeType>(String) initGeneratedLibrary(
      String name) {
    var path = _getLibraryFileName(name);
    if (_helperDir != null) {
      path = join(_helperDir!, path);
    }
    final dl = DynamicLibrary.open(path);
    final setJniGetters =
        dl.lookupFunction<SetJniGettersNativeType, SetJniGettersDartType>(
            'setJniGetters');
    setJniGetters(_getJniContextFn, _getJniEnvFn);
    final lookup = dl.lookup;
    return lookup;
  }

  /// Converts passed arguments to JValue array
  /// for use in methods that take arguments.
  ///
  /// int, bool, double and JObject types are converted out of the box.
  /// wrap values in types such as [JValueLong]
  /// to convert to other primitive types instead.
  static Pointer<JValue> jvalues(List<dynamic> args,
      {Allocator allocator = calloc}) {
    return toJValues(args, allocator: allocator);
  }

  // Temporarily for JlString.
  // A future idea is to unify JlObject and JniObject, and use global refs
  // everywhere for simplicity.
  late final toJavaString = _bindings.ToJavaString;
  late final getJavaStringChars = _bindings.GetJavaStringChars;
  late final releaseJavaStringChars = _bindings.ReleaseJavaStringChars;
}

typedef SetJniGettersNativeType = Void Function(Pointer<Void>, Pointer<Void>);
typedef SetJniGettersDartType = void Function(Pointer<Void>, Pointer<Void>);
