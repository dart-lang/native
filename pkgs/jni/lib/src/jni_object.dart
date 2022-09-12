// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import 'package:ffi/ffi.dart';

import 'third_party/jni_bindings_generated.dart';
import 'jni_exceptions.dart';
import 'jni.dart';
import 'env_extensions.dart';
import 'jvalues.dart';

// This typedef is needed because void is a keyword and cannot be used in
// type switch like a regular type.
typedef _VoidType = void;

/// A class which holds one or more JNI references, and has a `delete` operation
/// which disposes the reference(s).
abstract class JniReference implements Finalizable {
  static final _finalizer = NativeFinalizer(_env.ref.DeleteGlobalRef);

  JniReference.fromRef(this.reference) {
    _finalizer.attach(this, reference, detach: this);
  }

  bool _deleted = false;

  void _ensureNotDeleted() {
    if (_deleted) throw UseAfterFreeException(this, reference);
  }

  /// Check whether the underlying JNI reference is `null`.
  bool get isNull => reference == nullptr;

  /// Returns whether this object is deleted.
  bool get isDeleted => _deleted;

  /// Deletes the underlying JNI reference. Further uses will throw
  /// [UseAfterFreeException].
  void delete() {
    if (_deleted) {
      throw DoubleFreeException(this, reference);
    }
    _deleted = true;
    _finalizer.detach(this);
    _env.DeleteGlobalRef(reference);
  }

  /// The underlying JNI global object reference.
  final JObject reference;

  /// Registers this object to be deleted at the end of [arena]'s lifetime.
  void deletedIn(Arena arena) => arena.onReleaseAll(delete);
}

extension JniReferenceUseExtension<T extends JniReference> on T {
  /// Applies [callback] on [this] object and then delete the underlying JNI
  /// reference, returning the result of [callback].
  R use<R>(R Function(T) callback) {
    _ensureNotDeleted();
    try {
      final result = callback(this);
      delete();
      return result;
    } catch (e) {
      delete();
      rethrow;
    }
  }
}

class _CallGetMethods {
  _CallGetMethods(this.getField, this.getStaticField, this.callMethod,
      this.callStaticMethod);
  Function(JObject, JFieldID) getField;
  Function(JClass, JFieldID) getStaticField;
  Function(JObject, JMethodID, Pointer<JValue>) callMethod;
  Function(JClass, JMethodID, Pointer<JValue>) callStaticMethod;
}

final Pointer<GlobalJniEnv> _env = Jni.env;

final Map<int, _CallGetMethods> _accessors = {
  JniType.boolType: _CallGetMethods(
    _env.GetBooleanField,
    _env.GetStaticBooleanField,
    _env.CallBooleanMethodA,
    _env.CallStaticBooleanMethodA,
  ),
  JniType.byteType: _CallGetMethods(
    _env.GetByteField,
    _env.GetStaticByteField,
    _env.CallByteMethodA,
    _env.CallStaticByteMethodA,
  ),
  JniType.shortType: _CallGetMethods(
    _env.GetShortField,
    _env.GetStaticShortField,
    _env.CallShortMethodA,
    _env.CallStaticShortMethodA,
  ),
  JniType.charType: _CallGetMethods(
    _env.GetCharField,
    _env.GetStaticCharField,
    _env.CallCharMethodA,
    _env.CallStaticCharMethodA,
  ),
  JniType.intType: _CallGetMethods(
    _env.GetIntField,
    _env.GetStaticIntField,
    _env.CallIntMethodA,
    _env.CallStaticIntMethodA,
  ),
  JniType.longType: _CallGetMethods(
    _env.GetLongField,
    _env.GetStaticLongField,
    _env.CallLongMethodA,
    _env.CallStaticLongMethodA,
  ),
  JniType.floatType: _CallGetMethods(
    _env.GetFloatField,
    _env.GetStaticFloatField,
    _env.CallFloatMethodA,
    _env.CallStaticFloatMethodA,
  ),
  JniType.doubleType: _CallGetMethods(
    _env.GetDoubleField,
    _env.GetStaticDoubleField,
    _env.CallDoubleMethodA,
    _env.CallStaticDoubleMethodA,
  ),
  JniType.objectType: _CallGetMethods(
    _env.GetObjectField,
    _env.GetStaticObjectField,
    _env.CallObjectMethodA,
    _env.CallStaticObjectMethodA,
  ),
  JniType.voidType: _CallGetMethods(
    (x, y) => throw ArgumentError('void passed as field type'),
    (x, y) => throw ArgumentError('void passed as static field type'),
    _env.CallVoidMethodA,
    _env.CallStaticVoidMethodA,
  ),
};

T _getID<T>(
    T Function(Pointer<Void> ptr, Pointer<Char> name, Pointer<Char> sig) f,
    Pointer<Void> ptr,
    String name,
    String sig) {
  final result = using(
      (arena) => f(ptr, name.toNativeChars(arena), sig.toNativeChars(arena)));
  _env.checkException();
  return result;
}

int _getCallType(int? callType, int defaultType, Set<int> allowed) {
  if (callType == null) return defaultType;
  if (allowed.contains(callType)) return callType;
  throw InvalidCallTypeException(callType, allowed);
}

T _callOrGet<T>(int? callType, Function(int) f) {
  final int finalCallType;
  T result;
  switch (T) {
    case bool:
      finalCallType =
          _getCallType(callType, JniType.boolType, {JniType.boolType});
      result = (f(finalCallType) as int != 0) as T;
      break;
    case int:
      finalCallType = _getCallType(callType, JniType.intType, {
        JniType.byteType,
        JniType.charType,
        JniType.shortType,
        JniType.intType,
        JniType.longType,
      });
      result = f(finalCallType) as T;
      break;
    case double:
      finalCallType = _getCallType(callType, JniType.doubleType,
          {JniType.floatType, JniType.doubleType});
      result = f(finalCallType) as T;
      break;
    case String:
    case JniObject:
    case JniString:
      finalCallType =
          _getCallType(callType, JniType.objectType, {JniType.objectType});
      final ref = f(finalCallType) as JObject;
      if (ref == nullptr) {
        _env.checkException();
      }
      final ctor = T == String
          ? (ref) => _env.asDartString(ref, deleteOriginal: true)
          : (T == JniObject ? JniObject.fromRef : JniString.fromRef);
      result = ctor(ref) as T;
      break;
    case _VoidType:
      finalCallType =
          _getCallType(callType, JniType.voidType, {JniType.voidType});
      f(finalCallType);
      result = null as T;
      break;
    case dynamic:
      result = f(callType ?? JniType.voidType) as T;
      break;
    default:
      throw UnsupportedError('Unknown type $T');
  }
  return result;
}

T _callMethod<T>(
        int? callType, List<dynamic> args, Function(int, Pointer<JValue>) f) =>
    using((arena) {
      final jArgs = JValueArgs(args, arena);
      final result = _callOrGet<T>(callType, (ct) => f(ct, jArgs.values));
      jArgs.dispose();
      if (result == 0 || result == 0.0 || result == null) {
        _env.checkException();
      }
      return result;
    });

T _getField<T>(int? callType, Function(int) f) {
  final result = _callOrGet<T>(callType, f);
  _env.checkException();
  return result;
}

/// A high-level wrapper for JNI global object reference.
///
/// This is the base class for classes generated by `jnigen`.
class JniObject extends JniReference {
  /// Construct a new [JniObject] with [reference] as its underlying reference.
  JniObject.fromRef(JObject reference) : super.fromRef(reference);

  JniClass? _jniClass;

  JniClass get _class {
    _jniClass ??= getClass();
    return _jniClass!;
  }

  /// Deletes the JNI reference and marks this object as deleted. Any further
  /// uses will throw [UseAfterFreeException].
  @override
  void delete() {
    _jniClass?.delete();
    super.delete();
  }

  // TODO(#55): Support casting JniObject subclasses

  /// Returns [JniClass] corresponding to concrete class of this object.
  ///
  /// This may be a subclass of compile-time class.
  JniClass getClass() {
    _ensureNotDeleted();
    final classRef = _env.GetObjectClass(reference);
    if (classRef == nullptr) _env.checkException();
    return JniClass.fromRef(classRef);
  }

  /// Get [JFieldID] of instance field identified by [fieldName] & [signature].
  JFieldID getFieldID(String fieldName, String signature) {
    _ensureNotDeleted();
    return _getID(_env.GetFieldID, _class.reference, fieldName, signature);
  }

  /// Get [JFieldID] of static field identified by [fieldName] & [signature].
  JFieldID getStaticFieldID(String fieldName, String signature) {
    _ensureNotDeleted();
    return _getID(
        _env.GetStaticFieldID, _class.reference, fieldName, signature);
  }

  /// Get [JMethodID] of instance method [methodName] with [signature].
  JMethodID getMethodID(String methodName, String signature) {
    _ensureNotDeleted();
    return _getID(_env.GetMethodID, _class.reference, methodName, signature);
  }

  /// Get [JMethodID] of static method [methodName] with [signature].
  JMethodID getStaticMethodID(String methodName, String signature) {
    _ensureNotDeleted();
    return _getID(
        _env.GetStaticMethodID, _class.reference, methodName, signature);
  }

  /// Retrieve the value of the field using [fieldID].
  ///
  /// [callType] determines the return type of the underlying JNI call made.
  /// If the Java field is of `long` type, this must be [JniType.longType] and
  /// so on. Default is chosen based on return type [T], which maps int -> int,
  /// double -> double, void -> void, and JniObject types to `Object`.
  ///
  /// If [T] is String or [JniObject], required conversions are performed and
  /// final value is returned.
  T getField<T>(JFieldID fieldID, [int? callType]) {
    _ensureNotDeleted();
    return _getField<T>(
        callType, (ct) => _accessors[ct]!.getField(reference, fieldID));
  }

  /// Get value of the field identified by [name] and [signature].
  ///
  /// See [getField] for an explanation about [callType] parameter.
  T getFieldByName<T>(String name, String signature, [int? callType]) {
    final id = getFieldID(name, signature);
    return getField<T>(id, callType);
  }

  /// Get value of the static field using [fieldID].
  ///
  /// See [getField] for an explanation about [callType] parameter.
  T getStaticField<T>(JFieldID fieldID, [int? callType]) {
    _ensureNotDeleted();
    return _getField<T>(callType,
        (ct) => _accessors[ct]!.getStaticField(_class.reference, fieldID));
  }

  /// Get value of the static field identified by [name] and [signature].
  ///
  /// See [getField] for an explanation about [callType] parameter.
  T getStaticFieldByName<T>(String name, String signature, [int? callType]) {
    final id = getStaticFieldID(name, signature);
    return getStaticField<T>(id, callType);
  }

  /// Call the method using [methodID],
  ///
  /// [args] can consist of primitive types, JNI primitive wrappers such as
  /// [JValueLong], strings, and subclasses of [JniObject].
  ///
  /// See [getField] for an explanation about [callType] and return type [T].
  T callMethod<T>(JMethodID methodID, List<dynamic> args, [int? callType]) {
    _ensureNotDeleted();
    return _callMethod<T>(callType, args,
        (ct, jvs) => _accessors[ct]!.callMethod(reference, methodID, jvs));
  }

  /// Call instance method identified by [name] and [signature].
  ///
  /// This implementation looks up the method and calls it using [callMethod].
  T callMethodByName<T>(String name, String signature, List<dynamic> args,
      [int? callType]) {
    final id = getMethodID(name, signature);
    return callMethod<T>(id, args, callType);
  }

  /// Call static method using [methodID]. See [callMethod] and [getField] for
  /// more details about [args] and [callType].
  T callStaticMethod<T>(JMethodID methodID, List<dynamic> args,
      [int? callType]) {
    _ensureNotDeleted();
    return _callMethod<T>(
        callType,
        args,
        (ct, jvs) =>
            _accessors[ct]!.callStaticMethod(reference, methodID, jvs));
  }

  /// Call static method identified by [name] and [signature].
  ///
  /// This implementation looks up the method and calls [callStaticMethod].
  T callStaticMethodByName<T>(String name, String signature, List<dynamic> args,
      [int? callType]) {
    final id = getStaticMethodID(name, signature);
    return callStaticMethod<T>(id, args, callType);
  }
}

/// A high level wrapper over a JNI class reference.
class JniClass extends JniReference {
  /// Construct a new [JniClass] with [reference] as its underlying reference.
  JniClass.fromRef(JObject reference) : super.fromRef(reference);

  /// Get [JFieldID] of static field [fieldName] with [signature].
  JFieldID getStaticFieldID(String fieldName, String signature) {
    _ensureNotDeleted();
    return _getID(_env.GetStaticFieldID, reference, fieldName, signature);
  }

  /// Get [JMethodID] of static method [methodName] with [signature].
  JMethodID getStaticMethodID(String methodName, String signature) {
    _ensureNotDeleted();
    return _getID(_env.GetStaticMethodID, reference, methodName, signature);
  }

  /// Get [JFieldID] of field [fieldName] with [signature].
  JFieldID getFieldID(String fieldName, String signature) {
    _ensureNotDeleted();
    return _getID(_env.GetFieldID, reference, fieldName, signature);
  }

  /// Get [JMethodID] of method [methodName] with [signature].
  JMethodID getMethodID(String methodName, String signature) {
    _ensureNotDeleted();
    return _getID(_env.GetMethodID, reference, methodName, signature);
  }

  /// Get [JMethodID] of constructor with [signature].
  JMethodID getCtorID(String signature) => getMethodID("<init>", signature);

  /// Get the value of static field using [fieldID].
  ///
  /// See [JniObject.getField] for more explanation about [callType].
  T getStaticField<T>(JFieldID fieldID, [int? callType]) {
    _ensureNotDeleted();
    return _getField<T>(
        callType, (ct) => _accessors[ct]!.getStaticField(reference, fieldID));
  }

  /// Get the value of static field identified by [name] and [signature].
  ///
  /// This implementation looks up the field ID and calls [getStaticField].
  T getStaticFieldByName<T>(String name, String signature, [int? callType]) {
    final id = getStaticFieldID(name, signature);
    return getStaticField<T>(id, callType);
  }

  /// Call the static method using [methodID].
  ///
  /// See [JniObject.callMethod] and [JniObject.getField] for more explanation
  /// about [args] and [callType].
  T callStaticMethod<T>(JMethodID methodID, List<dynamic> args,
      [int? callType]) {
    _ensureNotDeleted();
    return _callMethod<T>(
        callType,
        args,
        (ct, jvs) =>
            _accessors[ct]!.callStaticMethod(reference, methodID, jvs));
  }

  /// Call the static method identified by [name] and [signature].
  ///
  /// This implementation looks up the method ID and calls [callStaticMethod].
  T callStaticMethodByName<T>(String name, String signature, List<dynamic> args,
      [int? callType]) {
    final id = getStaticMethodID(name, signature);
    return callStaticMethod<T>(id, args, callType);
  }

  /// Create a new instance of this class with [ctor] and [args].
  JniObject newInstance(JMethodID ctor, List<dynamic> args) => using((arena) {
        _ensureNotDeleted();
        final jArgs = JValueArgs(args, arena);
        final res = _env.NewObjectA(reference, ctor, jArgs.values);
        jArgs.dispose();
        if (res == nullptr) {
          _env.checkException();
        }
        return JniObject.fromRef(res);
      });
}

class JniString extends JniObject {
  /// Construct a new [JniString] with [reference] as its underlying reference.
  JniString.fromRef(JString reference) : super.fromRef(reference);

  static JString _toJavaString(String s) => using((arena) {
        final chars = s.toNativeUtf8(allocator: arena).cast<Char>();
        final jstr = _env.NewStringUTF(chars);
        if (jstr == nullptr) {
          _env.checkException();
        }
        return jstr;
      });

  /// Construct a [JniString] from the contents of Dart string [s].
  JniString.fromString(String s) : super.fromRef(_toJavaString(s));

  /// Returns the contents as a Dart String.
  ///
  /// If [deleteOriginal] is true, the underlying reference is deleted
  /// after conversion and this object will be marked as deleted.
  String toDartString({bool deleteOriginal = false}) {
    _ensureNotDeleted();
    if (reference == nullptr) {
      throw NullJniStringException();
    }
    final chars = _env.GetStringUTFChars(reference, nullptr);
    final result = chars.cast<Utf8>().toDartString();
    _env.ReleaseStringUTFChars(reference, chars);
    if (deleteOriginal) {
      delete();
    }
    return result;
  }
}

extension ToJniStringMethod on String {
  /// Returns a [JniString] with the contents of this String.
  JniString jniString() {
    return JniString.fromString(this);
  }
}
