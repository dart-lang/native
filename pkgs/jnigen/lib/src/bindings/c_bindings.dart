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
    s.write('// ${c.binaryName}\n');
    s.write('jclass $classVar = NULL;\n\n');

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
    final methodID = '${methodVarPrefix}_$functionName';
    s.write('jmethodID $methodID = NULL;\n');

    final cMethodName = getMemberNameInC(c, name);
    final cParams = _formalArgs(m);
    s.write('FFI_PLUGIN_EXPORT\n');
    s.write('$jniResultType $cMethodName($cParams) {\n');

    final classVar = '${classVarPrefix}_$classNameInC';
    final jniSignature = getJniSignatureForMethod(m);

    s.write(_loadEnvCall);
    s.write(_loadClassCall(classVar, getInternalName(c.binaryName)));

    final ifStatic = isStatic ? 'static_' : '';
    s.write('${indent}load_${ifStatic}method($classVar, '
        '&$methodID, "${m.name}", "$jniSignature");\n');
    s.write('${indent}if ($methodID == NULL) return $ifError;\n');

    var returnTypeName = m.returnType.name;
    if (isACtor) {
      returnTypeName = c.binaryName;
    }

    s.write(indent);
    if (returnTypeName != 'void') {
      s.write('${getCType(returnTypeName)} _result = ');
    }
    final callType = _typeNameAtCallSite(m.returnType);
    final callArgs = _callArgs(m, classVar, methodID);
    if (isACtor) {
      s.write('(*jniEnv)->NewObject($callArgs);\n');
    } else {
      final ifStatic = isStatic ? 'Static' : '';
      s.write('(*jniEnv)->Call$ifStatic${callType}Method($callArgs);\n');
    }
    s.write(_result(m));
    s.write('}\n');
    return s.toString();
  }

  String _field(ClassDecl c, Field f) {
    final cClassName = getUniqueClassName(c);
    final isStatic = isStaticField(f);
    // If the field is final and default is assigned, then no need to wrap
    // this field. It should then be a constant in dart code.
    if (isStatic && isFinalField(f) && f.defaultValue != null) {
      return "";
    }

    final s = StringBuffer();

    final fieldName = f.finalName;
    final fieldNameInC = getMemberNameInC(c, fieldName);
    final fieldVar = "${fieldVarPrefix}_$fieldNameInC";
    s.write('jfieldID $fieldVar = NULL;\n');
    final classVar = '${classVarPrefix}_$cClassName';

    void writeAccessor({bool isSetter = false}) {
      final prefix = isSetter ? 'set' : 'get';
      s.write('FFI_PLUGIN_EXPORT\n');
      const cReturnType = jniResultType;
      s.write('$cReturnType ${prefix}_$fieldNameInC(');
      final formalArgs = <String>[
        if (!isStatic) 'jobject self_',
        if (isSetter) '${getCType(f.type.name)} value',
      ];
      s.write(formalArgs.join(', '));
      s.write(') {\n');
      s.write(_loadEnvCall);
      s.write(_loadClassCall(classVar, getInternalName(c.binaryName)));

      var ifStatic = isStatic ? 'static_' : '';
      s.write(
          '${indent}load_${ifStatic}field($classVar, &$fieldVar, "$fieldName",'
          '"${_fieldSignature(f)}");\n');

      ifStatic = isStatic ? 'Static' : '';
      final self = isStatic ? classVar : 'self_';
      final callType = _typeNameAtCallSite(f.type);
      if (isSetter) {
        s.write('$indent(*jniEnv)->Set$ifStatic${callType}Field(jniEnv, '
            '$self, $fieldVar, value);\n');
        s.write('${indent}return $ifError;\n');
      } else {
        var getterExpr = '(*jniEnv)->Get$ifStatic${callType}Field(jniEnv, '
            '$self, $fieldVar)';
        if (!isPrimitive(f.type)) {
          getterExpr = 'to_global_ref($getterExpr)';
        }
        final cResultType = getCType(f.type.name);
        s.write('$indent$cResultType _result = $getterExpr;\n');
        final unionField = getJValueField(f.type);
        s.write('${indent}return (JniResult){.result = '
            '{.$unionField = _result}, .exception = check_exception()};\n');
      }
      s.write('}\n\n');
    }

    writeAccessor(isSetter: false);
    if (isFinalField(f)) {
      return s.toString();
    }
    writeAccessor(isSetter: true);
    return s.toString();
  }

  final String _loadEnvCall = '${indent}load_env();\n';

  String _loadClassCall(String classVar, String internalName) {
    return '${indent}load_class_gr(&$classVar, '
        '"$internalName");\n'
        '${indent}if ($classVar == NULL) return $ifError;\n';
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
    return '${indent}return (JniResult){.result = {.$unionField = $valuePart}, .exception = $exceptionPart};\n';
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
