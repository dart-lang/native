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

  static const String jobjectType = '${jni}JObject';

  static const String jthrowableType = '${jni}JThrowable';

  static const String jniObjectType = '${jni}JniObject';

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
  String getFormalArgs(Method m, SymbolResolver resolver) {
    final List<String> args = [];
    for (var param in m.params) {
      args.add(
          '${getDartOuterType(param.type, resolver)} ${kwRename(param.name)}');
    }
    return args.join(', ');
  }

  /// Actual arguments passed to native call.
  String actualArgs(Method m) {
    final List<String> args = [if (hasSelfParam(m)) selfPointer];
    for (var param in m.params) {
      final paramName = kwRename(param.name);
      args.add(toNativeArg(paramName, param.type));
    }
    return args.join(', ');
  }

  String dartSigForField(Field f,
      {bool isSetter = false, required bool isFfiSig}) {
    final conv = isFfiSig ? getDartFfiType : getDartInnerType;
    final ref = f.modifiers.contains('static') ? '' : '$jobjectType, ';
    if (isSetter) {
      return '$jthrowableType Function($ref${conv(f.type)})';
    }
    return '$jniResultType Function($ref)';
  }

  String dartSigForMethod(Method m, {required bool isFfiSig}) {
    final conv = isFfiSig ? getDartFfiType : getDartInnerType;
    final argTypes = [if (hasSelfParam(m)) voidPointer];
    for (var param in m.params) {
      argTypes.add(conv(param.type));
    }
    return '$jniResultType Function (${argTypes.join(", ")})';
  }

  String _dartType(TypeUsage t, {SymbolResolver? resolver}) {
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
    switch (t.kind) {
      case Kind.primitive:
        if (t.name == 'boolean' && resolver == null) return 'int';
        return primitives[(t.type as PrimitiveType).name]!;
      case Kind.typeVariable:
      case Kind.wildcard:
        throw SkipException('Not supported: generics');
      case Kind.array:
        if (resolver != null) {
          return jniObjectType;
        }
        return voidPointer;
      case Kind.declared:
        if (resolver != null) {
          return resolver.resolve((t.type as DeclaredType).binaryName) ??
              jniObjectType;
        }
        return voidPointer;
    }
  }

  // Get corresponding Dart FFI type of Java type.
  String getDartFfiType(TypeUsage t) {
    const primitives = {
      'byte': 'Int8',
      'short': 'Int16',
      'char': 'Int16',
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
      case Kind.typeVariable:
      case Kind.wildcard:
        throw SkipException(
            'Generic type parameters are not supported', t.toJson());
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
      return '"$value"';
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

  String toNativeArg(String name, TypeUsage type) {
    if (isPrimitive(type)) {
      return type.name == 'boolean' ? '$name ? 1 : 0' : name;
    }
    return '$name.$selfPointer';
  }

  String toDartResult(String expr, TypeUsage type, String dartType) {
    if (isPrimitive(type)) {
      return expr;
    }
    return '$dartType.fromRef($expr)';
  }

  static final deleteInstruction =
      '$indent/// The returned object must be deleted after use, '
      'by calling the `delete` method.\n';
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

String getCallType(TypeUsage returnType) {
  if (isPrimitive(returnType)) {
    return "jni.JniType.${returnType.name}Type";
  }
  return "jni.JniType.objectType";
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
