// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:meta/meta.dart' show internal;

import '../jobject.dart';
import '../jreference.dart';
import '../jvalues.dart';
import '../types.dart';

final class JCharacterNullableType extends JObjType<JCharacter?> {
  @internal
  const JCharacterNullableType();

  @internal
  @override
  String get signature => r'Ljava/lang/Character;';

  @internal
  @override
  JCharacter? fromReference(JReference reference) =>
      reference.isNull ? null : JCharacter.fromReference(reference);

  @internal
  @override
  JObjType get superType => const JObjectNullableType();

  @internal
  @override
  JObjType<JCharacter?> get nullableType => this;

  @internal
  @override
  final superCount = 1;

  @override
  int get hashCode => (JCharacterNullableType).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == JCharacterNullableType &&
        other is JCharacterNullableType;
  }
}

final class JCharacterType extends JObjType<JCharacter> {
  @internal
  const JCharacterType();

  @internal
  @override
  String get signature => r'Ljava/lang/Character;';

  @internal
  @override
  JCharacter fromReference(JReference reference) =>
      JCharacter.fromReference(reference);

  @internal
  @override
  JObjType get superType => const JObjectType();

  @internal
  @override
  JObjType<JCharacter?> get nullableType => const JCharacterNullableType();

  @internal
  @override
  final superCount = 1;

  @override
  int get hashCode => (JCharacterType).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == JCharacterType && other is JCharacterType;
  }
}

class JCharacter extends JObject {
  @internal
  @override
  // ignore: overridden_fields
  final JObjType<JCharacter> $type = type;

  JCharacter.fromReference(
    super.reference,
  ) : super.fromReference();

  /// The type which includes information such as the signature of this class.
  static const type = JCharacterType();

  /// The type which includes information such as the signature of this class.
  static const nullableType = JCharacterNullableType();

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
