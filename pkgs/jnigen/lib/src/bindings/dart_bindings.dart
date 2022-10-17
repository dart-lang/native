// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:jnigen/src/elements/elements.dart';
import 'package:jnigen/src/config/config.dart';
import 'package:jnigen/src/logging/logging.dart';

import 'symbol_resolver.dart';
import 'common.dart';

class CBasedDartBindingsGenerator extends BindingsGenerator {
  static const selfPointer = BindingsGenerator.selfPointer;

  /// Symbol lookup function for generated code.
  static const lookup = 'jniLookup';

  // import prefixes
  static const ffi = BindingsGenerator.ffi;
  static const jni = BindingsGenerator.jni;

  static final indent = ' ' * 2;

  static const voidPointer = BindingsGenerator.voidPointer;

  static const ffiVoidType = BindingsGenerator.ffiVoidType;

  static const jniObjectType = BindingsGenerator.jniObjectType;

  CBasedDartBindingsGenerator(this.config);
  Config config;

  @override
  String generateBindings(ClassDecl decl, SymbolResolver resolver) {
    if (!decl.isPreprocessed) {
      throw StateError('Java class declaration must be preprocessed before'
          'being passed to bindings generator');
    }
    if (!decl.isIncluded) {
      return '';
    }
    final bindings = _class(decl, resolver);
    log.finest('generated bindings for class ${decl.binaryName}');
    return bindings;
  }

  String _class(ClassDecl decl, SymbolResolver resolver) {
    final s = StringBuffer();

    s.write('/// from: ${decl.binaryName}\n');
    s.write(breakDocComment(decl.javadoc, depth: ''));
    final name = decl.finalName;

    var superName = jniObjectType;
    if (decl.superclass != null) {
      superName = resolver
              .resolve((decl.superclass!.type as DeclaredType).binaryName) ??
          jniObjectType;
    }

    s.write('class $name extends $superName {\n');
    s.write('$indent$name.fromRef($voidPointer ref) : '
        'super.fromRef(ref);\n');

    s.writeln();

    for (var field in decl.fields) {
      if (!field.isIncluded) {
        continue;
      }
      try {
        s.write(_field(decl, field, resolver));
        s.writeln();
      } on SkipException catch (e) {
        log.fine('skip field ${decl.binaryName}#${field.name}: '
            '${e.message}');
      }
    }

    for (var method in decl.methods) {
      if (!method.isIncluded) {
        continue;
      }
      try {
        s.write(_method(decl, method, resolver));
        s.writeln();
      } on SkipException catch (e) {
        log.fine('skip field ${decl.binaryName}#${method.name}: '
            '${e.message}');
      }
    }
    s.write("}\n");
    return s.toString();
  }

  String _method(ClassDecl c, Method m, SymbolResolver resolver) {
    final name = m.finalName;
    final cName = getMemberNameInC(c, name);
    final s = StringBuffer();
    final sym = '_$name';
    final ffiSig = dartSigForMethod(m, isFfiSig: true);
    final dartSig = dartSigForMethod(m, isFfiSig: false);
    s.write('${indent}static final $sym = $lookup'
        '<${ffi}NativeFunction<$ffiSig>>("$cName")\n'
        '.asFunction<$dartSig>();\n');
    // Different logic for constructor and method;
    // For constructor, we want return type to be new object.
    final returnType = getDartOuterType(m.returnType, resolver);
    s.write('$indent/// from: ${getOriginalMethodHeader(m)}\n');
    if (!isPrimitive(m.returnType)) {
      s.write(BindingsGenerator.deleteInstruction);
    }
    s.write(breakDocComment(m.javadoc));
    s.write(indent);

    if (isStaticMethod(m)) {
      s.write('static ');
    }

    if (isCtor(m)) {
      final wrapperExpr = '$sym(${actualArgs(m)})';
      final className = c.finalName;
      final ctorFnName = name == 'ctor' ? className : '$className.$name';
      s.write('$ctorFnName(${formalArgs(m, resolver)}) : '
          'super.fromRef($wrapperExpr.object);\n');
      return s.toString();
    }

    final resultGetter = getJValueAccessor(m.returnType);
    var wrapperExpr = '$sym(${actualArgs(m)}).$resultGetter';
    wrapperExpr = toDartResult(wrapperExpr, m.returnType, returnType);
    s.write('$returnType $name(${formalArgs(m, resolver)}) => ');
    s.write('$wrapperExpr;\n');
    return s.toString();
  }

  String _field(ClassDecl c, Field f, SymbolResolver resolver) {
    final name = f.finalName;
    final s = StringBuffer();

    void writeDocs({bool writeDeleteInstruction = true}) {
      s.write('$indent/// from: ${getOriginalFieldDecl(f)}\n');
      if (!isPrimitive(f.type) && writeDeleteInstruction) {
        s.write(BindingsGenerator.deleteInstruction);
      }
      s.write(breakDocComment(f.javadoc));
    }

    if (isStaticField(f) && isFinalField(f) && f.defaultValue != null) {
      writeDocs(writeDeleteInstruction: false);
      s.write(
          '${indent}static const $name = ${getDartLiteral(f.defaultValue)};\n');
      return s.toString();
    }
    final cName = getMemberNameInC(c, name);

    void writeAccessor({bool isSetter = false}) {
      final symPrefix = isSetter ? 'set' : 'get';
      final sym = '_${symPrefix}_$name';
      final ffiSig = dartSigForField(f, isSetter: isSetter, isFfiSig: true);
      final dartSig = dartSigForField(f, isSetter: isSetter, isFfiSig: false);
      s.write('${indent}static final $sym = $lookup'
          '<${ffi}NativeFunction<$ffiSig>>("${symPrefix}_$cName")\n'
          '.asFunction<$dartSig>();\n');
      // write original type
      writeDocs();
      s.write(indent);
      if (isStaticField(f)) s.write('static ');
      if (isSetter) {
        s.write(
            'set $name(${getDartOuterType(f.type, resolver)} value) => $sym(');
        if (!isStaticField(f)) {
          s.write('$selfPointer, ');
        }
        s.write(toNativeArg('value', f.type));
        s.write(');\n');
      } else {
        // getter
        final self = isStaticField(f) ? '' : selfPointer;
        final outer = getDartOuterType(f.type, resolver);
        final resultGetter = getJValueAccessor(f.type);
        final callExpr = '$sym($self).$resultGetter';
        final resultExpr = toDartResult(callExpr, f.type, outer);
        s.write('$outer get $name => $resultExpr;\n');
      }
    }

    writeAccessor(isSetter: false);
    if (!isFinalField(f)) writeAccessor(isSetter: true);
    return s.toString();
  }

  static const _importsForInitCode = 'import "dart:ffi" as ffi;\n'
      'import "package:jni/internal_helpers_for_jnigen.dart";\n';

  /// Initialization code for C based bindings.
  ///
  /// Should be called once in a package. In package-structured bindings
  /// this is placed in _init.dart in package root.
  String _initCode() => '// Auto-generated initialization code.\n'
      '\n'
      'final ffi.Pointer<T> Function<T extends ffi.NativeType>(String sym)\n'
      'jniLookup = ProtectedJniExtensions.initGeneratedLibrary'
      '("${config.outputConfig.cConfig.libraryName}");'
      '\n\n';
  static const autoGeneratedNotice = '// Autogenerated by jnigen. '
      'DO NOT EDIT!\n\n';
  static const defaultImports = 'import "dart:ffi" as ffi;\n'
      'import "package:jni/internal_helpers_for_jnigen.dart";\n'
      'import "package:jni/jni.dart" as jni;\n\n';
  static const defaultLintSuppressions =
      '// ignore_for_file: camel_case_types\n'
      '// ignore_for_file: file_names\n'
      '// ignore_for_file: unused_import\n'
      '// ignore_for_file: non_constant_identifier_names\n'
      '// ignore_for_file: constant_identifier_names\n'
      '// ignore_for_file: annotate_overrides\n'
      '// ignore_for_file: no_leading_underscores_for_local_identifiers\n'
      '// ignore_for_file: unused_element\n'
      '\n';
  static const preImportBoilerplate =
      autoGeneratedNotice + defaultLintSuppressions + defaultImports;

  @override
  String getPostImportBoilerplate([String? initFilePath]) {
    if (config.outputConfig.dartConfig.structure ==
        OutputStructure.singleFile) {
      return _initCode();
    } else {
      return 'import "${initFilePath!}" show jniLookup;\n\n';
    }
  }

  @override
  String getPreImportBoilerplate([String? initFilePath]) {
    return preImportBoilerplate;
  }

  @override
  String getInitFileContents() {
    return '$_importsForInitCode\n${_initCode()}';
  }
}
