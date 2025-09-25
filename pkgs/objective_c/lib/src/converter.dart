// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'internal.dart';
import 'ns_date.dart';
import 'ns_number.dart';
import 'ns_string.dart';
import 'objective_c_bindings_generated.dart';

ObjCObjectBase _defaultObjCConverter(Object o) =>
    throw UnimplementedError('No conversion for $o');

/// Converts a Dart object to the corresponding Objective C object.
///
/// This supports basic types like `num` and `String`. It also works on
/// collections, and recursively converts their elements.
///
/// If [dartObject] is not one of the recognized types, [convertOther] is
/// called. If [convertOther] is not provided, an error is thrown.
ObjCObjectBase toObjCObject(
  Object? dartObject, {
  ObjCObjectBase Function(Object) convertOther = _defaultObjCConverter,
}) => switch (dartObject) {
  null => NSNull.null$(),
  ObjCObjectBase() => dartObject,
  num() => dartObject.toNSNumber(),
  String() => dartObject.toNSString(),
  DateTime() => dartObject.toNSDate(),
  List<Object>() => dartObject.toNSArray(convertOther: convertOther),
  Set<Object>() => dartObject.toNSSet(convertOther: convertOther),
  Map<Object, Object>() => dartObject.toNSDictionary(
    convertOther: convertOther,
  ),
  _ => convertOther(dartObject),
};

extension DartListToNSArray on List<Object> {
  NSArray toNSArray({
    ObjCObjectBase Function(Object) convertOther = _defaultObjCConverter,
  }) => NSArray.of(map((o) => toObjCObject(o, convertOther: convertOther)));
}

extension DartSetToNSSet on Set<Object> {
  NSSet toNSSet({
    ObjCObjectBase Function(Object) convertOther = _defaultObjCConverter,
  }) => NSSet.of(map((o) => toObjCObject(o, convertOther: convertOther)));
}

extension DartMapToNSDictionary on Map<Object, Object> {
  NSDictionary toNSDictionary({
    ObjCObjectBase Function(Object) convertOther = _defaultObjCConverter,
  }) => NSDictionary.fromEntries(
    entries.map(
      (kv) => MapEntry(
        toObjCObject(kv.key, convertOther: convertOther) as NSCopying,
        toObjCObject(kv.value, convertOther: convertOther),
      ),
    ),
  );
}

Object _defaultDartConverter(ObjCObjectBase o) => o;

/// Converts a Objective C object to the corresponding Dart object.
///
/// This supports basic types like `NSNumber` and `NSString`. It also works on
/// collections, and recursively converts their elements.
///
/// If [objCObject] is not one of the recognized types, [convertOther] is
/// called. If [convertOther] is not provided, [objCObject] is returned
/// directly.
Object toDartObject(
  ObjCObjectBase objCObject, {
  Object Function(ObjCObjectBase) convertOther = _defaultDartConverter,
}) {
  // A type-based switch, like in toObjCObject, won't work here because the
  // object could have a Dart runtime type of eg NSObject, even if the
  // underlying ObjC object that the Dart object is wrapping is a NSNumber.
  if (NSNumber.isInstance(objCObject)) {
    return NSNumber.castFrom(objCObject).numValue;
  }
  if (NSString.isInstance(objCObject)) {
    return NSString.castFrom(objCObject).toDartString();
  }
  if (NSDate.isInstance(objCObject)) {
    return NSDate.castFrom(objCObject).toDateTime();
  }
  if (NSArray.isInstance(objCObject)) {
    return NSArray.castFrom(objCObject).toDartList(convertOther: convertOther);
  }
  if (NSSet.isInstance(objCObject)) {
    return NSSet.castFrom(objCObject).toDartSet(convertOther: convertOther);
  }
  if (NSDictionary.isInstance(objCObject)) {
    return NSDictionary.castFrom(
      objCObject,
    ).toDartMap(convertOther: convertOther);
  }
  return convertOther(objCObject);
}

/// Converts a Objective C object to the corresponding Dart object.
///
/// See [toDartObject]. This method will additionally return `null` if passed an
/// `NSNull`.
Object? toNullableDartObject(
  ObjCObjectBase objCObject, {
  Object Function(ObjCObjectBase) convertOther = _defaultDartConverter,
}) {
  if (NSNull.isInstance(objCObject)) {
    return null;
  }
  return toDartObject(objCObject, convertOther: convertOther);
}

extension NSArrayToDartList on NSArray {
  List<Object> toDartList({
    Object Function(ObjCObjectBase) convertOther = _defaultDartConverter,
  }) => map((o) => toDartObject(o, convertOther: convertOther)).toList();
}

extension NSSetToDartSet on NSSet {
  Set<Object> toDartSet({
    Object Function(ObjCObjectBase) convertOther = _defaultDartConverter,
  }) => map((o) => toDartObject(o, convertOther: convertOther)).toSet();
}

extension NSDictionaryToDartMap on NSDictionary {
  Map<Object, Object> toDartMap({
    Object Function(ObjCObjectBase) convertOther = _defaultDartConverter,
  }) => Map.fromEntries(
    entries.map(
      (kv) => MapEntry(
        toDartObject(kv.key, convertOther: convertOther),
        toDartObject(kv.value, convertOther: convertOther),
      ),
    ),
  );
}
