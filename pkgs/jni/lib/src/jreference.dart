// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:jni/src/third_party/generated_bindings.dart';

import 'errors.dart';
import 'jni.dart';

extension ProtectedJReference on JReference {
  void setAsReleased() {
    if (_released) {
      throw DoubleReleaseError();
    }
    _released = true;
    JReference._finalizer.detach(this);
  }

  void ensureNotNull() {
    if (isNull) {
      throw JNullError();
    }
  }

  /// Similar to [reference].
  ///
  /// Detaches the finalizer so the underlying pointer will not be deleted.
  JObjectPtr toPointer() {
    final ref = reference;
    setAsReleased();
    return ref;
  }
}

/// A managed JNI global reference.
///
/// Uses a [NativeFinalizer] to delete the JNI global reference when finalized.
abstract class JReference implements Finalizable {
  static final _finalizer =
      NativeFinalizer(Jni.env.ptr.ref.DeleteGlobalRef.cast());

  JReference.fromRef(this._reference) {
    if (_reference != nullptr) {
      _finalizer.attach(this, _reference, detach: this);
    }
  }

  bool _released = false;

  /// Whether the underlying JNI reference is `null` or not.
  bool get isNull => reference == nullptr;

  /// Whether the underlying JNI reference is deleted or not.
  bool get isReleased => _released;

  /// Deletes the underlying JNI reference and marks this as released.
  ///
  /// Throws [DoubleReleaseError] if this is already released.
  ///
  /// Further uses of this object will throw [UseAfterReleaseError].
  void release() {
    setAsReleased();
    Jni.env.DeleteGlobalRef(_reference);
  }

  /// The underlying JNI global object reference.
  ///
  /// Throws [UseAfterReleaseError] if the object is previously released.
  ///
  /// Be careful when storing this in a variable since it might have gotten
  /// released upon use.
  JObjectPtr get reference {
    if (_released) throw UseAfterReleaseError();
    return _reference;
  }

  final JObjectPtr _reference;

  /// Registers this object to be released at the end of [arena]'s lifetime.
  void releasedBy(Arena arena) => arena.onReleaseAll(release);
}

/// Creates a "lazy" [JReference].
///
/// The first use of [reference] will call [lazyReference].
///
/// This is useful when the Java object is not necessarily used directly, and
/// there are alternative ways to get a Dart representation of the Object.
///
/// Object mixed in with this must call their super.[fromRef] constructor
/// with [nullptr].
///
/// Also see [JFinalString].
mixin JLazyReference on JReference {
  JObjectPtr? _lazyReference;

  JObjectPtr Function() get lazyReference;

  @override
  JObjectPtr get reference {
    if (_lazyReference == null) {
      _lazyReference = lazyReference();
      JReference._finalizer.attach(this, _lazyReference!, detach: this);
      return _lazyReference!;
    }
    if (_released) {
      throw UseAfterReleaseError();
    }
    return _lazyReference!;
  }

  @override
  void release() {
    setAsReleased();
    if (_lazyReference == null) {
      return;
    }
    Jni.env.DeleteGlobalRef(_lazyReference!);
  }
}

extension JReferenceUseExtension<T extends JReference> on T {
  /// Applies [callback] on [this] object and then delete the underlying JNI
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
