// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../jobject.dart';
import '../jvalues.dart';
import '../types.dart';
import 'jnumber.dart';

extension type JFloat._(JObject _$this) implements JNumber {
  /// The type which includes information such as the signature of this class.
  static const JType<JFloat> type = JType(r'java/lang/Float');

  static final _class = type.jClass;

  static final _ctorId = _class.constructorId(r'(F)V');

  JFloat(double num) : _$this = _ctorId(_class, [JValueFloat(num)]);
}
