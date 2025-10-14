// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:meta/meta.dart' show internal;

import '../jobject.dart';
import '../jvalues.dart';
import '../types.dart';

@internal
final class $JCharacter$Type$ extends JType<JCharacter> {
  const $JCharacter$Type$();

  @override
  String get signature => r'Ljava/lang/Character;';
}

extension type JCharacter._(JObject _$this) implements JObject {
  /// The type which includes information such as the signature of this class.
  static const JType<JCharacter> type = $JCharacter$Type$();

  static final _class = JClass.forName(r'java/lang/Character');

  static final _ctorId = _class.constructorId(r'(C)V');

  JCharacter(int c) : _$this = _ctorId(_class, [JValueChar(c)]);

  static final _charValueId = _class.instanceMethodId(r'charValue', r'()C');

  int charValue({bool releaseOriginal = false}) {
    final ret = _charValueId(this, const jcharType(), []);
    if (releaseOriginal) {
      release();
    }
    return ret;
  }
}
