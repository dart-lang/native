// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../jobject.dart';
import '../jreference.dart';
import '../jvalues.dart';
import '../types.dart';

final class JBufferType extends JObjType<JBuffer> {
  const JBufferType();

  @override
  String get signature => r"Ljava/nio/Buffer;";

  @override
  JBuffer fromReference(JReference reference) =>
      JBuffer.fromReference(reference);

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

  JBuffer.fromReference(
    JReference reference,
  ) : super.fromReference(reference);

  static final _class = JClass.forName(r"java/nio/Buffer");

  /// The type which includes information such as the signature of this class.
  static const type = JBufferType();

  static final _capacityId = _class.instanceMethodId(r"capacity", r"()I");

  /// The number of elements this buffer contains.
  ///
  /// It is never negative and never changes.
  int get capacity {
    return _capacityId(this, const jintType(), []);
  }

  static final _positionId = _class.instanceMethodId(r"position", r"()I");

  /// The index of the next element to be read or written.
  ///
  /// It is never negative and is never greater than its [limit].
  int get position {
    return _positionId(this, const jintType(), []);
  }

  static final _setPositionId =
      _class.instanceMethodId(r"position", r"(I)Ljava/nio/Buffer;");

  /// Throws:
  /// * [IllegalArgumentException] - If the preconditions on [newPosition] do
  ///   not hold.
  set position(int position) {
    _setPositionId(this, const JObjectType(), [JValueInt(position)]).release();
  }

  static final _limitId = _class.instanceMethodId(r"limit", r"()I");

  /// The index of the first element that should not be read or written.
  ///
  /// It is never negative and is never greater than its [capacity].
  int get limit {
    return _limitId(this, const jintType(), []);
  }

  static final _setLimitId =
      _class.instanceMethodId(r"limit", r"(I)Ljava/nio/Buffer;");

  /// Throws:
  /// * [IllegalArgumentException] - If the preconditions on [newLimit] do not
  ///   hold.
  set limit(int newLimit) {
    _setLimitId(this, const JObjectType(), [JValueInt(newLimit)]).release();
  }

  static final _markId =
      _class.instanceMethodId(r"mark", r"()Ljava/nio/Buffer;");

  /// Sets this buffer's mark at its [position].
  ///
  /// Mark is the index to which its [position] will be reset when the [reset]
  /// method is invoked.
  void mark() {
    _markId(this, const JObjectType(), []).release();
  }

  static final _resetId =
      _class.instanceMethodId(r"reset", r"()Ljava/nio/Buffer;");

  /// Resets this buffer's [position] to the previously-marked position.
  ///
  /// Throws:
  /// * [InvalidMarkException] - If the mark has not been set
  void reset() {
    _resetId(this, const JObjectType(), []).release();
  }

  static final _clearId =
      _class.instanceMethodId(r"clear", r"()Ljava/nio/Buffer;");

  /// Clears this buffer.
  ///
  /// The [position] is set to zero, the [limit] is set to
  /// the [capacity], and the mark is discarded.
  void clear() {
    _clearId(this, const JObjectType(), []).release();
  }

  static final _flipId =
      _class.instanceMethodId(r"flip", r"()Ljava/nio/Buffer;");

  /// Flips this buffer.
  ///
  /// The limit is set to the current [position] and then the [position] is set
  /// to zero. If the mark is defined then it is discarded.
  void flip() {
    _flipId(this, const JObjectType(), []).release();
  }

  static final _rewindId =
      _class.instanceMethodId(r"rewind", r"()Ljava/nio/Buffer;");

  /// Rewinds this buffer.
  ///
  /// The [position] is set to zero and the mark is discarded.
  void rewind() {
    _rewindId(this, const JObjectType(), []).release();
  }

  static final _remainingId = _class.instanceMethodId(r"remaining", r"()I");

  /// The number of elements between the current [position] and the
  /// [limit].
  int get remaining {
    return _remainingId(this, const jintType(), []);
  }

  static final _hasRemainingId =
      _class.instanceMethodId(r"hasRemaining", r"()Z");

  /// Whether there are any elements between the current [position] and
  /// the [limit].
  bool get hasRemaining {
    return _hasRemainingId(this, const jbooleanType(), []);
  }

  static final _isReadOnlyId = _class.instanceMethodId(r"isReadOnly", r"()Z");

  /// Whether or not this buffer is read-only.
  bool get isReadOnly {
    return _isReadOnlyId(this, const jbooleanType(), []);
  }

  static final _hasArrayId = _class.instanceMethodId(r"hasArray", r"()Z");

  /// Whether or not this buffer is backed by an accessible array.
  bool get hasArray {
    return _hasArrayId(this, const jbooleanType(), []);
  }

  static final _arrayId =
      _class.instanceMethodId(r"array", r"()Ljava/lang/Object;");

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
    return _arrayId(this, const JObjectType(), []);
  }

  static final _arrayOffsetId = _class.instanceMethodId(r"arrayOffset", r"()I");

  /// The offset within this buffer's backing array of the first element
  /// of the buffer.
  ///
  /// Throws:
  /// * [ReadOnlyBufferException] - If this buffer is backed by an array but is
  ///   read-only
  /// * [UnsupportedOperationException] - If this buffer is not backed by an
  ///   accessible array
  int get arrayOffset {
    return _arrayOffsetId(this, const jintType(), []);
  }

  static final _isDirectId = _class.instanceMethodId(r"isDirect", r"()Z");

  /// Whether or not this buffer is direct.
  bool get isDirect {
    return _isDirectId(this, const jbooleanType(), []);
  }
}
