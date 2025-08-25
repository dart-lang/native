// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:meta/meta.dart' show internal;

import '../jni.dart';
import '../jobject.dart';
import '../jreference.dart';
import '../types.dart';

@internal
final class $JString$NullableType$ extends JType<JString?> {
  const $JString$NullableType$();

  @override
  String get signature => 'Ljava/lang/String;';

  @override
  JString? fromReference(JReference reference) =>
      reference.isNull ? null : JString.fromReference(reference);

  @override
  JType get superType => const $JObject$NullableType$();

  @override
  JType<JString?> get nullableType => this;

  @override
  final int superCount = 1;

  @override
  int get hashCode => ($JString$NullableType$).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == $JString$NullableType$ &&
        other is $JString$NullableType$;
  }
}

@internal
final class $JString$Type$ extends JType<JString> {
  const $JString$Type$();

  @override
  String get signature => 'Ljava/lang/String;';

  @override
  JString fromReference(JReference reference) =>
      JString.fromReference(reference);

  @override
  JType get superType => const $JObject$Type$();

  @override
  JType<JString?> get nullableType => const $JString$NullableType$();

  @override
  final int superCount = 1;

  @override
  int get hashCode => ($JString$Type$).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == $JString$Type$ && other is $JString$Type$;
  }
}

class JString extends JObject {
  @internal
  @override
  // ignore: overridden_fields
  final JType<JString> $type = type;

  /// The type which includes information such as the signature of this class.
  static const JType<JString> type = $JString$Type$();

  /// The type which includes information such as the signature of this class.
  static const JType<JString?> nullableType = $JString$NullableType$();

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
