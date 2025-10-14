// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../jobject.dart';
import '../jvalues.dart';
import '../types.dart';
import 'jnumber.dart';

final class _$JByte$Type$ extends JType<JByte> {
  const _$JByte$Type$();

  @override
  String get signature => r'Ljava/lang/Byte;';
}

extension type JByte._(JObject _$this) implements JNumber {
  /// The type which includes information such as the signature of this class.
  static const JType<JByte> type = _$JByte$Type$();

  static final _class = JClass.forName(r'java/lang/Byte');

  static final _ctorId = _class.constructorId(r'(B)V');

  JByte(int num) : _$this = _ctorId(_class, [JValueByte(num)]);
}
