// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:json_schema/json_schema.dart';

import '../model/class_info.dart';
import '../model/dart_type.dart';
import '../model/property_info.dart';
import '../model/schema_info.dart';

/// Analyzes a JSON schema and extracts information to a [SchemaInfo].
///
/// This analyzer makes decisions on how code should be generated and encodes
/// them in the [SchemaInfo]. This enables the code generator to be plain and
/// simple.
///
/// It supports the following features:
/// * Subclassing. JSON definitions refering with an `allOf` to another JSON
///   definition with a different name are interpreted as a subclass relation.
/// * Open enums. JSON definitions with an `anyOf` of `const`s and `type`
///   `string` are interpreted as an open enum.
/// * Tagged unions. JSON definitions with an `if`-`properties`-`type`-`const`
///   and `then`-`properties` are interpreted as tagged unions.
///
/// Code geneneration decisions made in this class:
/// * Naming according to "effective Dart". This class expects a JSON schema
///   with snake-cased keys and produces [SchemaInfo] with camel-cased Dart
///   names and types.
/// * Renaming with [nameOverrides].
/// * Whether setters are public or not with [publicSetters].
class SchemaAnalyzer {
  final JsonSchema schema;

  /// Overriding for names.
  ///
  /// Useful for
  /// * capitalization overrides (`macos` -> `macOS`),
  /// * naming conflicts (to prevent `myName` and `my_name` clasing), and
  /// * renames as preferred.
  final Map<String, String> nameOverrides;

  /// Generate public setters for these class names.
  final List<String> publicSetters;

  /// For subtypes of these classes, the union tag values are exposed.
  ///
  /// For example, if `Asset.type` is `NativeCodeAsset.typeValue`, then the
  /// asset is a native code asset. Listing `Asset` in [publicUnionTagValues]
  /// will add `static const typeValue = 'code_assets/code';`:
  ///
  /// ```dart
  /// class NativeCodeAsset extends Asset {
  ///   static const typeValue = 'code_assets/code';
  /// }
  ///
  /// class Asset {
  ///   String? get type => _reader.get<String?>('type');
  /// }
  /// ```
  final List<String> publicUnionTagValues;

  /// Generate public validate methods for these classes.
  ///
  /// This enables validating individual fields.
  final List<String> publicValidators;

  SchemaAnalyzer(
    this.schema, {
    this.nameOverrides = const {},
    this.publicSetters = const [],
    this.publicUnionTagValues = const [],
    this.publicValidators = const [],
  });

  /// Accumulator for all classes during the analysis.
  ///
  /// Because classes can have properties typed by other classes or subclass
  /// other classes, these classes are looked up by name during the analysis.
  /// The analysis ensures to add the classes in order: properties before main
  /// class and super classes before sub classes.
  final _classes = <String, ClassInfo>{};

  SchemaInfo analyze() {
    _classes.clear();
    final schemas = JsonSchemas(schema);
    for (final definitionKey in schemas.definitionKeys) {
      final definitionSchemas = schemas.getDefinition(definitionKey);
      if (definitionSchemas.generateOpenEnum) {
        _analyzeEnumClass(definitionSchemas, name: definitionKey);
      } else if (definitionSchemas.generateClass) {
        _analyzeClass(definitionSchemas, name: definitionKey);
      }
    }
    _classes.sortOnKey();
    return SchemaInfo(classes: _classes.values.toList());
  }

  void _analyzeEnumClass(JsonSchemas schemas, {String? name}) {
    if (schemas.type != .string) {
      throw UnimplementedError(schemas.type.toString());
    }
    var typeName = schemas.className;
    typeName ??= _ucFirst(_snakeToCamelCase(name!));
    if (_classes[typeName] != null) return; // Already analyzed.

    final values = schemas.enumOrTaggedUnionValues;
    _classes[typeName] = EnumClassInfo(
      name: typeName,
      enumValues: [
        for (final value in values)
          EnumValue(name: _snakeToCamelCase(value), jsonValue: value),
      ],
      isOpen: schemas.generateOpenEnum,
    );
  }

  void _analyzeClass(
    JsonSchemas schemas, {
    String? name,
    NormalClassInfo? superclass,
    String? taggedUnionValue,
  }) {
    final typeName = name != null
        ? _ucFirst(_snakeToCamelCase(name))
        : schemas.className!;
    if (_classes[typeName] != null) return; // Already analyzed.

    final properties = <PropertyInfo>[];

    if (superclass == null) {
      final superClassSchemas = schemas.superClassSchemas;
      if (superClassSchemas != null) {
        _analyzeClass(superClassSchemas);
      }
      final superClassName = schemas.superClassName;
      if (superClassName != null) {
        superclass = _classes[superClassName] as NormalClassInfo;
      }
    }
    final propertyKeys = schemas.propertyKeys;
    final settersPrivate = !publicSetters.contains(typeName);
    final validatorsPrivate = !publicValidators.contains(typeName);

    for (final propertyKey in propertyKeys) {
      if (propertyKey == r'$schema') continue;
      final propertySchemas = schemas.property(propertyKey);
      final required = schemas.propertyRequired(propertyKey);
      final allowEnum = !schemas.generateSubClasses;
      final dartType = _analyzeDartType(
        propertyKey,
        propertySchemas,
        required,
        allowEnum: allowEnum,
      );
      final fieldName = _snakeToCamelCase(propertyKey);
      final parentDartType = superclass?.getProperty(fieldName)?.type;
      final isOverride = parentDartType != null;
      if (parentDartType == null || parentDartType != dartType) {
        properties.add(
          PropertyInfo(
            name: fieldName,
            jsonKey: propertyKey,
            type: dartType,
            isOverride: isOverride,
            setterPrivate: settersPrivate,
            validatorPrivate: validatorsPrivate,
          ),
        );
      }
    }

    final extraValidation = _extractExtraValidation(schemas.ifThenSchemas);

    final classInfo = NormalClassInfo(
      name: typeName,
      superclass: superclass,
      properties: properties,
      taggedUnionValue: taggedUnionValue,
      taggedUnionProperty: schemas.generateSubClasses
          ? schemas.generateSubClassesKey!
          : null,
      visibleTaggedUnion: publicUnionTagValues.contains(typeName),
      extraValidation: extraValidation,
    );
    _classes[typeName] = classInfo;
    if (schemas.generateSubClasses) {
      _analyzeSubClasses(
        schemas,
        schemas.generateSubClassesKey!,
        name: name,
        superclass: classInfo,
      );
      return;
    }
  }

  List<ConditionallyRequired> _extractExtraValidation(
    List<(JsonSchemas, JsonSchemas)> ifThenSchemas,
  ) {
    final result = <ConditionallyRequired>[];
    for (final (ifSchema, thenSchema) in ifThenSchemas) {
      // Extract required path.

      final requiredPath = <String>[];
      var thenSchemaTraversed = thenSchema;
      while (thenSchemaTraversed.propertyKeys.length == 1) {
        final propertyKey = thenSchemaTraversed.propertyKeys.single;
        requiredPath.add(propertyKey);
        thenSchemaTraversed = thenSchemaTraversed.property(propertyKey);
      }
      final requiredProperties = thenSchemaTraversed.requiredProperties;
      if (requiredProperties.length == 1) {
        requiredPath.add(requiredProperties.single);
      } else {
        continue;
      }

      // Extract condition path.
      final path = <String>[];
      var ifSchemaTraversed = ifSchema;
      while (ifSchemaTraversed.propertyKeys.length == 1) {
        final propertyKey = ifSchemaTraversed.propertyKeys.single;
        path.add(propertyKey);
        ifSchemaTraversed = ifSchemaTraversed.property(propertyKey);
      }

      // Extract condition values.
      final values = <String>[];
      final singleConstValue = ifSchemaTraversed.constValue;
      if (singleConstValue != null) {
        values.add(singleConstValue as String);
      } else {
        final anyOfs = ifSchemaTraversed.anyOfs.single;
        for (final anyOf in anyOfs) {
          final constValue = anyOf.constValue;
          if (constValue != null) {
            values.add(constValue as String);
          }
        }
      }

      if (values.isEmpty) {
        continue;
      }
      result.add(
        ConditionallyRequired(
          conditionPath: path,
          conditionValues: values,
          requiredPath: requiredPath,
        ),
      );
    }
    return result;
  }

  void _analyzeSubClasses(
    JsonSchemas schemas,
    String propertyKey, {
    String? name,
    NormalClassInfo? superclass,
  }) {
    final typeName = schemas.className;

    final typeProperty = schemas.property(propertyKey);
    final subTypes = typeProperty.enumOrTaggedUnionValues;
    for (final subType in subTypes) {
      final ifThenSchemas = schemas.ifThenSchemas;
      final subTypeNameShort = _ucFirst(_snakeToCamelCase(subType));
      final subTypeName = '$subTypeNameShort$typeName';
      JsonSchemas? subtypeSchema;
      for (final (ifSchema, thenSchema) in ifThenSchemas) {
        if (ifSchema.property(propertyKey).constValue == subType) {
          subtypeSchema = thenSchema;
          break;
        }
      }
      if (subtypeSchema != null) {
        _analyzeClass(
          subtypeSchema,
          name: subTypeName,
          superclass: superclass,
          taggedUnionValue: subType,
        );
      } else {
        // This is a tagged union without any defined properties.
        _classes[subTypeName] = NormalClassInfo(
          name: subTypeName,
          superclass: superclass,
          properties: [],
          taggedUnionValue: subType,
        );
      }
    }
  }

  DartType _analyzeDartType(
    String propertyKey,
    JsonSchemas schemas,
    bool required, {
    bool allowEnum = true,
  }) {
    final (type, typeIsNullable) = schemas.typeAndNullable;
    final isNullable = typeIsNullable || !required;

    final DartType dartType;
    switch (type) {
      case null:
        dartType = ObjectDartType(isNullable: isNullable);
      case .boolean:
        dartType = BoolDartType(isNullable: isNullable);
      case .integer:
        dartType = IntDartType(isNullable: isNullable);
      case .string:
        if (schemas.generateUri) {
          dartType = UriDartType(isNullable: isNullable);
        } else if (schemas.generateEnum && allowEnum) {
          _analyzeEnumClass(schemas);
          final classInfo = _classes[schemas.className]!;
          dartType = ClassDartType(
            classInfo: classInfo,
            isNullable: isNullable,
          );
        } else {
          if (schemas.patterns.length > 1) {
            throw UnsupportedError('Only one pattern is supported.');
          }
          final pattern = schemas.patterns.firstOrNull;
          dartType = StringDartType(isNullable: isNullable, pattern: pattern);
        }
      case .object:
        final additionalPropertiesSchema =
            schemas.additionalPropertiesSchemas.isNotEmpty
            ? schemas.additionalPropertiesSchemas
            : schemas.patternPropertiesSchemas.values.firstOrNull ??
                  JsonSchemas._([]);
        if (schemas.generateMapOf) {
          final keyDartType = StringDartType(
            isNullable: false,
            pattern: schemas.patternPropertiesSchemas.keys.firstOrNull,
          );
          final (additionalPropertiesType, additionalNullable) =
              additionalPropertiesSchema.typeAndNullable;
          switch (additionalPropertiesType) {
            case .array:
              final items = additionalPropertiesSchema.items;
              final (itemType, itemNullable) = items.typeAndNullable;
              switch (itemType) {
                case .object:
                  _analyzeClass(items);
                  final itemClass = _classes[items.className]!;
                  dartType = MapDartType(
                    keyType: keyDartType,
                    valueType: ListDartType(
                      itemType: ClassDartType(
                        classInfo: itemClass,
                        isNullable: itemNullable,
                      ),
                      isNullable: additionalNullable,
                    ),
                    isNullable: isNullable,
                  );
                default:
                  throw UnimplementedError(itemType.toString());
              }
            case .object:
              final additionalPropertiesBool =
                  additionalPropertiesSchema.additionalPropertiesBool;
              if (additionalPropertiesBool != true) {
                _analyzeClass(additionalPropertiesSchema);
                final clazz = _classes[additionalPropertiesSchema.className]!;
                dartType = MapDartType(
                  keyType: keyDartType,
                  valueType: ClassDartType(
                    classInfo: clazz,
                    isNullable: additionalNullable,
                  ),
                  isNullable: isNullable,
                );
              } else {
                dartType = MapDartType(
                  keyType: keyDartType,
                  valueType: MapDartType(
                    valueType: const ObjectDartType(isNullable: true),
                    isNullable: additionalNullable,
                  ),
                  isNullable: isNullable,
                );
              }
            case null:
              if (schemas.additionalPropertiesBool == true) {
                dartType = ClassDartType(
                  classInfo: jsonObjectClassInfo,
                  isNullable: isNullable,
                );
              } else {
                final oneOfs = additionalPropertiesSchema.oneOfs;
                if (oneOfs.isEmpty) {
                  // No type information.
                  return const ObjectDartType(isNullable: true);
                }
                if (oneOfs.length != 1) {
                  throw UnimplementedError();
                }
                final oneOf = oneOfs.single;
                if (oneOf.length != 2) {
                  throw UnimplementedError();
                }
                final types = oneOf
                    .map((e) => e.type)
                    .whereType<SchemaType>()
                    .toList();
                if (types.length != 2) {
                  throw UnimplementedError();
                }
                if (types.contains(SchemaType.string) &&
                    types.contains(SchemaType.nullValue)) {
                  final stringPattern = oneOf
                      .where((e) => e.type == .string)
                      .single
                      .patterns
                      .firstOrNull;
                  dartType = MapDartType(
                    keyType: keyDartType,
                    valueType: StringDartType(
                      isNullable: true,
                      pattern: stringPattern,
                    ),
                    isNullable: isNullable,
                  );
                } else {
                  throw UnimplementedError();
                }
              }
            case .string:
              dartType = MapDartType(
                keyType: keyDartType,
                valueType: StringDartType(isNullable: additionalNullable),
                isNullable: isNullable,
              );
            case .integer:
              dartType = MapDartType(
                keyType: keyDartType,
                valueType: IntDartType(isNullable: additionalNullable),
                isNullable: isNullable,
              );
            default:
              throw UnimplementedError(additionalPropertiesType.toString());
          }
        } else {
          var typeName = schemas.className;
          typeName ??= _ucFirst(_snakeToCamelCase(propertyKey));
          _analyzeClass(schemas, name: typeName);
          final classInfo = _classes[typeName]!;
          dartType = ClassDartType(
            classInfo: classInfo,
            isNullable: isNullable,
          );
        }
      case .array:
        final items = schemas.items;
        final (itemType, itemNullable) = items.typeAndNullable;
        switch (itemType) {
          case .string:
            if (items.generateUri) {
              dartType = ListDartType(
                itemType: UriDartType(isNullable: itemNullable),
                isNullable: isNullable,
              );
            } else {
              dartType = ListDartType(
                itemType: StringDartType(isNullable: itemNullable),
                isNullable: isNullable,
              );
            }
          case .integer:
            dartType = ListDartType(
              itemType: IntDartType(isNullable: itemNullable),
              isNullable: isNullable,
            );
          case .object:
            final typeName = items.className;
            if (typeName != null) {
              _analyzeClass(items);
              final classInfo = _classes[typeName]!;
              dartType = ListDartType(
                itemType: ClassDartType(
                  classInfo: classInfo,
                  isNullable: itemNullable,
                ),
                isNullable: isNullable,
              );
            } else if (items.generateMapOf) {
              dartType = const ListDartType(
                itemType: MapDartType(
                  valueType: ObjectDartType(isNullable: true),
                  isNullable: true,
                ),
                isNullable: true,
              );
            } else {
              throw UnimplementedError(itemType.toString());
            }
          case null:
            // No type information.
            dartType = const ListDartType(
              itemType: ObjectDartType(isNullable: true),
              isNullable: true,
            );
          default:
            throw UnimplementedError(itemType.toString());
        }

      default:
        throw UnimplementedError(type.toString());
    }
    return dartType;
  }

  String _snakeToCamelCase(String string) {
    if (string.isEmpty) {
      return '';
    }

    final parts = string
        .replaceAll('/', '_')
        .replaceAll(' ', '_')
        .replaceAll('-', '_')
        .split('_');

    String remapCapitalization(String input) => nameOverrides[input] ?? input;

    var result = StringBuffer();
    result += remapCapitalization(parts[0]);

    for (var i = 1; i < parts.length; i++) {
      if (parts[i].isNotEmpty) {
        result += remapCapitalization(
          parts[i][0].toUpperCase() + parts[i].substring(1),
        );
      }
    }

    return result.toString();
  }
}

String _ucFirst(String str) {
  if (str.isEmpty) {
    return '';
  }
  return str[0].toUpperCase() + str.substring(1);
}

/// A view on [JsonSchema]s that extend/override each other.
extension type JsonSchemas._(List<JsonSchema> _schemas) {
  factory JsonSchemas(JsonSchema schema) => JsonSchemas._([schema])._flatten();

  JsonSchemas _flatten() {
    final flattened = <JsonSchema>[];
    final queue = <JsonSchema>[..._schemas];
    while (queue.isNotEmpty) {
      final item = queue.first;
      queue.removeAt(0);
      if (flattened.contains(item)) {
        continue;
      }
      flattened.add(item);
      queue.addAll(item.allOf);
      final ref = item.ref;
      if (ref != null) {
        queue.add(item.resolvePath(ref));
      }
    }
    final result = JsonSchemas._(flattened);
    return result;
  }

  List<String> get propertyKeys =>
      {for (final schema in _schemas) ...schema.properties.keys}.toList()
        ..sort();

  JsonSchemas property(String key) {
    final propertySchemas = <JsonSchema>[];
    for (final schema in _schemas) {
      final propertySchema = schema.properties[key];
      if (propertySchema != null) {
        propertySchemas.add(propertySchema);
      }
    }
    return JsonSchemas._(propertySchemas)._flatten();
  }

  bool propertyRequired(String? property) =>
      _schemas.any((e) => e.propertyRequired(property));

  List<String> get requiredProperties => <String>{
    for (final schema in _schemas) ...schema.requiredProperties ?? [],
  }.toList()..sort();

  Set<SchemaType> get types {
    final types = <SchemaType>{};
    for (final schema in _schemas) {
      final schemaTypes = schema.typeList;
      if (schemaTypes != null) {
        for (final schemaType in schemaTypes) {
          if (schemaType != null) types.add(schemaType);
        }
      }
    }
    return types;
  }

  SchemaType? get type {
    if (types.length <= 1) {
      return types.singleOrNull;
    } else if (types.length == 2 && types.contains(SchemaType.nullValue)) {
      return types.firstWhere((t) => t != SchemaType.nullValue);
    } else {
      throw StateError('Multiple types found: $types');
    }
  }

  (SchemaType?, bool) get typeAndNullable {
    if (types.length <= 1) {
      return (types.singleOrNull, false);
    } else if (types.length == 2 && types.contains(SchemaType.nullValue)) {
      final type = types.firstWhere((t) => t != SchemaType.nullValue);
      return (type, true);
    } else {
      throw UnsupportedError('Multiple types: $types.');
    }
  }

  List<RegExp> get patterns {
    final patterns = <RegExp>{};
    for (final schema in _schemas) {
      final pattern = schema.pattern;
      if (pattern != null) {
        patterns.add(pattern);
      }
    }
    return patterns.toList();
  }

  JsonSchemas get items {
    final items = <JsonSchema>[];
    for (final schema in _schemas) {
      final item = schema.items;
      if (item != null) {
        items.add(item);
      }
    }
    return JsonSchemas._(items)._flatten();
  }

  List<String> get paths {
    final paths = <String>{};
    for (final schema in _schemas) {
      final path = schema.path;
      if (path != null) paths.add(path);
    }
    return paths.toList();
  }

  List<String> get definitionKeys =>
      {for (final schema in _schemas) ...schema.definitions.keys}.toList()
        ..sort();

  JsonSchemas getDefinition(String key) {
    final definitionSchemas = <JsonSchema>[];
    for (final schema in _schemas) {
      final propertySchema = schema.definitions[key];
      if (propertySchema != null) {
        definitionSchemas.add(propertySchema);
      }
    }
    return JsonSchemas._(definitionSchemas)._flatten();
  }

  JsonSchemas get additionalPropertiesSchemas {
    final schemas = <JsonSchema>[];
    for (final schema in _schemas) {
      final additionalPropertiesSchema = schema.additionalPropertiesSchema;
      if (additionalPropertiesSchema != null) {
        schemas.add(additionalPropertiesSchema);
      }
    }
    return JsonSchemas._(schemas)._flatten();
  }

  bool? get additionalPropertiesBool {
    final result = <bool>[];
    for (final schema in _schemas) {
      final additionalPropertiesBool = schema.additionalPropertiesBool;
      if (additionalPropertiesBool != null) {
        result.add(additionalPropertiesBool);
      }
    }
    if (result.length > 1) {
      throw StateError('Both yes and no for additional properties.');
    }
    return result.singleOrNull;
  }

  Map<RegExp, JsonSchemas> get patternPropertiesSchemas {
    final result = <RegExp, JsonSchemas>{};
    for (final schema in _schemas) {
      final additionalPropertiesSchema = schema.patternProperties;
      for (final entry in additionalPropertiesSchema.entries) {
        result[entry.key] = JsonSchemas(entry.value);
      }
    }
    return result;
  }

  bool get isNotEmpty => _schemas.isNotEmpty;

  List<List<JsonSchemas>> get anyOfs {
    final result = <List<JsonSchemas>>[];
    for (final schema in _schemas) {
      final anyOf = schema.anyOf;
      final tempResult = <JsonSchemas>[];
      for (final option in anyOf) {
        tempResult.add(JsonSchemas(option)._flatten());
      }
      if (tempResult.isNotEmpty) {
        result.add(tempResult);
      }
    }
    return result;
  }

  List<List<JsonSchemas>> get oneOfs {
    final result = <List<JsonSchemas>>[];
    for (final schema in _schemas) {
      final oneOf = schema.oneOf;
      final tempResult = <JsonSchemas>[];
      for (final option in oneOf) {
        tempResult.add(JsonSchemas(option)._flatten());
      }
      if (tempResult.isNotEmpty) {
        result.add(tempResult);
      }
    }
    return result;
  }

  Object? get constValue {
    final result = <Object>[];
    for (final schema in _schemas) {
      final item = schema.constValue;
      if (item != null) {
        result.add(item as Object);
      }
    }
    if (result.length > 1) {
      throw UnimplementedError('Conflicting const values.');
    }
    return result.singleOrNull;
  }

  List<String> get enum_ => [
    for (final schema in _schemas)
      for (final value in schema.enumValues ?? [])
        if (value is String) value,
  ];

  List<Uri> get refs {
    final result = <Uri>[];
    for (final schema in _schemas) {
      final ref = schema.ref;
      if (ref != null) {
        result.add(ref);
      }
    }
    return result;
  }

  List<(JsonSchemas, JsonSchemas)> get ifThenSchemas {
    final result = <(JsonSchemas, JsonSchemas)>[];
    for (final schema in _schemas) {
      final ifSchema = schema.ifSchema;
      final thenSchema = schema.thenSchema;
      if (ifSchema != null && thenSchema != null) {
        result.add((
          JsonSchemas(ifSchema)._flatten(),
          JsonSchemas(thenSchema)._flatten(),
        ));
      }
    }
    return result;
  }
}

extension on JsonSchemas {
  bool get generateEnum => type == .string && anyOfs.isNotEmpty;

  /// A class with opaque members and an `unknown` option.
  bool get generateOpenEnum =>
      generateEnum && anyOfs.single.any((e) => e.type != null);

  /// Generate getters/setters as `Map<String, ...>`.
  bool get generateMapOf =>
      type == .object &&
      (additionalPropertiesSchemas.isNotEmpty ||
          additionalPropertiesBool == true ||
          patternPropertiesSchemas.isNotEmpty);

  bool get generateSubClasses => generateSubClassesKey != null;

  String? get generateSubClassesKey {
    if (type != .object) return null;
    for (final p in propertyKeys) {
      final propertySchemas = property(p);
      if (propertySchemas.anyOfs.isNotEmpty) {
        if (propertySchemas.className != null) {
          // This is an explicit enum field, don't make the surrounding class a
          // tagged union.
          return null;
        }
        return p;
      }
    }
    return null;
  }

  bool get generateClass => type == .object && !generateMapOf;

  /// Generate getters/setters as `Uri`.
  bool get generateUri {
    if (!stringWithPattern) return false;
    if (patterns.length != 1) return false;
    final pattern = patterns.single;
    if (pattern.pattern == '^(\\/|[A-Za-z]:)' ||
        pattern.pattern == '^([A-Za-z])') {
      // Patterns for a file path.
      return true;
    }
    return false;
  }

  bool get stringWithPattern => type == .string && patterns.isNotEmpty;

  static String? _pathToClassName(String path) {
    if (path.contains('#/definitions/')) {
      final splits = path.split('/');
      final indexOf = splits.indexOf('definitions');
      final nameParts = splits
          .skip(indexOf + 1)
          .where((e) => e.isNotEmpty)
          .toList();
      if (nameParts.length == 1 && nameParts.single.startsWithUpperCase()) {
        return nameParts.single;
      }
    }
    return null;
  }

  /// This is all the inferred class names from definitions in order of
  /// traversal.
  List<String> get classNames {
    final result = <String>[];
    for (final path in paths) {
      final className = _pathToClassName(path);
      if (className != null) {
        if (!result.contains(className)) {
          result.add(className);
        }
      }
    }
    return result;
  }

  String? get className => classNames.firstOrNull;

  String? get superClassName {
    final names = classNames;
    if (names.length == 2) {
      return names[1];
    }
    if (names.length > 2) {
      throw UnimplementedError('Deeper inheritance not implemented.');
    }
    return null;
  }

  JsonSchemas? get superClassSchemas {
    final parentClassName = superClassName;
    if (parentClassName == null) {
      return null;
    }
    for (final schema in _schemas) {
      final path = schema.path;
      if (path == null) continue;
      final className = _pathToClassName(path);
      if (className != parentClassName) continue;
      return JsonSchemas(schema)._flatten();
    }
    throw StateError('No super class schema found for $parentClassName.');
  }

  List<String> get enumOrTaggedUnionValues => [
    for (final schema in _schemas)
      for (final s in schema.anyOf) ...[
        if (s.constValue is String) s.constValue as String,
        ...s.enumValues?.whereType<String>() ?? [],
      ],
  ]..sort();
}

extension on String {
  bool startsWithUpperCase() {
    final codeUnit = codeUnitAt(0);
    return codeUnit >= 'A'.codeUnitAt(0) && codeUnit <= 'Z'.codeUnitAt(0);
  }
}

extension on StringBuffer {
  StringBuffer operator +(String value) => this..write(value);
}

extension<K extends Comparable<K>, V extends Object?> on Map<K, V> {
  void sortOnKey({List<K>? keysSorted}) {
    final result = <K, V>{};
    keysSorted ??= keys.toList()..sort();
    for (final key in keysSorted) {
      result[key] = this[key] as V;
    }
    clear();
    addAll(result);
  }
}
