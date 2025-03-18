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
    final required = property.isRequired;

    switch (classInfo) {
      case EnumClassInfo():
        final dartStringType = StringDartType(isNullable: !required);
        final earlyReturn =
            required ? '' : 'if(jsonValue == null) return null;';

        buffer.writeln('''
$dartType get $fieldName {
  final jsonValue = json.get<$dartStringType>('$jsonKey'); $earlyReturn
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
''');
        }

      case NormalClassInfo():
        final earlyReturn =
            required ? '' : 'if(jsonValue == null) return null;';
        final jsonRead = required ? 'map\$' : 'optionalMap';
        buffer.writeln('''
$dartType get $fieldName {
  final jsonValue = json.$jsonRead('$jsonKey'); $earlyReturn
  return $classType.fromJson(jsonValue);
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

    buffer.writeln('''
$dartType get $fieldName => json.get<$dartType>('$jsonKey');

set $setterName($dartType value) {
  json.setOrRemove('$jsonKey', value);
  $sortOnKey
}
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
    final valueType = dartType.valueType;

    switch (valueType) {
      case MapDartType():
        buffer.writeln('''
$dartType get $fieldName =>
  json.optionalMap<${dartType.valueType}>('$jsonKey');

set $setterName($dartType value) {
  json.setOrRemove('$jsonKey', value);
  $sortOnKey
}
''');
      case ListDartType():
        final itemType = valueType.itemType;
        final typeName = itemType.toString();
        buffer.writeln('''
$dartType get $fieldName {
  final map_ = json.optionalMap('$jsonKey');
  if(map_ == null){
    return null;
  }
  return {
    for (final MapEntry(:key, :value) in map_.entries)
      key : [
        for (final item in value as List<Object?>)
          $typeName.fromJson(item as $jsonObjectDartType)
      ],
  };
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
''');
      case SimpleDartType():
        switch (valueType.typeName) {
          case 'Object':
            if (valueType.isNullable) {
              buffer.writeln('''
$dartType get $fieldName => json.optionalMap('$jsonKey');

set $setterName($dartType value) {
  json.setOrRemove('$jsonKey', value);
  $sortOnKey
}
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
    final itemType = dartType.itemType;
    final typeName = itemType.toString();
    final required = property.isRequired;

    switch (itemType) {
      case ClassDartType():
        if (required) {
          throw UnimplementedError('Expected an optional property.');
        }
        buffer.writeln('''
$dartType get $fieldName =>
    json.optionalListParsed('$jsonKey', (e) => $typeName.fromJson(e as Map<String, Object?>));

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
''');
      case SimpleDartType():
        switch (itemType.typeName) {
          case 'String':
            final jsonRead = required ? 'stringList' : 'optionalStringList';
            final setter = setOrRemove(dartType, jsonKey);
            buffer.writeln('''
$dartType get $fieldName => json.$jsonRead('$jsonKey');

set $setterName($dartType value) {
  $setter
  $sortOnKey
}
''');

          default:
            throw UnimplementedError(itemType.toString());
        }
      case UriDartType():
        final jsonRead = required ? 'pathList' : 'optionalPathList';
        final setter = setOrRemove(dartType, jsonKey, '.toJson()');
        buffer.writeln('''
$dartType get $fieldName => json.$jsonRead('$jsonKey');

set $setterName($dartType value) {
  $setter
  $sortOnKey
}
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
    final required = property.isRequired;
    final jsonRead = required ? 'path' : 'optionalPath';
    final setter = setOrRemove(dartType, jsonKey, '.toFilePath()');
    buffer.writeln('''
$dartType get $fieldName => json.$jsonRead('$jsonKey');

set $setterName($dartType value) {
  $setter
  $sortOnKey
}
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
