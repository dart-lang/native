// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import 'package:collection/collection.dart';
import 'package:ffi/ffi.dart';

import 'accessors.dart';
import 'jni.dart';
import 'jvalues.dart';
import 'third_party/jni_bindings_generated.dart';

part 'jarray.dart';
part 'jexceptions.dart';
part 'jprimitives.dart';
part 'jreference.dart';
part 'jobject.dart';
part 'jstring.dart';

final Pointer<JniAccessors> _accessors = Jni.accessors;
final Pointer<GlobalJniEnv> _env = Jni.env;
// This typedef is needed because void is a keyword and cannot be used in
// type switch like a regular type.
typedef _VoidType = void;

abstract class JType<T> {
  const JType();

  int get _type => JniCallType.objectType;

  String get signature;

  JniClass _getClass() => Jni.findJniClass(signature);
}
