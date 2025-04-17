// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import 'dart:ffi';

import 'package:meta/meta.dart' show internal;

import '../jni.dart';
import 'jreference.dart';
import 'types.dart';

// Error thrown when casting between incompatible `JObject` subclasses.
final class CastError extends Error {
  final String _message;

  CastError(this._message);

  @override
  String toString() {
    return _message;
  }
}

final class JObjectNullableType extends JObjType<JObject?> {
  @internal
  const JObjectNullableType();

  @internal
  @override
  String get signature => 'Ljava/lang/Object;';

  @internal
  @override
  JObject? fromReference(JReference reference) =>
      reference.isNull ? null : JObject.fromReference(reference);

  @internal
  @override
  JObjType get superType => const JObjectNullableType();

  @internal
  @override
  JObjType get nullableType => this;

  // TODO(#70): Once interface implementation lands, other than [superType],
  // we should have a list of implemented interfaces.

  @internal
  @override
  final int superCount = 0;

  @override
  int get hashCode => (JObjectNullableType).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == JObjectNullableType &&
        other is JObjectNullableType;
  }
}

final class JObjectType extends JObjType<JObject> {
  @internal
  const JObjectType();

  @internal
  @override
  String get signature => 'Ljava/lang/Object;';

  @internal
  @override
  JObject fromReference(JReference reference) =>
      JObject.fromReference(reference);

  @internal
  @override
  JObjType get superType => const JObjectType();

  @internal
  @override
  JObjType get nullableType => const JObjectNullableType();

  // TODO(#70): Once interface implementation lands, other than [superType],
  // we should have a list of implemented interfaces.

  @internal
  @override
  final int superCount = 0;

  @override
  int get hashCode => (JObjectType).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == JObjectType && other is JObjectType;
  }
}

/// A high-level wrapper for JNI global object reference.
///
/// This is the base class for classes generated by `jnigen`.
class JObject {
  @internal
  final JReference reference;

  @internal
  final JObjType<JObject> $type = type;

  /// The type which includes information such as the signature of this class.
  static const JObjType<JObject> type = JObjectType();

  static const JObjType<JObject?> nullableType = JObjectNullableType();

  /// Constructs a [JObject] with the underlying [reference].
  JObject.fromReference(this.reference) {
    if (reference.isNull) {
      throw JNullError();
    }
  }

  /// Returns [JClass] corresponding to concrete class of this object.
  ///
  /// This may be a subclass of compile-time class.
  JClass get jClass {
    final classRef = Jni.env.GetObjectClass(reference.pointer);
    if (classRef == nullptr) {
      Jni.throwException(Jni.env.ExceptionOccurred());
    }
    return JClass.fromReference(JGlobalReference(classRef));
  }

  /// Releases the underlying [reference].
  ///
  /// Releasing in one isolate while using or releasing in another isolate might
  /// crash in the JNI layer.
  void release() {
    reference.release();
  }

  /// Whether this object is of the given [type] ignoring the type parameters.
  ///
  /// > [!WARNING]
  /// > Because of Java generic type erasure, this method cannot distinguish
  /// > between two classes `Foo<A>` and `Foo<B>` as they are both of type
  /// > `Foo`. Therefore, `object.isA(Foo.type(A.type))` will return a
  /// > false-positive `true` for objects of type `Foo<B>` as well.
  ///
  /// For example:
  ///
  /// ```dart
  /// if (object.isA(JLong.type)) {
  ///   final i = object.as(JLong.type).longValue;
  ///   ...
  /// }
  /// ```
  bool isA<T extends JObject?>(JObjType<T> type) {
    final targetJClass = type.jClass;
    final canBeCasted = isInstanceOf(targetJClass);
    targetJClass.release();
    return canBeCasted;
  }

  /// Whether this object is of the type of the given [jclass].
  bool isInstanceOf(JClass jclass) {
    return Jni.env.IsInstanceOf(reference.pointer, jclass.reference.pointer);
  }

  /// Casts this object to another [type].
  ///
  /// If [releaseOriginal] is `true`, the casted object will be released.
  ///
  /// Throws [CastError] if this object is not an instance of [type].
  T as<T extends JObject?>(
    JObjType<T> type, {
    bool releaseOriginal = false,
  }) {
    if (!isA(type)) {
      throw CastError('not a subtype of "${type.signature}"');
    }

    if (releaseOriginal) {
      final ret = type.fromReference(JGlobalReference(reference.pointer));
      reference.setAsReleased();
      return ret;
    }
    final newRef = JGlobalReference(Jni.env.NewGlobalRef(reference.pointer));
    return type.fromReference(newRef);
  }

  static final _class = JClass.forName('java/lang/Object');

  static final _hashCodeId = _class.instanceMethodId(r'hashCode', r'()I');

  @override
  int get hashCode => _hashCodeId(this, const jintType(), [])!;

  static final _equalsId =
      _class.instanceMethodId(r'equals', r'(Ljava/lang/Object;)Z');
  @override
  bool operator ==(Object other) {
    if (other is! JObject) {
      return false;
    }
    final otherRef = other.reference;
    return _equalsId(this, const jbooleanType(), [otherRef.pointer])!;
  }

  static final _toStringId =
      _class.instanceMethodId(r'toString', r'()Ljava/lang/String;');
  @override
  String toString() {
    return _toStringId(this, const JStringType(), [])
        .toDartString(releaseOriginal: true);
  }

  bool get isReleased => reference.isReleased;

  /// Registers this object to be released at the end of [arena]'s lifetime.
  void releasedBy(Arena arena) => arena.onReleaseAll(release);
}

extension JObjectUseExtension<T extends JObject> on T {
  /// Applies [callback] on this object and then delete the underlying JNI
  /// reference, returning the result of [callback].
  R use<R>(R Function(T) callback) {
    try {
      final result = callback(this);
      return result;
    } finally {
      release();
    }
  }
}
