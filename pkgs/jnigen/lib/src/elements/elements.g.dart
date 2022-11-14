// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'elements.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClassDecl _$ClassDeclFromJson(Map<String, dynamic> json) => ClassDecl(
      annotations: (json['annotations'] as List<dynamic>?)
              ?.map((e) => Annotation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      javadoc: json['javadoc'] == null
          ? null
          : JavaDocComment.fromJson(json['javadoc'] as Map<String, dynamic>),
      modifiers: (json['modifiers'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toSet() ??
          const {},
      simpleName: json['simpleName'] as String,
      binaryName: json['binaryName'] as String,
      packageName: json['packageName'] as String,
      parentName: json['parentName'] as String?,
      typeParams: (json['typeParams'] as List<dynamic>?)
              ?.map((e) => TypeParam.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      methods: (json['methods'] as List<dynamic>?)
              ?.map((e) => Method.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      fields: (json['fields'] as List<dynamic>?)
              ?.map((e) => Field.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      superclass: json['superclass'] == null
          ? null
          : TypeUsage.fromJson(json['superclass'] as Map<String, dynamic>),
      interfaces: (json['interfaces'] as List<dynamic>?)
              ?.map((e) => TypeUsage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      hasStaticInit: json['hasStaticInit'] as bool? ?? false,
      hasInstanceInit: json['hasInstanceInit'] as bool? ?? false,
      values:
          (json['values'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

TypeUsage _$TypeUsageFromJson(Map<String, dynamic> json) => TypeUsage(
      shorthand: json['shorthand'] as String,
      kind: $enumDecode(_$KindEnumMap, json['kind']),
      typeJson: json['type'] as Map<String, dynamic>,
    );

const _$KindEnumMap = {
  Kind.primitive: 'PRIMITIVE',
  Kind.typeVariable: 'TYPE_VARIABLE',
  Kind.wildcard: 'WILDCARD',
  Kind.declared: 'DECLARED',
  Kind.array: 'ARRAY',
};

PrimitiveType _$PrimitiveTypeFromJson(Map<String, dynamic> json) =>
    PrimitiveType(
      name: json['name'] as String,
    );

DeclaredType _$DeclaredTypeFromJson(Map<String, dynamic> json) => DeclaredType(
      binaryName: json['binaryName'] as String,
      simpleName: json['simpleName'] as String,
      params: (json['params'] as List<dynamic>?)
              ?.map((e) => TypeUsage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

TypeVar _$TypeVarFromJson(Map<String, dynamic> json) => TypeVar(
      name: json['name'] as String,
    );

Wildcard _$WildcardFromJson(Map<String, dynamic> json) => Wildcard(
      extendsBound: json['extendsBound'] == null
          ? null
          : TypeUsage.fromJson(json['extendsBound'] as Map<String, dynamic>),
      superBound: json['superBound'] == null
          ? null
          : TypeUsage.fromJson(json['superBound'] as Map<String, dynamic>),
    );

ArrayType _$ArrayTypeFromJson(Map<String, dynamic> json) => ArrayType(
      type: TypeUsage.fromJson(json['type'] as Map<String, dynamic>),
    );

Method _$MethodFromJson(Map<String, dynamic> json) => Method(
      annotations: (json['annotations'] as List<dynamic>?)
              ?.map((e) => Annotation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      javadoc: json['javadoc'] == null
          ? null
          : JavaDocComment.fromJson(json['javadoc'] as Map<String, dynamic>),
      modifiers: (json['modifiers'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toSet() ??
          const {},
      name: json['name'] as String,
      typeParams: (json['typeParams'] as List<dynamic>?)
              ?.map((e) => TypeParam.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      params: (json['params'] as List<dynamic>?)
              ?.map((e) => Param.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      returnType:
          TypeUsage.fromJson(json['returnType'] as Map<String, dynamic>),
    );

Param _$ParamFromJson(Map<String, dynamic> json) => Param(
      annotations: (json['annotations'] as List<dynamic>?)
              ?.map((e) => Annotation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      javadoc: json['javadoc'] == null
          ? null
          : JavaDocComment.fromJson(json['javadoc'] as Map<String, dynamic>),
      name: json['name'] as String,
      type: TypeUsage.fromJson(json['type'] as Map<String, dynamic>),
    );

Field _$FieldFromJson(Map<String, dynamic> json) => Field(
      annotations: (json['annotations'] as List<dynamic>?)
              ?.map((e) => Annotation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      javadoc: json['javadoc'] == null
          ? null
          : JavaDocComment.fromJson(json['javadoc'] as Map<String, dynamic>),
      modifiers: (json['modifiers'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toSet() ??
          const {},
      name: json['name'] as String,
      type: TypeUsage.fromJson(json['type'] as Map<String, dynamic>),
      defaultValue: json['defaultValue'],
    );

TypeParam _$TypeParamFromJson(Map<String, dynamic> json) => TypeParam(
      name: json['name'] as String,
      bounds: (json['bounds'] as List<dynamic>?)
              ?.map((e) => TypeUsage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

JavaDocComment _$JavaDocCommentFromJson(Map<String, dynamic> json) =>
    JavaDocComment(
      comment: json['comment'] as String?,
    );

Annotation _$AnnotationFromJson(Map<String, dynamic> json) => Annotation(
      simpleName: json['simpleName'] as String,
      binaryName: json['binaryName'] as String,
      properties: (json['properties'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as Object),
          ) ??
          const {},
    );
