// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';

import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;

import '../bindings/visitor.dart';

part 'elements.g.dart';

/// The stage in the generation pipeline.
enum GenerationStage {
  // The order of the enum elements must match the order in
  // `../generate_bindings.dart`.
  unprocessed,
  importer,
  kotlinProcessor,
  linker,
  graphBuilder,
  userTransformers,
  exporter,
  dartGenerator;

  bool operator <=(GenerationStage stage) {
    return index <= stage.index;
  }
}

base mixin Element<T extends Element<T>> {
  R accept<R>(ElementVisitor<T, R> v);
}

base mixin Annotated {
  abstract List<Annotation>? annotations;

  static final nullableAnnotations = [
    // Taken from https://kotlinlang.org/docs/java-interop.html#nullability-annotations
    'org.jetbrains.annotations.Nullable',
    'org.jspecify.nullness.Nullable',
    'com.android.annotations.Nullable',
    'androidx.annotation.Nullable',
    'android.support.annotations.Nullable',
    'edu.umd.cs.findbugs.annotations.Nullable',
    'org.eclipse.jdt.annotation.Nullable',
    'lombok.Nullable',
    'io.reactivex.rxjava3.annotations.Nullable',
  ];
  bool get hasNullable {
    return annotations?.any(
          (annotation) =>
              nullableAnnotations.contains(annotation.binaryName) ||
              annotation.binaryName == 'javax.annotation.Nullable' &&
                  annotation.properties['when'] == 'ALWAYS',
        ) ??
        false;
  }

  static final nonNullAnnotations = [
    // Taken from https://kotlinlang.org/docs/java-interop.html#nullability-annotations
    'org.jetbrains.annotations.NotNull',
    'org.jspecify.nullness.NonNull',
    'com.android.annotations.NonNull',
    'androidx.annotation.NonNull',
    'android.support.annotations.NonNull',
    'edu.umd.cs.findbugs.annotations.NonNull',
    'org.eclipse.jdt.annotation.NonNull',
    'lombok.NonNull',
    'io.reactivex.rxjava3.annotations.NonNull',
  ];
  bool get hasNonNull {
    return annotations?.any(
          (annotation) =>
              nonNullAnnotations.contains(annotation.binaryName) ||
              annotation.binaryName == 'javax.annotation.Nonnull' &&
                  annotation.properties['when'] == 'ALWAYS',
        ) ??
        false;
  }

  bool get hasNullabilityAnnotations => hasNonNull || hasNullable;

  bool get isNullable {
    if (hasNullable) {
      return true;
    }
    return !hasNonNull;
  }
}

base mixin HasModifiers<T extends Element<T>> on Element<T> {
  Set<String> get modifiers;

  bool get isAbstract => modifiers.contains('abstract');
  bool get isStatic => modifiers.contains('static');
  bool get isFinal => modifiers.contains('final');
  bool get isPublic => modifiers.contains('public');
  bool get isProtected => modifiers.contains('protected');
  bool get isSynthetic => modifiers.contains('synthetic');
  bool get isBridge => modifiers.contains('bridge');
}

base mixin Importable<T extends Element<T>> on Element<T> {
  /// Whether this class has been imported from a different JNIgen-generated
  /// package.
  ///
  /// Can be modified in [GenerationStage.importer].
  @JsonKey(includeFromJson: false)
  bool isImported = false;
}

/// Represents an element that could potentially be renamed.
base mixin Renamable<T extends Element<T>> on Element<T> {
  /// The name used in JVM bytecode or Java source.
  ///
  /// Might be different to [originalName] for Kotlin code.
  @JsonKey(includeFromJson: false)
  String get name;

  /// Defaults to [name] but will be changed to the original Kotlin name of the
  /// element in [GenerationStage.kotlinProcessor] if it has originated from
  /// Kotlin.
  @JsonKey(includeFromJson: false)
  late String originalName = name;

  /// The name loaded from the API stability file.
  ///
  /// Populated in [GenerationStage.importer].
  @JsonKey(includeFromJson: false)
  // FIXME
  late final String? stableName = null;

  /// The name used in the generated bindings.
  @JsonKey(includeFromJson: false)
  String? finalName;
}

base mixin Excludable<T extends Element<T>> on Element<T> {
  /// Whether this element is excluded from the generated bindings.
  @JsonKey(includeFromJson: false)
  bool isExcluded = false;
}

/// A kind describes the type of a declaration.
@JsonEnum()
enum DeclKind {
  @JsonValue('CLASS')
  classKind,
  @JsonValue('INTERFACE')
  interfaceKind,
  @JsonValue('ENUM')
  enumKind,
}

final class Classes with Element<Classes> {
  Classes(this.decls);

  final Map<String, ClassDecl> decls;

  /// Populated in [GenerationStage.importer].
  final Map<String, ClassDecl> importedClasses = {};

  /// Populated in [GenerationStage.linker].
  final Map<String, DartFile> files =
      HashMap(equals: p.equals, hashCode: p.hash);

  factory Classes.fromJson(List<dynamic> json) {
    final decls = <String, ClassDecl>{};
    for (final declJson in json) {
      final classDecl = ClassDecl.fromJson(declJson as Map<String, dynamic>);
      decls[classDecl.binaryName] = classDecl;
    }
    return Classes(decls);
  }

  @override
  R accept<R>(ElementVisitor<Classes, R> v) {
    return v.visit(this);
  }
}

final class DartFile with Element<DartFile>, Importable {
  final String path;
  final Map<String, ClassDecl> classes;
  final List<DartFile> exports = [];

  DartFile(this.path, this.classes);

  @override
  R accept<R>(ElementVisitor<DartFile, R> v) {
    return v.visit(this);
  }
}

// Note: We give default values in constructor, if the field is nullable in
// JSON. this allows us to reduce JSON size by providing Include.NON_NULL
// option in java.

@JsonSerializable(createToJson: false)
final class ClassDecl
    with
        Element<ClassDecl>,
        HasModifiers,
        Annotated,
        Renamable,
        Excludable,
        Importable {
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

  /// The type parameters introduced by this exact class.
  ///
  /// Does not contain the type parameters of any outer-classes if this class
  /// is a non-static inner-class. For a list of all type parameters including
  /// the ones from the outer-classes, use [allTypeParams].
  List<TypeParam> typeParams;
  List<Method> methods;
  List<Field> fields;
  final List<ReferredType> interfaces;

  /// Will default to java.lang.Object if null in [GenerationStage.linker].
  ReferredType? superclass;

  final String? outerClassBinaryName;

  /// Outer class's [ClassDecl] obtained from [outerClassBinaryName].
  ///
  /// Populated in [GenerationStage.linker].
  @JsonKey(includeFromJson: false)
  late ClassDecl? outerClass;

  /// Contains enum constant names if class is an enum,
  /// as obtained by `.values()` method in Java.
  final List<String>? values;

  String get internalName => binaryName.replaceAll('.', '/');

  String get packageName => (binaryName.split('.')..removeLast()).join('.');

  /// The number of super classes this type has.
  ///
  /// Populated in [GenerationStage.linker].
  @JsonKey(includeFromJson: false)
  late int superCount;

  /// Classes can have custom added fields and methods. This is used to ensure
  /// the identifiers of these extra members do not collide with the other
  /// identifiers present in the class.
  ///
  /// Populated in [GenerationStage.importer].
  @JsonKey(includeFromJson: false)
  final Set<String> extraMembers = {};

  /// Name of the type class.
  @JsonKey(includeFromJson: false)
  String get typeClassName => '\$$finalName\$Type\$';

  /// Name of the nullable type class.
  String get nullableTypeClassName => '\$$finalName\$NullableType\$';

  /// Type parameters including the ones from its outer classes.
  ///
  /// For `Foo<T>.Bar<U, V>.Baz<W>` it is [T, U, V, W].
  ///
  /// Populated in [GenerationStage.linker].
  @JsonKey(includeFromJson: false)
  late List<TypeParam> allTypeParams;

  /// The file which this class is generated in.
  ///
  /// Populated in [GenerationStage.linker].
  @JsonKey(includeFromJson: false)
  late DartFile file;

  /// Populated in [GenerationStage.linker].
  @JsonKey(includeFromJson: false)
  final Map<Operator, Method> operators = {};

  /// The `compareTo` method of this class.
  ///
  /// This method must take a single parameter of the same type of the enclosing
  /// class, and return integer.
  ///
  /// Used for overloading comparison operators.
  ///
  /// Populated in [GenerationStage.linker].
  @JsonKey(includeFromJson: false)
  Method? compareTo;

  @override
  String toString() {
    return 'Java class declaration for $binaryName';
  }

  String get signature => 'L$internalName;';

  factory ClassDecl.fromJson(Map<String, dynamic> json) =>
      _$ClassDeclFromJson(json);

  @override
  R accept<R>(ElementVisitor<ClassDecl, R> v) {
    return v.visit(this);
  }

  /// Simple name of this class without the outerclasses.
  ///
  /// This is not uniquely identifiable from the [binaryName]. For instance,
  /// `com.xyz.Foo$Bar` could represent a class named `Bar` that is nested in a
  /// class name `Foo` in which case its name is `Bar`. But it can also
  /// represent a class named `Foo$Bar`.
  @override
  String get name => binaryName
      .substring((outerClassBinaryName?.length ?? -1) + 1)
      .split('.')
      .last;

  bool get isObject => superCount == 0;

  @JsonKey(includeFromJson: false)
  bool get isNested => outerClassBinaryName != null;

  /// Whether the class is actually only a number of top-level Kotlin Functions
  /// and properties.
  @JsonKey(includeFromJson: false)
  late bool isTopLevel = kotlinPackage != null;
}

@JsonEnum(fieldRename: FieldRename.screamingSnake, alwaysCreate: true)
enum TypeKind {
  primitive,
  typeVariable,
  wildcard,
  declared,
  array,
}

sealed class ReferredType with Annotated {
  ReferredType();

  String get name;

  /// Populated in [GenerationStage.linker].
  @JsonKey(includeFromJson: false)
  String? descriptor;

  // Since json_serializable doesn't directly support union types,
  // we have to temporarily store `type` in a JSON map, and switch on the
  // enum value received.
  factory ReferredType.fromJson(Map<String, dynamic> json) {
    final kind = $enumDecode(_$TypeKindEnumMap, json['kind']);
    final typeJson = json['type'] as Map<String, dynamic>;
    switch (kind) {
      case TypeKind.primitive:
        return PrimitiveType.fromJson(typeJson);
      case TypeKind.typeVariable:
        return TypeVar.fromJson(typeJson);
      case TypeKind.wildcard:
        return Wildcard.fromJson(typeJson);
      case TypeKind.declared:
        return DeclaredType.fromJson(typeJson);
      case TypeKind.array:
        return ArrayType.fromJson(typeJson);
    }
  }

  R accept<R>(TypeVisitor<R> v);

  ReferredType clone({GenerationStage until = GenerationStage.unprocessed});
}

final class PrimitiveType extends ReferredType {
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
  String toString() => name;

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

  @override
  PrimitiveType clone({GenerationStage until = GenerationStage.unprocessed}) {
    final cloned = PrimitiveType._(
      boxedName: boxedName,
      cType: cType,
      dartType: dartType,
      ffiVarArgType: ffiVarArgType,
      name: name,
      signature: signature,
    );
    if (GenerationStage.linker <= until) {
      cloned.descriptor = descriptor;
    }
    return cloned;
  }
}

@JsonSerializable(createToJson: false)
final class DeclaredType extends ReferredType {
  static final object = DeclaredType(binaryName: 'java.lang.Object');

  DeclaredType({
    required this.binaryName,
    this.annotations,
    this.params = const [],
  });

  final String binaryName;
  final List<ReferredType> params;
  @override
  List<Annotation>? annotations;

  @JsonKey(includeFromJson: false)
  late ClassDecl classDecl;

  @override
  String get name => binaryName;

  @override
  String toString() {
    if (params.isEmpty) return binaryName;
    return '$binaryName<${params.join(', ')}>';
  }

  factory DeclaredType.fromJson(Map<String, dynamic> json) =>
      _$DeclaredTypeFromJson(json);

  @override
  R accept<R>(TypeVisitor<R> v) {
    return v.visitDeclaredType(this);
  }

  @override
  bool get hasNullabilityAnnotations =>
      super.hasNullabilityAnnotations ||
      params.any((param) => param.hasNullabilityAnnotations);

  @override
  DeclaredType clone({GenerationStage until = GenerationStage.unprocessed}) {
    final cloned = DeclaredType(
      binaryName: binaryName,
      annotations: [...?annotations],
      params: params.map((param) => param.clone(until: until)).toList(),
    );
    if (GenerationStage.linker <= until) {
      cloned.descriptor = descriptor;
    }
    return cloned;
  }
}

@JsonSerializable(createToJson: false)
final class TypeVar extends ReferredType {
  /// Populated in [GenerationStage.linker].
  @JsonKey(includeFromJson: false)
  late TypeParam origin;

  TypeVar({required this.name, this.annotations});

  @override
  String name;

  @override
  String toString() => name;

  @override
  List<Annotation>? annotations;

  @override
  bool get isNullable {
    // A type-var is nullable if its origin is nullable.
    if (origin.isNullable) {
      return true;
    }
    // If origin is non-null, it has to be explicitly set as nullable.
    if (!origin.isNullable && !hasNullable) {
      return false;
    }
    return super.isNullable;
  }

  /// Whether this type-variable has a question mark.
  ///
  /// This is different from [isNullable], a type-variable that extends
  /// `JObject?` is nullable, so to get the reference from an object with this
  /// type, a null check is needed. However type-variables can have an extra
  /// question mark, meaning that even if the original type extends `JObject`,
  /// this is nullable.
  bool get hasQuestionMark {
    // If the origin has any nullability set, this will only be nullable if it
    // is explicitly set to be.
    if (origin.hasNonNull || origin.hasNullable) {
      return hasNullable;
    }
    // Otherwise it is always nullable unless explicitly set to be
    // non-nullable.
    return !hasNonNull;
  }

  factory TypeVar.fromJson(Map<String, dynamic> json) =>
      _$TypeVarFromJson(json);

  @override
  R accept<R>(TypeVisitor<R> v) {
    return v.visitTypeVar(this);
  }

  @override
  TypeVar clone({GenerationStage until = GenerationStage.unprocessed}) {
    final cloned = TypeVar(name: name, annotations: [...?annotations]);
    if (GenerationStage.linker <= until) {
      cloned.origin = origin;
      cloned.descriptor = descriptor;
    }
    return cloned;
  }
}

@JsonSerializable(createToJson: false)
final class Wildcard extends ReferredType {
  Wildcard({this.extendsBound, this.superBound, this.annotations});
  ReferredType? extendsBound;
  ReferredType? superBound;

  @override
  bool get isNullable =>
      super.isNullable &&
      // If the extends bound is non-null, this is non-null.
      !(extendsBound?.hasNonNull ?? false);

  @override
  String get name {
    if (extendsBound != null) {
      return '? extends ${extendsBound!.name}';
    }
    if (superBound != null) {
      return '? super ${superBound!.name}';
    }
    return '?';
  }

  @override
  String toString() => name;

  @override
  List<Annotation>? annotations;

  factory Wildcard.fromJson(Map<String, dynamic> json) =>
      _$WildcardFromJson(json);

  @override
  R accept<R>(TypeVisitor<R> v) {
    return v.visitWildcard(this);
  }

  @override
  bool get hasNullabilityAnnotations =>
      super.hasNullabilityAnnotations ||
      (superBound?.hasNullabilityAnnotations ?? false) ||
      (extendsBound?.hasNullabilityAnnotations ?? false);

  @override
  Wildcard clone({GenerationStage until = GenerationStage.unprocessed}) {
    final cloned = Wildcard(
      annotations: [...?annotations],
      extendsBound: extendsBound?.clone(until: until),
      superBound: superBound?.clone(until: until),
    );
    if (GenerationStage.linker <= until) {
      cloned.descriptor = descriptor;
    }
    return cloned;
  }
}

@JsonSerializable(createToJson: false)
final class ArrayType extends ReferredType {
  ArrayType({required this.elementType, this.annotations});
  ReferredType elementType;

  @override
  String get name => '${elementType.name}[]';

  @override
  String toString() => name;

  @override
  List<Annotation>? annotations;

  factory ArrayType.fromJson(Map<String, dynamic> json) =>
      _$ArrayTypeFromJson(json);

  @override
  R accept<R>(TypeVisitor<R> v) {
    return v.visitArrayType(this);
  }

  @override
  bool get hasNullabilityAnnotations =>
      super.hasNullabilityAnnotations || elementType.hasNullabilityAnnotations;

  @override
  ArrayType clone({GenerationStage until = GenerationStage.unprocessed}) {
    final cloned = ArrayType(
      elementType: elementType.clone(until: until),
      annotations: [...?annotations],
    );
    if (GenerationStage.linker <= until) {
      cloned.descriptor = descriptor;
    }
    return cloned;
  }
}

/// This class represents the shared state of all [Method]s of the same name and
/// signature within a class hierarchy.
final class SharedMethodState {
  String? finalName;
  bool isExcluded = false;

  SharedMethodState();
}

@JsonSerializable(createToJson: false)
final class Method
    with
        Element<Method>,
        HasModifiers,
        Annotated,
        Renamable,
        Excludable,
        Importable {
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

  /// The original name in the bytecode or Java source. Might be different to
  /// [originalName] for Kotlin methods.
  @override
  final String name;

  @override
  final Set<String> modifiers;
  @override
  List<Annotation>? annotations;
  final JavaDocComment? javadoc;
  List<TypeParam> typeParams;
  List<Param> params;
  ReferredType returnType;

  /// Populated in [GenerationStage.kotlinProcessor].
  @JsonKey(includeFromJson: false)
  KotlinFunction? kotlinFunction;

  /// The actual return type when the method is a Kotlin's suspend fun.
  ///
  /// Populated in [GenerationStage.kotlinProcessor].
  @JsonKey(includeFromJson: false)
  ReferredType? asyncReturnType;

  /// The [ClassDecl] where this method is defined.
  ///
  /// Populated in [GenerationStage.linker].
  @JsonKey(includeFromJson: false)
  late ClassDecl classDecl;

  /// Populated in [GenerationStage.linker].
  @JsonKey(includeFromJson: false)
  late SharedMethodState sharedState = SharedMethodState();

  @JsonKey(includeFromJson: false)
  @override
  // ignore: overridden_fields
  late String originalName = name == '<init>' ? 'new' : name;

  @override
  String? get finalName => sharedState.finalName;

  @override
  set finalName(String? finalName) {
    sharedState.finalName = finalName;
  }

  @override
  bool get isExcluded => sharedState.isExcluded;

  @override
  set isExcluded(bool isExcluded) {
    sharedState.isExcluded = isExcluded;
  }

  /// Can be used to match with [KotlinFunction]'s descriptor.
  ///
  /// Can create a unique signature in combination with [name].
  /// Populated either by the ASM backend or in [GenerationStage.linker].
  String? descriptor;

  @JsonKey(includeFromJson: false)
  late String javaSig = '$name$descriptor';

  bool get isConstructor => name == '<init>';

  factory Method.fromJson(Map<String, dynamic> json) => _$MethodFromJson(json);

  Method clone({GenerationStage until = GenerationStage.unprocessed}) {
    final cloned = Method(
      name: name,
      returnType: returnType.clone(until: until),
      annotations: [...?annotations],
      descriptor: descriptor,
      javadoc: javadoc,
      modifiers: {...modifiers},
      params: params.map((param) => param.clone(until: until)).toList(),
      typeParams:
          typeParams.map((typeParam) => typeParam.clone(until: until)).toList(),
    );

    // In the reversed order of [GenerationStage]. So each stage sets all the
    // properties of the previous steps.
    switch (until) {
      case GenerationStage.dartGenerator:
      case GenerationStage.exporter:
      case GenerationStage.userTransformers:
        cloned.isExcluded = isExcluded;
        cloned.finalName = finalName;
        continue graphBuilder;
      graphBuilder:
      case GenerationStage.graphBuilder:
      case GenerationStage.linker:
        cloned.descriptor = descriptor;
        cloned.classDecl = classDecl;
        for (final param in cloned.params) {
          param.method = cloned;
        }
        for (final typeParam in cloned.typeParams) {
          typeParam.parent = cloned;
        }
        cloned.sharedState = sharedState;
        continue kotlinProcessor;
      kotlinProcessor:
      case GenerationStage.kotlinProcessor:
        cloned.kotlinFunction = kotlinFunction;
        cloned.asyncReturnType = asyncReturnType;
        continue importer;
      importer:
      case GenerationStage.importer:
      case GenerationStage.unprocessed:
    }
    return cloned;
  }

  @override
  R accept<R>(ElementVisitor<Method, R> v) {
    return v.visit(this);
  }
}

@JsonSerializable(createToJson: false)
final class Param with Element<Param>, Annotated, Renamable, Importable {
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
  bool get isNullable => type.isNullable || super.hasNullable;

  // Synthetic methods might not have parameter names.
  @override
  @JsonKey(defaultValue: 'synthetic')
  final String name;

  ReferredType type;

  /// Populated in [GenerationStage.linker].
  @JsonKey(includeFromJson: false)
  late Method method;

  factory Param.fromJson(Map<String, dynamic> json) => _$ParamFromJson(json);

  Param clone({GenerationStage until = GenerationStage.unprocessed}) {
    final cloned = Param(
      name: name,
      type: type,
      annotations: [...?annotations],
      javadoc: javadoc,
    );
    if (GenerationStage.linker <= until) {
      cloned.method = method;
    }
    if (GenerationStage.userTransformers <= until) {
      cloned.finalName = finalName;
    }
    return cloned;
  }

  @override
  R accept<R>(ElementVisitor<Param, R> v) {
    return v.visit(this);
  }
}

/// This class represents the shared state of all [Field]s of the same name and
/// type within a class hierarchy.
final class SharedFieldState {
  String? finalName;
  bool isExcluded = false;

  SharedFieldState();
}

@JsonSerializable(createToJson: false)
final class Field
    with
        Element<Field>,
        HasModifiers,
        Annotated,
        Renamable,
        Excludable,
        Importable {
  Field({
    this.annotations,
    this.javadoc,
    this.modifiers = const {},
    required this.name,
    required this.type,
    required this.descriptor,
    this.defaultValue,
  });

  @override
  final String name;
  @override
  final Set<String> modifiers;

  @override
  List<Annotation>? annotations;
  final JavaDocComment? javadoc;
  final ReferredType type;
  final Object? defaultValue;

  /// Can be used to match with [KotlinFunction]'s descriptor.
  ///
  /// Can create a unique signature in combination with [name].
  /// Populated either by the ASM backend or in [GenerationStage.linker].
  String? descriptor;

  /// The [ClassDecl] where this field is defined.
  ///
  /// Populated in [GenerationStage.linker].
  @JsonKey(includeFromJson: false)
  late ClassDecl classDecl;

  /// Populated in [GenerationStage.linker].
  @JsonKey(includeFromJson: false)
  late SharedFieldState sharedState = SharedFieldState();

  @override
  String? get finalName => sharedState.finalName;

  @override
  set finalName(String? finalName) {
    sharedState.finalName = finalName;
  }

  factory Field.fromJson(Map<String, dynamic> json) => _$FieldFromJson(json);

  @override
  R accept<R>(ElementVisitor<Field, R> v) {
    return v.visit(this);
  }
}

@JsonSerializable(createToJson: false)
final class TypeParam with Element<TypeParam>, Annotated {
  TypeParam({required this.name, this.bounds = const [], this.annotations});

  final String name;
  final List<ReferredType> bounds;

  @override
  List<Annotation>? annotations;

  @override
  bool get hasNonNull =>
      // A type param with any non-null bound is non-null.
      super.hasNonNull || bounds.any((bound) => !bound.isNullable);

  /// Can either be a [ClassDecl] or a [Method].
  ///
  /// Populated in [GenerationStage.linker].
  @JsonKey(includeFromJson: false)
  late HasModifiers parent;

  factory TypeParam.fromJson(Map<String, dynamic> json) =>
      _$TypeParamFromJson(json);

  /// Set [parent] after cloning.
  TypeParam clone({GenerationStage until = GenerationStage.unprocessed}) {
    final cloned = TypeParam(
      name: name,
      annotations: [...?annotations],
      bounds: bounds.map((bound) => bound.clone(until: until)).toList(),
    );
    if (GenerationStage.linker <= until) {
      cloned.parent = parent;
    }
    return cloned;
  }

  @override
  R accept<R>(ElementVisitor<TypeParam, R> v) {
    return v.visit(this);
  }
}

@JsonSerializable(createToJson: false)
final class JavaDocComment with Element<JavaDocComment> {
  JavaDocComment({this.comment = ''});

  final String comment;

  factory JavaDocComment.fromJson(Map<String, dynamic> json) =>
      _$JavaDocCommentFromJson(json);

  @override
  R accept<R>(ElementVisitor<JavaDocComment, R> v) {
    return v.visit(this);
  }
}

@visibleForTesting
List<TypePathStep> typePathFromString(String? string) {
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
  const semicolon = 59;
  assert(semicolon == ';'.codeUnitAt(0));
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
      case semicolon:
        typePaths.add(ToTypeParam(number));
        number = 0;
      default:
        throw const FormatException('Invalid type path');
    }
  }
  return typePaths;
}

final class TypePathStep {
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

  @override
  bool operator ==(Object other) {
    return other is ToTypeParam && index == other.index;
  }

  @override
  int get hashCode => (ToTypeParam).hashCode ^ index.hashCode;
}

@JsonSerializable(createToJson: false)
final class Annotation with Element<Annotation> {
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

  @JsonKey(fromJson: typePathFromString)
  final List<TypePathStep> typePath;

  factory Annotation.fromJson(Map<String, dynamic> json) =>
      _$AnnotationFromJson(json);

  @override
  R accept<R>(ElementVisitor<Annotation, R> v) {
    return v.visit(this);
  }
}

@JsonSerializable(createToJson: false)
final class KotlinClass with Element<KotlinClass> {
  KotlinClass({
    required this.name,
    required this.moduleName,
    this.functions = const [],
    this.properties = const [],
    this.constructors = const [],
    this.typeParameters = const [],
    this.contextReceiverTypes = const [],
    this.superTypes = const [],
    this.nestedClasses = const [],
    this.enumEntries = const [],
    this.sealedClasses = const [],
    required this.companionObject,
    required this.inlineClassUnderlyingPropertyName,
    required this.inlineClassUnderlyingType,
    required this.flags,
    required this.jvmFlags,
  });

  final String name;
  final String moduleName;
  final List<KotlinFunction> functions;
  final List<KotlinProperty> properties;
  final List<KotlinConstructor> constructors;
  final List<KotlinTypeParameter> typeParameters;
  final List<KotlinType> contextReceiverTypes;
  final List<KotlinType> superTypes;
  final List<String> nestedClasses;
  final List<String> enumEntries;
  final List<String> sealedClasses;
  final String? companionObject;
  final String? inlineClassUnderlyingPropertyName;
  final KotlinType? inlineClassUnderlyingType;
  final int flags;
  final int jvmFlags;

  factory KotlinClass.fromJson(Map<String, dynamic> json) =>
      _$KotlinClassFromJson(json);

  @override
  R accept<R>(ElementVisitor<KotlinClass, R> v) {
    return v.visit(this);
  }
}

@JsonSerializable(createToJson: false)
final class KotlinPackage with Element<KotlinPackage> {
  KotlinPackage({this.functions = const [], this.properties = const []});

  final List<KotlinFunction> functions;
  final List<KotlinProperty> properties;

  factory KotlinPackage.fromJson(Map<String, dynamic> json) =>
      _$KotlinPackageFromJson(json);

  @override
  R accept<R>(ElementVisitor<KotlinPackage, R> v) {
    return v.visit(this);
  }
}

@JsonSerializable(createToJson: false)
final class KotlinFunction {
  KotlinFunction({
    required this.name,
    required this.descriptor,
    required this.kotlinName,
    this.valueParameters = const [],
    required this.returnType,
    this.receiverParameterType,
    this.contextReceiverTypes = const [],
    this.typeParameters = const [],
    required this.flags,
    required this.isSuspend,
    required this.isOperator,
    required this.isPublic,
    required this.isPrivate,
    required this.isProtected,
    required this.isInternal,
  });

  /// Name in the byte code.
  final String name;
  final String descriptor;

  /// Name in the Kotlin's metadata.
  final String kotlinName;

  final List<KotlinValueParameter> valueParameters;
  final KotlinType returnType;
  final KotlinType? receiverParameterType;
  final List<KotlinType> contextReceiverTypes;
  final List<KotlinTypeParameter> typeParameters;
  final int flags;
  final bool isSuspend;
  final bool isOperator;
  final bool isPublic;
  final bool isPrivate;
  final bool isProtected;
  final bool isInternal;

  factory KotlinFunction.fromJson(Map<String, dynamic> json) =>
      _$KotlinFunctionFromJson(json);
}

@JsonSerializable(createToJson: false)
final class KotlinConstructor with Element<KotlinConstructor> {
  KotlinConstructor({
    required this.name,
    required this.descriptor,
    this.valueParameters = const [],
    required this.flags,
  });

  final String name;
  final String descriptor;
  final List<KotlinValueParameter> valueParameters;
  final int flags;

  factory KotlinConstructor.fromJson(Map<String, dynamic> json) =>
      _$KotlinConstructorFromJson(json);

  @override
  R accept<R>(ElementVisitor<KotlinConstructor, R> v) {
    return v.visit(this);
  }
}

@JsonSerializable(createToJson: false)
final class KotlinProperty with Element<KotlinProperty> {
  KotlinProperty({
    this.fieldName,
    this.fieldDescriptor,
    this.getterName,
    this.getterDescriptor,
    this.setterName,
    this.setterDescriptor,
    required this.kotlinName,
    required this.returnType,
    required this.receiverParameterType,
    this.contextReceiverTypes = const [],
    required this.jvmFlags,
    required this.flags,
    required this.setterFlags,
    required this.getterFlags,
    this.typeParameters = const [],
    required this.setterParameter,
  });

  final String? fieldName;
  final String? fieldDescriptor;

  /// Getter's name in the byte code.
  final String? getterName;
  final String? getterDescriptor;

  /// Setter's name in the byte code.
  final String? setterName;
  final String? setterDescriptor;

  /// Name in the Kotlin's metadata.
  final String kotlinName;

  final KotlinType returnType;
  final KotlinType? receiverParameterType;
  final List<KotlinType> contextReceiverTypes;
  final int jvmFlags;
  final int flags;
  final int setterFlags;
  final int getterFlags;
  final List<KotlinTypeParameter> typeParameters;
  final KotlinValueParameter? setterParameter;

  factory KotlinProperty.fromJson(Map<String, dynamic> json) =>
      _$KotlinPropertyFromJson(json);

  @override
  R accept<R>(ElementVisitor<KotlinProperty, R> v) {
    return v.visit(this);
  }
}

@JsonSerializable(createToJson: false)
final class KotlinType with Element<KotlinType> {
  KotlinType({
    required this.flags,
    required this.kind,
    required this.name,
    required this.id,
    required this.isNullable,
    this.arguments = const [],
  });

  final int flags;
  final String kind;
  final String? name;
  final int id;
  final List<KotlinTypeArgument> arguments;
  final bool isNullable;

  factory KotlinType.fromJson(Map<String, dynamic> json) =>
      _$KotlinTypeFromJson(json);

  @override
  R accept<R>(ElementVisitor<KotlinType, R> v) {
    return v.visit(this);
  }

  String? toDocComment(List<TypeParam> typeParametersByIndex) {
    final typeList = arguments.map((a) => switch (a) {
          KotlinWildcard() => '*',
          KotlinTypeProjection() => a.type.toDocComment(typeParametersByIndex),
        });
    final typeArgs = typeList.isNotEmpty ? '<${typeList.join(', ')}>' : '';
    final typeName = name == null
        ? typeParametersByIndex[id].name
        // Translate JVM internal form (aka binary name form) to Kotlin form.
        : name!.replaceAll('/', '.').replaceAll('\$', '.');
    return '$typeName$typeArgs${isNullable ? '?' : ''}';
  }
}

@JsonEnum()
enum KmVariance {
  @JsonValue('INVARIANT')
  invariant,
  @JsonValue('IN')
  contravariant,
  @JsonValue('OUT')
  covariant,
}

@JsonSerializable(createToJson: false)
final class KotlinTypeParameter with Element<KotlinTypeParameter> {
  KotlinTypeParameter({
    required this.name,
    required this.id,
    required this.flags,
    this.upperBounds = const [],
    required this.variance,
  });

  final String name;
  final int id;
  final int flags;
  final List<KotlinType> upperBounds;
  final KmVariance variance;

  factory KotlinTypeParameter.fromJson(Map<String, dynamic> json) =>
      _$KotlinTypeParameterFromJson(json);

  @override
  R accept<R>(ElementVisitor<KotlinTypeParameter, R> v) {
    return v.visit(this);
  }
}

@JsonSerializable(createToJson: false)
final class KotlinValueParameter with Element<KotlinValueParameter> {
  KotlinValueParameter({
    required this.name,
    required this.flags,
    required this.type,
    required this.varargElementType,
  });

  final String name;
  final int flags;
  final KotlinType type;
  final KotlinType? varargElementType;

  factory KotlinValueParameter.fromJson(Map<String, dynamic> json) =>
      _$KotlinValueParameterFromJson(json);

  @override
  R accept<R>(ElementVisitor<KotlinValueParameter, R> v) {
    return v.visit(this);
  }
}

sealed class KotlinTypeArgument with Element<KotlinTypeArgument> {
  KotlinTypeArgument();

  factory KotlinTypeArgument.fromJson(Map<String, dynamic> json) =>
      json['type'] == null
          ? KotlinWildcard()
          : KotlinTypeProjection(
              type: KotlinType.fromJson(json['type'] as Map<String, dynamic>),
              variance: $enumDecode(_$KmVarianceEnumMap, json['variance']),
            );

  @override
  R accept<R>(ElementVisitor<KotlinTypeArgument, R> v) {
    return v.visit(this);
  }
}

final class KotlinWildcard extends KotlinTypeArgument {}

final class KotlinTypeProjection extends KotlinTypeArgument {
  KotlinTypeProjection({required this.type, required this.variance});

  final KotlinType type;
  final KmVariance variance;
}

enum Operator {
  plus('+', parameterCount: 1),
  minus('-', parameterCount: 1),
  times('*', parameterCount: 1),
  div('/', parameterCount: 1),
  rem('%', parameterCount: 1),
  get('[]', parameterCount: 1),
  set('[]=', parameterCount: 2, returnsVoid: true);

  final String dartSymbol;

  /// The number of parameters this operator must have in Dart.
  final int parameterCount;

  /// Whether the return type that this operator must have in Dart is void.
  final bool returnsVoid;

  const Operator(
    this.dartSymbol, {
    required this.parameterCount,
    this.returnsVoid = false,
  });

  bool isCompatibleWith(Method method) {
    return parameterCount == method.params.length;
  }
}
