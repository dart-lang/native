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
class ClassDecl with ClassMember, Annotated implements Element<ClassDecl> {
  ClassDecl({
    this.annotations,
    this.javadoc,
    required this.declKind,
    this.modifiers = const {},
    required this.binaryName,
    this.typeParams = const [],
    this.methods = const [],
    this.fields = const [],
    this.superclass,
    this.outerClassBinaryName,
    this.interfaces = const [],
    this.hasStaticInit = false,
    this.hasInstanceInit = false,
    this.values,
    this.kotlinClass,
    this.kotlinPackage,
  });

  @override
  final Set<String> modifiers;

  @override
  List<Annotation>? annotations;
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

  final String? outerClassBinaryName;

  /// Outer class's [ClassDecl] obtained from [outerClassBinaryName].
  ///
  /// Populated by [Linker].
  @JsonKey(includeFromJson: false)
  late final ClassDecl? outerClass;

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

  /// Name of the nullable type class.
  ///
  /// Populated by [Renamer].
  @JsonKey(includeFromJson: false)
  late final String nullableTypeClassName;

  /// Type parameters including the ones from its outer classes.
  ///
  /// For `Foo<T>.Bar<U, V>.Baz<W>` it is [T, U, V, W].
  ///
  /// Populated by [Linker].
  @JsonKey(includeFromJson: false)
  late final List<TypeParam> allTypeParams;

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

  @JsonKey(includeFromJson: false)
  bool get isNested => outerClassBinaryName != null;

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

  TypeUsage clone() {
    final ReferredType clonedType;
    final clonedTypeJson = {...typeJson};
    switch (kind) {
      case Kind.primitive:
        clonedType = PrimitiveType.fromJson(clonedTypeJson);
        break;
      case Kind.typeVariable:
        clonedType = TypeVar.fromJson(clonedTypeJson);
        break;
      case Kind.wildcard:
        clonedType = Wildcard.fromJson(clonedTypeJson);
        break;
      case Kind.declared:
        clonedType = DeclaredType.fromJson(clonedTypeJson);
        break;
      case Kind.array:
        clonedType = ArrayType.fromJson(clonedTypeJson);
        break;
    }
    clonedType.annotations = type.annotations;
    return TypeUsage(shorthand: shorthand, kind: kind, typeJson: clonedTypeJson)
      ..type = clonedType;
  }
}

abstract class ReferredType with Annotated {
  ReferredType();
  String get name;

  R accept<R>(TypeVisitor<R> v);
}

class PrimitiveType extends ReferredType {
  static final _primitives = {
    'byte': PrimitiveType._(
      name: 'byte',
      signature: 'B',
      dartType: 'int',
      boxedName: 'Byte',
      cType: 'int8_t',
      ffiVarArgType: 'Int32',
    ),
    'short': PrimitiveType._(
      name: 'short',
      signature: 'S',
      dartType: 'int',
      boxedName: 'Short',
      cType: 'int16_t',
      ffiVarArgType: 'Int32',
    ),
    'char': PrimitiveType._(
      name: 'char',
      signature: 'C',
      dartType: 'int',
      boxedName: 'Character',
      cType: 'uint16_t',
      ffiVarArgType: 'Int32',
    ),
    'int': PrimitiveType._(
      name: 'int',
      signature: 'I',
      dartType: 'int',
      boxedName: 'Integer',
      cType: 'int32_t',
      ffiVarArgType: 'Int32',
    ),
    'long': PrimitiveType._(
      name: 'long',
      signature: 'J',
      dartType: 'int',
      boxedName: 'Long',
      cType: 'int64_t',
      ffiVarArgType: 'Int64',
    ),
    'float': PrimitiveType._(
      name: 'float',
      signature: 'F',
      dartType: 'double',
      boxedName: 'Float',
      cType: 'float',
      ffiVarArgType: 'Double',
    ),
    'double': PrimitiveType._(
      name: 'double',
      signature: 'D',
      dartType: 'double',
      boxedName: 'Double',
      cType: 'double',
      ffiVarArgType: 'Double',
    ),
    'boolean': PrimitiveType._(
      name: 'boolean',
      signature: 'Z',
      dartType: 'bool',
      boxedName: 'Boolean',
      cType: 'uint8_t',
      ffiVarArgType: 'Int32',
    ),
    'void': PrimitiveType._(
      name: 'void',
      signature: 'V',
      dartType: 'void',
      boxedName: 'Void', // Not used.
      cType: 'void',
      ffiVarArgType: 'Void', // Not used.
    ),
  };

  PrimitiveType._({
    required this.name,
    required this.signature,
    required this.dartType,
    required this.boxedName,
    required this.cType,
    required this.ffiVarArgType,
  }) : annotations = null;

  @override
  final String name;
  @override
  List<Annotation>? annotations;

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
    this.annotations,
    this.params = const [],
  });

  final String binaryName;
  final List<TypeUsage> params;
  @override
  List<Annotation>? annotations;

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
  /// Populated by [Linker].
  @JsonKey(includeFromJson: false)
  late final TypeParam origin;

  TypeVar({
    required this.name,
    this.annotations,
  });

  @override
  String name;
  @override
  List<Annotation>? annotations;

  @override
  bool get isNullable {
    // A type-var is nullable if it is explicitly set as nullable.
    if (origin.isNullable) {
      return true;
    }
    // If origin is non-null, it has to be explicitly set as nullable.
    if (!origin.isNullable && !hasNullable) {
      return false;
    }
    return super.isNullable;
  }

  factory TypeVar.fromJson(Map<String, dynamic> json) =>
      _$TypeVarFromJson(json);

  @override
  R accept<R>(TypeVisitor<R> v) {
    return v.visitTypeVar(this);
  }
}

@JsonSerializable(createToJson: false)
class Wildcard extends ReferredType {
  Wildcard({
    this.extendsBound,
    this.superBound,
    this.annotations,
  });
  TypeUsage? extendsBound, superBound;

  @override
  String get name => '?';
  @override
  List<Annotation>? annotations;

  factory Wildcard.fromJson(Map<String, dynamic> json) =>
      _$WildcardFromJson(json);

  @override
  R accept<R>(TypeVisitor<R> v) {
    return v.visitWildcard(this);
  }
}

@JsonSerializable(createToJson: false)
class ArrayType extends ReferredType {
  ArrayType({
    required this.elementType,
    this.annotations,
  });
  TypeUsage elementType;

  @override
  String get name => '[${elementType.name}';
  @override
  List<Annotation>? annotations;

  factory ArrayType.fromJson(Map<String, dynamic> json) =>
      _$ArrayTypeFromJson(json);

  @override
  R accept<R>(TypeVisitor<R> v) {
    return v.visitArrayType(this);
  }
}

mixin Annotated {
  abstract List<Annotation>? annotations;
  late final bool hasNullable = () {
    return annotations?.any((annotation) => [
              // Taken from https://kotlinlang.org/docs/java-interop.html#nullability-annotations
              'org.jetbrains.annotations.Nullable',
              'org.jspecify.nullness.Nullable',
              'com.android.annotations.Nullable',
              'androidx.annotation.Nullable',
              'android.support.annotations.Nullable',
              'edu.umd.cs.findbugs.annotations.Nullable',
              'org.eclipse.jdt.annotation.Nullable',
              'lombok.Nullable',
              'com.github.dart_lang.jnigen.annotations.Nullable', //FIXME: remove
              'io.reactivex.rxjava3.annotations.Nullable',
            ].contains(annotation.binaryName)) ??
        false;
  }();

  late final hasNonNull = () {
    return annotations?.any((annotation) =>
            [
              // Taken from https://kotlinlang.org/docs/java-interop.html#nullability-annotations
              'org.jetbrains.annotations.NotNull',
              'org.jspecify.nullness.NonNull',
              'com.android.annotations.NonNull',
              'androidx.annotation.NonNull',
              'android.support.annotations.NonNull',
              'edu.umd.cs.findbugs.annotations.NonNull',
              'org.eclipse.jdt.annotation.NonNull',
              'lombok.NonNull',
              'com.github.dart_lang.jnigen.annotations.NotNull', //FIXME: remove
              'io.reactivex.rxjava3.annotations.NonNull',
            ].contains(annotation.binaryName) ||
            annotation.binaryName == 'javax.annotation.Nonnull' &&
                annotation.properties['when'] == 'ALWAYS') ??
        false; //FIXME
  }();

  late final bool isNullable = () {
    if (hasNullable) {
      return true;
    }
    return !hasNonNull;
  }();
}

mixin ClassMember {
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
class Method with ClassMember, Annotated implements Element<Method> {
  Method({
    this.annotations,
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
  @override
  List<Annotation>? annotations;
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
class Param with Annotated implements Element<Param> {
  Param({
    this.annotations,
    this.javadoc,
    required this.name,
    required this.type,
  });

  @override
  List<Annotation>? annotations;
  final JavaDocComment? javadoc;

  @override
  bool get isNullable => type.type.isNullable || super.hasNullable;

  // Synthetic methods might not have parameter names.
  @JsonKey(defaultValue: 'synthetic')
  final String name;

  final TypeUsage type;

  /// Populated by [Renamer].
  @JsonKey(includeFromJson: false)
  late String finalName;

  /// Populated by [Linker].
  @JsonKey(includeFromJson: false)
  late final Method method;

  factory Param.fromJson(Map<String, dynamic> json) => _$ParamFromJson(json);

  @override
  R accept<R>(Visitor<Param, R> v) {
    return v.visit(this);
  }
}

@JsonSerializable(createToJson: false)
class Field with ClassMember, Annotated implements Element<Field> {
  Field({
    this.annotations,
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

  @override
  List<Annotation>? annotations;
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
class TypeParam with Annotated implements Element<TypeParam> {
  TypeParam({
    required this.name,
    this.bounds = const [],
    this.annotations,
  });

  final String name;
  final List<TypeUsage> bounds;

  @override
  List<Annotation>? annotations;

  @override
  bool get isNullable {
    // A type param with any non-null bound is non-null.
    final hasNonNullBounds = bounds.any((bound) => !bound.type.isNullable);
    return super.isNullable && !hasNonNullBounds;
  }

  /// Can either be a [ClassDecl] or a [Method].
  ///
  /// Populated by [Linker].
  @JsonKey(includeFromJson: false)
  late final ClassMember parent;

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

List<TypePathStep> _typePathFromString(String? string) {
  if (string == null) return const [];
  const innerClass = 46;
  assert(innerClass == '.'.codeUnitAt(0));
  const array = 91;
  assert(array == '['.codeUnitAt(0));
  const wildcard = 42;
  assert(wildcard == '*'.codeUnitAt(0));
  const digit0 = 48;
  assert(digit0 == '0'.codeUnitAt(0));
  const digit9 = 57;
  assert(digit9 == '9'.codeUnitAt(0));
  const digitEnd = 59;
  assert(digit9 == ';'.codeUnitAt(0));
  final typePaths = <TypePathStep>[];
  var number = 0;
  for (final codeUnit in string.codeUnits) {
    switch (codeUnit) {
      case array:
        typePaths.add(const ToArrayElement());
      case wildcard:
        typePaths.add(const ToWildcardBound());
      case innerClass:
        typePaths.add(const ToInnerClass());
      case >= digit0 && <= digit9:
        number = number * 10 + codeUnit - digit0;
      case digitEnd:
        typePaths.add(ToTypeParam(number));
        number = 0;
      default:
        throw const FormatException('Invalid type path');
    }
  }
  return typePaths;
}

sealed class TypePathStep {
  const TypePathStep();
}

final class ToArrayElement extends TypePathStep {
  const ToArrayElement();
  @override
  String toString() {
    return '[';
  }
}

final class ToInnerClass extends TypePathStep {
  const ToInnerClass();
  @override
  String toString() {
    return '.';
  }
}

final class ToWildcardBound extends TypePathStep {
  const ToWildcardBound();
  @override
  String toString() {
    return '*';
  }
}

final class ToTypeParam extends TypePathStep {
  final int index;
  const ToTypeParam(this.index);
  @override
  String toString() {
    return '$index;';
  }
}

@JsonSerializable(createToJson: false)
class Annotation implements Element<Annotation> {
  /// Specifies that this type can be null.
  static const Annotation nullable =
      // Any other valid `Nullable` annotation would work.
      Annotation(binaryName: 'androidx.annotation.Nullable');

  /// Specifies that this type cannot be null.
  static const Annotation nonNull =
      // Any other valid `NonNull` annotation would work.
      Annotation(binaryName: 'androidx.annotation.NonNull');

  const Annotation({
    required this.binaryName,
    this.properties = const {},
    this.typePath = const [],
  });

  final String binaryName;
  final Map<String, Object> properties;

  @JsonKey(fromJson: _typePathFromString)
  final List<TypePathStep> typePath;

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
