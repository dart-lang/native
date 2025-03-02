// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'elements.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClassDecl _$ClassDeclFromJson(Map<String, dynamic> json) => ClassDecl(
      annotations: (json['annotations'] as List<dynamic>?)
          ?.map((e) => Annotation.fromJson(e as Map<String, dynamic>))
          .toList(),
      javadoc: json['javadoc'] == null
          ? null
          : JavaDocComment.fromJson(json['javadoc'] as Map<String, dynamic>),
      declKind: $enumDecode(_$DeclKindEnumMap, json['declKind']),
      modifiers: (json['modifiers'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toSet() ??
          const {},
      binaryName: json['binaryName'] as String,
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
      outerClassBinaryName: json['outerClassBinaryName'] as String?,
      interfaces: (json['interfaces'] as List<dynamic>?)
              ?.map((e) => TypeUsage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      values:
          (json['values'] as List<dynamic>?)?.map((e) => e as String).toList(),
      kotlinClass: json['kotlinClass'] == null
          ? null
          : KotlinClass.fromJson(json['kotlinClass'] as Map<String, dynamic>),
      kotlinPackage: json['kotlinPackage'] == null
          ? null
          : KotlinPackage.fromJson(
              json['kotlinPackage'] as Map<String, dynamic>),
    );

const _$DeclKindEnumMap = {
  DeclKind.classKind: 'CLASS',
  DeclKind.interfaceKind: 'INTERFACE',
  DeclKind.enumKind: 'ENUM',
};

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

DeclaredType _$DeclaredTypeFromJson(Map<String, dynamic> json) => DeclaredType(
      binaryName: json['binaryName'] as String,
      annotations: (json['annotations'] as List<dynamic>?)
          ?.map((e) => Annotation.fromJson(e as Map<String, dynamic>))
          .toList(),
      params: (json['params'] as List<dynamic>?)
              ?.map((e) => TypeUsage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

TypeVar _$TypeVarFromJson(Map<String, dynamic> json) => TypeVar(
      name: json['name'] as String,
      annotations: (json['annotations'] as List<dynamic>?)
          ?.map((e) => Annotation.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Wildcard _$WildcardFromJson(Map<String, dynamic> json) => Wildcard(
      extendsBound: json['extendsBound'] == null
          ? null
          : TypeUsage.fromJson(json['extendsBound'] as Map<String, dynamic>),
      superBound: json['superBound'] == null
          ? null
          : TypeUsage.fromJson(json['superBound'] as Map<String, dynamic>),
      annotations: (json['annotations'] as List<dynamic>?)
          ?.map((e) => Annotation.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

ArrayType _$ArrayTypeFromJson(Map<String, dynamic> json) => ArrayType(
      elementType:
          TypeUsage.fromJson(json['elementType'] as Map<String, dynamic>),
      annotations: (json['annotations'] as List<dynamic>?)
          ?.map((e) => Annotation.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Method _$MethodFromJson(Map<String, dynamic> json) => Method(
      annotations: (json['annotations'] as List<dynamic>?)
          ?.map((e) => Annotation.fromJson(e as Map<String, dynamic>))
          .toList(),
      javadoc: json['javadoc'] == null
          ? null
          : JavaDocComment.fromJson(json['javadoc'] as Map<String, dynamic>),
      modifiers: (json['modifiers'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toSet() ??
          const {},
      name: json['name'] as String,
      descriptor: json['descriptor'] as String?,
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
          .toList(),
      javadoc: json['javadoc'] == null
          ? null
          : JavaDocComment.fromJson(json['javadoc'] as Map<String, dynamic>),
      name: json['name'] as String? ?? 'synthetic',
      type: TypeUsage.fromJson(json['type'] as Map<String, dynamic>),
    );

Field _$FieldFromJson(Map<String, dynamic> json) => Field(
      annotations: (json['annotations'] as List<dynamic>?)
          ?.map((e) => Annotation.fromJson(e as Map<String, dynamic>))
          .toList(),
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
      annotations: (json['annotations'] as List<dynamic>?)
          ?.map((e) => Annotation.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

JavaDocComment _$JavaDocCommentFromJson(Map<String, dynamic> json) =>
    JavaDocComment(
      comment: json['comment'] as String? ?? '',
    );

Annotation _$AnnotationFromJson(Map<String, dynamic> json) => Annotation(
      binaryName: json['binaryName'] as String,
      properties: (json['properties'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as Object),
          ) ??
          const {},
      typePath: json['typePath'] == null
          ? const []
          : typePathFromString(json['typePath'] as String?),
    );

KotlinClass _$KotlinClassFromJson(Map<String, dynamic> json) => KotlinClass(
      name: json['name'] as String,
      moduleName: json['moduleName'] as String,
      functions: (json['functions'] as List<dynamic>?)
              ?.map((e) => KotlinFunction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      properties: (json['properties'] as List<dynamic>?)
              ?.map((e) => KotlinProperty.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      constructors: (json['constructors'] as List<dynamic>?)
              ?.map(
                  (e) => KotlinConstructor.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      typeParameters: (json['typeParameters'] as List<dynamic>?)
              ?.map((e) =>
                  KotlinTypeParameter.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      contextReceiverTypes: (json['contextReceiverTypes'] as List<dynamic>?)
              ?.map((e) => KotlinType.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      superTypes: (json['superTypes'] as List<dynamic>?)
              ?.map((e) => KotlinType.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      nestedClasses: (json['nestedClasses'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      enumEntries: (json['enumEntries'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      sealedClasses: (json['sealedClasses'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      companionObject: json['companionObject'] as String?,
      inlineClassUnderlyingPropertyName:
          json['inlineClassUnderlyingPropertyName'] as String?,
      inlineClassUnderlyingType: json['inlineClassUnderlyingType'] == null
          ? null
          : KotlinType.fromJson(
              json['inlineClassUnderlyingType'] as Map<String, dynamic>),
      flags: (json['flags'] as num).toInt(),
      jvmFlags: (json['jvmFlags'] as num).toInt(),
    );

KotlinPackage _$KotlinPackageFromJson(Map<String, dynamic> json) =>
    KotlinPackage(
      functions: (json['functions'] as List<dynamic>?)
              ?.map((e) => KotlinFunction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      properties: (json['properties'] as List<dynamic>?)
              ?.map((e) => KotlinProperty.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

KotlinFunction _$KotlinFunctionFromJson(Map<String, dynamic> json) =>
    KotlinFunction(
      name: json['name'] as String,
      descriptor: json['descriptor'] as String,
      kotlinName: json['kotlinName'] as String,
      valueParameters: (json['valueParameters'] as List<dynamic>?)
              ?.map((e) =>
                  KotlinValueParameter.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      returnType:
          KotlinType.fromJson(json['returnType'] as Map<String, dynamic>),
      receiverParameterType: json['receiverParameterType'] == null
          ? null
          : KotlinType.fromJson(
              json['receiverParameterType'] as Map<String, dynamic>),
      contextReceiverTypes: (json['contextReceiverTypes'] as List<dynamic>?)
              ?.map((e) => KotlinType.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      typeParameters: (json['typeParameters'] as List<dynamic>?)
              ?.map((e) =>
                  KotlinTypeParameter.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      flags: (json['flags'] as num).toInt(),
      isSuspend: json['isSuspend'] as bool,
      isOperator: json['isOperator'] as bool,
    );

KotlinConstructor _$KotlinConstructorFromJson(Map<String, dynamic> json) =>
    KotlinConstructor(
      name: json['name'] as String,
      descriptor: json['descriptor'] as String,
      valueParameters: (json['valueParameters'] as List<dynamic>?)
              ?.map((e) =>
                  KotlinValueParameter.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      flags: (json['flags'] as num).toInt(),
    );

KotlinProperty _$KotlinPropertyFromJson(Map<String, dynamic> json) =>
    KotlinProperty(
      fieldName: json['fieldName'] as String?,
      fieldDescriptor: json['fieldDescriptor'] as String?,
      getterName: json['getterName'] as String?,
      getterDescriptor: json['getterDescriptor'] as String?,
      setterName: json['setterName'] as String?,
      setterDescriptor: json['setterDescriptor'] as String?,
      kotlinName: json['kotlinName'] as String,
      returnType:
          KotlinType.fromJson(json['returnType'] as Map<String, dynamic>),
      receiverParameterType: json['receiverParameterType'] == null
          ? null
          : KotlinType.fromJson(
              json['receiverParameterType'] as Map<String, dynamic>),
      contextReceiverTypes: (json['contextReceiverTypes'] as List<dynamic>?)
              ?.map((e) => KotlinType.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      jvmFlags: (json['jvmFlags'] as num).toInt(),
      flags: (json['flags'] as num).toInt(),
      setterFlags: (json['setterFlags'] as num).toInt(),
      getterFlags: (json['getterFlags'] as num).toInt(),
      typeParameters: (json['typeParameters'] as List<dynamic>?)
              ?.map((e) =>
                  KotlinTypeParameter.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      setterParameter: json['setterParameter'] == null
          ? null
          : KotlinValueParameter.fromJson(
              json['setterParameter'] as Map<String, dynamic>),
    );

KotlinType _$KotlinTypeFromJson(Map<String, dynamic> json) => KotlinType(
      flags: (json['flags'] as num).toInt(),
      kind: json['kind'] as String,
      name: json['name'] as String?,
      id: (json['id'] as num).toInt(),
      isNullable: json['isNullable'] as bool,
      arguments: (json['arguments'] as List<dynamic>?)
              ?.map(
                  (e) => KotlinTypeArgument.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

KotlinTypeParameter _$KotlinTypeParameterFromJson(Map<String, dynamic> json) =>
    KotlinTypeParameter(
      name: json['name'] as String,
      id: (json['id'] as num).toInt(),
      flags: (json['flags'] as num).toInt(),
      upperBounds: (json['upperBounds'] as List<dynamic>?)
              ?.map((e) => KotlinType.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      variance: $enumDecode(_$KmVarianceEnumMap, json['variance']),
    );

const _$KmVarianceEnumMap = {
  KmVariance.invariant: 'INVARIANT',
  KmVariance.contravariant: 'IN',
  KmVariance.covariant: 'OUT',
};

KotlinValueParameter _$KotlinValueParameterFromJson(
        Map<String, dynamic> json) =>
    KotlinValueParameter(
      name: json['name'] as String,
      flags: (json['flags'] as num).toInt(),
      type: KotlinType.fromJson(json['type'] as Map<String, dynamic>),
      varargElementType: json['varargElementType'] == null
          ? null
          : KotlinType.fromJson(
              json['varargElementType'] as Map<String, dynamic>),
    );
