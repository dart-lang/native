// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../model/class_info.dart';
import '../model/dart_type.dart';
import '../model/property_info.dart';

class PropertyGenerator {
  final PropertyInfo property;

  PropertyGenerator(this.property);

  String generate() {
    final buffer = StringBuffer();
    final dartType = property.type;
    final fieldName = property.name;
    final jsonKey = property.jsonKey;
    final setterName = property.setterPrivate ? '_$fieldName' : fieldName;
    final sortOnKey = property.setterPrivate ? '' : 'json.sortOnKey();';

    if (property.isOverride) {
      buffer.writeln('@override');
    }

    switch (dartType) {
      case ClassDartType():
        _generateClassTypeGetterSetter(
          buffer,
          property,
          dartType,
          jsonKey,
          setterName,
          sortOnKey,
        );
      case SimpleDartType():
        _generateSimpleTypeGetterSetter(
          buffer,
          property,
          dartType,
          jsonKey,
          setterName,
          sortOnKey,
        );
      case MapDartType():
        _generateMapTypeGetterSetter(
          buffer,
          property,
          dartType,
          jsonKey,
          setterName,
          sortOnKey,
        );
      case ListDartType():
        _generateListTypeGetterSetter(
          buffer,
          property,
          dartType,
          jsonKey,
          setterName,
          sortOnKey,
        );
      case UriDartType():
        _generateUriTypeGetterSetter(
          buffer,
          property,
          dartType,
          jsonKey,
          setterName,
          sortOnKey,
        );
    }

    return buffer.toString();
  }

  void _generateClassTypeGetterSetter(
    StringBuffer buffer,
    PropertyInfo property,
    ClassDartType dartType,
    String jsonKey,
    String setterName,
    String sortOnKey,
  ) {
    final classInfo = dartType.classInfo;
    final classType = classInfo.name;
    final fieldName = property.name;
    final validateName = property.validateName;
    final required = property.isRequired;

    switch (classInfo) {
      case EnumClassInfo():
        final dartStringType = StringDartType(isNullable: !required);
        final earlyReturn =
            required ? '' : 'if(jsonValue == null) return null;';

        buffer.writeln('''
$dartType get $fieldName {
  final jsonValue = _reader.get<$dartStringType>('$jsonKey'); $earlyReturn
  return $classType.fromJson(jsonValue);
}
''');
        if (!property.isOverride) {
          final setter = setOrRemove(dartStringType, jsonKey, '.name');
          buffer.writeln('''
set $setterName($dartType value) {
  $setter
  $sortOnKey
}

List<String> $validateName() => _reader.validate<$dartStringType>('$jsonKey');
''');
        }

      case NormalClassInfo():
        final earlyReturn =
            required ? '' : 'if(jsonValue == null) return null;';
        final jsonRead = required ? 'map\$' : 'optionalMap';
        buffer.writeln('''
$dartType get $fieldName {
  final jsonValue = _reader.$jsonRead('$jsonKey'); $earlyReturn
  return $classType.fromJson(jsonValue, path: [...path, '$jsonKey']);
}
''');
        if (!property.isOverride) {
          final setter = setOrRemove(dartType, jsonKey, '.json');
          buffer.writeln('''
set $setterName($dartType value) {
  $setter
  $sortOnKey
}
''');
          if (required) {
            buffer.writeln('''
List<String> $validateName() {
  final mapErrors = _reader.validate<Map<String, Object?>>('$jsonKey');
  if (mapErrors.isNotEmpty) {
    return mapErrors;
  }
  return $fieldName.validate();
}
''');
          } else {
            buffer.writeln('''
List<String> $validateName() {
  final mapErrors = _reader.validate<Map<String, Object?>?>('$jsonKey');
  if (mapErrors.isNotEmpty) {
    return mapErrors;
  }
  return $fieldName?.validate() ?? [];
}
''');
          }
        }
    }
  }

  void _generateSimpleTypeGetterSetter(
    StringBuffer buffer,
    PropertyInfo property,
    SimpleDartType dartType,
    String jsonKey,
    String setterName,
    String sortOnKey,
  ) {
    final fieldName = property.name;
    final validateName = property.validateName;

    buffer.writeln('''
$dartType get $fieldName => _reader.get<$dartType>('$jsonKey');

set $setterName($dartType value) {
  json.setOrRemove('$jsonKey', value);
  $sortOnKey
}

List<String> $validateName() => _reader.validate<$dartType>('$jsonKey');
''');
  }

  void _generateMapTypeGetterSetter(
    StringBuffer buffer,
    PropertyInfo property,
    MapDartType dartType,
    String jsonKey,
    String setterName,
    String sortOnKey,
  ) {
    if (property.isRequired) {
      throw UnimplementedError('Expected an optional property.');
    }
    final fieldName = property.name;
    final validateName = property.validateName;
    final valueType = dartType.valueType;

    switch (valueType) {
      case MapDartType():
        buffer.writeln('''
$dartType get $fieldName =>
  _reader.optionalMap<${dartType.valueType}>('$jsonKey');

set $setterName($dartType value) {
  json.setOrRemove('$jsonKey', value);
  $sortOnKey
}

List<String> $validateName() =>
  _reader.validateOptionalMap<${dartType.valueType}>('$jsonKey');
''');
      case ListDartType():
        final itemType = valueType.itemType;
        final typeName = itemType.toString();
        buffer.writeln('''
$dartType get $fieldName {
  final jsonValue = _reader.optionalMap('$jsonKey');
  if (jsonValue == null) {
    return null;
  }
  final result = <String, List<Asset>>{};
  for (final MapEntry(:key, :value) in jsonValue.entries) {
    var index = 0;
    result[key] = [
      for (final item in value as List<Object?>)
        $typeName.fromJson(
          item as $jsonObjectDartType,
          path: [...path, key, index++],
        ),
    ];
  }
  return result;
}

set $setterName($dartType value) {
  if (value == null) {
    json.remove('$jsonKey');
  } else {
    json['$jsonKey'] = {
      for (final MapEntry(:key, :value) in value.entries)
        key : [
          for (final item in value)
            item.json,
        ],
    };
  }
  $sortOnKey
}

List<String> $validateName() {
  final mapErrors = _reader.validateOptionalMap('$jsonKey');
  if (mapErrors.isNotEmpty) {
    return mapErrors;
  }
  final jsonValue = _reader.optionalMap(
    '$jsonKey',
  );
  if (jsonValue == null) {
    return [];
  }
  final result = <String>[];
  for (final list in $fieldName!.values) {
    for (final element in list) {
      result.addAll(element.validate());
    }
  }
  return result;
}
''');
      case SimpleDartType():
        switch (valueType.typeName) {
          case 'Object':
            if (valueType.isNullable) {
              buffer.writeln('''
$dartType get $fieldName => _reader.optionalMap('$jsonKey');

set $setterName($dartType value) {
  json.setOrRemove('$jsonKey', value);
  $sortOnKey
}

List<String> $validateName() => _reader.validateOptionalMap('$jsonKey');
''');
            } else {
              throw UnimplementedError(valueType.toString());
            }
          default:
            throw UnimplementedError(valueType.toString());
        }
      default:
        throw UnimplementedError(valueType.toString());
    }
  }

  void _generateListTypeGetterSetter(
    StringBuffer buffer,
    PropertyInfo property,
    ListDartType dartType,
    String jsonKey,
    String setterName,
    String sortOnKey,
  ) {
    final fieldName = property.name;
    final validateName = property.validateName;
    final itemType = dartType.itemType;
    final typeName = itemType.toString();
    final required = property.isRequired;

    switch (itemType) {
      case ClassDartType():
        if (required) {
          throw UnimplementedError('Expected an optional property.');
        }
        buffer.writeln('''
$dartType get $fieldName {
  var index = 0;
  return _reader.optionalListParsed(
    '$jsonKey',
    (e) => $typeName.fromJson(
      e as Map<String, Object?>,
      path: [...path, '$jsonKey', index++],
    ),
  );
}

set $setterName($dartType value) {
  if (value == null) {
    json.remove('$jsonKey');
  }
  else {
    json['$jsonKey'] = [
      for (final item in value)
        item.json
    ];
  }
  $sortOnKey
}

List<String> $validateName() {
  final listErrors = _reader.validateOptionalList<Map<String, Object?>>(
    '$jsonKey',
  );
  if (listErrors.isNotEmpty) {
    return listErrors;
  }
  final elements = $fieldName;
  if (elements == null) {
    return [];
  }
  return [for (final element in elements) ...element.validate()];
}
''');
      case SimpleDartType():
        switch (itemType.typeName) {
          case 'String':
            final jsonRead = required ? 'stringList' : 'optionalStringList';
            final jsonValidate =
                required ? 'validateStringList' : 'validateOptionalStringList';
            final setter = setOrRemove(dartType, jsonKey);
            buffer.writeln('''
$dartType get $fieldName => _reader.$jsonRead('$jsonKey');

set $setterName($dartType value) {
  $setter
  $sortOnKey
}

List<String> $validateName() => _reader.$jsonValidate('$jsonKey');
''');

          default:
            throw UnimplementedError(itemType.toString());
        }
      case UriDartType():
        final jsonRead = required ? 'pathList' : 'optionalPathList';
        final jsonValidate =
            required ? 'validatePathList' : 'validateOptionalPathList';
        final setter = setOrRemove(dartType, jsonKey, '.toJson()');
        buffer.writeln('''
$dartType get $fieldName => _reader.$jsonRead('$jsonKey');

set $setterName($dartType value) {
  $setter
  $sortOnKey
}

List<String> $validateName() => _reader.$jsonValidate('$jsonKey');
''');
      default:
        throw UnimplementedError(itemType.toString());
    }
  }

  void _generateUriTypeGetterSetter(
    StringBuffer buffer,
    PropertyInfo property,
    UriDartType dartType,
    String jsonKey,
    String setterName,
    String sortOnKey,
  ) {
    final fieldName = property.name;
    final validateName = property.validateName;
    final required = property.isRequired;
    final jsonRead = required ? r'path$' : 'optionalPath';
    final jsonValidate = required ? r'validatePath' : 'validateOptionalPath';
    final setter = setOrRemove(dartType, jsonKey, '.toFilePath()');
    buffer.writeln('''
$dartType get $fieldName => _reader.$jsonRead('$jsonKey');

set $setterName($dartType value) {
  $setter
  $sortOnKey
}

List<String> $validateName() => _reader.$jsonValidate('$jsonKey');
''');
  }

  /// If the type is nullable use `setOrRemove` otherwise just set.
  ///
  /// If provided [expression] is nullably applied to `value`.
  static String setOrRemove(
    DartType type,
    String jsonKey, [
    String? expression,
  ]) {
    expression ??= '';
    if (type.isNullable) {
      if (expression.isNotEmpty) {
        expression = '?$expression';
      }
      return "json.setOrRemove('$jsonKey', value$expression);";
    }
    return "json['$jsonKey'] = value$expression;";
  }

  /// The Dart type for a JSON object after parsing.
  static const jsonObjectDartType = MapDartType(
    valueType: ObjectDartType(isNullable: true),
    isNullable: false,
  );
}
