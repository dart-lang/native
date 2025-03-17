// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../model/class_info.dart';
import '../model/dart_type.dart';
import '../model/property_info.dart';
import '../model/schema_info.dart';

/// Generates Dart code from a [SchemaInfo].
///
/// This is a simple code generator, all code generation decisions are already
/// made in the [schemaInfo] and its properties.
///
/// It supports the following features:
/// * Optional and required fields. Constructors and getters are generated with
///   the right nullability.
/// * Subclassing and tagged unions. A subtype hierarchy is generated and the
///   constructors call the parent constructor. For tagged unions, the field
///   identifying the subtype does not have to be provided in the constructor.
///   For normal subtyping all parent fields have to be supplied.
/// * Open enums. These are generated with `static const`s for the known values.
class SyntaxGenerator {
  final SchemaInfo schemaInfo;

  SyntaxGenerator(this.schemaInfo);

  String generate() {
    final buffer = StringBuffer();

    buffer.writeln('''
// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// This file is generated, do not edit.

import '../utils/json.dart';
''');

    for (final classInfo in schemaInfo.classes) {
      buffer.writeln(_generateClass(classInfo));
    }

    return buffer.toString();
  }

  String _generateClass(ClassInfo classInfo) {
    switch (classInfo) {
      case NormalClassInfo():
        return _generateNormalClass(classInfo);
      case EnumClassInfo():
        return _generateEnumClass(classInfo);
    }
  }

  String _generateNormalClass(NormalClassInfo classInfo) {
    final buffer = StringBuffer();
    final className = classInfo.name;
    final superclass = classInfo.superclass;
    final superclassName = superclass?.name;
    final properties = classInfo.properties;
    final identifyingSubtype = classInfo.taggedUnionKey;

    final constructorParams = <String>[];
    final setupParams = <String>[];
    final constructorSetterCalls = <String>[];
    final accessors = <String>[];
    final superParams = <String>[];

    final propertyNames =
        {
            for (final property in properties) property.name,
            if (superclass != null)
              for (final property in superclass.properties) property.name,
          }.toList()
          ..sort();
    for (final propertyName in propertyNames) {
      final superClassProperty = superclass?.getProperty(propertyName);
      final thisClassProperty = classInfo.getProperty(propertyName);
      final property = superClassProperty ?? thisClassProperty!;
      if (superClassProperty != null) {
        if (identifyingSubtype == null) {
          constructorParams.add(
            '${property.isRequired ? 'required ' : ''}super.${property.name}',
          );
        } else {
          superParams.add("type: '$identifyingSubtype'");
        }
      } else {
        final dartType = property.type;
        constructorParams.add(
          '${property.isRequired ? 'required ' : ''}$dartType ${property.name}',
        );
        setupParams.add(
          '${property.isRequired ? 'required' : ''} $dartType ${property.name}',
        );
        if (property.setterPrivate) {
          constructorSetterCalls.add('_${property.name} = ${property.name};');
        } else {
          constructorSetterCalls.add(
            'this.${property.name} = ${property.name};',
          );
        }
      }
      if (thisClassProperty != null) {
        accessors.add(_generateGetterAndSetter(thisClassProperty));
      }
    }

    if (constructorSetterCalls.isNotEmpty) {
      constructorSetterCalls.add('json.sortOnKey();');
    }

    if (superclass != null) {
      buffer.writeln('''
class $className extends $superclassName {
  $className.fromJson(super.json) : super.fromJson();

  $className(${_wrapBracesIfNotEmpty(constructorParams.join(', '))})
    : super(${superParams.join(',')}) 
    ${_wrapInBracesOrSemicolon(constructorSetterCalls.join('\n    '))}
''');
      if (setupParams.isNotEmpty) {
        buffer.writeln('''
  /// Setup all fields for [$className] that are not in
  /// [$superclassName].
  void setup (
    ${_wrapBracesIfNotEmpty(setupParams.join(','))}
  ) {
    ${constructorSetterCalls.join('\n')}
  }
''');
      }

      buffer.writeln('''
  ${accessors.join('\n')}

  @override
  String toString() => '$className(\$json)';
}
''');
    } else {
      buffer.writeln('''
class $className {
  final Map<String, Object?> json;

  $className.fromJson(this.json);

  $className(${_wrapBracesIfNotEmpty(constructorParams.join(', '))}) : json = {} {
    ${constructorSetterCalls.join('\n    ')}
  }

  ${accessors.join('\n')}

  @override
  String toString() => '$className(\$json)';
}
''');
    }

    if (identifyingSubtype != null) {
      buffer.writeln('''
extension ${className}Extension on $superclassName {
  bool get is$className => type == '$identifyingSubtype';

  $className get as$className => $className.fromJson(json);
}
''');
    }

    return buffer.toString();
  }

  String _generateEnumClass(EnumClassInfo classInfo) {
    final buffer = StringBuffer();
    final className = classInfo.name;
    final enumValues = classInfo.enumValues;

    final staticFinals = <String>[];
    for (final value in enumValues) {
      final valueName = value.name;
      final jsonValue = value.jsonValue;
      staticFinals.add(
        'static const $valueName = $className._(\'$jsonValue\');',
      );
    }

    buffer.writeln('''
class $className {
  final String name;

  const $className._(this.name);

  ${staticFinals.join('\n\n')}

  static const List<$className> values = [
    ${enumValues.map((e) => e.name).join(',')}
  ];

  static final Map<String, $className> _byName = {
    for (final value in values) value.name: value,
  };

  $className.unknown(this.name) : assert(!_byName.keys.contains(name));

  factory $className.fromJson(String name) {
    final knownValue = _byName[name];
    if(knownValue != null) {
      return knownValue;
    }
    return $className.unknown(name);
  }

  bool get isKnown => _byName[name] != null;

  @override
  String toString() => name;
}
''');
    return buffer.toString();
  }

  String _generateGetterAndSetter(PropertyInfo property) {
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
        if (required) {
          buffer.writeln('''
$dartType get $fieldName => $classType.fromJson( json.string('$jsonKey') );
''');
          if (!property.isOverride) {
            buffer.writeln('''
set $setterName($dartType value) {
  json['$jsonKey'] = value.name;
}
''');
          }
        } else {
          buffer.writeln('''
$dartType get $fieldName {
  final string = json.optionalString('$jsonKey');
  if(string == null) return null;
  return $classType.fromJson(string);
}
''');
          if (!property.isOverride) {
            buffer.writeln('''
set $setterName($dartType value) {
  if (value == null) {
    json.remove('$jsonKey');
  }
  else {
    json['$jsonKey'] = value.name;
  }
  $sortOnKey
}
''');
          }
        }
      case NormalClassInfo():
        if (required) {
          buffer.writeln('''
$dartType get $fieldName => $classType.fromJson( json.map\$('$jsonKey') );
''');
          if (!property.isOverride) {
            buffer.writeln('''
set $setterName($dartType value) => json['$jsonKey'] = value.json;
''');
          }
        } else {
          buffer.writeln('''
$dartType get $fieldName {
  final map_ = json.optionalMap('$jsonKey');
  if(map_ == null){
    return null;
  }
  return $classType.fromJson(map_);
}
''');
          if (!property.isOverride) {
            buffer.writeln('''
set $setterName($dartType value) {
  if (value == null) {
    json.remove('$jsonKey');
  }
  else {
    json['$jsonKey'] = value.json;
  }
  $sortOnKey
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
    final required = property.isRequired;

    switch (dartType.typeName) {
      case 'String':
        if (required) {
          buffer.writeln('''
String get $fieldName => json.string('$jsonKey');

set $setterName(String value) {
  json['$jsonKey'] = value;
  $sortOnKey
}
''');
        } else {
          buffer.writeln('''
String? get $fieldName => json.optionalString('$jsonKey');

set $setterName(String? value) {
  if (value == null) {
    json.remove('$jsonKey');
  }
  else {
    json['$jsonKey'] = value;
  }
  $sortOnKey
}
''');
        }
      case 'int':
        if (required) {
          buffer.writeln('''
int get $fieldName => json.get<int>('$jsonKey');

set $setterName(int value) => json['$jsonKey'] = value;
''');
        } else {
          buffer.writeln('''
int? get $fieldName => json.getOptional<int>('$jsonKey');

set $setterName(int? value) {
  if (value == null) {
    json.remove('$jsonKey');
  }
  else {
    json['$jsonKey'] = value;
  }
  $sortOnKey
}
''');
        }
      case 'bool':
        if (required) {
          buffer.writeln('''
bool get $fieldName => json.get<bool>('$jsonKey');

set $setterName(bool value) {
  json['$jsonKey'] = value;
  $sortOnKey
}
''');
        } else {
          buffer.writeln('''
bool? get $fieldName => json.getOptional<bool>('$jsonKey');

set $setterName(bool? value) {
  if (value == null) {
    json.remove('$jsonKey');
  }
  else {
    json['$jsonKey'] = value;
  }
  $sortOnKey
}
''');
        }
      default:
        throw UnimplementedError(
          'Unsupported SimpleDartType: ${dartType.typeName}',
        );
    }
  }

  void _generateMapTypeGetterSetter(
    StringBuffer buffer,
    PropertyInfo property,
    MapDartType dartType,
    String jsonKey,
    String setterName,
    String sortOnKey,
  ) {
    final fieldName = property.name;
    final valueType = dartType.valueType;

    switch (valueType) {
      case MapDartType():
        buffer.writeln('''
Map<String, Map<String, Object?>>? get $fieldName =>
  json.optionalMap<Map<String, Object?>>('$jsonKey');

set $setterName(Map<String, Map<String, Object?>>? value) {
  if (value == null) {
    json.remove('$jsonKey');
  } else {
    json['$jsonKey'] = value;
  }
  $sortOnKey
}
''');
      case ListDartType():
        final itemType = valueType.itemType;
        final typeName = itemType.toString();
        buffer.writeln('''
Map<String, List<$typeName>>? get $fieldName {
  final map_ = json.optionalMap('$jsonKey');
  if(map_ == null){
    return null;
  }
  return {
    for (final MapEntry(:key, :value) in map_.entries)
      key : [
        for (final item in value as List<Object?>)
          $typeName.fromJson(item as Map<String, Object?>)
      ],
  };
}

set $setterName(Map<String, List<$typeName>>? value) {
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
Map<String, Object?>? get $fieldName => json.optionalMap('$jsonKey');

set $setterName(Map<String, Object?>? value) {
  if (value == null) {
    json.remove('$jsonKey');
  } else {
    json['$jsonKey'] = value;
  }
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
List<$typeName>? get $fieldName {
  final list_ = json.optionalList('$jsonKey')?.cast<Map<String, Object?>>();
  if(list_ == null){
    return null;
  }
  final result = <$typeName>[];
  for(final item in list_){
    result.add($typeName.fromJson(item));
  }
  return result;
}

set $setterName(List<$typeName>? value) {
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
            if (required) {
              buffer.writeln('''
List<String> get $fieldName => json.stringList('$jsonKey');

set $setterName(List<String> value) {
  json['$jsonKey'] = value;
  $sortOnKey
} 
''');
            } else {
              buffer.writeln('''
List<String>? get $fieldName => json.optionalStringList('$jsonKey');

set $setterName(List<String>? value) {
  if (value == null) {
    json.remove('$jsonKey');
  }
  else {
    json['$jsonKey'] = value;
  }
  $sortOnKey
}
''');
            }
          default:
            throw UnimplementedError(itemType.toString());
        }
      case UriDartType():
        if (required) {
          buffer.writeln('''
List<Uri> get $fieldName => json.pathList('$jsonKey');

set $setterName(List<Uri> value) {
  json['$jsonKey'] = value;
  $sortOnKey
} 
''');
        } else {
          buffer.writeln('''
List<Uri>? get $fieldName => json.optionalPathList('$jsonKey');

set $setterName(List<Uri>? value) {
  if (value == null) {
    json.remove('$jsonKey');
  }
  else {
    json['$jsonKey'] = value.toJson();
  }
  $sortOnKey
}
''');
        }
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
    if (required) {
      buffer.writeln('''
Uri get $fieldName => json.path('$jsonKey');

set $setterName(Uri value){
  json['$jsonKey'] = value.toFilePath();
  $sortOnKey
}
''');
    } else {
      buffer.writeln('''
Uri? get $fieldName => json.optionalPath('$jsonKey');

set $setterName(Uri? value) {
  if (value == null) {
    json.remove('$jsonKey');
  }
  else {
    json['$jsonKey'] = value.toFilePath();
  }
  $sortOnKey
}
''');
    }
  }
}

String _wrapBracesIfNotEmpty(String input) =>
    input.isEmpty ? input : '{$input}';

String _wrapInBracesOrSemicolon(String input) =>
    input.isEmpty ? ';' : '{ $input }';
