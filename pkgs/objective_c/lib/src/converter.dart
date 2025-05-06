// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'objective_c_bindings_generated.dart';

ObjCObjectBase toObjCObject(
  Object dartObject, {
  ObjCObjectBase Function(Object) convertOther = (o) =>
      throw UnimplementedError('No conversion for $o'),
}) =>
    switch (dartObject) {
      ObjCObjectBase() => dartObject,
      num() => dartObject.toNSNumber(),
      String() => dartObject.toNSString(),
      DateTime() => dartObject.toNSDate(),
      List<Object>() => NSMutableArray.of(
          dartObject.map((o) => toObjCObject(o, convertOther: convertOther))),
      Set<Object>() => NSMutableSet.of(
          dartObject.map((o) => toObjCObject(o, convertOther: convertOther))),
      Map<Object, Object>() =>
          NSMutableDictionary.fromEntries(
          dartObject.entries.map((kv) =>
              MapEntry(
                toObjCObject(kv.key, convertOther: convertOther),
                toObjCObject(kv.value, convertOther: convertOther),
              ))),
      _ => convertOther(dartObject),
    };

Object toDartObject(
  ObjCObjectBase objCObject, {
  Object Function(ObjCObjectBase) convertOther = (o) =>
      throw UnimplementedError('No conversion for $o'),
}) =>
    switch (objCObject) {
      NSNumber() => dartObject.toNSNumber(),
      String() => dartObject.toNSString(),
      DateTime() => dartObject.toNSDate(),
      List<Object>() => NSMutableArray.of(
          dartObject.map((o) => toObjCObject(o, convertOther: convertOther))),
      Set<Object>() => NSMutableSet.of(
          dartObject.map((o) => toObjCObject(o, convertOther: convertOther))),
      Map<Object, Object>() =>
          NSMutableDictionary.fromEntries(
          dartObject.entries.map((kv) =>
              MapEntry(
                toObjCObject(kv.key, convertOther: convertOther),
                toObjCObject(kv.value, convertOther: convertOther),
              ))),
      _ => convertOther(dartObject),
    };
