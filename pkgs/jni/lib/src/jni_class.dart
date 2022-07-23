import 'dart:ffi';

import 'package:ffi/ffi.dart';

import 'third_party/jni_bindings_generated.dart';
import 'extensions.dart';
import 'jvalues.dart';
import 'jni_exceptions.dart';
import 'jni_object.dart';

part 'jni_class_methods_generated.dart';

final ctorLookupChars = "<init>".toNativeChars();

/// Convenience wrapper around a JNI local class reference.
///
/// Reference lifetime semantics are same as [JniObject].
class JniClass {
  final JClass _cls;
  final Pointer<JniEnv> _env;
  bool _deleted = false;
  JniClass.of(this._env, this._cls);

  JniClass.fromJClass(Pointer<JniEnv> env, JClass cls)
      : _env = env,
        _cls = cls;

  JniClass.fromGlobalRef(Pointer<JniEnv> env, JniGlobalClassRef r)
      : _env = env,
        _cls = env.NewLocalRef(r._cls) {
    if (r._deleted) {
      throw UseAfterFreeException(r, r._cls);
    }
  }

  @pragma('vm:prefer-inline')
  void _checkDeleted() {
    if (_deleted) {
      throw UseAfterFreeException(this, _cls);
    }
  }

  JMethodID getConstructorID(String signature) {
    return _getMethodID("<init>", signature, false);
  }

  /// Construct new object using [ctor].
  JniObject newObject(JMethodID ctor, List<dynamic> args) {
    _checkDeleted();
    final jvArgs = JValueArgs(args, _env);
    final newObj = _env.NewObjectA(_cls, ctor, jvArgs.values);
    jvArgs.disposeIn(_env);
    calloc.free(jvArgs.values);
    _env.checkException();
    return JniObject.of(_env, newObj, nullptr);
  }

  JMethodID _getMethodID(String name, String signature, bool isStatic) {
    _checkDeleted();
    final methodName = name.toNativeChars();
    final methodSig = signature.toNativeChars();
    final result = isStatic
        ? _env.GetStaticMethodID(_cls, methodName, methodSig)
        : _env.GetMethodID(_cls, methodName, methodSig);
    calloc.free(methodName);
    calloc.free(methodSig);
    _env.checkException();
    return result;
  }

  JFieldID _getFieldID(String name, String signature, bool isStatic) {
    _checkDeleted();
    final methodName = name.toNativeChars();
    final methodSig = signature.toNativeChars();
    final result = isStatic
        ? _env.GetStaticFieldID(_cls, methodName, methodSig)
        : _env.GetFieldID(_cls, methodName, methodSig);
    calloc.free(methodName);
    calloc.free(methodSig);
    _env.checkException();
    return result;
  }

  @pragma('vm:prefer-inline')
  JMethodID getMethodID(String name, String signature) {
    return _getMethodID(name, signature, false);
  }

  @pragma('vm:prefer-inline')
  JMethodID getStaticMethodID(String name, String signature) {
    return _getMethodID(name, signature, true);
  }

  @pragma('vm:prefer-inline')
  JFieldID getFieldID(String name, String signature) {
    return _getFieldID(name, signature, false);
  }

  @pragma('vm:prefer-inline')
  JFieldID getStaticFieldID(String name, String signature) {
    return _getFieldID(name, signature, true);
  }

  /// Returns the underlying [JClass].
  JClass get jclass {
    _checkDeleted();
    return _cls;
  }

  JniGlobalClassRef getGlobalRef() {
    _checkDeleted();
    return JniGlobalClassRef._(_env.NewGlobalRef(_cls));
  }

  void delete() {
    if (_deleted) {
      throw DoubleFreeException(this, _cls);
    }
    _env.DeleteLocalRef(_cls);
    _deleted = true;
  }

  /// Use this [JniClass] to execute callback, then delete.
  ///
  /// Useful in expression chains.
  T use<T>(T Function(JniClass) callback) {
    _checkDeleted();
    final result = callback(this);
    delete();
    return result;
  }
}

/// Global reference type for JniClasses
///
/// Instead of passing local references between functions
/// that may be run on different threads, convert it
/// using [JniClass.getGlobalRef] and reconstruct using
/// [JniClass.fromGlobalRef]
class JniGlobalClassRef {
  JniGlobalClassRef._(this._cls);
  final JClass _cls;
  JClass get jclass => _cls;
  bool _deleted = false;

  void deleteIn(Pointer<JniEnv> env) {
    if (_deleted) {
      throw DoubleFreeException(this, _cls);
    }
    env.DeleteGlobalRef(_cls);
    _deleted = true;
  }
}
