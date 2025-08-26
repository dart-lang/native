// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stability_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StabilityInfo _$StabilityInfoFromJson(Map<String, dynamic> json) =>
    StabilityInfo(
      formatVersion: Version.parse(json['formatVersion'] as String),
      packageName: json['packageName'] as String,
      files: (json['files'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, StabilityFile.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$StabilityInfoToJson(StabilityInfo instance) =>
    <String, dynamic>{
      'formatVersion': _versionToString(instance.formatVersion),
      'packageName': instance.packageName,
      'files': instance.files,
    };

StabilityFile _$StabilityFileFromJson(Map<String, dynamic> json) =>
    StabilityFile(
      classes: (json['classes'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, StabilityClass.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$StabilityFileToJson(StabilityFile instance) =>
    <String, dynamic>{
      'classes': instance.classes,
    };

StabilityClass _$StabilityClassFromJson(Map<String, dynamic> json) =>
    StabilityClass(
      name: json['name'] as String,
      superClass:
          StabilityType.fromJson(json['superClass'] as Map<String, dynamic>),
      superInterfaces: (json['superInterfaces'] as List<dynamic>)
          .map((e) => StabilityType.fromJson(e as Map<String, dynamic>))
          .toList(),
      fields: (json['fields'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, StabilityField.fromJson(e as Map<String, dynamic>)),
      ),
      methods: (json['methods'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, StabilityMethod.fromJson(e as Map<String, dynamic>)),
      ),
      typeParameters: (json['typeParameters'] as List<dynamic>)
          .map(
              (e) => StabilityTypeParameter.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$StabilityClassToJson(StabilityClass instance) =>
    <String, dynamic>{
      'name': instance.name,
      'superClass': instance.superClass,
      'superInterfaces': instance.superInterfaces,
      'fields': instance.fields,
      'methods': instance.methods,
      'typeParameters': instance.typeParameters,
    };

StabilityField _$StabilityFieldFromJson(Map<String, dynamic> json) =>
    StabilityField(
      name: json['name'] as String,
      type: StabilityType.fromJson(json['type'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$StabilityFieldToJson(StabilityField instance) =>
    <String, dynamic>{
      'name': instance.name,
      'type': instance.type,
    };

StabilityMethod _$StabilityMethodFromJson(Map<String, dynamic> json) =>
    StabilityMethod(
      name: json['name'] as String,
      typeParameters: (json['typeParameters'] as List<dynamic>)
          .map(
              (e) => StabilityTypeParameter.fromJson(e as Map<String, dynamic>))
          .toList(),
      methodParameters: (json['methodParameters'] as List<dynamic>)
          .map((e) =>
              StabilityMethodParameter.fromJson(e as Map<String, dynamic>))
          .toList(),
      returnType:
          StabilityType.fromJson(json['returnType'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$StabilityMethodToJson(StabilityMethod instance) =>
    <String, dynamic>{
      'name': instance.name,
      'typeParameters': instance.typeParameters,
      'methodParameters': instance.methodParameters,
      'returnType': instance.returnType,
    };

StabilityMethodParameter _$StabilityMethodParameterFromJson(
        Map<String, dynamic> json) =>
    StabilityMethodParameter(
      name: json['name'] as String,
      type: StabilityType.fromJson(json['type'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$StabilityMethodParameterToJson(
        StabilityMethodParameter instance) =>
    <String, dynamic>{
      'name': instance.name,
      'type': instance.type,
    };

StabilityTypeParameter _$StabilityTypeParameterFromJson(
        Map<String, dynamic> json) =>
    StabilityTypeParameter(
      name: json['name'] as String,
      bounds: (json['bounds'] as List<dynamic>)
          .map((e) => StabilityType.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$StabilityTypeParameterToJson(
        StabilityTypeParameter instance) =>
    <String, dynamic>{
      'name': instance.name,
      'bounds': instance.bounds,
    };

StabilityPrimitiveType _$StabilityPrimitiveTypeFromJson(
        Map<String, dynamic> json) =>
    StabilityPrimitiveType(
      name: json['name'] as String,
    );

Map<String, dynamic> _$StabilityPrimitiveTypeToJson(
        StabilityPrimitiveType instance) =>
    <String, dynamic>{
      'name': instance.name,
    };

StabilityTypeVariable _$StabilityTypeVariableFromJson(
        Map<String, dynamic> json) =>
    StabilityTypeVariable(
      name: json['name'] as String,
      nullability: $enumDecode(_$NullabilityEnumMap, json['nullability']),
    );

Map<String, dynamic> _$StabilityTypeVariableToJson(
        StabilityTypeVariable instance) =>
    <String, dynamic>{
      'name': instance.name,
      'nullability': _$NullabilityEnumMap[instance.nullability]!,
    };

const _$NullabilityEnumMap = {
  Nullability.nonNullable: 'nonNullable',
  Nullability.nullable: 'nullable',
  Nullability.platform: 'platform',
};

StabilityWildcard _$StabilityWildcardFromJson(Map<String, dynamic> json) =>
    StabilityWildcard(
      extendsBound: json['extendsBound'] == null
          ? null
          : StabilityType.fromJson(
              json['extendsBound'] as Map<String, dynamic>),
      superBound: json['superBound'] == null
          ? null
          : StabilityType.fromJson(json['superBound'] as Map<String, dynamic>),
      nullability: $enumDecode(_$NullabilityEnumMap, json['nullability']),
    );

Map<String, dynamic> _$StabilityWildcardToJson(StabilityWildcard instance) =>
    <String, dynamic>{
      'extendsBound': instance.extendsBound,
      'superBound': instance.superBound,
      'nullability': _$NullabilityEnumMap[instance.nullability]!,
    };

StabilityDeclaredType _$StabilityDeclaredTypeFromJson(
        Map<String, dynamic> json) =>
    StabilityDeclaredType(
      binaryName: json['binaryName'] as String,
      typeArguments: (json['typeArguments'] as List<dynamic>)
          .map((e) => StabilityType.fromJson(e as Map<String, dynamic>))
          .toList(),
      nullability: $enumDecode(_$NullabilityEnumMap, json['nullability']),
    );

Map<String, dynamic> _$StabilityDeclaredTypeToJson(
        StabilityDeclaredType instance) =>
    <String, dynamic>{
      'binaryName': instance.binaryName,
      'typeArguments': instance.typeArguments,
      'nullability': _$NullabilityEnumMap[instance.nullability]!,
    };

StabilityArrayType _$StabilityArrayTypeFromJson(Map<String, dynamic> json) =>
    StabilityArrayType(
      elementType:
          StabilityType.fromJson(json['elementType'] as Map<String, dynamic>),
      nullability: $enumDecode(_$NullabilityEnumMap, json['nullability']),
    );

Map<String, dynamic> _$StabilityArrayTypeToJson(StabilityArrayType instance) =>
    <String, dynamic>{
      'elementType': instance.elementType,
      'nullability': _$NullabilityEnumMap[instance.nullability]!,
    };

const _$StabilityTypeKindEnumMap = {
  StabilityTypeKind.primitive: 'primitive',
  StabilityTypeKind.typeVariable: 'typeVariable',
  StabilityTypeKind.wildcard: 'wildcard',
  StabilityTypeKind.declared: 'declared',
  StabilityTypeKind.array: 'array',
};
