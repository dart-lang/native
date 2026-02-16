// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:meta/meta.dart' show internal;

import '../jobject.dart';
import '../jreference.dart';
import '../jvalues.dart';
import '../types.dart';

@internal
final class $JCharacter$NullableType$ extends JType<JCharacter?> {
  const $JCharacter$NullableType$();

  @override
  String get signature => r'Ljava/lang/Character;';

  @override
  JCharacter? fromReference(JReference reference) =>
      reference.isNull ? null : JCharacter.fromReference(reference);

  @override
  JType get superType => const $JObject$NullableType$();

  @override
  JType<JCharacter?> get nullableType => this;

  @override
  final superCount = 1;

  @override
  int get hashCode => ($JCharacter$NullableType$).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == $JCharacter$NullableType$ &&
        other is $JCharacter$NullableType$;
  }
}

@internal
final class $JCharacter$Type$ extends JType<JCharacter> {
  const $JCharacter$Type$();

  @override
  String get signature => r'Ljava/lang/Character;';

  @override
  JCharacter fromReference(JReference reference) =>
      JCharacter.fromReference(reference);

  @override
  JType get superType => const $JObject$Type$();

  @override
  JType<JCharacter?> get nullableType => const $JCharacter$NullableType$();

  @override
  final superCount = 1;

  @override
  int get hashCode => ($JCharacter$Type$).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == $JCharacter$Type$ && other is $JCharacter$Type$;
  }
}

class JCharacter extends JObject {
  @internal
  @override
  // ignore: overridden_fields
  final JType<JCharacter> $type = type;

  JCharacter.fromReference(super.reference) : super.fromReference();

  /// The type which includes information such as the signature of this class.
  static const JType<JCharacter> type = $JCharacter$Type$();

  /// The type which includes information such as the signature of this class.
  static const JType<JCharacter?> nullableType = $JCharacter$NullableType$();

  static final _class = JClass.forName(r'java/lang/Character');

  static final _ctorId = _class.constructorId(r'(C)V');

  JCharacter(int c)
    : super.fromReference(_ctorId(_class, referenceType, [JValueChar(c)]));

  static final _charValueId = _class.instanceMethodId(r'charValue', r'()C');

  int charValue({bool releaseOriginal = false}) {
    final ret = _charValueId(this, const jcharType(), []);
    if (releaseOriginal) {
      release();
    }
    return ret;
  }
}
