// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:meta/meta.dart' show internal;

import '../jni.dart';
import '../jobject.dart';
import '../jreference.dart';
import '../types.dart';

final class JStringNullableType extends JObjType<JString?> {
  @internal
  const JStringNullableType();

  @internal
  @override
  String get signature => 'Ljava/lang/String;';

  @internal
  @override
  JString? fromReference(JReference reference) =>
      reference.isNull ? null : JString.fromReference(reference);

  @internal
  @override
  JObjType get superType => const JObjectNullableType();

  @internal
  @override
  JObjType<JString?> get nullableType => this;

  @internal
  @override
  final int superCount = 1;

  @override
  int get hashCode => (JStringNullableType).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == JStringNullableType &&
        other is JStringNullableType;
  }
}

final class JStringType extends JObjType<JString> {
  @internal
  const JStringType();

  @internal
  @override
  String get signature => 'Ljava/lang/String;';

  @internal
  @override
  JString fromReference(JReference reference) =>
      JString.fromReference(reference);

  @internal
  @override
  JObjType get superType => const JObjectType();

  @internal
  @override
  JObjType<JString?> get nullableType => const JStringNullableType();

  @internal
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
  @internal
  @override
  // ignore: overridden_fields
  final JObjType<JString> $type = type;

  /// The type which includes information such as the signature of this class.
  static const JObjType<JString> type = JStringType();

  /// Construct a new [JString] with [reference] as its underlying reference.
  JString.fromReference(super.reference) : super.fromReference();

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
