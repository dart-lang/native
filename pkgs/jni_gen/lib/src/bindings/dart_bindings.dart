// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:jni_gen/src/elements/elements.dart';
import 'package:jni_gen/src/config/config.dart';
import 'package:jni_gen/src/util/rename_conflict.dart';

import 'symbol_resolver.dart';
import 'common.dart';

final _indent = ' ' * 2;

class DartBindingsGenerator {
  // Name for reference in base class.
  static const _self = 'reference';
  // symbol lookup function for generated code.
  static const _jlookup = 'jlookup';

  // import prefixes
  static const ffi = 'ffi.';
  static const jni = 'jni.';

  static const String _voidPtr = '${ffi}Pointer<${ffi}Void>';

  static const String _void = '${ffi}Void';

  static const String _jlObject = '${jni}JlObject';

  DartBindingsGenerator(this.config, this.resolver);
  Config config;
  SymbolResolver resolver;

  String generateBinding(ClassDecl decl) {
    if (!decl.isPreprocessed) {
      throw StateError('Java class declaration must be preprocessed before'
          'being passed to bindings generator');
    }
    if (!decl.isIncluded) {
      return '';
    }
    return _class(decl);
  }

  String _class(ClassDecl decl) {
    final s = StringBuffer();

    s.write('/// from: ${decl.binaryName}\n');
    s.write(_breakDocComment(decl.javadoc, depth: ''));
    final name = _getSimpleName(decl.binaryName);

    var superName = _jlObject;
    if (decl.superclass != null) {
      superName = resolver
              .resolve((decl.superclass!.type as DeclaredType).binaryName) ??
          _jlObject;
    }

    s.write('class $name extends $superName {\n');
    s.write('$_indent$name.fromRef($_voidPtr ref) : '
        'super.fromRef(ref);\n');

    s.writeln();

    for (var field in decl.fields) {
      if (!field.isIncluded) {
        continue;
      }
      try {
        s.write(_field(decl, field));
        s.writeln();
      } on SkipException catch (e) {
        stderr.writeln('skip field ${decl.binaryName}#${field.name}: '
            '${e.message}');
      }
    }

    for (var method in decl.methods) {
      if (!method.isIncluded) {
        continue;
      }
      try {
        s.write(_method(decl, method));
        s.writeln();
      } on SkipException catch (e) {
        stderr.writeln('skip field ${decl.binaryName}#${method.name}: '
            '${e.message}');
      }
    }
    s.write("}\n");
    return s.toString();
  }

  static final _deleteInstruction =
      '$_indent/// The returned object must be deleted after use, '
      'by calling the `delete` method.\n';

  String _method(ClassDecl c, Method m) {
    final name = m.finalName;
    final cName = memberNameInC(c, name);
    final s = StringBuffer();
    final sym = '_$name';
    final ffiSig = dartSigForMethod(m, isFfiSig: true);
    final dartSig = dartSigForMethod(m, isFfiSig: false);
    s.write('${_indent}static final $sym = $_jlookup'
        '<${ffi}NativeFunction<$ffiSig>>("$cName")\n'
        '.asFunction<$dartSig>();\n');
    // Different logic for constructor and method;
    // For constructor, we want return type to be new object.
    final returnType = dartOuterType(m.returnType);
    s.write('$_indent/// from: ${_originalMethodHeader(m)}\n');
    if (!isPrimitive(m.returnType)) {
      s.write(_deleteInstruction);
    }
    s.write(_breakDocComment(m.javadoc));
    s.write(_indent);

    if (isStaticMethod(m)) {
      s.write('static ');
    }

    if (isCtor(m)) {
      final wrapperExpr = '$sym(${_actualArgs(m)})';
      final className = _getSimpleName(c.binaryName);
      final ctorFnName = name == 'ctor' ? className : '$className.$name';
      s.write('$ctorFnName(${_formalArgs(m)}) : '
          'super.fromRef($wrapperExpr);\n');
      return s.toString();
    }

    var wrapperExpr = '$sym(${_actualArgs(m)})';
    wrapperExpr = _toDartResult(wrapperExpr, m.returnType, returnType);
    s.write('$returnType $name(${_formalArgs(m)}) '
        '=> $wrapperExpr;\n');

    return s.toString();
  }

  String _formalArgs(Method m) {
    final List<String> args = [];
    for (var param in m.params) {
      args.add('${dartOuterType(param.type)} ${kwRename(param.name)}');
    }
    return args.join(', ');
  }

  String _actualArgs(Method m) {
    final List<String> args = [if (hasSelfParam(m)) _self];
    for (var param in m.params) {
      final paramName = kwRename(param.name);
      args.add(_toCArg(paramName, param.type));
    }
    return args.join(', ');
  }

  String _field(ClassDecl c, Field f) {
    final name = f.finalName;
    final s = StringBuffer();

    void _writeDocs({bool writeDeleteInstruction = true}) {
      s.write('$_indent/// from: ${_originalFieldDecl(f)}\n');
      if (!isPrimitive(f.type) && writeDeleteInstruction) {
        s.write(_deleteInstruction);
      }
      s.write(_breakDocComment(f.javadoc));
    }

    if (isStaticField(f) && isFinalField(f) && f.defaultValue != null) {
      _writeDocs(writeDeleteInstruction: false);
      s.write('${_indent}static const $name = ${_literal(f.defaultValue)};\n');
      return s.toString();
    }
    final cName = memberNameInC(c, name);

    void writeAccessor({bool isSetter = false}) {
      final symPrefix = isSetter ? 'set' : 'get';
      final sym = '_${symPrefix}_$name';
      final ffiSig = dartSigForField(f, isSetter: isSetter, isFfiSig: true);
      final dartSig = dartSigForField(f, isSetter: isSetter, isFfiSig: false);
      s.write('${_indent}static final $sym = $_jlookup'
          '<${ffi}NativeFunction<$ffiSig>>("${symPrefix}_$cName")\n'
          '.asFunction<$dartSig>();\n');
      // write original type
      _writeDocs();
      s.write(_indent);
      if (isStaticField(f)) s.write('static ');
      if (isSetter) {
        s.write('set $name(${dartOuterType(f.type)} value) => $sym(');
        if (!isStaticField(f)) {
          s.write('$_self, ');
        }
        s.write(_toCArg('value', f.type));
        s.write(');\n');
      } else {
        // getter
        final self = isStaticField(f) ? '' : _self;
        final outer = dartOuterType(f.type);
        final callExpr = '$sym($self)';
        final resultExpr = _toDartResult(callExpr, f.type, outer);
        s.write('$outer get $name => $resultExpr;\n');
      }
    }

    writeAccessor(isSetter: false);
    if (!isFinalField(f)) writeAccessor(isSetter: true);
    return s.toString();
  }

  String _getSimpleName(String binaryName) {
    final components = binaryName.split(".");
    return components.last.replaceAll("\$", "_");
  }

  String dartSigForField(Field f,
      {bool isSetter = false, required bool isFfiSig}) {
    final conv = isFfiSig ? dartFfiType : dartInnerType;
    final voidType = isFfiSig ? _void : 'void';
    final ref = f.modifiers.contains('static') ? '' : '$_voidPtr, ';
    if (isSetter) {
      return '$voidType Function($ref${conv(f.type)})';
    }
    return '${conv(f.type)} Function($ref)';
  }

  String dartSigForMethod(Method m, {required bool isFfiSig}) {
    final conv = isFfiSig ? dartFfiType : dartInnerType;
    final argTypes = [if (hasSelfParam(m)) _voidPtr];
    for (var param in m.params) {
      argTypes.add(conv(param.type));
    }
    final retType = isCtor(m) ? _voidPtr : conv(m.returnType);
    return '$retType Function (${argTypes.join(", ")})';
  }

  // Type for FFI Function signature
  String dartFfiType(TypeUsage t) {
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
        return _voidPtr;
    }
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
          return _jlObject;
        }
        return _voidPtr;
      case Kind.declared:
        if (resolver != null) {
          return resolver.resolve((t.type as DeclaredType).binaryName) ??
              _jlObject;
        }
        return _voidPtr;
    }
  }

  String dartInnerType(TypeUsage t) => _dartType(t);
  String dartOuterType(TypeUsage t) => _dartType(t, resolver: resolver);

  String _literal(dynamic value) {
    if (value is String) {
      // TODO(#31): escape string literal.
      return '"$value"';
    }
    if (value is int || value is double || value is bool) {
      return value.toString();
    }
    throw SkipException('Not a constant of a known type.');
  }

  String _originalFieldDecl(Field f) {
    final declStmt = '${f.type.shorthand} ${f.name}';
    return [...f.modifiers, declStmt].join(' ');
  }

  String _originalMethodHeader(Method m) {
    final args = <String>[];
    for (var p in m.params) {
      args.add('${p.type.shorthand} ${p.name}');
    }
    final declStmt = '${m.returnType.shorthand} ${m.name}'
        '(${args.join(', ')})';
    return [...m.modifiers, declStmt].join(' ');
  }

  String _toCArg(String name, TypeUsage type) {
    if (isPrimitive(type)) {
      return type.name == 'boolean' ? '$name ? 1 : 0' : name;
    }
    return '$name.$_self';
  }

  String _toDartResult(String expr, TypeUsage type, String dartType) {
    if (isPrimitive(type)) {
      return type.name == 'boolean' ? '$expr != 0' : expr;
    }
    return '$dartType.fromRef($expr)';
  }

  static String _breakDocComment(JavaDocComment? javadoc,
      {String depth = '    '}) {
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
}

class DartPreludes {
  static String initFile(String libraryName) => 'import "dart:ffi";\n'
      'import "package:jni/jni.dart";\n'
      '\n'
      'final Pointer<T> Function<T extends NativeType>(String sym) '
      'jlookup = Jni.getInstance().initGeneratedLibrary("$libraryName");\n'
      '\n';
  static const autoGeneratedNotice = '// Autogenerated by jni_gen. '
      'DO NOT EDIT!\n\n';
  static const defaultImports = 'import "dart:ffi" as ffi;\n\n'
      'import "package:jni/jni.dart" as jni;\n\n';
  static const defaultLintSuppressions =
      '// ignore_for_file: camel_case_types\n'
      '// ignore_for_file: non_constant_identifier_names\n'
      '// ignore_for_file: constant_identifier_names\n'
      '// ignore_for_file: annotate_overrides\n'
      '// ignore_for_file: no_leading_underscores_for_local_identifiers\n'
      '// ignore_for_file: unused_element\n'
      '\n';
  static const bindingFileHeaders =
      autoGeneratedNotice + defaultLintSuppressions + defaultImports;
}
