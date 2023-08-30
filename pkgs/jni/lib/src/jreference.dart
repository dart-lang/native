// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:jni/src/third_party/generated_bindings.dart';

import 'jexceptions.dart';
import 'jni.dart';

extension ProtectedJReference on JReference {
  void setAsReleased() {
    if (_released) {
      throw DoubleReleaseException(_reference);
    }
    _released = true;
    JReference._finalizer.detach(this);
  }

  void ensureNotNull() {
    if (isNull) {
      throw const JNullException();
    }
  }

  /// Similar to [reference].
  ///
  /// Detaches the finalizer so the underlying pointer will not be deleted.
  JObjectPtr toPointer() {
    setAsReleased();
    return _reference;
  }
}

/// A managed JNI global reference.
///
/// Uses a [NativeFinalizer] to delete the JNI global reference when finalized.
abstract class JReference implements Finalizable {
  static final _finalizer =
      NativeFinalizer(Jni.env.ptr.ref.DeleteGlobalRef.cast());

  JReference.fromRef(this._reference) {
    _finalizer.attach(this, _reference, detach: this);
  }

  bool _released = false;

  /// Check whether the underlying JNI reference is `null`.
  bool get isNull => reference == nullptr;

  /// Returns `true` if the underlying JNI reference is deleted.
  bool get isReleased => _released;

  /// Deletes the underlying JNI reference.
  ///
  /// Further uses will throw [UseAfterReleaseException].
  void release() {
    setAsReleased();
    Jni.env.DeleteGlobalRef(_reference);
  }

  /// The underlying JNI global object reference.
  ///
  /// Throws [UseAfterReleaseException] if the object is previously released.
  ///
  /// Be careful when storing this in a variable since it might have gotten
  /// released upon use.
  JObjectPtr get reference {
    if (_released) throw UseAfterReleaseException(_reference);
    return _reference;
  }

  final JObjectPtr _reference;

  /// Registers this object to be released at the end of [arena]'s lifetime.
  void releasedBy(Arena arena) => arena.onReleaseAll(release);
}

extension JReferenceUseExtension<T extends JReference> on T {
  /// Applies [callback] on [this] object and then delete the underlying JNI
  /// reference, returning the result of [callback].
  R use<R>(R Function(T) callback) {
    try {
      final result = callback(this);
      release();
      return result;
    } catch (e) {
      release();
      rethrow;
    }
  }
}
