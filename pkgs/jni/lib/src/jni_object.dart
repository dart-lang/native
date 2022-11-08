// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import 'package:collection/collection.dart';
import 'package:ffi/ffi.dart';

import 'accessors.dart';
import 'jni.dart';
import 'jni_exceptions.dart';
import 'jvalues.dart';
import 'third_party/jni_bindings_generated.dart';

part 'jni_array.dart';
part 'jni_type_class.dart';

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

final Pointer<JniAccessors> _accessors = Jni.accessors;

final Pointer<GlobalJniEnv> _env = Jni.env;

Pointer<T> _getID<T extends NativeType>(
    JniPointerResult Function(
            Pointer<Void> ptr, Pointer<Char> name, Pointer<Char> sig)
        f,
    Pointer<Void> ptr,
    String name,
    String sig) {
  final result = using(
      (arena) => f(ptr, name.toNativeChars(arena), sig.toNativeChars(arena)));
  if (result.exception != nullptr) {
    _accessors.throwException(result.exception);
  }
  return result.id.cast<T>();
}

int _getCallType(int? callType, int defaultType, Set<int> allowed) {
  if (callType == null) return defaultType;
  if (allowed.contains(callType)) return callType;
  throw InvalidCallTypeException(callType, allowed);
}

T _callOrGet<T>(int? callType, JniResult Function(int) function) {
  final int finalCallType;
  late T result;
  switch (T) {
    case bool:
      finalCallType = _getCallType(
          callType, JniCallType.booleanType, {JniCallType.booleanType});
      result = function(finalCallType).boolean as T;
      break;
    case int:
      finalCallType = _getCallType(callType, JniCallType.intType, {
        JniCallType.byteType,
        JniCallType.charType,
        JniCallType.shortType,
        JniCallType.intType,
        JniCallType.longType,
      });
      final jniResult = function(finalCallType);
      switch (finalCallType) {
        case JniCallType.byteType:
          result = jniResult.byte as T;
          break;
        case JniCallType.shortType:
          result = jniResult.short as T;
          break;
        case JniCallType.charType:
          result = jniResult.char as T;
          break;
        case JniCallType.intType:
          result = jniResult.integer as T;
          break;
        case JniCallType.longType:
          result = jniResult.long as T;
          break;
      }
      break;
    case double:
      finalCallType = _getCallType(callType, JniCallType.doubleType,
          {JniCallType.floatType, JniCallType.doubleType});
      final jniResult = function(finalCallType);
      switch (finalCallType) {
        case JniCallType.floatType:
          result = jniResult.float as T;
          break;
        case JniCallType.doubleType:
          result = jniResult.doubleFloat as T;
          break;
      }
      break;
    case String:
    case JniObject:
    case JniString:
      finalCallType = _getCallType(
          callType, JniCallType.objectType, {JniCallType.objectType});
      final ref = function(finalCallType).object;
      final ctor = T == String
          ? (ref) => _env.asDartString(ref, deleteOriginal: true)
          : (T == JniObject ? JniObject.fromRef : JniString.fromRef);
      result = ctor(ref) as T;
      break;
    case _VoidType:
      finalCallType =
          _getCallType(callType, JniCallType.voidType, {JniCallType.voidType});
      function(finalCallType).check();
      result = null as T;
      break;
    case dynamic:
      throw UnsupportedError("Return type not specified for JNI call");
    default:
      throw UnsupportedError('Unknown type $T');
  }
  return result;
}

T _callMethod<T>(int? callType, List<dynamic> args,
        JniResult Function(int, Pointer<JValue>) f) =>
    using((arena) {
      final jArgs = JValueArgs(args, arena);
      arena.onReleaseAll(jArgs.dispose);
      return _callOrGet<T>(callType, (ct) => f(ct, jArgs.values));
    });

T _getField<T>(int? callType, JniResult Function(int) f) {
  final result = _callOrGet<T>(callType, f);
  return result;
}

/// A high-level wrapper for JNI global object reference.
///
/// This is the base class for classes generated by `jnigen`.
class JniObject extends JniReference {
  /// The type which includes information such as the signature of this class.
  static const JniType<JniObject> type = _JniObjectType();

  /// Construct a new [JniObject] with [reference] as its underlying reference.
  JniObject.fromRef(JObject reference) : super.fromRef(reference);

  JniClass? _jniClass;

  JniClass get _class {
    return _jniClass ??= getClass();
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
    if (classRef == nullptr) {
      _accessors.throwException(_env.ExceptionOccurred());
    }
    return JniClass.fromRef(classRef);
  }

  /// Get [JFieldID] of instance field identified by [fieldName] & [signature].
  JFieldID getFieldID(String fieldName, String signature) {
    _ensureNotDeleted();
    return _getID(
        _accessors.getFieldID, _class.reference, fieldName, signature);
  }

  /// Get [JFieldID] of static field identified by [fieldName] & [signature].
  JFieldID getStaticFieldID(String fieldName, String signature) {
    _ensureNotDeleted();
    return _getID<jfieldID_>(
        _accessors.getStaticFieldID, _class.reference, fieldName, signature);
  }

  /// Get [JMethodID] of instance method [methodName] with [signature].
  JMethodID getMethodID(String methodName, String signature) {
    _ensureNotDeleted();
    return _getID<jmethodID_>(
        _accessors.getMethodID, _class.reference, methodName, signature);
  }

  /// Get [JMethodID] of static method [methodName] with [signature].
  JMethodID getStaticMethodID(String methodName, String signature) {
    _ensureNotDeleted();
    return _getID<jmethodID_>(
        _accessors.getStaticMethodID, _class.reference, methodName, signature);
  }

  /// Retrieve the value of the field using [fieldID].
  ///
  /// [callType] determines the return type of the underlying JNI call made.
  /// If the Java field is of `long` type, this must be [JniCallType.longType] and
  /// so on. Default is chosen based on return type [T], which maps int -> int,
  /// double -> double, void -> void, and JniObject types to `Object`.
  ///
  /// If [T] is String or [JniObject], required conversions are performed and
  /// final value is returned.
  T getField<T>(JFieldID fieldID, [int? callType]) {
    _ensureNotDeleted();
    if (callType == JniCallType.voidType) {
      throw ArgumentError("void is not a valid field type.");
    }
    return _getField<T>(
        callType, (ct) => _accessors.getField(reference, fieldID, ct));
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
    if (callType == JniCallType.voidType) {
      throw ArgumentError("void is not a valid field type.");
    }
    _ensureNotDeleted();
    return _getField<T>(callType,
        (ct) => _accessors.getStaticField(_class.reference, fieldID, ct));
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
        (ct, jvs) => _accessors.callMethod(reference, methodID, ct, jvs));
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
    return _callMethod<T>(callType, args,
        (ct, jvs) => _accessors.callStaticMethod(reference, methodID, ct, jvs));
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
    return _getID<jfieldID_>(
        _accessors.getStaticFieldID, reference, fieldName, signature);
  }

  /// Get [JMethodID] of static method [methodName] with [signature].
  JMethodID getStaticMethodID(String methodName, String signature) {
    _ensureNotDeleted();
    return _getID<jmethodID_>(
        _accessors.getStaticMethodID, reference, methodName, signature);
  }

  /// Get [JFieldID] of field [fieldName] with [signature].
  JFieldID getFieldID(String fieldName, String signature) {
    _ensureNotDeleted();
    return _getID<jfieldID_>(
        _accessors.getFieldID, reference, fieldName, signature);
  }

  /// Get [JMethodID] of method [methodName] with [signature].
  JMethodID getMethodID(String methodName, String signature) {
    _ensureNotDeleted();
    return _getID<jmethodID_>(
        _accessors.getMethodID, reference, methodName, signature);
  }

  /// Get [JMethodID] of constructor with [signature].
  JMethodID getCtorID(String signature) => getMethodID("<init>", signature);

  /// Get the value of static field using [fieldID].
  ///
  /// See [JniObject.getField] for more explanation about [callType].
  T getStaticField<T>(JFieldID fieldID, [int? callType]) {
    if (callType == JniCallType.voidType) {
      throw ArgumentError("void is not a valid field type.");
    }
    _ensureNotDeleted();
    return _getField<T>(
        callType, (ct) => _accessors.getStaticField(reference, fieldID, ct));
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
    return _callMethod<T>(callType, args,
        (ct, jvs) => _accessors.callStaticMethod(reference, methodID, ct, jvs));
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
        arena.onReleaseAll(jArgs.dispose);
        final res = _accessors.newObject(reference, ctor, jArgs.values).object;
        return JniObject.fromRef(res);
      });
}

class JniString extends JniObject {
  /// The type which includes information such as the signature of this class.
  static const JniType<JniString> type = _JniStringType();

  /// Construct a new [JniString] with [reference] as its underlying reference.
  JniString.fromRef(JString reference) : super.fromRef(reference);

  static JString _toJavaString(String s) => using((arena) {
        final chars = s.toNativeUtf8(allocator: arena).cast<Char>();
        final jstr = _env.NewStringUTF(chars);
        if (jstr == nullptr) {
          throw 'Fatal: cannot convert string to Java string: $s';
        }
        return jstr;
      });

  /// The number of Unicode characters in this Java string.
  int get length => _env.GetStringLength(reference);

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
