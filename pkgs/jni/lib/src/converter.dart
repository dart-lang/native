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
      List<Object?>() => dartObject.toJList(
          convertOther: convertOther,
        ),
      Set<Object?>() => dartObject.toJSet(
          convertOther: convertOther,
        ),
      Map<Object?, Object?>() => dartObject.toJMap(
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

extension DartIterableToJList on Iterable<Object?> {
  /// Converts this Dart [Iterable] to a [JList].
  ///
  /// Elements are recursively converted to Java objects.
  JList<JObject?> toJList({
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
  /// Converts this Dart [List] to a [JArray].
  ///
  /// Elements are recursively converted to Java objects.
  JArray<JObject?> toJArray({
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

extension DartIterableToJSet on Iterable<Object?> {
  /// Converts this Dart [Iterable] to a [JSet].
  ///
  /// Elements are recursively converted to Java objects.
  JSet<JObject?> toJSet({
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
  /// Converts this Dart [Map] to a [JMap].
  ///
  /// Keys and values are recursively converted to Java objects.
  JMap<JObject?, JObject?> toJMap({
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
  bool releaseOriginal = false,
}) {
  if (javaObject == null) {
    return null;
  }

  return toDartObject(
    javaObject,
    convertOther: convertOther,
    releaseOriginal: releaseOriginal,
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
///
/// If [releaseOriginal] is `true`, [javaObject] is released after conversion
/// unless [javaObject] itself is returned directly.
Object toDartObject(
  JObject javaObject, {
  Object Function(JObject) convertOther = _defaultDartConverter,
  bool releaseOriginal = false,
}) {
  Object? result;
  try {
    if (javaObject.isA(JBoolean.type)) {
      return result = (javaObject as JBoolean).booleanValue();
    }

    if (javaObject.isA(JByte.type)) {
      return result = (javaObject as JByte).longValue();
    }

    if (javaObject.isA(JShort.type)) {
      return result = (javaObject as JShort).longValue();
    }

    if (javaObject.isA(JInteger.type)) {
      return result = (javaObject as JInteger).longValue();
    }

    if (javaObject.isA(JLong.type)) {
      return result = (javaObject as JLong).longValue();
    }

    if (javaObject.isA(JFloat.type)) {
      return result = (javaObject as JFloat).doubleValue();
    }

    if (javaObject.isA(JDouble.type)) {
      return result = (javaObject as JDouble).doubleValue();
    }

    if (javaObject.isA(JString.type)) {
      return result = (javaObject as JString).toDartString();
    }

    if (javaObject.isA(JList.type)) {
      return result = (javaObject as JList<JObject?>).toDartList(
        convertOther: convertOther,
      );
    }

    if (javaObject.isA(JSet.type)) {
      return result = (javaObject as JSet<JObject?>).toDartSet(
        convertOther: convertOther,
      );
    }

    if (javaObject.isA(JMap.type)) {
      return result = (javaObject as JMap<JObject?, JObject?>).toDartMap(
        convertOther: convertOther,
      );
    }

    if (javaObject.isA(JBooleanArray.type)) {
      return result = (javaObject as JBooleanArray).asDart().toList();
    }

    if (javaObject.isA(JByteArray.type)) {
      return result = (javaObject as JByteArray).asDart().toList();
    }

    if (javaObject.isA(JCharArray.type)) {
      return result = (javaObject as JCharArray).asDart().toList();
    }

    if (javaObject.isA(JShortArray.type)) {
      return result = (javaObject as JShortArray).asDart().toList();
    }

    if (javaObject.isA(JIntArray.type)) {
      return result = (javaObject as JIntArray).asDart().toList();
    }

    if (javaObject.isA(JLongArray.type)) {
      return result = (javaObject as JLongArray).asDart().toList();
    }

    if (javaObject.isA(JFloatArray.type)) {
      return result = (javaObject as JFloatArray).asDart().toList();
    }

    if (javaObject.isA(JDoubleArray.type)) {
      return result = (javaObject as JDoubleArray).asDart().toList();
    }

    if (javaObject.isA(JArray.type(JObject.type))) {
      return result = (javaObject as JArray<JObject?>).toDartList(
        convertOther: convertOther,
      );
    }

    return result = convertOther(javaObject);
  } finally {
    if (releaseOriginal &&
        !identical(result, javaObject) &&
        !javaObject.isReleased) {
      javaObject.release();
    }
  }
}

extension JListToDartList on JList<JObject?> {
  /// Deep converts this [JList] to a Dart [List].
  ///
  /// This creates a new [List], converts all the [JList] elements, and adds
  /// them to the [List]. If you only need iteration and element access,
  /// [asDart] is much more efficient.
  ///
  /// If [releaseOriginal] is `true`, this [JList] is released after conversion.
  List<Object?> toDartList({
    Object Function(JObject) convertOther = _defaultDartConverter,
    bool releaseOriginal = false,
  }) {
    try {
      return iterator()!.use((iterator) {
        final result = <Object?>[];
        while (iterator.hasNext()) {
          result.add(
            toNullableDartObject(
              iterator.next(),
              convertOther: convertOther,
              releaseOriginal: true,
            ),
          );
        }
        return result;
      });
    } finally {
      if (releaseOriginal) {
        release();
      }
    }
  }
}

extension JArrayToDartList on JArray<JObject?> {
  /// Deep converts this [JArray] to a Dart [List].
  ///
  /// This creates a new [List], converts all the [JArray] elements, and adds
  /// them to the [List]. If you only need iteration and element access,
  /// [asDart] is much more efficient.
  ///
  /// If [releaseOriginal] is `true`, this [JArray] is released after
  /// conversion.
  List<Object?> toDartList({
    Object Function(JObject) convertOther = _defaultDartConverter,
    bool releaseOriginal = false,
  }) {
    try {
      final len = length;
      return [
        for (var i = 0; i < len; i++)
          toNullableDartObject(
            this[i],
            convertOther: convertOther,
            releaseOriginal: true,
          ),
      ];
    } finally {
      if (releaseOriginal) {
        release();
      }
    }
  }
}

extension JSetToDartSet on JSet<JObject?> {
  /// Deep converts this [JSet] to a Dart [Set].
  ///
  /// This creates a new [Set], converts all the [JSet] elements, and adds
  /// them to the [Set]. If you only need iteration and element access,
  /// [asDart] is much more efficient.
  ///
  /// If [releaseOriginal] is `true`, this [JSet] is released after conversion.
  Set<Object?> toDartSet({
    Object Function(JObject) convertOther = _defaultDartConverter,
    bool releaseOriginal = false,
  }) {
    try {
      return iterator()!.use((iterator) {
        final result = <Object?>{};
        while (iterator.hasNext()) {
          result.add(
            toNullableDartObject(
              iterator.next(),
              convertOther: convertOther,
              releaseOriginal: true,
            ),
          );
        }
        return result;
      });
    } finally {
      if (releaseOriginal) {
        release();
      }
    }
  }
}

extension JMapToDartMap on JMap<JObject?, JObject?> {
  /// Deep converts this [JMap] to a Dart [Map].
  ///
  /// This creates a new [Map], converts all the [JMap] keys and values, and
  /// adds them to the [Map]. If you only need iteration and element access,
  /// [asDart] is much more efficient.
  ///
  /// If [releaseOriginal] is `true`, this [JMap] is released after conversion.
  Map<Object?, Object?> toDartMap({
    Object Function(JObject) convertOther = _defaultDartConverter,
    bool releaseOriginal = false,
  }) {
    try {
      return keySet()!.use(
        (keys) => keys.iterator()!.use((iterator) {
          final result = <Object?, Object?>{};
          while (iterator.hasNext()) {
            final key = iterator.next();
            final JObject? value;
            final Object? dartKey;
            try {
              value = get(key);
            } catch (_) {
              key?.release();
              rethrow;
            }
            try {
              dartKey = toNullableDartObject(
                key,
                convertOther: convertOther,
                releaseOriginal: true,
              );
            } catch (_) {
              value?.release();
              rethrow;
            }
            final dartValue = toNullableDartObject(
              value,
              convertOther: convertOther,
              releaseOriginal: true,
            );
            result[dartKey] = dartValue;
          }
          return result;
        }),
      );
    } finally {
      if (releaseOriginal) {
        release();
      }
    }
  }
}
