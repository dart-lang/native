// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../jobject.dart';
import '../jvalues.dart';
import '../types.dart';
import 'jnumber.dart';

final class _$JInteger$Type$ extends JType<JInteger> {
  const _$JInteger$Type$();

  @override
  String get signature => r'Ljava/lang/Integer;';
}

extension type JInteger._(JObject _$this) implements JNumber {
  /// The type which includes information such as the signature of this class.
  static const JType<JInteger> type = _$JInteger$Type$();

  static final _class = JClass.forName(r'java/lang/Integer');

  static final _ctorId = _class.constructorId('(I)V');

  JInteger(int num) : _$this = _ctorId<JInteger>(_class, [JValueInt(num)]);
}
