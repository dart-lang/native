// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:meta/meta.dart' show internal;

import '../jobject.dart';
import '../types.dart';
import 'jnumber.dart';

@internal
final class $JDouble$Type$ extends JType<JDouble> {
  const $JDouble$Type$();

  @override
  String get signature => r'Ljava/lang/Double;';
}

extension type JDouble._(JObject _$this) implements JNumber {
  /// The type which includes information such as the signature of this class.
  static const JType<JDouble> type = $JDouble$Type$();

  static final _class = JClass.forName(r'java/lang/Double');

  static final _ctorId = _class.constructorId(r'(D)V');

  JDouble(double num) : _$this = _ctorId(_class, [num]);
}
