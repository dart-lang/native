// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../jobject.dart';
import '../types.dart';

extension type JBoolean._(JObject _$this) implements JObject {
  /// The type which includes information such as the signature of this class.
  static const JType<JBoolean> type = JType(r'java/lang/Boolean');

  static final _class = type.jClass;

  static final _ctorId = _class.constructorId(r'(Z)V');

  JBoolean(bool boolean) : _$this = _ctorId(_class, [boolean ? 1 : 0]);

  static final _booleanValueId =
      _class.instanceMethodId(r'booleanValue', r'()Z');

  bool booleanValue({bool releaseOriginal = false}) {
    final ret = _booleanValueId(this, const jbooleanType(), []);
    if (releaseOriginal) {
      release();
    }
    return ret;
  }
}
