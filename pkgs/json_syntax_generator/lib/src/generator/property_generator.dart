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
    final classType = classInfo.className;
    final fieldName = property.name;
    final validateName = property.validateName;
    final isNullable = property.type.isNullable;

    switch (classInfo) {
      case EnumClassInfo():
        final dartStringType = StringDartType(isNullable: isNullable);
        final earlyReturn = isNullable
            ? 'if(jsonValue == null) return null;'
            : '';

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
        final earlyReturn = isNullable
            ? 'if(jsonValue == null) return null;'
            : '';
        final jsonRead = isNullable ? 'optionalMap' : r'map$';
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
          final mapType = MapDartType(
            valueType: const ObjectDartType(isNullable: true),
            isNullable: dartType.isNullable,
          );
          final questionMark = isNullable ? '?' : '';
          final orEmptyList = isNullable ? ' ?? []' : '';
          buffer.writeln('''
List<String> $validateName() {
  final mapErrors = _reader.validate<$mapType>('$jsonKey');
  if (mapErrors.isNotEmpty) {
    return mapErrors;
  }
  return $fieldName$questionMark.validate() $orEmptyList;
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
    final validateName = property.validateName;

    if (dartType is StringDartType && dartType.pattern != null) {
      final String readerGetter, readerValidate, setterGuard;
      if (dartType.isNullable) {
        readerGetter = 'optionalString';
        readerValidate = 'validateOptionalString';
        setterGuard = 'value != null && ';
      } else {
        readerGetter = 'string';
        readerValidate = 'validateString';
        setterGuard = '';
      }

      final pattern = dartType.pattern!;
      buffer.writeln('''
static final _${fieldName}Pattern = RegExp(r'${pattern.pattern}');

$dartType get $fieldName => _reader.$readerGetter('$jsonKey', _${fieldName}Pattern);

set $setterName($dartType value) {
  if ($setterGuard !_${fieldName}Pattern.hasMatch(value)) {
    throw ArgumentError.value(
      value,
      'value',
      'Value does not satisify pattern: \${_${fieldName}Pattern.pattern}.',
    );
  }
  json.setOrRemove('$jsonKey', value);
  $sortOnKey
}

List<String> $validateName() => _reader.$readerValidate('$jsonKey', _${fieldName}Pattern);
''');
      return;
    }

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
    if (!property.type.isNullable) {
      throw UnimplementedError('Expected a nullable property.');
    }
    final fieldName = property.name;
    final validateName = property.validateName;
    final valueType = dartType.valueType;

    final pattern = (dartType.keyType as StringDartType).pattern;
    var keyPattern = '';

    if (pattern != null) {
      buffer.writeln('''
static final _${fieldName}KeyPattern = RegExp(r'${pattern.pattern}');
''');
      keyPattern = 'keyPattern: _${fieldName}KeyPattern,';
    }

    switch (valueType) {
      case MapDartType():
        buffer.writeln('''
$dartType get $fieldName =>
  _reader.optionalMap<${dartType.valueType}>('$jsonKey', $keyPattern);

set $setterName($dartType value) {
  _checkArgumentMapKeys(value, $keyPattern);
  json.setOrRemove('$jsonKey', value);
  $sortOnKey
}

List<String> $validateName() =>
  _reader.validateOptionalMap<${dartType.valueType}>('$jsonKey', $keyPattern);
''');
      case ListDartType():
        final itemType = valueType.itemType;
        final typeName = itemType.toString();
        buffer.writeln('''
$dartType get $fieldName {
  final jsonValue = _reader.optionalMap('$jsonKey', $keyPattern);
  if (jsonValue == null) {
    return null;
  }
  final result = <String, List<$typeName>>{};
  for (final MapEntry(:key, :value) in jsonValue.entries) {
    result[key] = [
      for (final (index, item) in (value as List<Object?>).indexed)
        $typeName.fromJson(
          item as $jsonObjectDartType,
          path: [...path, key, index],
        ),
    ];
  }
  return result;
}

set $setterName($dartType value) {
  _checkArgumentMapKeys(value, $keyPattern);
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
  final mapErrors = _reader.validateOptionalMap('$jsonKey', $keyPattern);
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
      case ClassDartType():
        final itemType = valueType;
        final typeName = itemType.toString();
        buffer.writeln('''
$dartType get $fieldName {
  final jsonValue = _reader.optionalMap('$jsonKey', $keyPattern);
  if (jsonValue == null) {
    return null;
  }
  return {
    for (final MapEntry(:key, :value) in jsonValue.entries)
      key: $typeName.fromJson(
        value as $jsonObjectDartType,
        path: [...path, key],
      )
  };
}

set $setterName($dartType value) {
  _checkArgumentMapKeys(value, $keyPattern);
  if (value == null) {
    json.remove('$jsonKey');
  } else {
    json['$jsonKey'] = {
      for (final MapEntry(:key, :value) in value.entries) key: value.json,
    };
  }
  $sortOnKey
}

List<String> $validateName() {
  final mapErrors = _reader.validateOptionalMap('$jsonKey', $keyPattern);
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
    for (final value in $fieldName!.values) {
      result.addAll(value.validate());
    }
  return result;
}
''');
      case SimpleDartType():
        if (valueType.isNullable) {
          if (valueType is StringDartType && valueType.pattern != null) {
            buffer.writeln('''
static final _${fieldName}ValuePattern = RegExp(r'${valueType.pattern!.pattern}');

$dartType get $fieldName {
  final value = _reader.optionalMap<${dartType.valueType}>('$jsonKey', $keyPattern);
  if (value == null) {
    return value;
  }
  final valueErrors = _reader.validateMapStringElements(
    value,
    '$jsonKey',
    valuePattern: _${fieldName}ValuePattern,
  );
  if (valueErrors.isNotEmpty) {
    throw FormatException(valueErrors.join('\\n'));
  }
  return value;
}

set $setterName($dartType value) {
  _checkArgumentMapKeys(value, $keyPattern);
  _checkArgumentMapStringElements(
    value,
    valuePattern: _${fieldName}ValuePattern,
  );
  json.setOrRemove('$jsonKey', value);
  $sortOnKey
}

List<String> $validateName() {
  final mapErrors = _reader.validateOptionalMap<${dartType.valueType}>(
    '$jsonKey',
    $keyPattern
  );
  if (mapErrors.isNotEmpty) {
    return mapErrors;
  }
  final value = _reader.optionalMap<${dartType.valueType}>('$jsonKey');
  if (value == null) {
    return [];
  }
  return _reader.validateMapStringElements(
    value,
    '$jsonKey',
    valuePattern: _${fieldName}ValuePattern,
  );
}
''');
          } else {
            buffer.writeln('''
$dartType get $fieldName => _reader.optionalMap<${dartType.valueType}>('$jsonKey', $keyPattern);

set $setterName($dartType value) {
  _checkArgumentMapKeys(value, $keyPattern);
  json.setOrRemove('$jsonKey', value);
  $sortOnKey
}

List<String> $validateName() => _reader.validateOptionalMap<${dartType.valueType}>('$jsonKey', $keyPattern);
''');
          }
        } else {
          buffer.writeln('''
$dartType get $fieldName => _reader.map\$<${dartType.valueType}>('$jsonKey', $keyPattern);

set $setterName($dartType value) {
  _checkArgumentMapKeys(value, $keyPattern);
  json['$jsonKey'] = value;
  $sortOnKey
}

List<String> $validateName() => _reader.validateMap<${dartType.valueType}>('$jsonKey', $keyPattern);
''');
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
    final isNullable = property.type.isNullable;

    switch (itemType) {
      case ClassDartType():
        if (isNullable) {
          buffer.writeln('''
$dartType get $fieldName {
  final jsonValue = _reader.optionalList('$jsonKey');
  if (jsonValue == null) return null;
  return [
    for (final (index, element) in jsonValue.indexed)
      $typeName.fromJson(
        element as Map<String, Object?>,
        path: [...path, '$jsonKey', index],
      ),
  ];
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
        } else {
          buffer.writeln('''
$dartType get $fieldName {
  final jsonValue = _reader.list('$jsonKey');
  return [
    for (final (index, element) in jsonValue.indexed)
      $typeName.fromJson(
        element as Map<String, Object?>,
        path: [...path, '$jsonKey', index],
      ),
  ];
}

set $setterName($dartType value) {
  json['$jsonKey'] = [
    for (final item in value)
      item.json
  ];
  $sortOnKey
}

List<String> $validateName() {
  final listErrors = _reader.validateList<Map<String, Object?>>(
    '$jsonKey',
  );
  if (listErrors.isNotEmpty) {
    return listErrors;
  }
  final elements = $fieldName;
  return [for (final element in elements) ...element.validate()];
}
''');
        }
      case SimpleDartType():
        switch (itemType.typeName) {
          case 'String':
            final jsonRead = isNullable ? 'optionalStringList' : 'stringList';
            final jsonValidate = isNullable
                ? 'validateOptionalStringList'
                : 'validateStringList';
            final setter = setOrRemove(dartType, jsonKey);
            buffer.writeln('''
$dartType get $fieldName => _reader.$jsonRead('$jsonKey');

set $setterName($dartType value) {
  $setter
  $sortOnKey
}

List<String> $validateName() => _reader.$jsonValidate('$jsonKey');
''');

          case 'Object':
          case 'int':
            final jsonRead = isNullable
                ? 'optionalList<$itemType>'
                : 'list<$itemType>';
            final jsonValidate = isNullable
                ? 'validateOptionalList<$itemType>'
                : 'validateList<$itemType>';
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
        final jsonRead = isNullable ? 'optionalPathList' : 'pathList';
        final jsonValidate = isNullable
            ? 'validateOptionalPathList'
            : 'validatePathList';
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
    final isNullable = property.type.isNullable;
    final jsonRead = isNullable ? 'optionalPath' : r'path$';
    final jsonValidate = isNullable ? 'validateOptionalPath' : 'validatePath';
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
