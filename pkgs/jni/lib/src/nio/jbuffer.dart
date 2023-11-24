// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../accessors.dart';
import '../jni.dart';
import '../jobject.dart';
import '../jvalues.dart';
import '../third_party/generated_bindings.dart';
import '../types.dart';

final class JBufferType extends JObjType<JBuffer> {
  const JBufferType();

  @override
  String get signature => r"Ljava/nio/Buffer;";

  @override
  JBuffer fromRef(JObjectPtr ref) => JBuffer.fromRef(ref);

  @override
  JObjType get superType => const JObjectType();

  @override
  final superCount = 1;

  @override
  int get hashCode => (JBufferType).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == (JBufferType) && other is JBufferType;
  }
}

/// A container for data of a specific primitive type.
///
/// The bindings for `java.nio.Buffer`.
///
/// A buffer is a linear, finite sequence of elements of a specific primitive
/// type. Aside from its content, the essential properties of a buffer are its
/// [capacity], [limit], and [position].
///
/// There is one subclass of this class for each non-boolean primitive type.
/// We currently only have the bindings for `java.nio.ByteBuffer` in this
/// package as [JByteBuffer].
class JBuffer extends JObject {
  @override
  // ignore: overridden_fields
  late final JObjType<JBuffer> $type = type;

  JBuffer.fromRef(
    JObjectPtr ref,
  ) : super.fromRef(ref);

  static final _class = Jni.findJClass(r"java/nio/Buffer");

  /// The type which includes information such as the signature of this class.
  static const type = JBufferType();

  static final _capacityId =
      Jni.accessors.getMethodIDOf(_class.reference, r"capacity", r"()I");

  /// The number of elements this buffer contains.
  ///
  /// It is never negative and never changes.
  int get capacity {
    return Jni.accessors.callMethodWithArgs(
        reference, _capacityId, JniCallType.intType, []).integer;
  }

  static final _positionId =
      Jni.accessors.getMethodIDOf(_class.reference, r"position", r"()I");

  /// The index of the next element to be read or written.
  ///
  /// It is never negative and is never greater than its [limit].
  int get position {
    return Jni.accessors.callMethodWithArgs(
        reference, _positionId, JniCallType.intType, []).integer;
  }

  static final _setPositionId = Jni.accessors
      .getMethodIDOf(_class.reference, r"position", r"(I)Ljava/nio/Buffer;");

  /// Throws:
  /// * [IllegalArgumentException] - If the preconditions on [newPosition] do
  ///   not hold.
  set position(int position) {
    Jni.env.DeleteGlobalRef(Jni.accessors.callMethodWithArgs(reference,
        _setPositionId, JniCallType.objectType, [JValueInt(position)]).object);
  }

  static final _limitId =
      Jni.accessors.getMethodIDOf(_class.reference, r"limit", r"()I");

  /// The index of the first element that should not be read or written.
  ///
  /// It is never negative and is never greater than its [capacity].
  int get limit {
    return Jni.accessors.callMethodWithArgs(
        reference, _limitId, JniCallType.intType, []).integer;
  }

  static final _setLimitId = Jni.accessors
      .getMethodIDOf(_class.reference, r"limit", r"(I)Ljava/nio/Buffer;");

  /// Throws:
  /// * [IllegalArgumentException] - If the preconditions on [newLimit] do not
  ///   hold.
  set limit(int newLimit) {
    Jni.env.DeleteGlobalRef(Jni.accessors.callMethodWithArgs(reference,
        _setLimitId, JniCallType.objectType, [JValueInt(newLimit)]).object);
  }

  static final _markId = Jni.accessors
      .getMethodIDOf(_class.reference, r"mark", r"()Ljava/nio/Buffer;");

  /// Sets this buffer's mark at its [position].
  ///
  /// Mark is the index to which its [position] will be reset when the [reset]
  /// method is invoked.
  void mark() {
    Jni.env.DeleteGlobalRef(Jni.accessors.callMethodWithArgs(
        reference, _markId, JniCallType.objectType, []).object);
  }

  static final _resetId = Jni.accessors
      .getMethodIDOf(_class.reference, r"reset", r"()Ljava/nio/Buffer;");

  /// Resets this buffer's [position] to the previously-marked position.
  ///
  /// Throws:
  /// * [InvalidMarkException] - If the mark has not been set
  void reset() {
    Jni.env.DeleteGlobalRef(Jni.accessors.callMethodWithArgs(
        reference, _resetId, JniCallType.objectType, []).object);
  }

  static final _clearId = Jni.accessors
      .getMethodIDOf(_class.reference, r"clear", r"()Ljava/nio/Buffer;");

  /// Clears this buffer.
  ///
  /// The [position] is set to zero, the [limit] is set to
  /// the [capacity], and the mark is discarded.
  void clear() {
    Jni.env.DeleteGlobalRef(Jni.accessors.callMethodWithArgs(
        reference, _clearId, JniCallType.objectType, []).object);
  }

  static final _flipId = Jni.accessors
      .getMethodIDOf(_class.reference, r"flip", r"()Ljava/nio/Buffer;");

  /// Flips this buffer.
  ///
  /// The limit is set to the current [position] and then the [position] is set
  /// to zero. If the mark is defined then it is discarded.
  void flip() {
    Jni.env.DeleteGlobalRef(Jni.accessors.callMethodWithArgs(
        reference, _flipId, JniCallType.objectType, []).object);
  }

  static final _rewindId = Jni.accessors
      .getMethodIDOf(_class.reference, r"rewind", r"()Ljava/nio/Buffer;");

  /// Rewinds this buffer.
  ///
  /// The [position] is set to zero and the mark is discarded.
  void rewind() {
    Jni.env.DeleteGlobalRef(Jni.accessors.callMethodWithArgs(
        reference, _rewindId, JniCallType.objectType, []).object);
  }

  static final _remainingId =
      Jni.accessors.getMethodIDOf(_class.reference, r"remaining", r"()I");

  /// The number of elements between the current [position] and the
  /// [limit].
  int get remaining {
    return Jni.accessors.callMethodWithArgs(
        reference, _remainingId, JniCallType.intType, []).integer;
  }

  static final _hasRemainingId =
      Jni.accessors.getMethodIDOf(_class.reference, r"hasRemaining", r"()Z");

  /// Whether there are any elements between the current [position] and
  /// the [limit].
  bool get hasRemaining {
    return Jni.accessors.callMethodWithArgs(
        reference, _hasRemainingId, JniCallType.booleanType, []).boolean;
  }

  static final _isReadOnlyId =
      Jni.accessors.getMethodIDOf(_class.reference, r"isReadOnly", r"()Z");

  /// Whether or not this buffer is read-only.
  bool get isReadOnly {
    return Jni.accessors.callMethodWithArgs(
        reference, _isReadOnlyId, JniCallType.booleanType, []).boolean;
  }

  static final _hasArrayId =
      Jni.accessors.getMethodIDOf(_class.reference, r"hasArray", r"()Z");

  /// Whether or not this buffer is backed by an accessible array.
  bool get hasArray {
    return Jni.accessors.callMethodWithArgs(
        reference, _hasArrayId, JniCallType.booleanType, []).boolean;
  }

  static final _arrayId = Jni.accessors
      .getMethodIDOf(_class.reference, r"array", r"()Ljava/lang/Object;");

  /// The array that backs this buffer.
  ///
  /// Concrete subclasses like [JByteBuffer] provide more strongly-typed return
  /// values for this method.
  ///
  /// Throws:
  /// * [ReadOnlyBufferException] - If this buffer is backed by an array but is
  ///   read-only
  /// * [UnsupportedOperationException] - If this buffer is not backed by an
  ///   accessible array
  JObject get array {
    return const JObjectType().fromRef(Jni.accessors.callMethodWithArgs(
        reference, _arrayId, JniCallType.objectType, []).object);
  }

  static final _arrayOffsetId =
      Jni.accessors.getMethodIDOf(_class.reference, r"arrayOffset", r"()I");

  /// The offset within this buffer's backing array of the first element
  /// of the buffer.
  ///
  /// Throws:
  /// * [ReadOnlyBufferException] - If this buffer is backed by an array but is
  ///   read-only
  /// * [UnsupportedOperationException] - If this buffer is not backed by an
  ///   accessible array
  int get arrayOffset {
    return Jni.accessors.callMethodWithArgs(
        reference, _arrayOffsetId, JniCallType.intType, []).integer;
  }

  static final _isDirectId =
      Jni.accessors.getMethodIDOf(_class.reference, r"isDirect", r"()Z");

  /// Whether or not this buffer is direct.
  bool get isDirect {
    return Jni.accessors.callMethodWithArgs(
        reference, _isDirectId, JniCallType.booleanType, []).boolean;
  }
}
