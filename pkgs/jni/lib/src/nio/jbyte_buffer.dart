// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';
import 'dart:typed_data';

import '../accessors.dart';
import '../jarray.dart';
import '../jni.dart';
import '../jprimitives.dart';
import '../jreference.dart';
import '../jvalues.dart';
import '../third_party/generated_bindings.dart';
import '../types.dart';
import 'jbuffer.dart';

final class JByteBufferType extends JObjType<JByteBuffer> {
  const JByteBufferType();

  @override
  String get signature => r"Ljava/nio/ByteBuffer;";

  @override
  JByteBuffer fromRef(JObjectPtr ref) => JByteBuffer.fromRef(ref);

  @override
  JObjType get superType => const JBufferType();

  @override
  final superCount = 2;

  @override
  int get hashCode => (JByteBufferType).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == (JByteBufferType) && other is JByteBufferType;
  }
}

/// A byte [JBuffer].
///
/// The bindings for `java.nio.ByteBuffer`.
///
/// This enables fast memory copying between Java and Dart when directly
/// allocated (See [JByteBuffer.allocateDirect]).
///
/// To create a [JByteBuffer] from the content of a [Uint8List],
/// use [JByteBuffer.fromList]. This uses direct allocation to enable fast
/// copying.
///
/// [asUint8List] provides a direct access to the underlying [Uint8List] that
/// this buffer uses. This means any changes to it will change the content of
/// the buffer and vice versa. This can be used to access to [Uint8List] methods
/// such as [Uint8List.setRange].
///
/// Example:
/// ```dart
/// final directBuffer = JByteBuffer.allocateDirect(3);
/// directBuffer.asUint8List().setAll(0, [1, 2, 3]);
/// // The buffer is now 1, 2, 3.
/// ```
///
/// Both the original buffer and the [Uint8List] keep the underlying Java buffer
/// alive. Once all the instances of the original buffer and the lists produced
/// from [asUint8List] are inaccessible both in Java and Dart, Java will
/// correctly garbage collects the buffer and frees its underlying memory.
///
/// Example:
/// ```dart
/// final directBuffer = JByteBuffer.allocateDirect(3);
/// final data = directBuffer.asUint8List();
/// directBuffer.release(); // Releasing the original buffer.
/// data.setAll(0, [1, 2, 3]); // Works! [data] is still accessible.
/// ```
///
/// The original buffer can be [release]d when calling [asUint8List]
/// by setting the `releaseOriginal` parameter to `true`.
///
/// Example:
/// ```dart
/// final directBuffer = JByteBuffer.allocateDirect(3);
/// // [releaseOriginal] is `false` by default.
/// final data1 = directBuffer.asUint8List();
/// directBuffer.nextByte = 42; // No problem!
/// print(data1[0]); // prints 42!
/// final data2 = directBuffer.asUint8List(releaseOriginal: true);
/// // directBuffer.nextByte = 42; // throws [UseAfterReleaseException]!
/// ```
class JByteBuffer extends JBuffer {
  @override
  // ignore: overridden_fields
  late final JObjType<JByteBuffer> $type = type;

  JByteBuffer.fromRef(
    JObjectPtr ref,
  ) : super.fromRef(ref);

  static final _class = Jni.findJClass(r"java/nio/ByteBuffer");

  /// The type which includes information such as the signature of this class.
  static const type = JByteBufferType();

  static final _allocateDirectId = Jni.accessors.getStaticMethodIDOf(
      _class.reference, r"allocateDirect", r"(I)Ljava/nio/ByteBuffer;");

  /// Allocates a new direct byte buffer.
  ///
  /// Throws:
  /// * [IllegalArgumentException] - If the capacity is a negative integer
  factory JByteBuffer.allocateDirect(int capacity) {
    return JByteBuffer.fromRef(
      Jni.accessors.callStaticMethodWithArgs(
          _class.reference,
          _allocateDirectId,
          JniCallType.objectType,
          [JValueInt(capacity)]).object,
    );
  }

  static final _allocateId = Jni.accessors.getStaticMethodIDOf(
      _class.reference, r"allocate", r"(I)Ljava/nio/ByteBuffer;");

  /// Allocates a new byte buffer.
  ///
  /// Throws:
  /// * [IllegalArgumentException] - If the capacity is a negative integer
  factory JByteBuffer.allocate(int capacity) {
    return const JByteBufferType().fromRef(Jni.accessors
        .callStaticMethodWithArgs(_class.reference, _allocateId,
            JniCallType.objectType, [JValueInt(capacity)]).object);
  }

  static final _wrapWholeId = Jni.accessors.getStaticMethodIDOf(
      _class.reference, r"wrap", r"([B)Ljava/nio/ByteBuffer;");
  static final _wrapId = Jni.accessors.getStaticMethodIDOf(
      _class.reference, r"wrap", r"([BII)Ljava/nio/ByteBuffer;");

  /// Wraps a byte array into a buffer.
  ///
  /// The new buffer will be backed by the given byte array; that is,
  /// modifications to the buffer will cause the array to be modified
  /// and vice versa.
  static JByteBuffer wrap(
    JArray<jbyte> array, [
    int? offset,
    int? length,
  ]) {
    if (offset == null && length == null) {
      return const JByteBufferType().fromRef(
        Jni.accessors.callStaticMethodWithArgs(
          _class.reference,
          _wrapWholeId,
          JniCallType.objectType,
          [array.reference],
        ).object,
      );
    }
    offset ??= 0;
    length ??= array.length - offset;
    return const JByteBufferType().fromRef(
      Jni.accessors.callStaticMethodWithArgs(
        _class.reference,
        _wrapId,
        JniCallType.objectType,
        [array.reference, JValueInt(offset), JValueInt(length)],
      ).object,
    );
  }

  /// Creates a [JByteBuffer] from the content of [list].
  ///
  /// The [JByteBuffer] will be allocated using [JByteBuffer.allocateDirect].
  factory JByteBuffer.fromList(Uint8List list) {
    final buffer = JByteBuffer.allocateDirect(list.length);
    buffer._asUint8ListUnsafe().setAll(0, list);
    return buffer;
  }

  static final _sliceId = Jni.accessors
      .getMethodIDOf(_class.reference, r"slice", r"()Ljava/nio/ByteBuffer;");

  /// Creates a new byte buffer whose content is a shared subsequence of this
  /// buffer's content.
  JByteBuffer slice() {
    return const JByteBufferType().fromRef(Jni.accessors.callMethodWithArgs(
        reference, _sliceId, JniCallType.objectType, []).object);
  }

  static final _duplicateId = Jni.accessors.getMethodIDOf(
      _class.reference, r"duplicate", r"()Ljava/nio/ByteBuffer;");

  /// Creates a new byte buffer that shares this buffer's content.
  JByteBuffer duplicate() {
    return const JByteBufferType().fromRef(Jni.accessors.callMethodWithArgs(
        reference, _duplicateId, JniCallType.objectType, []).object);
  }

  static final _asReadOnlyBufferId = Jni.accessors.getMethodIDOf(
      _class.reference, r"asReadOnlyBuffer", r"()Ljava/nio/ByteBuffer;");

  /// Creates a new, read-only byte buffer that shares this buffer's content.
  JByteBuffer asReadOnlyBuffer() {
    return const JByteBufferType().fromRef(Jni.accessors.callMethodWithArgs(
        reference, _asReadOnlyBufferId, JniCallType.objectType, []).object);
  }

  static final _getId =
      Jni.accessors.getMethodIDOf(_class.reference, r"get", r"()B");

  /// Reads the byte at this buffer's current [position], and then increments the
  /// [position].
  ///
  /// Throws:
  ///  * [BufferOverflowException] - If the buffer's current [position] is not
  ///    smaller than its [limit]
  int get nextByte {
    return Jni.accessors
        .callMethodWithArgs(reference, _getId, JniCallType.byteType, []).byte;
  }

  static final _putId = Jni.accessors
      .getMethodIDOf(_class.reference, r"put", r"(B)Ljava/nio/ByteBuffer;");

  /// Writes the given byte into this buffer at the current [position], and then
  /// increments the [position].
  ///
  /// Throws:
  /// * [BufferOverflowException] - If this buffer's current [position] is not
  ///   smaller than its [limit]
  /// * [ReadOnlyBufferException] - If this buffer is read-only
  set nextByte(int b) {
    Jni.env.DeleteGlobalRef(Jni.accessors.callMethodWithArgs(
        reference, _putId, JniCallType.objectType, [JValueByte(b)]).object);
  }

  static final _arrayId =
      Jni.accessors.getMethodIDOf(_class.reference, r"array", r"()[B");

  @override
  JArray<jbyte> get array {
    return const JArrayType(jbyteType()).fromRef(Jni.accessors
        .callMethodWithArgs(
            reference, _arrayId, JniCallType.objectType, []).object);
  }

  void _ensureIsDirect() {
    if (!isDirect) {
      throw StateError(
        'The buffer must be created with `JByteBuffer.allocateDirect`.',
      );
    }
  }

  Pointer<Void> _directBufferAddress() {
    final address = Jni.env.GetDirectBufferAddress(reference);
    if (address == nullptr) {
      throw StateError(
        'The memory region is undefined or '
        'direct buffer access is not supported by this JVM.',
      );
    }
    return address;
  }

  int _directBufferCapacity() {
    final capacity = Jni.env.GetDirectBufferCapacity(reference);
    if (capacity == -1) {
      throw StateError(
        'The object is an unaligned view buffer and the processor '
        'architecture does not support unaligned access.',
      );
    }
    return capacity;
  }

  Uint8List _asUint8ListUnsafe() {
    _ensureIsDirect();
    final address = _directBufferAddress();
    final capacity = _directBufferCapacity();
    return address.cast<Uint8>().asTypedList(capacity);
  }

  /// Returns this byte buffer as a [Uint8List].
  ///
  /// If [releaseOriginal] is `true`, this byte buffer will be released.
  ///
  /// Throws [StateError] if the buffer is not direct
  /// (see [JByteBuffer.allocateDirect]) or the JVM does not support the direct
  /// buffer operations or the object is an unaligned view buffer and
  /// the processor does not support unaligned access.
  Uint8List asUint8List({bool releaseOriginal = false}) {
    _ensureIsDirect();
    final address = _directBufferAddress();
    final capacity = _directBufferCapacity();
    final token = releaseOriginal ? reference : Jni.env.NewGlobalRef(reference);
    if (releaseOriginal) {
      setAsReleased();
    }
    return address.cast<Uint8>().asTypedList(
          capacity,
          token: token,
          finalizer: Jni.env.ptr.ref.DeleteGlobalRef.cast(),
        );
  }
}

extension Uint8ListToJava on Uint8List {
  /// Creates a [JByteBuffer] from the content of this list.
  ///
  /// The [JByteBuffer] will be allocated using [JByteBuffer.allocateDirect].
  JByteBuffer toJByteBuffer() {
    return JByteBuffer.fromList(this);
  }
}
