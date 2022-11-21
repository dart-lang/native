// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of 'types.dart';

class JStringType extends JObjType<JString> {
  const JStringType();

  @override
  String get signature => "Ljava/lang/String;";

  @override
  JString fromRef(Pointer<Void> ref) => JString.fromRef(ref);
}

class JString extends JObject {
  @override
  JObjType<JObject> get $type => _$type ??= type;

  /// The type which includes information such as the signature of this class.
  static const JObjType<JString> type = JStringType();

  /// Construct a new [JString] with [reference] as its underlying reference.
  JString.fromRef(JStringPtr reference) : super.fromRef(reference);

  static JStringPtr _toJavaString(String s) => using((arena) {
        final chars = s.toNativeUtf8(allocator: arena).cast<Char>();
        final jstr = _env.NewStringUTF(chars);
        if (jstr == nullptr) {
          throw 'Fatal: cannot convert string to Java string: $s';
        }
        return jstr;
      });

  /// The number of Unicode characters in this Java string.
  int get length => _env.GetStringLength(reference);

  /// Construct a [JString] from the contents of Dart string [s].
  JString.fromString(String s) : super.fromRef(_toJavaString(s));

  /// Returns the contents as a Dart String.
  ///
  /// If [deleteOriginal] is true, the underlying reference is deleted
  /// after conversion and this object will be marked as deleted.
  String toDartString({bool deleteOriginal = false}) {
    _ensureNotDeleted();
    if (reference == nullptr) {
      throw NullJStringException();
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

extension ToJStringMethod on String {
  /// Returns a [JString] with the contents of this String.
  JString toJString() {
    return JString.fromString(this);
  }
}
