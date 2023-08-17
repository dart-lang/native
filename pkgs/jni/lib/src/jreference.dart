// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:jni/src/third_party/generated_bindings.dart';

import 'jexceptions.dart';
import 'jni.dart';

extension ProtectedJReference on JReference {
  void setAsDeleted() {
    if (_deleted) {
      throw DoubleFreeException(_reference);
    }
    _deleted = true;
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
    setAsDeleted();
    return _reference;
  }
}

/// A class which holds one or more JNI references, and has a `delete` operation
/// which disposes the reference(s).
abstract class JReference implements Finalizable {
  static final _finalizer =
      NativeFinalizer(Jni.env.ptr.ref.DeleteGlobalRef.cast());

  JReference.fromRef(this._reference) {
    _finalizer.attach(this, _reference, detach: this);
  }

  bool _deleted = false;

  /// Check whether the underlying JNI reference is `null`.
  bool get isNull => reference == nullptr;

  /// Returns whether this object is deleted.
  bool get isDeleted => _deleted;

  /// Deletes the underlying JNI reference.
  ///
  /// Further uses will throw [UseAfterFreeException].
  void delete() {
    setAsDeleted();
    Jni.env.DeleteGlobalRef(_reference);
  }

  /// The underlying JNI global object reference.
  ///
  /// Throws [UseAfterFreeException] if the object is previously deleted.
  ///
  /// Be careful when storing this reference in a variable, since the underlying
  /// object might get deleted.
  JObjectPtr get reference {
    if (_deleted) throw UseAfterFreeException(_reference);
    return _reference;
  }

  final JObjectPtr _reference;

  /// Registers this object to be deleted at the end of [arena]'s lifetime.
  void deletedIn(Arena arena) => arena.onReleaseAll(delete);
}

extension JReferenceUseExtension<T extends JReference> on T {
  /// Applies [callback] on [this] object and then delete the underlying JNI
  /// reference, returning the result of [callback].
  R use<R>(R Function(T) callback) {
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
