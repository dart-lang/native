// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'jarray.dart';
import 'jni.dart';
import 'jobject.dart';
import 'lang/lang.dart';
import 'types.dart';
import 'util/util.dart';

JObject _defaultJNIConverter(Object o) =>
    throw UnimplementedError('No conversion for $o');

/// Converts a Dart object to a JNI object.
JObject? toJObject(
  Object? dartObject, {
  JObject Function(Object) convertOther = _defaultJNIConverter,
}) =>
    switch (dartObject) {
      null => null,
      JObject() => dartObject,
      bool() => dartObject.toJBoolean(),
      int() => dartObject.toJLong(),
      double() => dartObject.toJDouble(),
      String() => dartObject.toJString(),
      List<Object?>() => dartObject.toJList(convertOther: convertOther),
      Set<Object?>() => dartObject.toJSet(convertOther: convertOther),
      Map<Object?, Object?>() => dartObject.toJMap(convertOther: convertOther),
      _ => convertOther(dartObject),
    };

extension DartListToJList on List<Object?> {
  JList<JObject?> toJList({
    JObject Function(Object) convertOther = _defaultJNIConverter,
  }) {
    final list = JList.array(JObject.nullableType);
    for (final element in this) {
      list.add(toJObject(element, convertOther: convertOther));
    }
    return list;
  }
}

extension DartSetToJSet on Set<Object?> {
  JSet<JObject?> toJSet({
    JObject Function(Object) convertOther = _defaultJNIConverter,
  }) {
    final set = JSet.hash(JObject.nullableType);
    for (final element in this) {
      set.add(toJObject(element, convertOther: convertOther));
    }
    return set;
  }
}

extension DartMapToJMap on Map<Object?, Object?> {
  JMap<JObject?, JObject?> toJMap({
    JObject Function(Object) convertOther = _defaultJNIConverter,
  }) {
    final map = JMap.hash(JObject.nullableType, JObject.nullableType);
    for (final entry in entries) {
      map[toJObject(entry.key, convertOther: convertOther)] =
          toJObject(entry.value, convertOther: convertOther);
    }
    return map;
  }
}

extension DartListToJBooleanArray on List<bool> {
  JBooleanArray toJBooleanArray() =>
      JBooleanArray(length)..setRange(0, length, this);
}

extension DartListToJByteArray on List<int> {
  JByteArray toJByteArray() => JByteArray(length)..setRange(0, length, this);
}

extension DartListToJCharArray on List<int> {
  JCharArray toJCharArray() => JCharArray(length)..setRange(0, length, this);
}

extension DartListToJShortArray on List<int> {
  JShortArray toJShortArray() => JShortArray(length)..setRange(0, length, this);
}

extension DartListToJIntArray on List<int> {
  JIntArray toJIntArray() => JIntArray(length)..setRange(0, length, this);
}

extension DartListToJLongArray on List<int> {
  JLongArray toJLongArray() => JLongArray(length)..setRange(0, length, this);
}

extension DartListToJFloatArray on List<double> {
  JFloatArray toJFloatArray() => JFloatArray(length)..setRange(0, length, this);
}

extension DartListToJDoubleArray on List<double> {
  JDoubleArray toJDoubleArray() =>
      JDoubleArray(length)..setRange(0, length, this);
}

extension DartListToJObjectArray<E extends JObject?> on List<E> {
  JArray<E> toJObjectArray(JType<E> elementType) =>
      JArray.of(elementType, this);
}

Object? _defaultDartConverter(JObject? o) => o;

/// Converts a JNI object to a Dart object.
Object? toDartObject(
  JObject? jObject, {
  Object? Function(JObject?) convertOther = _defaultDartConverter,
}) {
  if (jObject == null) return null;

  if (jObject.isA(JString.type)) {
    return jObject.as(JString.type).toDartString();
  }
  if (jObject.isA(JBoolean.type)) {
    return jObject.as(JBoolean.type).booleanValue();
  }
  if (jObject.isA(JInteger.type)) {
    return jObject.as(JInteger.type).intValue();
  }
  if (jObject.isA(JLong.type)) {
    return jObject.as(JLong.type).longValue();
  }
  if (jObject.isA(JDouble.type)) {
    return jObject.as(JDouble.type).doubleValue();
  }
  if (jObject.isA(JFloat.type)) {
    return jObject.as(JFloat.type).floatValue();
  }
  if (jObject.isA(JShort.type)) {
    return jObject.as(JShort.type).shortValue();
  }
  if (jObject.isA(JByte.type)) {
    return jObject.as(JByte.type).byteValue();
  }
  if (jObject.isA(JCharacter.type)) {
    return jObject.as(JCharacter.type).charValue();
  }

  if (jObject.isA(JBooleanArray.type)) {
    return jObject.as(JBooleanArray.type).toList();
  }
  if (jObject.isA(JByteArray.type)) {
    return jObject.as(JByteArray.type).toList();
  }
  if (jObject.isA(JCharArray.type)) {
    return jObject.as(JCharArray.type).toList();
  }
  if (jObject.isA(JShortArray.type)) {
    return jObject.as(JShortArray.type).toList();
  }
  if (jObject.isA(JIntArray.type)) {
    return jObject.as(JIntArray.type).toList();
  }
  if (jObject.isA(JLongArray.type)) {
    return jObject.as(JLongArray.type).toList();
  }
  if (jObject.isA(JFloatArray.type)) {
    return jObject.as(JFloatArray.type).toList();
  }
  if (jObject.isA(JDoubleArray.type)) {
    return jObject.as(JDoubleArray.type).toList();
  }

  if (jObject.isA(JArray.type(JObject.nullableType))) {
    return jObject
        .as(JArray.type(JObject.nullableType))
        .toDeepDartList(convertOther: convertOther);
  }

  if (jObject.isA(JList.type(JObject.nullableType))) {
    return jObject
        .as(JList.type(JObject.nullableType))
        .toDeepDartList(convertOther: convertOther);
  }
  if (jObject.isA(JSet.type(JObject.nullableType))) {
    return jObject
        .as(JSet.type(JObject.nullableType))
        .toDeepDartSet(convertOther: convertOther);
  }
  if (jObject.isA(JMap.type(JObject.nullableType, JObject.nullableType))) {
    return jObject
        .as(JMap.type(JObject.nullableType, JObject.nullableType))
        .toDeepDartMap(convertOther: convertOther);
  }

  return convertOther(jObject);
}

Object? toNullableDartObject(
  JObject? jObject, {
  Object? Function(JObject?) convertOther = _defaultDartConverter,
}) =>
    toDartObject(jObject, convertOther: convertOther);

extension JArrayToDartList<E extends JObject?> on JArray<E> {
  List<Object?> toDeepDartList({
    Object? Function(JObject?) convertOther = _defaultDartConverter,
  }) =>
      map((e) => toDartObject(e, convertOther: convertOther)).toList();
}

extension JListToDartList<E extends JObject?> on JList<E> {
  List<Object?> toDeepDartList({
    Object? Function(JObject?) convertOther = _defaultDartConverter,
  }) =>
      map((e) => toDartObject(e, convertOther: convertOther)).toList();
}

extension JSetToDartSet<E extends JObject?> on JSet<E> {
  Set<Object?> toDeepDartSet({
    Object? Function(JObject?) convertOther = _defaultDartConverter,
  }) =>
      map((e) => toDartObject(e, convertOther: convertOther)).toSet();
}

extension JMapToDartMap<K extends JObject?, V extends JObject?> on JMap<K, V> {
  Map<Object?, Object?> toDeepDartMap({
    Object? Function(JObject?) convertOther = _defaultDartConverter,
  }) =>
      Map.fromEntries(
        entries.map(
          (e) => MapEntry(
            toDartObject(e.key, convertOther: convertOther),
            toDartObject(e.value, convertOther: convertOther),
          ),
        ),
      );
}
