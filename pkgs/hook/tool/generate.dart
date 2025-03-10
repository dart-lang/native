// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: prefer_expression_function_bodies

import 'dart:io';

import 'package:json_schema/json_schema.dart';

import '../test/schema/helpers.dart';

const generateFor = ['hook', 'code_assets', 'data_assets'];

final rootSchemas = loadSchemas([
  packageUri.resolve('doc/schema/'),
  packageUri.resolve('../code_assets/doc/schema/'),
  packageUri.resolve('../data_assets/doc/schema/'),
]);
final rootSchemas2 = rootSchemas.map((key, value) => MapEntry(value, key));

const packageImports = {
  'code_assets': ['hook'],
  'data_assets': ['hook'],
  'hook': <String>[],
};

/// These classes are constructed peacemeal instead of in one go.
///
/// Generate public setters.
const _publicSetters = {
  'BuildOutput',
  'Config',
  'HookInput',
  'HookOutput',
  'LinkOutput',
};

String dependency(List<String> packages) {
  if (packages.length != 2) {
    throw UnimplementedError();
  }
  if (packageImports[packages[0]]!.contains(packages[1])) {
    return packages[1];
  }
  if (packageImports[packages[1]]!.contains(packages[0])) {
    return packages[0];
  }
  throw UnimplementedError();
}

String importer(List<String> packages) {
  if (packages.length != 2) {
    throw UnimplementedError();
  }
  if (packageImports[packages[0]]!.contains(packages[1])) {
    return packages[0];
  }
  if (packageImports[packages[1]]!.contains(packages[0])) {
    return packages[1];
  }
  throw UnimplementedError();
}

void main() {
  if (rootSchemas.length != rootSchemas2.length) {
    throw StateError(
      'Some schemas are not unique, try adding a unique title field.',
    );
  }

  for (final packageName in generateFor) {
    const schemaName = 'shared';
    final schemaUri = packageUri.resolve(
      '../$packageName/doc/schema/$schemaName/shared_definitions.schema.json',
    );
    final outputUri = packageUri.resolve(
      '../native_assets_cli/lib/src/$packageName/syntax.g.dart',
    );
    generate(
      JsonSchemas(rootSchemas[schemaUri]!),
      schemaName,
      packageName,
      outputUri,
    );
  }
}

Uri packageUri = findPackageRoot('hook');

const remapPropertyKeys = <String, String>{
  // TODO: Fix the casing in the schema.
  // 'assetsForLinking': 'assets_for_linking_old',
};

String remapPropertyKey(String name) {
  return remapPropertyKeys[name] ?? name;
}

void generate(
  JsonSchemas schemas,
  String schemaName,
  String packageName,
  Uri outputUri,
) {
  final classes = <String>[];
  for (final definitionKey in schemas.definitionKeys) {
    final definitionSchemas = schemas.getDefinition(definitionKey);
    if (definitionSchemas.generateOpenEnum) {
      classes.add(generateEnumClass(definitionSchemas, name: definitionKey));
    } else if (definitionSchemas.generateExtension(packageName)) {
      classes.add(generateExtension(definitionSchemas));
    } else if (definitionSchemas.generateClass) {
      classes.add(generateClass(definitionSchemas, name: definitionKey));
    }
  }

  final imports = [
    if (packageName != 'hook') "import '../hook/syntax.g.dart';",
    "import '../utils/json.dart';",
  ];

  final output2 = '''
// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// This file is generated, do not edit.

${imports.join()}

${classes.join('\n\n')}
''';
  final file = File.fromUri(outputUri);
  file.createSync(recursive: true);
  file.writeAsStringSync(output2);
  Process.runSync(Platform.executable, ['format', outputUri.toFilePath()]);
}

String generateExtension(JsonSchemas schemas) {
  final typeName = schemas.className!;
  final extensionSchemas = schemas.extensionSchemas;
  final baseSchemas = schemas.baseSchemas;
  final baseName = baseSchemas.className;
  if (baseName != typeName) {
    throw UnimplementedError();
  }
  final basePropertyKeys = baseSchemas.propertyKeys;
  final extensionPropertyKeys =
      extensionSchemas.propertyKeys
          .where((e) => !basePropertyKeys.contains(e))
          .toList();

  final accessors = <String>[];
  final classes = <String>[];
  for (final propertyKey in extensionPropertyKeys) {
    final propertySchemas = schemas.property(propertyKey);
    final required = schemas.propertyRequired(propertyKey);
    accessors.add(
      generateAccessor(
        propertyKey,
        propertySchemas,
        required,
        setterPrivate: false,
      ),
    );
    if (propertySchemas.generateClass && propertySchemas.refs.isEmpty) {
      classes.add(generateClass(propertySchemas, name: propertyKey));
    }
  }

  if (schemas.generateSubClasses) {
    classes.addAll(generateSubClasses(schemas));
  }

  return [
    if (extensionPropertyKeys.isNotEmpty)
      '''
extension ${baseName}Extension on $baseName {
  ${accessors.join('\n\n')}
}
''',
    ...classes,
  ].join('\n\n');
}

List<String> generateSubClasses(JsonSchemas schemas) {
  final classes = <String>[];
  final typeName = schemas.className;
  final propertyKey = schemas.propertyKeys.single;
  final typeProperty = schemas.property(propertyKey);
  final anyOf = typeProperty.anyOfs.single;
  final subTypes = anyOf.map((e) => e.constValue).whereType<String>().toList();
  final ifThenSchemas = schemas.ifThenSchemas;
  for (final subType in subTypes) {
    final subTypeNameShort = ucFirst(snakeToCamelCase(subType));
    final subTypeName = '$subTypeNameShort$typeName';
    JsonSchemas? subtypeSchema;
    for (final (ifSchema, thenSchema) in ifThenSchemas) {
      if (ifSchema.property(propertyKey).constValue == subType) {
        subtypeSchema = thenSchema;
        break;
      }
    }
    if (subtypeSchema != null) {
      classes.add(
        generateClass(
          subtypeSchema,
          name: subTypeName,
          superclass: typeName,
          identifyingSubtype: subType,
        ),
      );
    } else {
      classes.add('''
class $subTypeName extends $typeName {
  $subTypeName.fromJson(super.json) : super.fromJson();

  $subTypeName() : super(
    type: '$subType'
  );
}
''');
    }
    classes.add('''
extension ${subTypeName}Extension on $typeName {
  bool get is$subTypeName => type == '$subType';

  $subTypeName get as$subTypeName => $subTypeName.fromJson(json);
}
''');
  }

  return classes;
}

String generateClass(
  JsonSchemas schemas, {
  String? name,
  String? superclass,
  String? identifyingSubtype,
}) {
  var typeName = schemas.className;
  typeName ??= ucFirst(snakeToCamelCase(name!));
  final accessors = <String>[];
  final constructorParams = <String>[];
  final setupParams = <String>[];
  final constructorSuperParams = <String>[];
  final constructorSetterCalls = <String>[];
  final classes = <String>[];
  final superClassName = schemas.superClassName;
  superclass ??= superClassName;
  final superSchemas = schemas.superClassSchemas;
  final propertyKeys = schemas.propertyKeys;
  final settersPrivate = !_publicSetters.contains(typeName);
  for (final propertyKey in propertyKeys) {
    if (propertyKey == r'$schema') continue;
    final propertySchemas = schemas.property(propertyKey);
    final required = schemas.propertyRequired(propertyKey);
    final allowEnum = !schemas.generateSubClasses;
    final parentPropertySchemas = superSchemas?.property(propertyKey);
    final dartType = generateDartType(
      propertyKey,
      propertySchemas,
      required,
      allowEnum: allowEnum,
    );
    final fieldName = snakeToCamelCase(remapPropertyKey(propertyKey));

    if (parentPropertySchemas == null) {
      accessors.add(
        generateAccessor(
          propertyKey,
          propertySchemas,
          required,
          allowEnum: allowEnum,
          setterPrivate: settersPrivate,
        ),
      );
      constructorParams.add(
        '${required ? 'required' : ''} $dartType $fieldName',
      );
      setupParams.add('${required ? 'required' : ''} $dartType $fieldName');
      if (settersPrivate) {
        constructorSetterCalls.add('_$fieldName = $fieldName;');
      } else {
        constructorSetterCalls.add('this.$fieldName = $fieldName;');
      }
    } else {
      if (parentPropertySchemas.className != propertySchemas.className ||
          propertySchemas.type != parentPropertySchemas.type) {
        final override =
            parentPropertySchemas?.type != null ||
            propertySchemas.className != null;
        accessors.add(
          generateAccessor(
            propertyKey,
            propertySchemas,
            required,
            override: override,
            setterPrivate: settersPrivate,
          ),
        );
        if (override) {
          constructorParams.add(
            '${required ? 'required' : ''} super.$fieldName',
          );
        } else {
          constructorParams.add(
            '${required ? 'required' : ''} $dartType $fieldName',
          );
          setupParams.add('${required ? 'required' : ''} $dartType $fieldName');
          if (settersPrivate) {
            constructorSetterCalls.add('_$fieldName = $fieldName;');
          } else {
            constructorSetterCalls.add('this.$fieldName = $fieldName;');
          }
        }
      } else {
        constructorParams.add('${required ? 'required' : ''} super.$fieldName');
      }
    }
    if (propertySchemas.generateClass && propertySchemas.refs.isEmpty) {
      classes.add(generateClass(propertySchemas, name: propertyKey));
    }
  }

  if (schemas.generateSubClasses) {
    classes.addAll(generateSubClasses(schemas));
  }

  if (identifyingSubtype != null) {
    constructorSuperParams.add("type: '$identifyingSubtype'");
  }

  if (constructorSetterCalls.isNotEmpty) {
    constructorSetterCalls.add('json.sortOnKey();');
  }

  String wrapBracesIfNotEmpty(String input) =>
      input.isEmpty ? input : '{$input}';

  String wrapInBracesOrSemicolon(String input) =>
      input.isEmpty ? ';' : '{ $input }';

  if (superclass != null) {
    return '''
class $typeName extends $superclass  {
  $typeName.fromJson(super.json) : super.fromJson();

  $typeName({
    ${constructorParams.join(',')}
  }) : super(
    ${constructorSuperParams.join(',')}
  ) ${wrapInBracesOrSemicolon(constructorSetterCalls.join('\n'))}

  /// Setup all fields for [$typeName] that are not in
  /// [$superclass].
  void setup (
    ${wrapBracesIfNotEmpty(setupParams.join(','))}
  ) {
    ${constructorSetterCalls.join('\n')}
  }

  ${accessors.join('\n\n')}

  @override
  String toString() => '$typeName(\$json)';
}

${classes.join('\n\n')}
''';
  }

  return '''
class $typeName {
  final Map<String, Object?> json;

  $typeName.fromJson(this.json);

  $typeName({
    ${constructorParams.join(',')}
  }) : json = {} {
    ${constructorSetterCalls.join('\n')}
  }

  ${accessors.join('\n\n')}

  @override
  String toString() => '$typeName(\$json)';
}

${classes.join('\n\n')}
''';
}

String generateEnumClass(JsonSchemas schemas, {String? name}) {
  if (schemas.type != SchemaType.string) {
    throw UnimplementedError(schemas.type.toString());
  }
  var typeName = schemas.className;
  typeName ??= ucFirst(snakeToCamelCase(name!));

  final anyOf = schemas.anyOfs.single;
  final values =
      anyOf.map((e) => e.constValue).whereType<String>().toList()..sort();

  final staticFinals = <String>[];

  for (final value in values) {
    final valueName = snakeToCamelCase(value);
    staticFinals.add('''
static const $valueName = $typeName._('$value');
''');
  }

  return '''
  class $typeName {
    final String name;

    const $typeName._(this.name);

    ${staticFinals.join('\n\n')}

    static const List<$typeName> values = [
      ${values.map(snakeToCamelCase).join(',')}
    ];

    static final Map<String, $typeName> _byName = {
      for (final value in values) value.name: value,
    };

    $typeName.unknown(this.name) : assert(!_byName.keys.contains(name));

    factory $typeName.fromJson(String name) {
      final knownValue = _byName[name];
      if(knownValue != null) {
        return knownValue;
      }
      return $typeName.unknown(name);
    }

    bool get isKnown => _byName[name] != null;

    @override
    String toString() => name;
  }
  ''';
}

String generateDartType(
  String propertyKey,
  JsonSchemas schemas,
  bool required, {
  bool allowEnum = true,
}) {
  final type = schemas.type;
  final String dartTypeNonNullable;
  switch (type) {
    case SchemaType.boolean:
      dartTypeNonNullable = 'bool';
    case SchemaType.integer:
      dartTypeNonNullable = 'int';
    case SchemaType.string:
      if (schemas.generateUri) {
        dartTypeNonNullable = 'Uri';
      } else if (schemas.generateEnum && allowEnum) {
        dartTypeNonNullable = schemas.className!;
      } else {
        dartTypeNonNullable = 'String';
      }
    case SchemaType.object:
      final additionalPropertiesSchema = schemas.additionalPropertiesSchemas;
      if (schemas.generateMapOf) {
        final additionalPropertiesType = additionalPropertiesSchema.type;
        switch (additionalPropertiesType) {
          case SchemaType.array:
            final items = additionalPropertiesSchema.items;
            final itemType = items.type;
            switch (itemType) {
              case SchemaType.object:
                if (required) throw UnimplementedError();
                final typeName = items.className!;
                dartTypeNonNullable = 'Map<String, List<$typeName>>';
              default:
                throw UnimplementedError(itemType.toString());
            }
          case SchemaType.object:
            final additionalPropertiesBool =
                additionalPropertiesSchema.additionalPropertiesBool;
            if (additionalPropertiesBool != true) {
              throw UnimplementedError(additionalPropertiesBool.toString());
            }
            dartTypeNonNullable = 'Map<String, Map<String, Object?>>';
          case null:
            if (schemas.additionalPropertiesBool != true) {
              throw UnimplementedError();
            }
            dartTypeNonNullable = 'Map<String, Object?>';
          default:
            throw UnimplementedError(additionalPropertiesType.toString());
        }
      } else {
        var typeName = schemas.className;
        typeName ??= ucFirst(snakeToCamelCase(propertyKey));
        dartTypeNonNullable = typeName;
      }
    case SchemaType.array:
      final items = schemas.items;
      final itemType = items.type;
      switch (itemType) {
        case SchemaType.string:
          if (items.patterns.isNotEmpty) {
            dartTypeNonNullable = 'List<Uri>';
          } else {
            dartTypeNonNullable = 'List<String>';
          }
        case SchemaType.object:
          final typeName = items.className!;
          dartTypeNonNullable = 'List<$typeName>';
        default:
          throw UnimplementedError(itemType.toString());
      }

    default:
      throw UnimplementedError(type.toString());
  }
  if (required) {
    return dartTypeNonNullable;
  }
  return '$dartTypeNonNullable?';
}

String generateAccessor(
  String propertyKey,
  JsonSchemas schemas,
  bool required, {
  bool override = false,
  bool allowEnum = true,
  bool setterPrivate = true,
}) {
  var result = '';
  final type = schemas.type;
  final fieldName = snakeToCamelCase(remapPropertyKey(propertyKey));
  final setterName = setterPrivate ? '_$fieldName' : fieldName;
  final sortOnKey = setterPrivate ? '' : 'json.sortOnKey();';
  if (override) {
    result += '@override\n';
  }
  switch (type) {
    case SchemaType.string:
      if (schemas.generateUri) {
        if (required) {
          result += '''
Uri get $fieldName => json.path('$propertyKey');

set $setterName(Uri value){
  json['$propertyKey'] = value.toFilePath();
  $sortOnKey
}
''';
        } else {
          result += '''
Uri? get $fieldName => json.optionalPath('$propertyKey');

set $setterName(Uri? value) {
  if (value == null) {
    json.remove('$propertyKey');
  }
  else {
    json['$propertyKey'] = value.toFilePath();
  }
  $sortOnKey
}
''';
        }
      } else if (schemas.generateEnum && allowEnum) {
        var typeName = schemas.className;
        typeName ??= ucFirst(snakeToCamelCase(propertyKey));
        if (required) {
          result += '''
$typeName get $fieldName => $typeName.fromJson(json.string('$propertyKey'));

set $setterName($typeName value) {
  json['$propertyKey'] = value.name;
  $sortOnKey
}
''';
        } else {
          result += '''
$typeName? get $fieldName {
  final string = json.optionalString('$propertyKey');
  if(string == null) return null;
  return $typeName.fromJson(string);
}

set $setterName($typeName? value) {
  if (value == null) {
    json.remove('$propertyKey');
  }
  else {
    json['$propertyKey'] = value.name;
  }
  $sortOnKey
} 
''';
        }
      } else {
        if (required) {
          result += '''
String get $fieldName => json.string('$propertyKey');

set $setterName(String value) {
  json['$propertyKey'] = value;
  $sortOnKey
}
''';
        } else {
          result += '''
String? get $fieldName => json.optionalString('$propertyKey');

set $setterName(String? value) {
  if (value == null) {
    json.remove('$propertyKey');
  }
  else {
    json['$propertyKey'] = value;
  }
  $sortOnKey
}
''';
        }
      }
    case SchemaType.object:
      final additionalPropertiesSchema = schemas.additionalPropertiesSchemas;
      if (schemas.generateMapOf) {
        final additionalPropertiesType = additionalPropertiesSchema.type;
        switch (additionalPropertiesType) {
          case SchemaType.array:
            final items = additionalPropertiesSchema.items;
            final itemType = items.type;
            switch (itemType) {
              case SchemaType.object:
                if (required) throw UnimplementedError();
                final typeName = items.className!;
                result += '''
Map<String, List<$typeName>>? get $fieldName {
  final map_ = json.optionalMap('$propertyKey');
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
    json.remove('$propertyKey');
  }
  else {
    json['$propertyKey'] = {
      for (final MapEntry(:key, :value) in value.entries)
        key : [
          for (final item in value)
            item.json,
        ],
    };
  }
  $sortOnKey
}
''';
              default:
                throw UnimplementedError(itemType.toString());
            }
          case SchemaType.object:
            final additionalPropertiesBool =
                additionalPropertiesSchema.additionalPropertiesBool;
            if (additionalPropertiesBool != true) {
              throw UnimplementedError(additionalPropertiesBool.toString());
            }
            result += '''
Map<String, Map<String, Object?>>? get $fieldName =>
  json.optionalMap<Map<String, Object?>>('$propertyKey');

set $setterName(Map<String, Map<String, Object?>>? value) {
  if (value == null) {
    json.remove('$propertyKey');
  }
  else {
    json['$propertyKey'] = value;
  }
  $sortOnKey
}
''';
          case null:
            if (schemas.additionalPropertiesBool != true) {
              throw UnimplementedError();
            }
            result += '''
Map<String, Object?>? get $fieldName => json.optionalMap('$propertyKey');

set $setterName(Map<String, Object?>? value) {
  if (value == null) {
    json.remove('$propertyKey');
  }
  else {
    json['$propertyKey'] = value;
  }
  $sortOnKey
}
''';
          default:
            throw UnimplementedError(additionalPropertiesType.toString());
        }
      } else {
        var typeName = schemas.className;
        typeName ??= ucFirst(snakeToCamelCase(propertyKey));
        if (required) {
          result += '''
$typeName get $fieldName => $typeName.fromJson( json.map\$('$propertyKey') );
''';
          if (!override) {
            result += '''
set $setterName($typeName value) => json['$propertyKey'] = value.json;
''';
          }
        } else {
          result += '''
$typeName? get $fieldName {
  final map_ = json.optionalMap('$propertyKey');
  if(map_ == null){
    return null;
  }
  return $typeName.fromJson(map_);
}

set $setterName($typeName? value) {
  if (value == null) {
    json.remove('$propertyKey');
  }
  else {
    json['$propertyKey'] = value.json;
  }
  $sortOnKey
}
''';
        }
      }
    case SchemaType.boolean:
      if (required) {
        result += '''
bool get $fieldName => json.get<bool>('$propertyKey');

set $setterName(bool value) {
  json['$propertyKey'] = value;
  $sortOnKey
}
''';
      } else {
        result += '''
bool? get $fieldName => json.getOptional<bool>('$propertyKey');

set $setterName(bool? value) {
  if (value == null) {
    json.remove('$propertyKey');
  }
  else {
    json['$propertyKey'] = value;
  }
  $sortOnKey
};
''';
      }
    case SchemaType.integer:
      if (required) {
        result += '''
int get $fieldName => json.get<int>('$propertyKey');

set $setterName(int value) => json['$propertyKey'] = value;
''';
      } else {
        result += '''
int? get $fieldName => json.getOptional<int>('$propertyKey');

set $setterName(int? value) {
  if (value == null) {
    json.remove('$propertyKey');
  }
  else {
    json['$propertyKey'] = value;
  }
  $sortOnKey
}
''';
      }
    case SchemaType.array:
      final items = schemas.items;
      final itemType = items.type;
      switch (itemType) {
        case SchemaType.string:
          if (items.patterns.isNotEmpty) {
            if (required) {
              result += '''
List<Uri> get $fieldName => json.pathList('$propertyKey');

set $setterName(List<Uri> value) => json['$propertyKey'] = value.toJson();
''';
            } else {
              result += '''
List<Uri>? get $fieldName => json.optionalPathList('$propertyKey');

set $setterName(List<Uri>? value) {
  if (value == null) {
    json.remove('$propertyKey');
  }
  else {
    json['$propertyKey'] = value.toJson();
  }
  $sortOnKey
}
''';
            }
          } else {
            if (required) {
              result += '''
List<String> get $fieldName => json.stringList('$propertyKey');

set $setterName(List<String> value) {
  json['$propertyKey'] = value;
  $sortOnKey
} 
''';
            } else {
              result += '''
List<String>? get $fieldName => json.optionalStringList('$propertyKey');

set $setterName(List<String>? value) {
  if (value == null) {
    json.remove('$propertyKey');
  }
  else {
    json['$propertyKey'] = value;
  }
  $sortOnKey
}
''';
            }
          }
        case SchemaType.object:
          final typeName = items.className!;
          if (required) {
            throw UnimplementedError();
          } else {
            result += '''
List<$typeName>? get $fieldName {
  final list_ = json.optionalList('$propertyKey')?.cast<Map<String, Object?>>();
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
    json.remove('$propertyKey');
  }
  else {
    json['$propertyKey'] = [
      for (final item in value)
        item.json
    ];
  }
  $sortOnKey
}
''';
          }
        default:
          throw UnimplementedError(itemType.toString());
      }

    default:
      throw UnimplementedError(type.toString());
  }
  return result;
}

String snakeToCamelCase(String string) {
  if (string.isEmpty) {
    return '';
  }

  final parts = string.replaceAll('-', '_').split('_');

  const capitalizationOverrides = {
    'ios': 'iOS',
    'Ios': 'IOS',
    'macos': 'macOS',
    'Macos': 'MacOS',
  };

  String remapCapitalization(String input) =>
      capitalizationOverrides[input] ?? input;

  var camelStr = remapCapitalization(parts[0]);

  for (var i = 1; i < parts.length; i++) {
    if (parts[i].isNotEmpty) {
      camelStr += remapCapitalization(
        parts[i][0].toUpperCase() + parts[i].substring(1),
      );
    }
  }

  return camelStr;
}

String ucFirst(String str) {
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
    if (result.dartPackages.length > 2) {
      throw UnimplementedError();
    }
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

  SchemaType? get type {
    final types = <SchemaType>{};
    for (final schema in _schemas) {
      final schemaTypes = schema.typeList;
      if (schemaTypes != null) {
        for (final schemaType in schemaTypes) {
          if (schemaType != null) types.add(schemaType);
        }
      }
    }
    if (types.length > 1) {
      throw StateError('Multiple types found');
    }
    return types.singleOrNull;
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
      throw UnimplementedError();
    }
    return result.singleOrNull;
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

  Object? get constValue {
    final result = <Object>[];
    for (final schema in _schemas) {
      final item = schema.constValue;
      if (item != null) {
        result.add(item as Object);
      }
    }
    if (result.length > 1) {
      throw UnimplementedError();
    }
    return result.singleOrNull;
  }

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

extension CodeGenDecisions on JsonSchemas {
  /// Either [generateClosedEnum] or [generateOpenEnum].
  bool get generateEnum => type == SchemaType.string && anyOfs.isNotEmpty;

  /// A class with opaque members.
  bool get generateClosedEnum =>
      generateEnum && !anyOfs.single.any((e) => e.type != null);

  /// A class with opaque members and an `unknown` option.
  bool get generateOpenEnum =>
      generateEnum && anyOfs.single.any((e) => e.type != null);

  /// Generate getters/setters as `Map<String, ...>.
  bool get generateMapOf =>
      type == SchemaType.object &&
      (additionalPropertiesSchemas.isNotEmpty ||
          additionalPropertiesBool == true);

  bool get generateSubClasses =>
      type == SchemaType.object &&
      propertyKeys.length == 1 &&
      property(propertyKeys.single).anyOfs.isNotEmpty;

  bool get generateClass => type == SchemaType.object && !generateMapOf;

  /// Generate getters/setters as `Uri`.
  bool get generateUri => type == SchemaType.string && patterns.isNotEmpty;

  static String? _pathToClassName(String path) {
    if (path.contains('#/definitions/')) {
      final splits = path.split('/');
      final indexOf = splits.indexOf('definitions');
      final nameParts = splits.skip(indexOf + 1).where((e) => e.isNotEmpty);
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
      throw UnimplementedError();
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
    throw UnimplementedError();
  }

  JsonSchemas get baseSchemas {
    final packages = dartPackages;
    if (packages.length == 1) {
      return this;
    }
    if (packages.length != 2) {
      throw UnimplementedError();
    }
    final package = dependency(packages);
    final result = <JsonSchema>[];
    for (final schema in _schemas) {
      if (schema.dartPackage == package) {
        result.add(schema);
      }
    }
    return JsonSchemas._(result);
  }

  JsonSchemas get extensionSchemas {
    final packages = dartPackages;
    if (packages.length == 1) {
      return JsonSchemas._([]);
    }
    if (packages.length != 2) {
      throw UnimplementedError();
    }
    final package = importer(packages);
    final result = <JsonSchema>[];
    for (final schema in _schemas) {
      if (schema.dartPackage == package) {
        result.add(schema);
      }
    }
    return JsonSchemas._(result);
  }

  bool generateExtension(String currentPackage) =>
      dartPackages.length > 1 ||
      dartPackages[0] != currentPackage && className != null;

  List<String> get dartPackages {
    final result = <String>[];
    for (final schema in _schemas) {
      final pkg = schema.dartPackage;
      if (!result.contains(pkg)) {
        result.add(pkg);
      }
    }
    return result;
  }
}

extension on JsonSchema {
  String get dartPackage {
    final schemaUri = rootSchemas2[root]!;
    final segments = schemaUri.pathSegments;
    final pkgName = segments[segments.indexOf('pkgs') + 1];
    return pkgName;
  }
}

extension on String {
  bool startsWithUpperCase() {
    final codeUnit = codeUnitAt(0);
    return codeUnit >= 65 && codeUnit <= 90;
  }
}
