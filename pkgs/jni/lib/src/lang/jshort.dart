// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:meta/meta.dart' show internal;

import '../jobject.dart';
import '../jvalues.dart';
import '../types.dart';
import 'jnumber.dart';

@internal
final class $JShort$Type$ extends JType<JShort> {
  const $JShort$Type$();

  @override
  String get signature => r'Ljava/lang/Short;';
}

extension type JShort._(JObject _$this) implements JNumber {
  /// The type which includes information such as the signature of this class.
  static const JType<JShort> type = $JShort$Type$();

  static final _class = JClass.forName(r'java/lang/Short');

  static final _ctorId = _class.constructorId(r'(S)V');

  JShort(int num) : _$this = _ctorId(_class, [JValueShort(num)]);
}
