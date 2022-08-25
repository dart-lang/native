// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Types to describe java API elements

import 'package:json_annotation/json_annotation.dart';

part 'elements.g.dart';

@JsonEnum()

/// A kind describes the type of a declaration.
enum DeclKind {
  @JsonValue('CLASS')
  classKind,
  @JsonValue('INTERFACE')
  interfaceKind,
  @JsonValue('ENUM')
  enumKind,
}

// Note: We give default values in constructor, if the field is nullable in
// JSON. this allows us to reduce JSON size by providing Include.NON_NULL
// option in java.

@JsonSerializable(explicitToJson: true)
class ClassDecl {
  /// Methods & properties already defined by dart JlObject base class.
  static const Map<String, int> _definedSyms = {
    'equals': 1,
    'toString': 1,
    'hashCode': 1,
    'runtimeType': 1,
    'noSuchMethod': 1,
    'reference': 1,
    'delete': 1,
  };

  ClassDecl({
    this.annotations = const [],
    this.javadoc,
    this.modifiers = const {},
    required this.simpleName,
    required this.binaryName,
    this.parentName,
    this.packageName,
    this.typeParams = const [],
    this.methods = const [],
    this.fields = const [],
    this.superclass,
    this.interfaces = const [],
    this.hasStaticInit = false,
    this.hasInstanceInit = false,
    this.values,
  });

  List<Annotation> annotations;
  JavaDocComment? javadoc;

  Set<String> modifiers;
  String simpleName, binaryName;
  String? parentName, packageName;
  List<TypeParam> typeParams;
  List<Method> methods;
  List<Field> fields;
  TypeUsage? superclass;
  List<TypeUsage> interfaces;
  bool hasStaticInit, hasInstanceInit;

  // Contains enum constant names if class is an enum,
  // as obtained by `.values()` method in Java.
  List<String>? values;

  factory ClassDecl.fromJson(Map<String, dynamic> json) =>
      _$ClassDeclFromJson(json);
  Map<String, dynamic> toJson() => _$ClassDeclToJson(this);

  // synthesized attributes
  @JsonKey(ignore: true)
  late String finalName;

  @JsonKey(ignore: true)
  bool isPreprocessed = false;
  @JsonKey(ignore: true)
  bool isIncluded = true;

  /// Contains number with which certain overload of a method is renamed to,
  /// so the overriding method in subclass can be renamed to same final name.
  @JsonKey(ignore: true)
  Map<String, int> methodNumsAfterRenaming = {};

  /// Name counts map, it's a field so that it can be later used by subclasses.
  @JsonKey(ignore: true)
  Map<String, int> nameCounts = {..._definedSyms};

  @override
  String toString() {
    return 'Java class declaration for $binaryName';
  }
}

@JsonEnum()
enum Kind {
  @JsonValue('PRIMITIVE')
  primitive,
  @JsonValue('TYPE_VARIABLE')
  typeVariable,
  @JsonValue('WILDCARD')
  wildcard,
  @JsonValue('DECLARED')
  declared,
  @JsonValue('ARRAY')
  array,
}

@JsonSerializable(explicitToJson: true)
class TypeUsage {
  TypeUsage({
    required this.shorthand,
    required this.kind,
    required this.typeJson,
  });

  String shorthand;
  Kind kind;
  @JsonKey(ignore: true)
  late ReferredType type;
  @JsonKey(name: "type")
  Map<String, dynamic> typeJson;

  String get name => type.name;

  // Since json_serializable doesn't directly support union types,
  // we have to temporarily store `type` in a JSON map, and switch on the
  // enum value received.
  factory TypeUsage.fromJson(Map<String, dynamic> json) {
    final t = _$TypeUsageFromJson(json);
    switch (t.kind) {
      case Kind.primitive:
        t.type = PrimitiveType.fromJson(t.typeJson);
        break;
      case Kind.typeVariable:
        t.type = TypeVar.fromJson(t.typeJson);
        break;
      case Kind.wildcard:
        t.type = Wildcard.fromJson(t.typeJson);
        break;
      case Kind.declared:
        t.type = DeclaredType.fromJson(t.typeJson);
        break;
      case Kind.array:
        t.type = ArrayType.fromJson(t.typeJson);
        break;
    }
    return t;
  }
  Map<String, dynamic> toJson() => _$TypeUsageToJson(this);
}

abstract class ReferredType {
  String get name;
}

@JsonSerializable(explicitToJson: true)
class PrimitiveType implements ReferredType {
  PrimitiveType({required this.name});

  @override
  String name;

  factory PrimitiveType.fromJson(Map<String, dynamic> json) =>
      _$PrimitiveTypeFromJson(json);
  Map<String, dynamic> toJson() => _$PrimitiveTypeToJson(this);
}

@JsonSerializable(explicitToJson: true)
class DeclaredType implements ReferredType {
  DeclaredType({
    required this.binaryName,
    required this.simpleName,
    this.params = const [],
  });
  String binaryName, simpleName;
  List<TypeUsage> params;

  @override
  String get name => binaryName;

  factory DeclaredType.fromJson(Map<String, dynamic> json) =>
      _$DeclaredTypeFromJson(json);
  Map<String, dynamic> toJson() => _$DeclaredTypeToJson(this);
}

@JsonSerializable(explicitToJson: true)
class TypeVar implements ReferredType {
  TypeVar({required this.name});
  @override
  String name;

  factory TypeVar.fromJson(Map<String, dynamic> json) =>
      _$TypeVarFromJson(json);
  Map<String, dynamic> toJson() => _$TypeVarToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Wildcard implements ReferredType {
  Wildcard({this.extendsBound, this.superBound});
  TypeUsage? extendsBound, superBound;

  @override
  String get name => "?";

  factory Wildcard.fromJson(Map<String, dynamic> json) =>
      _$WildcardFromJson(json);
  Map<String, dynamic> toJson() => _$WildcardToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ArrayType implements ReferredType {
  ArrayType({required this.type});
  TypeUsage type;

  @override
  String get name => "[${type.name}";

  factory ArrayType.fromJson(Map<String, dynamic> json) =>
      _$ArrayTypeFromJson(json);
  Map<String, dynamic> toJson() => _$ArrayTypeToJson(this);
}

abstract class ClassMember {
  String get name;
}

@JsonSerializable(explicitToJson: true)
class Method implements ClassMember {
  Method(
      {this.annotations = const [],
      this.javadoc,
      this.modifiers = const {},
      required this.name,
      this.typeParams = const [],
      this.params = const [],
      required this.returnType});
  List<Annotation> annotations;
  JavaDocComment? javadoc;
  Set<String> modifiers;

  @override
  String name;

  List<TypeParam> typeParams;
  List<Param> params;
  TypeUsage returnType;

  @JsonKey(ignore: true)
  late String finalName;
  @JsonKey(ignore: true)
  late bool isOverridden;
  @JsonKey(ignore: true)
  bool isIncluded = true;

  @JsonKey(ignore: true)
  late String javaSig = _javaSig();

  String _javaSig() {
    final paramNames = params.map((p) => p.type.name).join(', ');
    return '${returnType.name} $name($paramNames)';
  }

  factory Method.fromJson(Map<String, dynamic> json) => _$MethodFromJson(json);
  Map<String, dynamic> toJson() => _$MethodToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Param {
  Param(
      {this.annotations = const [],
      this.javadoc,
      required this.name,
      required this.type});
  List<Annotation> annotations;
  JavaDocComment? javadoc;

  String name;
  TypeUsage type;

  factory Param.fromJson(Map<String, dynamic> json) => _$ParamFromJson(json);
  Map<String, dynamic> toJson() => _$ParamToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Field implements ClassMember {
  Field(
      {this.annotations = const [],
      this.javadoc,
      this.modifiers = const {},
      required this.name,
      required this.type,
      this.defaultValue});

  List<Annotation> annotations;
  JavaDocComment? javadoc;

  Set<String> modifiers;

  @override
  String name;

  TypeUsage type;
  Object? defaultValue;

  @JsonKey(ignore: true)
  late String finalName;
  @JsonKey(ignore: true)
  bool isIncluded = true;

  factory Field.fromJson(Map<String, dynamic> json) => _$FieldFromJson(json);
  Map<String, dynamic> toJson() => _$FieldToJson(this);
}

@JsonSerializable(explicitToJson: true)
class TypeParam {
  TypeParam({required this.name, this.bounds = const []});
  String name;
  List<TypeUsage> bounds;

  @JsonKey(ignore: true)
  late String erasure;

  factory TypeParam.fromJson(Map<String, dynamic> json) =>
      _$TypeParamFromJson(json);
  Map<String, dynamic> toJson() => _$TypeParamToJson(this);
}

@JsonSerializable(explicitToJson: true)
class JavaDocComment {
  JavaDocComment({String? comment}) : comment = comment ?? '';
  String comment;

  @JsonKey(ignore: true)
  late String dartDoc;

  factory JavaDocComment.fromJson(Map<String, dynamic> json) =>
      _$JavaDocCommentFromJson(json);
  Map<String, dynamic> toJson() => _$JavaDocCommentToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Annotation {
  Annotation(
      {required this.simpleName,
      required this.binaryName,
      this.properties = const {}});
  String simpleName;
  String binaryName;
  Map<String, Object> properties;

  factory Annotation.fromJson(Map<String, dynamic> json) =>
      _$AnnotationFromJson(json);
  Map<String, dynamic> toJson() => _$AnnotationToJson(this);
}
