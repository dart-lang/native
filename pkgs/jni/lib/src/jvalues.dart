// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';
import 'package:ffi/ffi.dart';

import 'third_party/jni_bindings_generated.dart';
import 'jni.dart';
import 'types.dart';

void _fillJValue(Pointer<JValue> pos, dynamic arg) {
  if (arg is JObject) {
    pos.ref.l = arg.reference;
    return;
  }

  switch (arg.runtimeType) {
    case int:
      pos.ref.i = arg;
      break;
    case bool:
      pos.ref.z = arg ? 1 : 0;
      break;
    case Pointer<Void>:
    case Pointer<Never>: // for nullptr
      pos.ref.l = arg;
      break;
    case double:
      pos.ref.d = arg;
      break;
    case JValueFloat:
      pos.ref.f = (arg as JValueFloat).value;
      break;
    case JValueLong:
      pos.ref.j = (arg as JValueLong).value;
      break;
    case JValueShort:
      pos.ref.s = (arg as JValueShort).value;
      break;
    case JValueChar:
      pos.ref.c = (arg as JValueChar).value;
      break;
    case JValueByte:
      pos.ref.b = (arg as JValueByte).value;
      break;
    default:
      throw UnsupportedError("cannot convert ${arg.runtimeType} to jvalue");
  }
}

/// Converts passed arguments to JValue array
/// for use in methods that take arguments.
///
/// int, bool, double and JObject types are converted out of the box.
/// wrap values in types such as [JValueLong]
/// to convert to other primitive types instead.
Pointer<JValue> toJValues(List<dynamic> args, {Allocator allocator = calloc}) {
  final result = allocator<JValue>(args.length);
  for (int i = 0; i < args.length; i++) {
    final arg = args[i];
    final pos = result.elementAt(i);
    _fillJValue(pos, arg);
  }
  return result;
}

/// Use this class as wrapper to convert an integer
/// to Java `long` in jvalues method.
class JValueLong {
  int value;
  JValueLong(this.value);
}

/// Use this class as wrapper to convert an integer
/// to Java `short` in jvalues method.
class JValueShort {
  int value;
  JValueShort(this.value);
}

/// Use this class as wrapper to convert an integer
/// to Java `byte` in jvalues method.
class JValueByte {
  int value;
  JValueByte(this.value);
}

/// Use this class as wrapper to convert an double
/// to Java `float` in jvalues method.
class JValueFloat {
  double value;
  JValueFloat(this.value);
}

/// Use this class as wrapper to convert an integer
/// to Java `char` in jvalues method.
class JValueChar {
  int value;
  JValueChar(this.value);
  JValueChar.fromString(String s) : value = 0 {
    if (s.length != 1) {
      throw "Expected string of length 1";
    }
    value = s.codeUnitAt(0).toInt();
  }
}

/// class used to convert dart types passed to convenience methods
/// into their corresponding Java values.
///
/// Similar to Jni.jvalues, but instead of a pointer, an instance
/// with a dispose method is returned.
/// This allows us to take dart strings.
///
/// Returned value is allocated using provided allocator.
/// But default allocator may be used for string conversions.
class JValueArgs {
  late Pointer<JValue> values;
  final List<JObjectPtr> createdRefs = [];
  final _env = Jni.env;

  JValueArgs(List<dynamic> args, [Allocator allocator = malloc]) {
    values = allocator<JValue>(args.length);
    for (int i = 0; i < args.length; i++) {
      final arg = args[i];
      final ptr = values.elementAt(i);
      if (arg is String) {
        final jstr = _env.asJString(arg);
        ptr.ref.l = jstr;
        createdRefs.add(jstr);
      } else {
        _fillJValue(ptr, arg);
      }
    }
  }

  /// Deletes temporary references such as [JStringPtr]s.
  void dispose() {
    for (var ref in createdRefs) {
      _env.DeleteGlobalRef(ref);
    }
  }
}
