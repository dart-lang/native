// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:jnigen/src/elements/elements.dart';
import 'package:jnigen/src/util/rename_conflict.dart';

import 'symbol_resolver.dart';

/// Base class of both C based and Dart-only binding generators. Implements
/// Many methods used commonly by both of them.
///
/// These methods are in a superclass since they usually require access
/// to resolver, or for consistency with similar methods which require
/// the resolver.
abstract class BindingsGenerator {
  // Name for reference in base class.
  static const selfPointer = 'reference';
  static final indent = ' ' * 2;

  // import prefixes
  static const ffi = 'ffi.';
  static const jni = 'jni.';

  static const String voidPointer = '${ffi}Pointer<${ffi}Void>';

  static const String ffiVoidType = '${ffi}Void';

  static const String jobjectType = '${jni}JObjectPtr';

  static const String jthrowableType = '${jni}JThrowablePtr';

  static const String jniStringType = '${jni}JString';
  static const String jniStringTypeClass = '${jni}JString$typeClassSuffix';

  static const String jniObjectType = '${jni}JObject';
  static const String jniObjectTypeClass = '${jni}JObject$typeClassSuffix';

  static const String jniArrayType = '${jni}JArray';
  static const String jniArrayTypeClass = '${jni}JArray$typeClassSuffix';

  static const String jniCallType = '${jni}JniCallType';

  static const String jniTypeType = '${jni}JObjType';
  static const String typeClassSuffix = 'Type';
  // TODO(#143): this is a temporary fix for the name collision.
  static const String typeClassPrefix = '\$';

  static const String instanceTypeGetter = '\$type';

  static const String typeParamPrefix = '\$';

  static const String jniResultType = '${jni}JniResult';

  /// Generate bindings string for given class declaration.
  String generateBindings(ClassDecl decl, SymbolResolver resolver);

  /// Get common initialization code for bindings.
  ///
  /// if this method returns an empty String, no init file is created.
  String getInitFileContents();

  /// Get boilerplate to be pasted on a file before any imports.
  ///
  /// [initFilePath], if provided, shall point to the _init.dart file where
  /// initialization code is stored. If this is null, the method should provide
  /// standalone boilerplate which doesn't need an init file.
  ///
  /// This method should return an empty string if no such boilerplate is
  /// required.
  String getPreImportBoilerplate([String? initFilePath]);

  /// Get boilerplate to be pasted on a file before any imports.
  ///
  /// See [getPreImportBoilerplate] for an explanation of [initFilePath].
  ///
  /// This method should return an empty String if no such boilerplate is
  /// required.
  String getPostImportBoilerplate([String? initFilePath]);

  /// Returns the formal parameters list of the generated function.
  ///
  /// This is the signature seen by the user.
  String getFormalArgs(ClassDecl c, Method m, SymbolResolver resolver) {
    final List<String> args = [];
    // Prepending the parameters with type parameters
    if (isCtor(m)) {
      for (final typeParam in c.allTypeParams) {
        args.add('this.$typeParamPrefix${typeParam.name}');
      }
    }
    for (final typeParam in m.typeParams) {
      args.add(
          '$jniTypeType<${typeParam.name}> $typeParamPrefix${typeParam.name}');
    }
    for (final param in m.params) {
      args.add(
          '${getDartOuterType(param.type, resolver)} ${kwRename(param.name)}');
    }
    return args.join(', ');
  }

  /// Actual arguments passed to native call.
  String actualArgs(Method m, {bool addSelf = true}) {
    final List<String> args = [if (hasSelfParam(m) && addSelf) selfPointer];
    for (var param in m.params) {
      final paramName = kwRename(param.name);
      args.add(toNativeArg(paramName, param.type));
    }
    return args.join(', ');
  }

  String _dartTypeClassName(String className) {
    return '$typeClassPrefix$className$typeClassSuffix';
  }

  String dartTypeParams(List<TypeParam> typeParams,
      {required bool includeExtends}) {
    if (typeParams.isEmpty) return '';
    // TODO(#144): resolve the actual type being extended, if any.
    final ifExtendsIncluded = includeExtends ? ' extends $jniObjectType' : '';
    final args =
        typeParams.map((e) => '${e.name}$ifExtendsIncluded').join(' ,');
    return '<$args>';
  }

  String dartClassDefinition(ClassDecl decl, SymbolResolver resolver) {
    final name = decl.finalName;
    var superName = jniObjectType;
    if (decl.superclass != null) {
      superName = _dartType(decl.superclass!, resolver: resolver);
    }
    final typeParamsWithExtend =
        dartTypeParams(decl.allTypeParams, includeExtends: true);
    final ifSomeArgs =
        decl.allTypeParams.isNotEmpty ? '(${_typeParamArgs(decl)})' : '';
    return 'class $name$typeParamsWithExtend extends $superName {\n'
        'late final $jniTypeType? _$instanceTypeGetter;\n'
        '@override\n'
        '$jniTypeType get $instanceTypeGetter => '
        '_$instanceTypeGetter ??= type$ifSomeArgs;\n\n'
        '${_typeParamDefs(decl)}\n'
        '$indent$name.fromRef(\n'
        '${_typeParamCtorArgs(decl)}'
        '$jobjectType ref,'
        '): super.fromRef(${dartSuperArgs(decl, resolver)}ref);\n\n';
  }

  String dartSigForField(Field f,
      {bool isSetter = false, required bool isFfiSig}) {
    final ref = f.modifiers.contains('static') ? '' : '$jobjectType, ';
    final conv = isFfiSig ? getDartFfiType : getDartInnerType;
    if (isSetter) {
      return '$jthrowableType Function($ref${conv(f.type)})';
    }
    return '$jniResultType Function($ref)';
  }

  String dartSuperArgs(ClassDecl decl, SymbolResolver resolver) {
    if (decl.superclass == null ||
        resolver.resolve((decl.superclass!.type as DeclaredType).binaryName) ==
            null) {
      return '';
    }
    return (decl.superclass!.type as DeclaredType)
        .params
        .map((param) => '${getDartTypeClass(param, resolver)},')
        .join();
  }

  String dartArrayExtension(ClassDecl decl) {
    final name = decl.finalName;
    final typeParamsWithExtend =
        dartTypeParams(decl.allTypeParams, includeExtends: true);
    final typeParams =
        dartTypeParams(decl.allTypeParams, includeExtends: false);
    final typeClassName = _dartTypeClassName(name);
    return '\nextension \$${name}Array$typeParamsWithExtend on $jniArrayType<$name$typeParams> {\n'
        '$indent$name$typeParams operator [](int index) {\n'
        '${indent * 2}return (elementType as $typeClassName$typeParams)'
        '.fromRef(elementAt(index, ${jni}JniCallType.objectType).object);\n'
        '$indent}\n\n'
        '${indent}void operator []=(int index, $name$typeParams value) {\n'
        '${indent * 2}(this as $jniArrayType<$jniObjectType>)[index] = value;\n'
        '$indent}\n'
        '}\n';
  }

  String _typeParamDefs(ClassDecl decl) {
    return decl.allTypeParams
        .map((e) =>
            '${indent}final $jniTypeType<${e.name}> $typeParamPrefix${e.name};\n')
        .join();
  }

  String _typeParamCtorArgs(ClassDecl decl) {
    return decl.allTypeParams
        .map((e) => '${indent * 2}this.$typeParamPrefix${e.name},\n')
        .join();
  }

  String _typeParamArgs(ClassDecl decl) {
    return decl.allTypeParams.map((e) => '$typeParamPrefix${e.name}, ').join();
  }

  String dartTypeClass(ClassDecl decl) {
    final name = decl.finalName;
    final signature = getSignature(decl.binaryName);
    final typeClassName = _dartTypeClassName(name);
    final typeParamsWithExtend =
        dartTypeParams(decl.allTypeParams, includeExtends: true);
    final typeParams =
        dartTypeParams(decl.allTypeParams, includeExtends: false);

    return '\nclass $typeClassName$typeParamsWithExtend extends $jniTypeType<$name$typeParams> {\n'
        '${_typeParamDefs(decl)}\n'
        '${indent}const $typeClassName(\n'
        '${_typeParamCtorArgs(decl)}'
        '$indent);\n\n'
        '$indent@override\n'
        '${indent}String get signature => r"$signature";\n\n'
        '$indent@override\n'
        '$indent$name$typeParams fromRef($jobjectType ref) => $name.fromRef(${_typeParamArgs(decl)}ref);\n'
        '}\n';
  }

  String dartInitType(ClassDecl decl) {
    final typeClassName = _dartTypeClassName(decl.finalName);
    final args =
        decl.allTypeParams.map((e) => '$typeParamPrefix${e.name},').join();
    return '$instanceTypeGetter = $typeClassName($args)';
  }

  String dartStaticTypeGetter(ClassDecl decl) {
    final typeClassName = _dartTypeClassName(decl.finalName);
    const docs =
        '/// The type which includes information such as the signature of this class.';
    if (decl.allTypeParams.isEmpty) {
      return '$indent$docs\n'
          '${indent}static const type = $typeClassName();\n\n';
    }
    final typeParamsWithExtend =
        dartTypeParams(decl.allTypeParams, includeExtends: true);
    final typeParams =
        dartTypeParams(decl.allTypeParams, includeExtends: false);
    final methodArgs = decl.allTypeParams
        .map((e) =>
            '${indent * 2}$jniTypeType<${e.name}> $typeParamPrefix${e.name},\n')
        .join();
    final ctorArgs = decl.allTypeParams
        .map((e) => '${indent * 3}$typeParamPrefix${e.name},\n')
        .join();
    return '$indent$docs\n'
        '${indent}static $typeClassName$typeParams type$typeParamsWithExtend(\n'
        '$methodArgs'
        '$indent) {\n'
        '${indent * 2}return $typeClassName(\n'
        '$ctorArgs'
        '${indent * 2});\n'
        '$indent}\n\n';
  }

  String dartSigForMethod(Method m, {required bool isFfiSig}) {
    final conv = isFfiSig ? getDartFfiType : getDartInnerType;
    final argTypes = [if (hasSelfParam(m)) voidPointer];
    for (var param in m.params) {
      argTypes.add(conv(param.type));
    }
    return '$jniResultType Function (${argTypes.join(", ")})';
  }

  String _dartType(
    TypeUsage t, {
    SymbolResolver? resolver,
  }) {
    // if resolver == null, looking for inner fn type, type of fn reference
    // else looking for outer fn type, that's what user of the library sees.
    const primitives = {
      'byte': 'int',
      'short': 'int',
      'char': 'int',
      'int': 'int',
      'long': 'int',
      'float': 'double',
      'double': 'double',
      'void': 'void',
      'boolean': 'bool',
    };
    const jniTypes = {
      'byte': 'JByte',
      'short': 'JShort',
      'char': 'JChar',
      'int': 'JInt',
      'long': 'JLong',
      'float': 'JFloat',
      'double': 'JDouble',
      'boolean': 'JBoolean',
    };
    switch (t.kind) {
      case Kind.primitive:
        if (t.name == 'boolean' && resolver == null) return 'int';
        return primitives[(t.type as PrimitiveType).name]!;
      case Kind.typeVariable:
        if (resolver != null) {
          return t.name;
        }
        return voidPointer;
      case Kind.wildcard:
        throw SkipException('Wildcards are not yet supported');
      case Kind.array:
        if (resolver != null) {
          final innerType = (t.type as ArrayType).type;
          final dartType = innerType.kind == Kind.primitive
              ? jni + jniTypes[(innerType.type as PrimitiveType).name]!
              : _dartType(innerType, resolver: resolver);
          return '$jniArrayType<$dartType>';
        }
        return voidPointer;
      case Kind.declared:
        if (resolver != null) {
          final type = t.type as DeclaredType;
          final resolved = resolver.resolve(type.binaryName);
          final resolvedClass = resolver.resolveClass(type.binaryName);
          if (resolved == null ||
              resolvedClass == null ||
              !resolvedClass.isIncluded) {
            return jniObjectType;
          }

          // All type parameters of this type
          final allTypeParams =
              resolvedClass.allTypeParams.map((param) => param.name).toList();

          // The ones that are declared.
          final paramTypeClasses =
              type.params.map((param) => _dartType(param, resolver: resolver));

          // Replacing the declared ones. They come at the end.
          if (allTypeParams.length >= type.params.length) {
            allTypeParams.replaceRange(
              allTypeParams.length - type.params.length,
              allTypeParams.length,
              paramTypeClasses,
            );
          }

          final args = allTypeParams.join(',');
          final ifArgs = args.isNotEmpty ? '<$args>' : '';
          return '$resolved$ifArgs';
        }
        return voidPointer;
    }
  }

  String getDartTypeClass(
    TypeUsage t,
    SymbolResolver resolver,
  ) {
    return _getDartTypeClass(t, resolver, addConst: true).name;
  }

  _TypeClass _getDartTypeClass(
    TypeUsage t,
    SymbolResolver resolver, {
    required bool addConst,
  }) {
    const primitives = {
      'byte': 'JByteType',
      'short': 'JShortType',
      'char': 'JCharType',
      'int': 'JIntType',
      'long': 'JLongType',
      'float': 'JFloatType',
      'double': 'JDoubleType',
      'boolean': 'JBooleanType',
      'void': 'JVoidType', // This will never be in the generated code.
    };
    switch (t.kind) {
      case Kind.primitive:
        final ifConst = addConst ? 'const ' : '';
        return _TypeClass(
          '$ifConst$jni${primitives[(t.type as PrimitiveType).name]}()',
          true,
        );
      case Kind.typeVariable:
        return _TypeClass(
          '$typeParamPrefix${(t.type as TypeVar).name}',
          false,
        );
      case Kind.wildcard:
        throw SkipException('Wildcards are not yet supported');
      case Kind.array:
        final innerType = (t.type as ArrayType).type;
        final innerTypeClass = _getDartTypeClass(
          innerType,
          resolver,
          addConst: false,
        );
        final ifConst = addConst && innerTypeClass.canBeConst ? 'const ' : '';
        return _TypeClass(
          '$ifConst$jniArrayTypeClass(${innerTypeClass.name})',
          innerTypeClass.canBeConst,
        );
      case Kind.declared:
        final type = (t.type as DeclaredType);
        final resolved = resolver.resolve(type.binaryName);
        final resolvedClass = resolver.resolveClass(type.binaryName);

        if (resolved == null ||
            resolvedClass == null ||
            !resolvedClass.isIncluded) {
          return _TypeClass(
            '${addConst ? 'const ' : ''}$jniObjectTypeClass()',
            true,
          );
        }

        // All type params of this type
        final allTypeParams = resolvedClass.allTypeParams
            .map((param) => '$typeParamPrefix${param.name}')
            .toList();

        // The ones that are declared.
        final paramTypeClasses = type.params.map(
            (param) => _getDartTypeClass(param, resolver, addConst: false));

        // Replacing the declared ones. They come at the end.
        if (allTypeParams.length >= type.params.length) {
          allTypeParams.replaceRange(
            allTypeParams.length - type.params.length,
            allTypeParams.length,
            paramTypeClasses.map((param) => param.name),
          );
        }

        final args = allTypeParams.join(',');

        final canBeConst = (allTypeParams.length == paramTypeClasses.length &&
                paramTypeClasses.every((e) => e.canBeConst)) ||
            allTypeParams.isEmpty;
        final ifConst = addConst && canBeConst ? 'const ' : '';

        if (resolved == jniObjectType) {
          return _TypeClass('$ifConst$jniObjectTypeClass()', true);
        } else if (resolved == jniStringType) {
          return _TypeClass('$ifConst$jniStringTypeClass()', true);
        } else if (resolved.contains('.')) {
          // It is in form of jni.SomeClass which should be converted to jni.$SomeClassType
          final dotIndex = resolved.indexOf('.');
          final module = resolved.substring(0, dotIndex);
          final clazz = resolved.substring(dotIndex + 1);
          return _TypeClass(
            '$ifConst$module.${_dartTypeClassName(clazz)}($args)',
            canBeConst,
          );
        }
        return _TypeClass(
          '$ifConst${_dartTypeClassName(resolved)}($args)',
          canBeConst,
        );
    }
  }

  /// Get corresponding Dart FFI type of Java type.
  String getDartFfiType(TypeUsage t) {
    const primitives = {
      'byte': 'Int8',
      'short': 'Int16',
      'char': 'Uint16',
      'int': 'Int32',
      'long': 'Int64',
      'float': 'Float',
      'double': 'Double',
      'void': 'Void',
      'boolean': 'Uint8',
    };
    switch (t.kind) {
      case Kind.primitive:
        return ffi + primitives[(t.type as PrimitiveType).name]!;
      case Kind.wildcard:
        throw SkipException('Wildcards are not yet supported');
      case Kind.typeVariable:
      case Kind.array:
      case Kind.declared:
        return voidPointer;
    }
  }

  String getDartInnerType(TypeUsage t) => _dartType(t);
  String getDartOuterType(TypeUsage t, SymbolResolver resolver) =>
      _dartType(t, resolver: resolver);

  String getDartLiteral(dynamic value) {
    if (value is String) {
      // TODO(#31): escape string literal.
      return '"$value"'.replaceAll('\\', '\\\\');
    }
    if (value is int || value is double || value is bool) {
      return value.toString();
    }
    throw SkipException('Not a constant of a known type.');
  }

  String getJValueAccessor(TypeUsage type) {
    const primitives = {
      'boolean': 'boolean',
      'byte': 'byte',
      'short': 'short',
      'char': 'char',
      'int': 'integer',
      'long': 'long',
      'float': 'float',
      'double': 'doubleFloat',
      'void': 'check()',
    };
    if (isPrimitive(type)) {
      return primitives[type.name]!;
    }
    return 'object';
  }

  String getOriginalFieldDecl(Field f) {
    final declStmt = '${f.type.shorthand} ${f.name}';
    return [...f.modifiers, declStmt].join(' ');
  }

  String getOriginalMethodHeader(Method m) {
    final args = <String>[];
    for (var p in m.params) {
      args.add('${p.type.shorthand} ${p.name}');
    }
    final declStmt = '${m.returnType.shorthand} ${m.name}'
        '(${args.join(', ')})';
    return [...m.modifiers, declStmt].join(' ');
  }

  String toNativeArg(String name, TypeUsage type,
      {bool convertBooleanToInt = true}) {
    if (isPrimitive(type)) {
      return (type.name == 'boolean' && convertBooleanToInt)
          ? '$name ? 1 : 0'
          : name;
    }
    return '$name.$selfPointer';
  }

  String toDartResult(String expr, TypeUsage type, String dartTypeClass) {
    if (isPrimitive(type)) {
      return expr;
    }
    return '$dartTypeClass.fromRef($expr)';
  }

  static final deleteInstruction =
      '$indent/// The returned object must be deleted after use, '
      'by calling the `delete` method.\n';
  String getCallType(TypeUsage returnType) {
    if (isPrimitive(returnType)) {
      return "$jniCallType.${returnType.name}Type";
    }
    return "$jniCallType.objectType";
  }
}

String breakDocComment(JavaDocComment? javadoc, {String depth = '    '}) {
  final link = RegExp('{@link ([^{}]+)}');
  if (javadoc == null) return '';
  final comment = javadoc.comment
      .replaceAllMapped(link, (match) => match.group(1) ?? '')
      .replaceAll('#', '\\#')
      .replaceAll('<p>', '')
      .replaceAll('</p>', '\n')
      .replaceAll('<b>', '__')
      .replaceAll('</b>', '__')
      .replaceAll('<em>', '_')
      .replaceAll('</em>', '_');
  return '$depth///\n'
      '$depth/// ${comment.replaceAll('\n', '\n$depth///')}\n';
}

/// class name canonicalized for C bindings, by replacing "." with "_" and
/// "$" with "__".
String getUniqueClassName(ClassDecl decl) {
  if (!decl.isPreprocessed) {
    throw StateError("class not preprocessed: ${decl.binaryName}");
  }
  return decl.uniqueName;
}

/// Returns the name of the class member as referred to by C bindings
String getMemberNameInC(ClassDecl decl, String name) =>
    "${getUniqueClassName(decl)}__$name";

String getCType(String binaryName) {
  switch (binaryName) {
    case "void":
      return "void";
    case "byte":
      return "int8_t";
    case "char":
      return "char";
    case "double":
      return "double";
    case "float":
      return "float";
    case "int":
      return "int32_t";
    case "long":
      return "int64_t";
    case "short":
      return "int16_t";
    case "boolean":
      return "uint8_t";
    default:
      return "jobject";
  }
}

String getInternalName(String binaryName) {
  switch (binaryName) {
    case "void":
      return "V";
    case "byte":
      return "B";
    case "char":
      return "C";
    case "double":
      return "D";
    case "float":
      return "F";
    case "int":
      return "I";
    case "long":
      return "J";
    case "short":
      return "S";
    case "boolean":
      return "Z";
    default:
      return binaryName.replaceAll(".", "/");
  }
}

String getSignature(String binaryName) {
  switch (binaryName) {
    case "void":
      return "V";
    case "byte":
      return "B";
    case "char":
      return "C";
    case "double":
      return "D";
    case "float":
      return "F";
    case "int":
      return "I";
    case "long":
      return "J";
    case "short":
      return "S";
    case "boolean":
      return "Z";
    default:
      return 'L${binaryName.replaceAll(".", "/")};';
  }
}

String getDescriptor(TypeUsage usage, {bool escapeDollarSign = false}) {
  switch (usage.kind) {
    case Kind.declared:
      return getSignature((usage.type as DeclaredType).binaryName);
    case Kind.primitive:
      return getSignature((usage.type as PrimitiveType).name);
    case Kind.typeVariable:
      // It should be possible to compute the erasure of a type
      // in parser itself.
      // TODO(#23): Use erasure of the type variable here.
      // This is just a (wrong) placeholder
      return "Ljava/lang/Object;";
    case Kind.array:
      final inner = getDescriptor((usage.type as ArrayType).type);
      return "[$inner";
    case Kind.wildcard:
      final extendsBound = (usage.type as Wildcard).extendsBound;
      if (extendsBound != null) {
        return getDescriptor(extendsBound);
      }
      return 'Ljava/lang/Object;';
  }
}

bool isPrimitive(TypeUsage t) => t.kind == Kind.primitive;
bool isVoid(TypeUsage t) => isPrimitive(t) && t.name == 'void';

bool isStaticField(Field f) => f.modifiers.contains('static');
bool isStaticMethod(Method m) => m.modifiers.contains('static');

bool isFinalField(Field f) => f.modifiers.contains('final');
bool isFinalMethod(Method m) => m.modifiers.contains('final');

bool isCtor(Method m) => m.name == '<init>';

// static methods & constructors do not have self param.
bool hasSelfParam(Method m) => !isStaticMethod(m) && !isCtor(m);

bool isObjectField(Field f) => !isPrimitive(f.type);
bool isObjectMethod(Method m) => !isPrimitive(m.returnType);

/// Returns class name as useful in dart.
///
/// Eg -> a.b.X.Y -> X_Y
String getSimplifiedClassName(String binaryName) =>
    binaryName.split('.').last.replaceAll('\$', '_');

// Marker exception when a method or class cannot be translated
// The inner functions may not know how much context has to be skipped in case
// of an error or unknown element. They throw SkipException.
class SkipException implements Exception {
  SkipException(this.message, [this.element]);
  String message;
  dynamic element;

  @override
  String toString() {
    return '$message;';
  }
}

String getTypeNameAtCallSite(TypeUsage t) {
  if (isPrimitive(t)) {
    return t.name.substring(0, 1).toUpperCase() + t.name.substring(1);
  }
  return "Object";
}

String getResultGetterName(TypeUsage returnType) {
  final primitives = {
    'boolean': 'boolean',
    'byte': 'byte',
    'short': 'short',
    'char': 'char',
    'int': 'integer',
    'long': 'long',
    'float': 'float',
    'double': 'doubleFloat',
    'void': 'check()',
  };
  return primitives[returnType.name] ?? 'object';
}

/// Returns the JNI signature of the method.
String getJniSignatureForMethod(Method m) {
  final s = StringBuffer();
  s.write('(');
  for (var param in m.params) {
    final type = getDescriptor(param.type);
    s.write(type);
  }
  s.write(')');
  final returnType = getDescriptor(m.returnType);
  s.write(returnType);
  return s.toString();
}

class _TypeClass {
  final String name;
  final bool canBeConst;

  _TypeClass(this.name, this.canBeConst);
}
