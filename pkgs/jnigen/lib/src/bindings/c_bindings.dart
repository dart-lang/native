// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:jnigen/src/elements/elements.dart';
import 'package:jnigen/src/config/config.dart';

import 'common.dart';

class CBindingGenerator {
  static const classVarPrefix = '_c';
  static const methodVarPrefix = '_m';
  static const fieldVarPrefix = '_f';
  static final indent = ' ' * 4;
  static const jniResultType = 'JniResult';
  static const ifError =
      '(JniResult){.result = {.j = 0}, .exception = check_exception()}';

  // These should be avoided in parameter names.
  static const _cTypeKeywords = {
    'short',
    'char',
    'int',
    'long',
    'float',
    'double',
  };

  String _renameCParam(String paramName) =>
      _cTypeKeywords.contains(paramName) ? '${paramName}0' : paramName;

  CBindingGenerator(this.config);
  Config config;

  String generateBinding(ClassDecl c) => _class(c);

  String _class(ClassDecl c) {
    final s = StringBuffer();
    final classNameInC = getUniqueClassName(c);

    // global variable in C that holds the reference to class
    final classVar = '${classVarPrefix}_$classNameInC';
    s.write('// ${c.binaryName}\n'
        'jclass $classVar = NULL;\n\n');

    for (var m in c.methods) {
      if (!m.isIncluded) {
        continue;
      }
      s.write(_method(c, m));
      s.writeln();
    }

    for (var f in c.fields) {
      if (!f.isIncluded) {
        continue;
      }
      final fieldBinding = _field(c, f);
      s.write(fieldBinding);
      // Fields are skipped if they're static final. In that case
      // do not write too much whitespace.
      if (fieldBinding.isNotEmpty) s.writeln();
    }
    return s.toString();
  }

  String _method(ClassDecl c, Method m) {
    final classNameInC = getUniqueClassName(c);
    final isACtor = isCtor(m);
    final isStatic = isStaticMethod(m);

    final s = StringBuffer();
    final name = m.finalName;
    final functionName = getMemberNameInC(c, name);
    final classRef = '${classVarPrefix}_$classNameInC';
    final methodID = '${methodVarPrefix}_$functionName';
    final cMethodName = getMemberNameInC(c, name);
    final cMethodParams = _formalArgs(m);
    final jniSignature = getJniSignatureForMethod(m);
    final ifStaticMethodID = isStatic ? 'static_' : '';

    var javaReturnType = m.returnType.name;
    if (isACtor) {
      javaReturnType = c.binaryName;
    }
    final callType = _typeNameAtCallSite(m.returnType);
    final callArgs = _callArgs(m, classRef, methodID);

    var ifAssignResult = '';
    if (javaReturnType != 'void') {
      ifAssignResult = '${getCType(javaReturnType)} _result = ';
    }

    final ifStaticCall = isStatic ? 'Static' : '';
    final envMethod =
        isACtor ? 'NewObject' : 'Call$ifStaticCall${callType}Method';
    final returnResultIfAny = _result(m);
    s.write('''
jmethodID $methodID = NULL;
FFI_PLUGIN_EXPORT
$jniResultType $cMethodName($cMethodParams) {
    $_loadEnvCall
    ${_loadClassCall(classRef, getInternalName(c.binaryName))}
    load_${ifStaticMethodID}method($classRef,
      &$methodID, "${m.name}", "$jniSignature");
    if ($methodID == NULL) return $ifError;
    $ifAssignResult(*jniEnv)->$envMethod($callArgs);
    $returnResultIfAny
}\n''');
    return s.toString();
  }

  String _field(ClassDecl c, Field f) {
    final cClassName = getUniqueClassName(c);
    final isStatic = isStaticField(f);

    final fieldName = f.finalName;
    final fieldNameInC = getMemberNameInC(c, fieldName);
    final fieldVar = "${fieldVarPrefix}_$fieldNameInC";

    // If the field is final and default is assigned, then no need to wrap
    // this field. It should then be a constant in dart code.
    if (isStatic && isFinalField(f) && f.defaultValue != null) {
      return "";
    }

    final s = StringBuffer();

    s.write('jfieldID $fieldVar = NULL;\n');

    final classVar = '${classVarPrefix}_$cClassName';
    void writeAccessor({bool isSetter = false}) {
      const cReturnType = jniResultType;
      final cMethodPrefix = isSetter ? 'set' : 'get';
      final formalArgs = <String>[
        if (!isStatic) 'jobject self_',
        if (isSetter) '${getCType(f.type.name)} value',
      ].join(', ');
      final ifStaticField = isStatic ? 'static_' : '';
      final ifStaticCall = isStatic ? 'Static' : '';
      final callType = _typeNameAtCallSite(f.type);
      final objectArgument = isStatic ? classVar : 'self_';

      String accessorStatements;
      if (isSetter) {
        accessorStatements =
            '$indent(*jniEnv)->Set$ifStaticCall${callType}Field(jniEnv, '
            '$objectArgument, $fieldVar, value);\n'
            '${indent}return $ifError;';
      } else {
        var getterExpr = '(*jniEnv)->Get$ifStaticCall${callType}Field(jniEnv, '
            '$objectArgument, $fieldVar)';
        if (!isPrimitive(f.type)) {
          getterExpr = 'to_global_ref($getterExpr)';
        }
        final cResultType = getCType(f.type.name);
        final unionField = getJValueField(f.type);
        accessorStatements = '$indent$cResultType _result = $getterExpr;\n'
            '${indent}return (JniResult){.result = '
            '{.$unionField = _result}, .exception = check_exception()};';
      }

      s.write('''
FFI_PLUGIN_EXPORT
$cReturnType ${cMethodPrefix}_$fieldNameInC($formalArgs) {
    $_loadEnvCall
    ${_loadClassCall(classVar, getInternalName(c.binaryName))}
    load_${ifStaticField}field($classVar, &$fieldVar, "$fieldName",
      "${_fieldSignature(f)}");
$accessorStatements
}\n\n''');
    }

    writeAccessor(isSetter: false);
    if (isFinalField(f)) {
      return s.toString();
    }
    writeAccessor(isSetter: true);
    return s.toString();
  }

  final String _loadEnvCall = '${indent}load_env();';

  String _loadClassCall(String classVar, String internalName) {
    return '${indent}load_class_gr(&$classVar, "$internalName");\n'
        '${indent}if ($classVar == NULL) return $ifError;';
  }

  String _formalArgs(Method m) {
    final args = <String>[];
    if (hasSelfParam(m)) {
      // The underscore-suffixed name prevents accidental collision with
      // parameter named self, if any.
      args.add('jobject self_');
    }

    for (var param in m.params) {
      final paramName = _renameCParam(param.name);
      args.add('${getCType(param.type.name)} $paramName');
    }

    return args.join(", ");
  }

  String getJValueField(TypeUsage type) {
    const primitives = {
      'boolean': 'z',
      'byte': 'b',
      'short': 's',
      'char': 'c',
      'int': 'i',
      'long': 'j',
      'float': 'f',
      'double': 'd',
      'void': 'j', // in case of void return, just write 0 to largest field.
    };
    if (isPrimitive(type)) {
      return primitives[type.name]!;
    }
    return 'l';
  }

  // Returns arguments at call site, concatenated by `,`.
  String _callArgs(Method m, String classVar, String methodVar) {
    final args = ['jniEnv'];
    if (hasSelfParam(m)) {
      args.add('self_');
    } else {
      args.add(classVar);
    }
    args.add(methodVar);
    for (var param in m.params) {
      final paramName = _renameCParam(param.name);
      args.add(paramName);
    }
    return args.join(', ');
  }

  String _result(Method m) {
    final cReturnType = getCType(m.returnType.name);
    String valuePart;
    String unionField;
    if (cReturnType == 'jobject' || isCtor(m)) {
      unionField = 'l';
      valuePart = 'to_global_ref(_result)';
    } else if (cReturnType == 'void') {
      // in case of void return, just write 0 in result part of JniResult
      unionField = 'j';
      valuePart = '0';
    } else {
      unionField = getJValueField(m.returnType);
      valuePart = '_result';
    }
    const exceptionPart = 'check_exception()';
    return '${indent}return (JniResult){.result = {.$unionField = $valuePart}, '
        '.exception = $exceptionPart};';
  }

  String _fieldSignature(Field f) {
    final internalName = getInternalNameOfUsage(f.type);
    if (internalName.length == 1) {
      return internalName;
    }
    return 'L$internalName;';
  }

  /// Returns capitalized java type name to be used as in call${type}Method
  /// or get${type}Field etc..
  String _typeNameAtCallSite(TypeUsage type) {
    if (isPrimitive(type)) {
      return type.name.substring(0, 1).toUpperCase() + type.name.substring(1);
    }
    return "Object";
  }
}

class CPreludes {
  static const autoGeneratedNotice = '// Autogenerated by jnigen. '
      'DO NOT EDIT!\n\n';
  static const includes = '#include <stdint.h>\n'
      '#include "jni.h"\n'
      '#include "dartjni.h"\n'
      '\n';
  static const defines = 'thread_local JNIEnv *jniEnv;\n'
      'JniContext jni;\n\n'
      'JniContext (*context_getter)(void);\n'
      'JNIEnv *(*env_getter)(void);\n'
      '\n';
  static const initializers = 'void setJniGetters(JniContext (*cg)(void),\n'
      '        JNIEnv *(*eg)(void)) {\n'
      '    context_getter = cg;\n'
      '    env_getter = eg;\n'
      '}\n'
      '\n';
  static const prelude =
      autoGeneratedNotice + includes + defines + initializers;
}
