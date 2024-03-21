// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';
import 'package:jni/internal_helpers_for_jnigen.dart';

import 'jobject.dart';
import 'third_party/generated_bindings.dart';

void _fillJValue(Pointer<JValue> pos, dynamic arg) {
  switch (arg) {
    case JObject():
      pos.ref.l = arg.reference.pointer;
    case JReference():
      pos.ref.l = arg.pointer;
    case Pointer<Void>() || Pointer<Never>(): // for nullptr
      pos.ref.l = arg;
      break;
    case int():
      pos.ref.j = arg;
      break;
    case bool():
      pos.ref.z = arg ? 1 : 0;
      break;
    case double():
      pos.ref.d = arg;
      break;
    case JValueFloat():
      pos.ref.f = arg.value;
      break;
    case JValueInt():
      pos.ref.i = arg.value;
      break;
    case JValueShort():
      pos.ref.s = arg.value;
      break;
    case JValueChar():
      pos.ref.c = arg.value;
      break;
    case JValueByte():
      pos.ref.b = arg.value;
      break;
    default:
      throw UnsupportedError("cannot convert ${arg.runtimeType} to jvalue");
  }
}

/// Converts passed arguments to JValue array
/// for use in methods that take arguments.
///
/// int, bool, double and JObject types are converted out of the box.
/// wrap values in types such as [JValueInt]
/// to convert to other primitive types instead.
Pointer<JValue> toJValues(List<dynamic> args, {required Allocator allocator}) {
  final result = allocator<JValue>(args.length);
  for (int i = 0; i < args.length; i++) {
    final arg = args[i];
    final pos = result + i;
    _fillJValue(pos, arg);
  }
  return result;
}

/// Use this class as wrapper to convert an integer
/// to Java `int` in jvalues method.
final class JValueInt {
  int value;
  JValueInt(this.value);
}

/// Use this class as wrapper to convert an integer
/// to Java `short` in jvalues method.
final class JValueShort {
  int value;
  JValueShort(this.value);
}

/// Use this class as wrapper to convert an integer
/// to Java `byte` in jvalues method.
final class JValueByte {
  int value;
  JValueByte(this.value);
}

/// Use this class as wrapper to convert an double
/// to Java `float` in jvalues method.
final class JValueFloat {
  double value;
  JValueFloat(this.value);
}

/// Use this class as wrapper to convert an integer
/// to Java `char` in jvalues method.
final class JValueChar {
  int value;
  JValueChar(this.value);
  JValueChar.fromString(String s) : value = 0 {
    if (s.length != 1) {
      throw "Expected string of length 1";
    }
    value = s.codeUnitAt(0).toInt();
  }
}
