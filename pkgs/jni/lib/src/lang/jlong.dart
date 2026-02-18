// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../jobject.dart';
import '../types.dart';
import 'jnumber.dart';

final class _$JLong$Type$ extends JType<JLong> {
  const _$JLong$Type$();

  @override
  String get signature => r'Ljava/lang/Long;';
}

extension type JLong._(JObject _$this) implements JNumber {
  /// The type which includes information such as the signature of this class.
  static const JType<JLong> type = _$JLong$Type$();

  static final _class = JClass.forName(r'java/lang/Long');

  static final _ctorId = _class.constructorId(r'(J)V');

  JLong(int num) : _$this = _ctorId<JLong>(_class, [num]);
}
