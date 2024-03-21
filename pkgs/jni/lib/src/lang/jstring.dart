// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:jni/src/jreference.dart';

import '../jni.dart';
import '../jobject.dart';
import '../types.dart';

final class JStringType extends JObjType<JString> {
  const JStringType();

  @override
  String get signature => "Ljava/lang/String;";

  @override
  JString fromReference(JReference reference) =>
      JString.fromReference(reference);

  @override
  JObjType get superType => const JObjectType();

  @override
  final int superCount = 1;

  @override
  int get hashCode => (JStringType).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == JStringType && other is JStringType;
  }
}

class JString extends JObject {
  @override
  // ignore: overridden_fields
  late final JObjType<JString> $type = type;

  /// The type which includes information such as the signature of this class.
  static const JObjType<JString> type = JStringType();

  /// Construct a new [JString] with [reference] as its underlying reference.
  JString.fromReference(JReference reference) : super.fromReference(reference);

  /// The number of Unicode characters in this Java string.
  int get length => Jni.env.GetStringLength(reference.pointer);

  /// Construct a [JString] from the contents of Dart string [s].
  JString.fromString(String s)
      : super.fromReference(JGlobalReference(Jni.env.toJStringPtr(s)));

  /// Returns the contents as a Dart String.
  ///
  /// If [releaseOriginal] is true, the underlying reference is deleted
  /// after conversion and this object will be marked as released.
  String toDartString({bool releaseOriginal = false}) {
    reference.ensureNotNull();
    final result = Jni.env.toDartString(reference.pointer);
    if (releaseOriginal) {
      release();
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
