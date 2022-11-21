// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:jnigen/src/elements/elements.dart';
import 'package:jnigen/src/config/config.dart';
import 'package:jnigen/src/logging/logging.dart';

import 'symbol_resolver.dart';
import 'common.dart';

class PureDartBindingsGenerator extends BindingsGenerator {
  static final indent = BindingsGenerator.indent;
  static const accessors = 'jniAccessors';
  static const env = 'jniEnv';

  /// Name for reference in base class.
  static const selfPointer = BindingsGenerator.selfPointer;

  /// Name of field holding class reference.
  static const classRef = '_classRef';

  static const ffi = BindingsGenerator.ffi;
  static const jni = BindingsGenerator.jni;

  static const voidPointer = BindingsGenerator.voidPointer;
  static const ffiVoidType = BindingsGenerator.ffiVoidType;
  static const jniObjectType = BindingsGenerator.jniObjectType;
  static const jobjectType = BindingsGenerator.jobjectType;

  static final _deleteInstruction = BindingsGenerator.deleteInstruction;

  String escapeDollarSign(String s) => s.replaceAll('\$', '\\\$');

  PureDartBindingsGenerator(this.config);
  final Config config;

  @override
  String generateBindings(ClassDecl decl, SymbolResolver resolver) {
    if (!decl.isPreprocessed) {
      throw StateError(
          'Java class declaration ${decl.binaryName} must be preprocessed before'
          'being passed to bindings generator');
    }
    if (!decl.isIncluded) {
      return '';
    }
    final bindings = _class(decl, resolver);
    log.fine('generated bindings for class ${decl.binaryName}');
    return bindings;
  }

  String _class(ClassDecl decl, SymbolResolver resolver) {
    final s = StringBuffer();

    s.write('/// from: ${decl.binaryName}\n');
    s.write(breakDocComment(decl.javadoc, depth: ''));

    final internalName = escapeDollarSign(getInternalName(decl.binaryName));

    s.write(dartClassDefinition(decl, resolver));
    s.write(
        '${indent}static final $classRef = $accessors.getClassOf("$internalName");\n');

    s.write(dartStaticTypeGetter(decl));
    for (var field in decl.fields) {
      if (!field.isIncluded) continue;
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
    s.write(dartTypeClass(decl));
    s.write(dartArrayExtension(decl));
    return s.toString();
  }

  @override
  String toNativeArg(String name, TypeUsage type,
      {bool convertBooleanToInt = false}) {
    return super
        .toNativeArg(name, type, convertBooleanToInt: convertBooleanToInt);
  }

  @override
  String actualArgs(Method m, {bool addSelf = false}) {
    return super.actualArgs(m, addSelf: addSelf);
  }

  String _method(ClassDecl c, Method m, SymbolResolver resolver) {
    final name = m.finalName;
    final isStatic = isStaticMethod(m);
    final ifStatic = isStatic ? 'Static' : '';
    final s = StringBuffer();
    final mID = '_id_$name';
    final jniSignature = escapeDollarSign(getJniSignatureForMethod(m));

    s.write('static final $mID = $accessors.get${ifStatic}MethodIDOf('
        '$classRef, "${m.name}", "$jniSignature");\n');

    // Different logic for constructor and method;
    // For constructor, we want return type to be new object.
    final returnType = getDartOuterType(m.returnType, resolver);
    final returnTypeClass = getDartTypeClass(m.returnType, resolver);
    s.write('$indent/// from: ${getOriginalMethodHeader(m)}\n');
    if (!isPrimitive(m.returnType) || isCtor(m)) {
      s.write(_deleteInstruction);
    }
    s.write(breakDocComment(m.javadoc));
    if (isCtor(m)) {
      final wrapperExpr =
          '$accessors.newObjectWithArgs($classRef, $mID, [${actualArgs(m)}]).object';
      final className = c.finalName;
      final ctorFnName = name == 'ctor' ? className : '$className.$name';
      s.write(
        '$ctorFnName(${getFormalArgs(c, m, resolver)}) : '
        'super.fromRef(${dartSuperArgs(c, resolver)}$wrapperExpr);\n',
      );
      return s.toString();
    }

    s.write(indent);
    if (isStatic) {
      s.write('static ');
    }
    final selfArgument = isStatic ? classRef : selfPointer;
    final callType = getCallType(m.returnType);
    final resultGetter = getResultGetterName(m.returnType);
    final typeParamsWithExtend =
        dartTypeParams(m.typeParams, includeExtends: true);
    var wrapperExpr = '$accessors.call${ifStatic}MethodWithArgs'
        '($selfArgument, $mID, $callType, [${actualArgs(m)}])'
        '.$resultGetter';
    wrapperExpr = toDartResult(wrapperExpr, m.returnType, returnTypeClass);
    s.write(
        '$returnType $name$typeParamsWithExtend(${getFormalArgs(c, m, resolver)}) => $wrapperExpr;\n');
    return s.toString();
  }

  String _field(ClassDecl c, Field f, SymbolResolver resolver) {
    final name = f.finalName;
    final isStatic = isStaticField(f);
    final ifStatic = isStatic ? 'Static' : '';
    final isFinal = isFinalField(f);
    final s = StringBuffer();
    final selfArgument = isStatic ? classRef : selfPointer;
    final callType = getCallType(f.type);
    final resultGetter = getResultGetterName(f.type);
    final outerType = getDartOuterType(f.type, resolver);

    void writeDocs({bool writeDeleteInstruction = true}) {
      s.write('$indent/// from: ${getOriginalFieldDecl(f)}\n');
      if (!isPrimitive(f.type) && writeDeleteInstruction) {
        s.write(_deleteInstruction);
      }
      s.write(breakDocComment(f.javadoc));
    }

    if (isStatic && isFinal && f.defaultValue != null) {
      writeDocs(writeDeleteInstruction: false);
      s.write(
          '${indent}static const $name = ${getDartLiteral(f.defaultValue)};\n');
      return s.toString();
    }
    final jniSignature = escapeDollarSign(getDescriptor(f.type));
    final fID = '_id_$name';
    s.write('static final $fID = '
        '$accessors.get${ifStatic}FieldIDOf(_classRef, '
        '"${f.name}","$jniSignature");\n');
    void writeAccessor({bool setter = false}) {
      writeDocs();
      s.write(indent);
      if (isStatic) s.write('static ');
      if (setter) {
        final fieldType = getTypeNameAtCallSite(f.type);
        s.write('set $name($outerType value) => $env.Set$ifStatic'
            '${fieldType}Field($selfArgument, $fID, '
            '${toNativeArg("value", f.type, convertBooleanToInt: true)});\n');
      } else {
        final outer = getDartOuterType(f.type, resolver);
        final typeClass = getDartTypeClass(f.type, resolver);
        final callExpr =
            '$accessors.get${ifStatic}Field($selfArgument, $fID, $callType)'
            '.$resultGetter';
        final resultExpr = toDartResult(callExpr, f.type, typeClass);
        s.write('$outer get $name => $resultExpr;\n');
      }
    }

    writeAccessor(setter: false);
    if (!isFinalField(f)) writeAccessor(setter: true);
    return s.toString();
  }

  static const autoGeneratedNotice = '// Autogenerated by jnigen. '
      'DO NOT EDIT!\n\n';
  static const defaultLintSuppressions =
      '// ignore_for_file: annotate_overrides\n'
      '// ignore_for_file: camel_case_extensions\n'
      '// ignore_for_file: camel_case_types\n'
      '// ignore_for_file: constant_identifier_names\n'
      '// ignore_for_file: file_names\n'
      '// ignore_for_file: no_leading_underscores_for_local_identifiers\n'
      '// ignore_for_file: non_constant_identifier_names\n'
      '// ignore_for_file: overridden_fields\n'
      '// ignore_for_file: unnecessary_cast\n'
      '// ignore_for_file: unused_element\n'
      '// ignore_for_file: unused_field\n'
      '// ignore_for_file: unused_import\n'
      '// ignore_for_file: unused_shown_name\n'
      '\n';

  static const jniImport = 'import "package:jni/jni.dart" as jni;\n\n';
  static const internalHelpersImport =
      'import "package:jni/internal_helpers_for_jnigen.dart";\n\n';
  static const defaultImports = jniImport + internalHelpersImport;

  static const initialization = 'final jniEnv = ${jni}Jni.env;\n'
      'final jniAccessors = ${jni}Jni.accessors;\n\n';
  static String initImport(String initFilePath) =>
      'import "$initFilePath" show jniEnv, jniAccessors;\n\n';

  @override
  String getPostImportBoilerplate([String? initFilePath]) {
    return (config.outputConfig.dartConfig.structure ==
            OutputStructure.singleFile)
        ? initialization
        : initImport(initFilePath!);
  }

  @override
  String getPreImportBoilerplate([String? initFilePath]) {
    return autoGeneratedNotice + defaultLintSuppressions + defaultImports;
  }

  @override
  String getInitFileContents() {
    return jniImport + initialization;
  }
}
