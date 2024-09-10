// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:json_annotation/json_annotation.dart';

// Types to describe java API elements

import '../bindings/descriptor.dart';
import '../bindings/kotlin_processor.dart';
import '../bindings/linker.dart';
import '../bindings/renamer.dart';
import '../bindings/visitor.dart';

part 'elements.g.dart';

abstract class Element<T extends Element<T>> {
  const Element();

  R accept<R>(Visitor<T, R> v);
}

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

class Classes implements Element<Classes> {
  const Classes(this.decls);

  final Map<String, ClassDecl> decls;

  factory Classes.fromJson(List<dynamic> json) {
    final decls = <String, ClassDecl>{};
    for (final declJson in json) {
      final classDecl = ClassDecl.fromJson(declJson as Map<String, dynamic>);
      decls[classDecl.binaryName] = classDecl;
    }
    return Classes(decls);
  }

  @override
  R accept<R>(Visitor<Classes, R> v) {
    return v.visit(this);
  }
}

// Note: We give default values in constructor, if the field is nullable in
// JSON. this allows us to reduce JSON size by providing Include.NON_NULL
// option in java.

@JsonSerializable(createToJson: false)
class ClassDecl extends ClassMember implements Element<ClassDecl> {
  ClassDecl({
    this.annotations = const [],
    this.javadoc,
    required this.declKind,
    this.modifiers = const {},
    required this.binaryName,
    this.typeParams = const [],
    this.methods = const [],
    this.fields = const [],
    this.superclass,
    this.interfaces = const [],
    this.hasStaticInit = false,
    this.hasInstanceInit = false,
    this.values,
    this.kotlinClass,
    this.kotlinPackage,
  });

  @override
  final Set<String> modifiers;

  final List<Annotation> annotations;
  final KotlinClass? kotlinClass;
  final KotlinPackage? kotlinPackage;
  final JavaDocComment? javadoc;
  final DeclKind declKind;
  final String binaryName;
  List<TypeParam> typeParams;
  List<Method> methods;
  List<Field> fields;
  final List<TypeUsage> interfaces;
  final bool hasStaticInit;
  final bool hasInstanceInit;

  /// Will default to java.lang.Object if null by [Linker].
  TypeUsage? superclass;

  /// Contains enum constant names if class is an enum,
  /// as obtained by `.values()` method in Java.
  final List<String>? values;

  String get internalName => binaryName.replaceAll('.', '/');

  String get packageName => (binaryName.split('.')..removeLast()).join('.');

  /// The number of super classes this type has.
  ///
  /// Populated by [Linker].
  @JsonKey(includeFromJson: false)
  late final int superCount;

  /// Parent's [ClassDecl] obtained from [parentName].
  ///
  /// Populated by [Linker].
  @JsonKey(includeFromJson: false)
  late final ClassDecl? parent;

  /// Final name of this class.
  ///
  /// Populated by [Renamer].
  @JsonKey(includeFromJson: false)
  @override
  late final String finalName;

  /// Name of the type class.
  ///
  /// Populated by [Renamer].
  @JsonKey(includeFromJson: false)
  late final String typeClassName;

  /// Type parameters including the ones from its ancestors
  ///
  /// Populated by [Linker].
  @JsonKey(includeFromJson: false)
  List<TypeParam> allTypeParams = const [];

  /// The path which this class is generated in.
  ///
  /// Populated by [Linker].
  @JsonKey(includeFromJson: false)
  late final String path;

  /// The numeric suffix of the methods.
  ///
  /// Populated by [Renamer].
  @JsonKey(includeFromJson: false)
  late final Map<String, int> methodNumsAfterRenaming;

  @override
  String toString() {
    return 'Java class declaration for $binaryName';
  }

  String get signature => 'L$internalName;';

  factory ClassDecl.fromJson(Map<String, dynamic> json) =>
      _$ClassDeclFromJson(json);

  @override
  R accept<R>(Visitor<ClassDecl, R> v) {
    return v.visit(this);
  }

  @override
  ClassDecl get classDecl => this;

  @override
  String get name => binaryName.split('.').last;

  bool get isObject => superCount == 0;

  // TODO(https://github.com/dart-lang/native/issues/1544): Use a better
  // heuristic. Class names can have dollar signs without being nested.
  @JsonKey(includeFromJson: false)
  late final String? parentName = binaryName.contains(r'$')
      ? binaryName.splitMapJoin(RegExp(r'\$[^$]+$'), onMatch: (_) => '')
      : null;

  @JsonKey(includeFromJson: false)
  late final isNested = parentName != null;

  /// Whether the class is actually only a number of top-level Kotlin Functions.
  bool get isTopLevel => kotlinPackage != null;
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

@JsonSerializable(createToJson: false)
class TypeUsage {
  TypeUsage({
    required this.shorthand,
    required this.kind,
    required this.typeJson,
  });

  static TypeUsage object = TypeUsage(
      kind: Kind.declared, shorthand: 'java.lang.Object', typeJson: {})
    ..type = DeclaredType(binaryName: 'java.lang.Object');

  final String shorthand;
  final Kind kind;

  @JsonKey(name: 'type')
  final Map<String, dynamic> typeJson;

  /// Populated by [TypeUsage.fromJson].
  @JsonKey(includeFromJson: false)
  late final ReferredType type;

  /// Populated by [Descriptor].
  @JsonKey(includeFromJson: false)
  late String descriptor;

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

  R accept<R>(TypeVisitor<R> v) {
    return type.accept(v);
  }
}

abstract class ReferredType {
  const ReferredType();
  String get name;

  R accept<R>(TypeVisitor<R> v);
}

class PrimitiveType extends ReferredType {
  static const _primitives = {
    'byte': PrimitiveType._(
      name: 'byte',
      signature: 'B',
      dartType: 'int',
      boxedName: 'Byte',
      cType: 'int8_t',
      ffiVarArgType: '\$Int32',
    ),
    'short': PrimitiveType._(
      name: 'short',
      signature: 'S',
      dartType: 'int',
      boxedName: 'Short',
      cType: 'int16_t',
      ffiVarArgType: '\$Int32',
    ),
    'char': PrimitiveType._(
      name: 'char',
      signature: 'C',
      dartType: 'int',
      boxedName: 'Character',
      cType: 'uint16_t',
      ffiVarArgType: '\$Int32',
    ),
    'int': PrimitiveType._(
      name: 'int',
      signature: 'I',
      dartType: 'int',
      boxedName: 'Integer',
      cType: 'int32_t',
      ffiVarArgType: '\$Int32',
    ),
    'long': PrimitiveType._(
      name: 'long',
      signature: 'J',
      dartType: 'int',
      boxedName: 'Long',
      cType: 'int64_t',
      ffiVarArgType: 'ffi.Int64',
    ),
    'float': PrimitiveType._(
      name: 'float',
      signature: 'F',
      dartType: 'double',
      boxedName: 'Float',
      cType: 'float',
      ffiVarArgType: 'ffi.Double',
    ),
    'double': PrimitiveType._(
      name: 'double',
      signature: 'D',
      dartType: 'double',
      boxedName: 'Double',
      cType: 'double',
      ffiVarArgType: 'ffi.Double',
    ),
    'boolean': PrimitiveType._(
      name: 'boolean',
      signature: 'Z',
      dartType: 'bool',
      boxedName: 'Boolean',
      cType: 'uint8_t',
      ffiVarArgType: '\$Int32',
    ),
    'void': PrimitiveType._(
      name: 'void',
      signature: 'V',
      dartType: 'void',
      boxedName: 'Void', // Not used.
      cType: 'void',
      ffiVarArgType: 'ffi.Void', // Not used.
    ),
  };

  const PrimitiveType._({
    required this.name,
    required this.signature,
    required this.dartType,
    required this.boxedName,
    required this.cType,
    required this.ffiVarArgType,
  });

  @override
  final String name;

  final String signature;
  final String dartType;
  final String boxedName;
  final String cType;
  final String ffiVarArgType;

  factory PrimitiveType.fromJson(Map<String, dynamic> json) {
    return _primitives[json['name']]!;
  }

  @override
  R accept<R>(TypeVisitor<R> v) {
    return v.visitPrimitiveType(this);
  }
}

@JsonSerializable(createToJson: false)
class DeclaredType extends ReferredType {
  DeclaredType({
    required this.binaryName,
    this.params = const [],
  });

  final String binaryName;
  final List<TypeUsage> params;

  @JsonKey(includeFromJson: false)
  late ClassDecl classDecl;

  @override
  String get name => binaryName;

  factory DeclaredType.fromJson(Map<String, dynamic> json) =>
      _$DeclaredTypeFromJson(json);

  @override
  R accept<R>(TypeVisitor<R> v) {
    return v.visitDeclaredType(this);
  }
}

@JsonSerializable(createToJson: false)
class TypeVar extends ReferredType {
  TypeVar({required this.name});

  @override
  String name;

  factory TypeVar.fromJson(Map<String, dynamic> json) =>
      _$TypeVarFromJson(json);

  @override
  R accept<R>(TypeVisitor<R> v) {
    return v.visitTypeVar(this);
  }
}

@JsonSerializable(createToJson: false)
class Wildcard extends ReferredType {
  Wildcard({this.extendsBound, this.superBound});
  TypeUsage? extendsBound, superBound;

  @override
  String get name => '?';

  factory Wildcard.fromJson(Map<String, dynamic> json) =>
      _$WildcardFromJson(json);

  @override
  R accept<R>(TypeVisitor<R> v) {
    return v.visitWildcard(this);
  }
}

@JsonSerializable(createToJson: false)
class ArrayType extends ReferredType {
  ArrayType({required this.type});
  TypeUsage type;

  @override
  String get name => '[${type.name}';

  factory ArrayType.fromJson(Map<String, dynamic> json) =>
      _$ArrayTypeFromJson(json);

  @override
  R accept<R>(TypeVisitor<R> v) {
    return v.visitArrayType(this);
  }
}

abstract class ClassMember {
  String get name;
  ClassDecl get classDecl;
  Set<String> get modifiers;
  String get finalName;

  bool get isAbstract => modifiers.contains('abstract');
  bool get isStatic => modifiers.contains('static');
  bool get isFinal => modifiers.contains('final');
  bool get isPublic => modifiers.contains('public');
  bool get isProtected => modifiers.contains('protected');
  bool get isSynthetic => modifiers.contains('synthetic');
  bool get isBridge => modifiers.contains('bridge');
}

@JsonSerializable(createToJson: false)
class Method extends ClassMember implements Element<Method> {
  Method({
    this.annotations = const [],
    this.javadoc,
    this.modifiers = const {},
    required this.name,
    this.descriptor,
    this.typeParams = const [],
    this.params = const [],
    required this.returnType,
  });

  @override
  final String name;
  @override
  final Set<String> modifiers;

  final List<Annotation> annotations;
  final JavaDocComment? javadoc;
  final List<TypeParam> typeParams;
  List<Param> params;
  final TypeUsage returnType;

  /// Can be used to match with [KotlinFunction]'s descriptor.
  ///
  /// Can create a unique signature in combination with [name].
  /// Populated either by the ASM backend or [Descriptor].
  String? descriptor;

  /// The [ClassDecl] where this method is defined.
  ///
  /// Populated by [Linker].
  @JsonKey(includeFromJson: false)
  @override
  late ClassDecl classDecl;

  /// Populated by [Renamer].
  @JsonKey(includeFromJson: false)
  @override
  late String finalName;

  @JsonKey(includeFromJson: false)
  late bool isOverridden;

  /// The actual return type when the method is a Kotlin's suspend fun.
  ///
  /// Populated by [KotlinProcessor].
  @JsonKey(includeFromJson: false)
  TypeUsage? asyncReturnType;

  @JsonKey(includeFromJson: false)
  late final String javaSig = '$name$descriptor';

  bool get isConstructor => name == '<init>';

  factory Method.fromJson(Map<String, dynamic> json) => _$MethodFromJson(json);

  @override
  R accept<R>(Visitor<Method, R> v) {
    return v.visit(this);
  }
}

@JsonSerializable(createToJson: false)
class Param implements Element<Param> {
  Param({
    this.annotations = const [],
    this.javadoc,
    required this.name,
    required this.type,
  });

  final List<Annotation> annotations;
  final JavaDocComment? javadoc;
  final String name;
  final TypeUsage type;

  /// Populated by [Renamer].
  @JsonKey(includeFromJson: false)
  late String finalName;

  factory Param.fromJson(Map<String, dynamic> json) => _$ParamFromJson(json);

  @override
  R accept<R>(Visitor<Param, R> v) {
    return v.visit(this);
  }
}

@JsonSerializable(createToJson: false)
class Field extends ClassMember implements Element<Field> {
  Field({
    this.annotations = const [],
    this.javadoc,
    this.modifiers = const {},
    required this.name,
    required this.type,
    this.defaultValue,
  });

  @override
  final String name;
  @override
  final Set<String> modifiers;

  final List<Annotation> annotations;
  final JavaDocComment? javadoc;
  final TypeUsage type;
  final Object? defaultValue;

  /// The [ClassDecl] where this field is defined.
  ///
  /// Populated by [Linker].
  @JsonKey(includeFromJson: false)
  @override
  late final ClassDecl classDecl;

  /// Populated by [Renamer].
  @JsonKey(includeFromJson: false)
  @override
  late final String finalName;

  factory Field.fromJson(Map<String, dynamic> json) => _$FieldFromJson(json);

  @override
  R accept<R>(Visitor<Field, R> v) {
    return v.visit(this);
  }
}

@JsonSerializable(createToJson: false)
class TypeParam implements Element<TypeParam> {
  TypeParam({required this.name, this.bounds = const []});

  final String name;
  final List<TypeUsage> bounds;

  @JsonKey(includeFromJson: false)
  late final String erasure;

  factory TypeParam.fromJson(Map<String, dynamic> json) =>
      _$TypeParamFromJson(json);

  @override
  R accept<R>(Visitor<TypeParam, R> v) {
    return v.visit(this);
  }
}

@JsonSerializable(createToJson: false)
class JavaDocComment implements Element<JavaDocComment> {
  JavaDocComment({this.comment = ''});

  final String comment;

  @JsonKey(includeFromJson: false)
  late final String dartDoc;

  factory JavaDocComment.fromJson(Map<String, dynamic> json) =>
      _$JavaDocCommentFromJson(json);

  @override
  R accept<R>(Visitor<JavaDocComment, R> v) {
    return v.visit(this);
  }
}

@JsonSerializable(createToJson: false)
class Annotation implements Element<Annotation> {
  Annotation({
    required this.binaryName,
    this.properties = const {},
  });

  final String binaryName;
  final Map<String, Object> properties;

  factory Annotation.fromJson(Map<String, dynamic> json) =>
      _$AnnotationFromJson(json);

  @override
  R accept<R>(Visitor<Annotation, R> v) {
    return v.visit(this);
  }
}

@JsonSerializable(createToJson: false)
class KotlinClass implements Element<KotlinClass> {
  KotlinClass({
    required this.name,
    this.functions = const [],
  });

  final String name;
  final List<KotlinFunction> functions;

  factory KotlinClass.fromJson(Map<String, dynamic> json) =>
      _$KotlinClassFromJson(json);

  @override
  R accept<R>(Visitor<KotlinClass, R> v) {
    return v.visit(this);
  }
}

@JsonSerializable(createToJson: false)
class KotlinPackage implements Element<KotlinPackage> {
  KotlinPackage({
    this.functions = const [],
  });

  final List<KotlinFunction> functions;

  factory KotlinPackage.fromJson(Map<String, dynamic> json) =>
      _$KotlinPackageFromJson(json);

  @override
  R accept<R>(Visitor<KotlinPackage, R> v) {
    return v.visit(this);
  }
}

@JsonSerializable(createToJson: false)
class KotlinFunction implements Element<KotlinFunction> {
  KotlinFunction({
    required this.name,
    required this.descriptor,
    required this.kotlinName,
    required this.isSuspend,
  });

  final String name;

  /// Used to match with [Method]'s descriptor.
  ///
  /// Creates a unique signature in combination with [name].
  final String descriptor;
  final String kotlinName;
  final bool isSuspend;

  factory KotlinFunction.fromJson(Map<String, dynamic> json) =>
      _$KotlinFunctionFromJson(json);

  @override
  R accept<R>(Visitor<KotlinFunction, R> v) {
    return v.visit(this);
  }
}
