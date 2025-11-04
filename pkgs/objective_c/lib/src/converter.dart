// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'internal.dart';
import 'ns_array.dart';
import 'ns_date.dart';
import 'ns_dictionary.dart';
import 'ns_number.dart';
import 'ns_set.dart';
import 'ns_string.dart';
import 'objective_c_bindings_generated.dart';

ObjCObject _defaultObjCConverter(Object o) =>
    throw UnimplementedError('No conversion for $o');

/// Converts a Dart object to the corresponding Objective C object.
///
/// This supports basic types like `num` and `String`. It also works on
/// collections, and recursively converts their elements.
///
/// If [dartObject] is not one of the recognized types, [convertOther] is
/// called. If [convertOther] is not provided, an error is thrown.
ObjCObject toObjCObject(
  Object? dartObject, {
  ObjCObject Function(Object) convertOther = _defaultObjCConverter,
}) => switch (dartObject) {
  null => NSNull.null$(),
  ObjCObject() => dartObject,
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
    ObjCObject Function(Object) convertOther = _defaultObjCConverter,
  }) => NSArray.of(map((o) => toObjCObject(o, convertOther: convertOther)));
}

extension DartSetToNSSet on Set<Object> {
  NSSet toNSSet({
    ObjCObject Function(Object) convertOther = _defaultObjCConverter,
  }) => NSSet.of(map((o) => toObjCObject(o, convertOther: convertOther)));
}

extension DartMapToNSDictionary on Map<Object, Object> {
  NSDictionary toNSDictionary({
    ObjCObject Function(Object) convertOther = _defaultObjCConverter,
  }) => NSDictionary.fromEntries(
    entries.map(
      (kv) => MapEntry(
        toObjCObject(kv.key, convertOther: convertOther) as NSCopying,
        toObjCObject(kv.value, convertOther: convertOther),
      ),
    ),
  );
}

Object _defaultDartConverter(ObjCObject o) => o;

/// Converts a Objective C object to the corresponding Dart object.
///
/// This supports basic types like `NSNumber` and `NSString`. It also works on
/// collections, and recursively converts their elements.
///
/// If [objCObject] is not one of the recognized types, [convertOther] is
/// called. If [convertOther] is not provided, [objCObject] is returned
/// directly.
Object toDartObject(
  ObjCObject objCObject, {
  Object Function(ObjCObject) convertOther = _defaultDartConverter,
}) {
  // A type-based switch, like in toObjCObject, won't work here because the
  // object could have a Dart runtime type of eg NSObject, even if the
  // underlying ObjC object that the Dart object is wrapping is a NSNumber.
  if (NSNumber.isA(objCObject)) {
    return NSNumber.as(objCObject).numValue;
  }
  if (NSString.isA(objCObject)) {
    return NSString.as(objCObject).toDartString();
  }
  if (NSDate.isA(objCObject)) {
    return NSDate.as(objCObject).toDateTime();
  }
  if (NSArray.isA(objCObject)) {
    return NSArray.as(objCObject).toDartList(convertOther: convertOther);
  }
  if (NSSet.isA(objCObject)) {
    return NSSet.as(objCObject).toDartSet(convertOther: convertOther);
  }
  if (NSDictionary.isA(objCObject)) {
    return NSDictionary.as(objCObject).toDartMap(convertOther: convertOther);
  }
  return convertOther(objCObject);
}

/// Converts a Objective C object to the corresponding Dart object.
///
/// See [toDartObject]. This method will additionally return `null` if passed an
/// `NSNull`.
Object? toNullableDartObject(
  ObjCObject objCObject, {
  Object Function(ObjCObject) convertOther = _defaultDartConverter,
}) {
  if (NSNull.isA(objCObject)) {
    return null;
  }
  return toDartObject(objCObject, convertOther: convertOther);
}

extension NSArrayToDartList on NSArray {
  /// Deep converts this [NSArray] to a Dart [List].
  ///
  /// This creates a new [List], converts all the [NSArray] elements, and adds
  /// them to the [List]. If you only need iteration and element access,
  /// [toDart] is much more efficient.
  List<Object> toDartList({
    Object Function(ObjCObject) convertOther = _defaultDartConverter,
  }) =>
      toDart().map((o) => toDartObject(o, convertOther: convertOther)).toList();
}

extension NSSetToDartSet on NSSet {
  /// Deep converts this [NSSet] to a Dart [Set].
  ///
  /// This creates a new [Set], converts all the [NSSet] elements, and adds
  /// them to the [Set]. If you only need iteration and element access,
  /// [toDart] is much more efficient.
  Set<Object> toDartSet({
    Object Function(ObjCObject) convertOther = _defaultDartConverter,
  }) =>
      toDart().map((o) => toDartObject(o, convertOther: convertOther)).toSet();
}

extension NSDictionaryToDartMap on NSDictionary {
  /// Deep converts this [NSDictionary] to a Dart [Map].
  ///
  /// This creates a new [Map], converts all the [NSDictionary] elements, and
  /// adds them to the [Map]. If you only need iteration and element access,
  /// [toDart] is much more efficient.
  Map<Object, Object> toDartMap({
    Object Function(ObjCObject) convertOther = _defaultDartConverter,
  }) => Map.fromEntries(
    toDart().entries.map(
      (kv) => MapEntry(
        toDartObject(kv.key, convertOther: convertOther),
        toDartObject(kv.value, convertOther: convertOther),
      ),
    ),
  );
}
