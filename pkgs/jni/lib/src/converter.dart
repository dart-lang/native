import 'core_bindings.dart';
import 'jarray.dart';
import 'jobject.dart';
import 'lang/jnumber.dart';
import 'lang/jstring.dart';
import 'util/jlist.dart';
import 'util/jmap.dart';
import 'util/jset.dart';

JObject _defaultJObjectConverter(Object o) =>
    throw UnimplementedError('No conversion for $o');

/// Converts a Dart object to the corresponding Java object.
///
/// This supports basic types like `int`, `double`, and `String`. It also works
/// on collections, and recursively converts their elements.
///
/// If [dartObject] is not one of the recognized types, [convertOther] is
/// called. If [convertOther] is not provided, an error is thrown.
JObject toJObject(
  Object dartObject, {
  JObject Function(Object) convertOther = _defaultJObjectConverter,
}) =>
    switch (dartObject) {
      JObject() => dartObject,
      bool() => dartObject.toJBoolean(),
      int() => dartObject.toJLong(),
      double() => dartObject.toJDouble(),
      String() => dartObject.toJString(),
      List<Object?>() => dartObject.toJListDeep(
          convertOther: convertOther,
        ),
      Set<Object?>() => dartObject.toJSetDeep(
          convertOther: convertOther,
        ),
      Map<Object?, Object?>() => dartObject.toJMapDeep(
          convertOther: convertOther,
        ),
      _ => convertOther(dartObject),
    };

/// Converts a nullable Dart object to the corresponding Java object.
///
/// See [toJObject]. This additionally returns `null` if [dartObject] is
/// `null`.
JObject? toNullableJObject(
  Object? dartObject, {
  JObject Function(Object) convertOther = _defaultJObjectConverter,
}) {
  if (dartObject == null) {
    return null;
  }

  return toJObject(
    dartObject,
    convertOther: convertOther,
  );
}

extension DartListToJList on List<Object?> {
  /// Deep converts this Dart [List] to a [JList].
  JList<JObject?> toJListDeep({
    JObject Function(Object) convertOther = _defaultJObjectConverter,
  }) =>
      map(
        (o) => toNullableJObject(
          o,
          convertOther: convertOther,
        ),
      ).toJList();
}

extension DartListToJArray on List<Object?> {
  /// Deep converts this Dart [List] to a [JArray].
  JArray<JObject?> toJArrayDeep({
    JObject Function(Object) convertOther = _defaultJObjectConverter,
  }) =>
      JArray.of(
        JObject.type,
        map(
          (o) => toNullableJObject(
            o,
            convertOther: convertOther,
          ),
        ),
      );
}

extension DartSetToJSet on Set<Object?> {
  /// Deep converts this Dart [Set] to a [JSet].
  JSet<JObject?> toJSetDeep({
    JObject Function(Object) convertOther = _defaultJObjectConverter,
  }) =>
      map(
        (o) => toNullableJObject(
          o,
          convertOther: convertOther,
        ),
      ).toJSet();
}

extension DartMapToJMap on Map<Object?, Object?> {
  /// Deep converts this Dart [Map] to a [JMap].
  JMap<JObject?, JObject?> toJMapDeep({
    JObject Function(Object) convertOther = _defaultJObjectConverter,
  }) =>
      map(
        (key, value) => MapEntry(
          toNullableJObject(
            key,
            convertOther: convertOther,
          ),
          toNullableJObject(
            value,
            convertOther: convertOther,
          ),
        ),
      ).toJMap();
}

Object _defaultDartConverter(JObject o) => o;

/// Converts a nullable Java object to the corresponding Dart object.
///
/// See [toDartObject]. This additionally returns `null` if [javaObject] is
/// `null`.
Object? toNullableDartObject(
  JObject? javaObject, {
  Object Function(JObject) convertOther = _defaultDartConverter,
}) {
  if (javaObject == null) {
    return null;
  }

  return toDartObject(
    javaObject,
    convertOther: convertOther,
  );
}

/// Converts a Java object to the corresponding Dart object.
///
/// This supports boxed primitive values, strings, collections, and arrays.
/// Collections and object arrays are recursively converted.
///
/// If [javaObject] is not one of the recognized types, [convertOther] is
/// called. If [convertOther] is not provided, [javaObject] is returned
/// directly.
Object toDartObject(
  JObject javaObject, {
  Object Function(JObject) convertOther = _defaultDartConverter,
}) {
  if (javaObject.isA(JBoolean.type)) {
    return (javaObject as JBoolean).booleanValue();
  }

  if (javaObject.isA(JByte.type)) {
    return (javaObject as JByte).longValue();
  }

  if (javaObject.isA(JShort.type)) {
    return (javaObject as JShort).longValue();
  }

  if (javaObject.isA(JInteger.type)) {
    return (javaObject as JInteger).longValue();
  }

  if (javaObject.isA(JLong.type)) {
    return (javaObject as JLong).longValue();
  }

  if (javaObject.isA(JFloat.type)) {
    return (javaObject as JFloat).doubleValue();
  }

  if (javaObject.isA(JDouble.type)) {
    return (javaObject as JDouble).doubleValue();
  }

  if (javaObject.isA(JString.type)) {
    return (javaObject as JString).toDartString();
  }

  if (javaObject.isA(JList.type)) {
    return (javaObject as JList<JObject?>).toDartList(
      convertOther: convertOther,
    );
  }

  if (javaObject.isA(JSet.type)) {
    return (javaObject as JSet<JObject?>).toDartSet(
      convertOther: convertOther,
    );
  }

  if (javaObject.isA(JMap.type)) {
    return (javaObject as JMap<JObject?, JObject?>).toDartMap(
      convertOther: convertOther,
    );
  }

  if (javaObject.isA(JBooleanArray.type)) {
    return (javaObject as JBooleanArray).asDart().toList();
  }

  if (javaObject.isA(JByteArray.type)) {
    return (javaObject as JByteArray).asDart().toList();
  }

  if (javaObject.isA(JCharArray.type)) {
    return (javaObject as JCharArray).asDart().toList();
  }

  if (javaObject.isA(JShortArray.type)) {
    return (javaObject as JShortArray).asDart().toList();
  }

  if (javaObject.isA(JIntArray.type)) {
    return (javaObject as JIntArray).asDart().toList();
  }

  if (javaObject.isA(JLongArray.type)) {
    return (javaObject as JLongArray).asDart().toList();
  }

  if (javaObject.isA(JFloatArray.type)) {
    return (javaObject as JFloatArray).asDart().toList();
  }

  if (javaObject.isA(JDoubleArray.type)) {
    return (javaObject as JDoubleArray).asDart().toList();
  }

  if (javaObject.isA(JArray.type(JObject.type))) {
    return (javaObject as JArray<JObject?>).toDartList(
      convertOther: convertOther,
    );
  }

  return convertOther(javaObject);
}

extension JListToDartList on JList<JObject?> {
  /// Deep converts this [JList] to a Dart [List].
  ///
  /// This creates a new [List], converts all the [JList] elements, and adds
  /// them to the [List]. If you only need iteration and element access,
  /// [asDart] is much more efficient.
  List<Object?> toDartList({
    Object Function(JObject) convertOther = _defaultDartConverter,
  }) =>
      asDart()
          .map(
            (o) => toNullableDartObject(
              o,
              convertOther: convertOther,
            ),
          )
          .toList();
}

extension JArrayToDartList on JArray<JObject?> {
  /// Deep converts this [JArray] to a Dart [List].
  ///
  /// This creates a new [List], converts all the [JArray] elements, and adds
  /// them to the [List]. If you only need iteration and element access,
  /// [asDart] is much more efficient.
  List<Object?> toDartList({
    Object Function(JObject) convertOther = _defaultDartConverter,
  }) =>
      asDart()
          .map(
            (o) => toNullableDartObject(
              o,
              convertOther: convertOther,
            ),
          )
          .toList();
}

extension JSetToDartSet on JSet<JObject?> {
  /// Deep converts this [JSet] to a Dart [Set].
  ///
  /// This creates a new [Set], converts all the [JSet] elements, and adds
  /// them to the [Set]. If you only need iteration and element access,
  /// [asDart] is much more efficient.
  Set<Object?> toDartSet({
    Object Function(JObject) convertOther = _defaultDartConverter,
  }) =>
      asDart()
          .map(
            (o) => toNullableDartObject(
              o,
              convertOther: convertOther,
            ),
          )
          .toSet();
}

extension JMapToDartMap on JMap<JObject?, JObject?> {
  /// Deep converts this [JMap] to a Dart [Map].
  ///
  /// This creates a new [Map], converts all the [JMap] keys and values, and
  /// adds them to the [Map]. If you only need iteration and element access,
  /// [asDart] is much more efficient.
  Map<Object?, Object?> toDartMap({
    Object Function(JObject) convertOther = _defaultDartConverter,
  }) =>
      asDart().map(
        (key, value) => MapEntry(
          toNullableDartObject(
            key,
            convertOther: convertOther,
          ),
          toNullableDartObject(
            value,
            convertOther: convertOther,
          ),
        ),
      );
}
