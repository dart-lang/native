// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:json_annotation/json_annotation.dart';
import 'package:pub_semver/pub_semver.dart';

part 'stability_models.g.dart';

String _versionToString(Version v) => v.toString();

@JsonSerializable()
final class StabilityInfo {
  @JsonKey(fromJson: Version.parse, toJson: _versionToString)
  final Version formatVersion;
  final String packageName;
  final Map<String, StabilityFile> files;

  StabilityInfo({
    required this.formatVersion,
    required this.packageName,
    required this.files,
  });

  factory StabilityInfo.fromJson(Map<String, dynamic> json) =>
      _$StabilityInfoFromJson(json);

  Map<String, dynamic> toJson() => _$StabilityInfoToJson(this);
}

@JsonSerializable()
final class StabilityFile {
  final Map<String, StabilityClass> classes;

  StabilityFile({required this.classes});

  factory StabilityFile.fromJson(Map<String, dynamic> json) =>
      _$StabilityFileFromJson(json);

  Map<String, dynamic> toJson() => _$StabilityFileToJson(this);
}

@JsonSerializable()
final class StabilityClass {
  final String name;
  final StabilityType superClass;
  final List<StabilityType> superInterfaces;
  final Map<String, StabilityField> fields;
  final Map<String, StabilityMethod> methods;
  final List<StabilityTypeParameter> typeParameters;

  StabilityClass({
    required this.name,
    required this.superClass,
    required this.superInterfaces,
    required this.fields,
    required this.methods,
    required this.typeParameters,
  });

  factory StabilityClass.fromJson(Map<String, dynamic> json) =>
      _$StabilityClassFromJson(json);

  Map<String, dynamic> toJson() => _$StabilityClassToJson(this);
}

@JsonSerializable()
final class StabilityField {
  final String name;
  final StabilityType type;

  StabilityField({required this.name, required this.type});

  factory StabilityField.fromJson(Map<String, dynamic> json) =>
      _$StabilityFieldFromJson(json);

  Map<String, dynamic> toJson() => _$StabilityFieldToJson(this);
}

@JsonSerializable()
final class StabilityMethod {
  final String name;
  final List<StabilityTypeParameter> typeParameters;
  final List<StabilityMethodParameter> methodParameters;
  final StabilityType returnType;

  StabilityMethod({
    required this.name,
    required this.typeParameters,
    required this.methodParameters,
    required this.returnType,
  });

  factory StabilityMethod.fromJson(Map<String, dynamic> json) =>
      _$StabilityMethodFromJson(json);

  Map<String, dynamic> toJson() => _$StabilityMethodToJson(this);
}

@JsonSerializable()
final class StabilityMethodParameter {
  final String name;
  final StabilityType type;

  StabilityMethodParameter({required this.name, required this.type});

  factory StabilityMethodParameter.fromJson(Map<String, dynamic> json) =>
      _$StabilityMethodParameterFromJson(json);

  Map<String, dynamic> toJson() => _$StabilityMethodParameterToJson(this);
}

@JsonSerializable()
final class StabilityTypeParameter {
  final String name;
  final List<StabilityType> bounds;

  StabilityTypeParameter({required this.name, required this.bounds});

  factory StabilityTypeParameter.fromJson(Map<String, dynamic> json) =>
      _$StabilityTypeParameterFromJson(json);

  Map<String, dynamic> toJson() => _$StabilityTypeParameterToJson(this);
}

@JsonEnum(alwaysCreate: true)
enum StabilityTypeKind {
  primitive,
  typeVariable,
  wildcard,
  declared,
  array,
}

@JsonEnum(alwaysCreate: true)
enum Nullability {
  /// The type is explicitly non-nullable.
  nonNullable,

  /// The type is explicitly nullable.
  nullable,

  /// The nullability is unspecified.
  platform,
}

sealed class StabilityType {
  // Since json_serializable doesn't directly support union types,
  // we have to temporarily store `type` in a JSON map, and switch on the
  // enum value received.
  factory StabilityType.fromJson(Map<String, dynamic> json) {
    final kind = $enumDecode(_$StabilityTypeKindEnumMap, json['kind']);
    final typeJson = json['type'] as Map<String, dynamic>;
    switch (kind) {
      case StabilityTypeKind.primitive:
        return StabilityPrimitiveType.fromJson(typeJson);
      case StabilityTypeKind.typeVariable:
        return StabilityTypeVariable.fromJson(typeJson);
      case StabilityTypeKind.wildcard:
        return StabilityWildcard.fromJson(typeJson);
      case StabilityTypeKind.declared:
        return StabilityDeclaredType.fromJson(typeJson);
      case StabilityTypeKind.array:
        return StabilityArrayType.fromJson(typeJson);
    }
  }

  Map<String, dynamic> toJson();
}

@JsonSerializable()
final class StabilityPrimitiveType implements StabilityType {
  final String name;

  StabilityPrimitiveType({required this.name});

  factory StabilityPrimitiveType.fromJson(Map<String, dynamic> json) =>
      _$StabilityPrimitiveTypeFromJson(json);

  @override
  Map<String, dynamic> toJson() => {
        'kind': _$StabilityTypeKindEnumMap[StabilityTypeKind.primitive],
        'type': _$StabilityPrimitiveTypeToJson(this)
      };
}

@JsonSerializable()
final class StabilityTypeVariable implements StabilityType {
  final String name;
  final Nullability nullability;

  StabilityTypeVariable({required this.name, required this.nullability});

  factory StabilityTypeVariable.fromJson(Map<String, dynamic> json) =>
      _$StabilityTypeVariableFromJson(json);

  @override
  Map<String, dynamic> toJson() => {
        'kind': _$StabilityTypeKindEnumMap[StabilityTypeKind.typeVariable],
        'type': _$StabilityTypeVariableToJson(this)
      };
}

@JsonSerializable()
final class StabilityWildcard implements StabilityType {
  final StabilityType? extendsBound;
  final StabilityType? superBound;
  final Nullability nullability;

  StabilityWildcard({
    this.extendsBound,
    this.superBound,
    required this.nullability,
  });

  factory StabilityWildcard.fromJson(Map<String, dynamic> json) =>
      _$StabilityWildcardFromJson(json);

  @override
  Map<String, dynamic> toJson() => {
        'kind': _$StabilityTypeKindEnumMap[StabilityTypeKind.wildcard],
        'type': _$StabilityWildcardToJson(this)
      };
}

@JsonSerializable()
final class StabilityDeclaredType implements StabilityType {
  final String binaryName;
  final List<StabilityType> typeArguments;
  final Nullability nullability;

  StabilityDeclaredType({
    required this.binaryName,
    required this.typeArguments,
    required this.nullability,
  });

  factory StabilityDeclaredType.fromJson(Map<String, dynamic> json) =>
      _$StabilityDeclaredTypeFromJson(json);

  @override
  Map<String, dynamic> toJson() => {
        'kind': _$StabilityTypeKindEnumMap[StabilityTypeKind.declared],
        'type': _$StabilityDeclaredTypeToJson(this)
      };
}

@JsonSerializable()
final class StabilityArrayType implements StabilityType {
  final StabilityType elementType;
  final Nullability nullability;

  StabilityArrayType({
    required this.elementType,
    required this.nullability,
  });

  factory StabilityArrayType.fromJson(Map<String, dynamic> json) =>
      _$StabilityArrayTypeFromJson(json);

  @override
  Map<String, dynamic> toJson() => {
        'kind': _$StabilityTypeKindEnumMap[StabilityTypeKind.declared],
        'type': _$StabilityArrayTypeToJson(this)
      };
}
