// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:jni_gen/src/elements/elements.dart';
import 'package:jni_gen/src/config/wrapper_options.dart';

import 'common.dart';

// fullName / mangled name =
// binaryName with replace('.', '_'), replace('$', '__');

class CBindingGenerator {
  static const _classVarPrefix = '_c';
  static const _methodVarPrefix = '_m';
  static const _fieldVarPrefix = '_f';
  static const _indent = '    ';

  static const _cTypeKeywords = {
    'short',
    'char',
    'int',
    'long',
    'float',
    'double',
  };

  String _cParamRename(String paramName) =>
      _cTypeKeywords.contains(paramName) ? '${paramName}0' : paramName;

  CBindingGenerator(this.options);
  WrapperOptions options;

  String generateBinding(ClassDecl c) {
    return _class(c);
  }

  String _class(ClassDecl c) {
    final s = StringBuffer();

    final fullName = mangledClassName(c);

    // global variable in C that holds the reference to class
    final classVar = '${_classVarPrefix}_$fullName';
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
    final cClassName = mangledClassName(c);
    final isACtor = isCtor(m);
    final isStatic = isStaticMethod(m);

    final s = StringBuffer();
    final name = m.finalName;

    final methodVar = '${_methodVarPrefix}_${cClassName}_$name';
    s.write('jmethodID $methodVar = NULL;\n');

    final returnType = isCtor(m) ? 'jobject' : m.returnType.name;
    final cReturnType = cType(returnType);
    final cMethodName = '${cClassName}_$name';
    final cParams = _formalArgs(m);
    s.write('FFI_PLUGIN_EXPORT\n');
    s.write('$cReturnType $cMethodName($cParams) {\n');

    final classVar = '${_classVarPrefix}_$cClassName';
    final signature = _signature(m);

    s.write(_loadEnvCall);
    s.write(_loadClassCall(classVar, _internalName(c.binaryName)));

    final ifStatic = isStatic ? 'static_' : '';
    s.write('${_indent}load_${ifStatic}method($classVar, '
        '&$methodVar, "${m.name}", "$signature");\n');

    s.write(_initParams(m));

    var returnTypeName = m.returnType.name;
    if (isACtor) {
      returnTypeName = c.binaryName;
    }

    s.write(_indent);
    if (returnTypeName != 'void') {
      s.write('${cType(returnTypeName)} _result = ');
    }

    final callType = _typeNameAtCallSite(m.returnType);
    final callArgs = _callArgs(m, classVar, methodVar);
    if (isACtor) {
      s.write('(*jniEnv)->NewObject($callArgs);\n');
    } else {
      final ifStatic = isStatic ? 'Static' : '';
      s.write('(*jniEnv)->Call$ifStatic${callType}Method($callArgs);\n');
    }
    s.write(_destroyParams(m));
    if (returnTypeName != 'void') {
      s.write(_result(m));
    }
    s.write('}\n');
    return s.toString();
  }

  String _field(ClassDecl c, Field f) {
    final cClassName = mangledClassName(c);
    final isStatic = isStaticField(f);

    // If the field is final and default is assigned, then no need to wrap
    // this field. It should then be a constant in dart code.
    if (isStatic && isFinalField(f) && f.defaultValue != null) {
      return "";
    }

    final s = StringBuffer();

    final fieldName = f.finalName;
    final fieldVar = "${_fieldVarPrefix}_${cClassName}_$fieldName";

    s.write('jfieldID $fieldVar = NULL;\n');
    final classVar = '${_classVarPrefix}_$cClassName';

    void writeAccessor({bool isSetter = false}) {
      final ct = isSetter ? 'void' : cType(f.type.name);
      // Getter
      final prefix = isSetter ? 'set' : 'get';
      s.write('$ct ${prefix}_${memberNameInC(c, fieldName)}(');
      final formalArgs = <String>[
        if (!isStatic) 'jobject self_',
        if (isSetter) '${cType(f.type.name)} value',
      ];
      s.write(formalArgs.join(', '));
      s.write(') {\n');
      s.write(_loadEnvCall);
      s.write(_loadClassCall(classVar, _internalName(c.binaryName)));

      var ifStatic = isStatic ? 'static_' : '';
      s.write(
          '${_indent}load_${ifStatic}field($classVar, &$fieldVar, "$fieldName",'
          '"${_fieldSignature(f)}");\n');

      ifStatic = isStatic ? 'Static' : '';
      final callType = _typeNameAtCallSite(f.type);
      final acc = isSetter ? 'Set' : 'Get';
      final ret = isSetter ? '' : 'return ';
      final conv = !isSetter && !isPrimitive(f.type) ? 'to_global_ref' : '';
      s.write('$_indent$ret$conv((*jniEnv)->$acc$ifStatic${callType}Field');
      final secondArg = isStatic ? classVar : 'self_';
      s.write('(jniEnv, $secondArg, $fieldVar');
      if (isSetter) {
        s.write(', value');
      }
      s.write('));\n');
      // TODO(#25): Check Exceptions.
      s.write('}\n\n');
    }

    writeAccessor(isSetter: false);
    if (isFinalField(f)) {
      return s.toString();
    }
    writeAccessor(isSetter: true);
    return s.toString();
  }

  final String _loadEnvCall = '${_indent}load_env();\n';

  String _loadClassCall(String classVar, String internalName) {
    return '${_indent}load_class_gr(&$classVar, '
        '"$internalName");\n';
  }

  String _formalArgs(Method m) {
    final args = <String>[];
    if (hasSelfParam(m)) {
      // The underscore-suffixed name prevents accidental collision with
      // parameter named self, if any.
      args.add('jobject self_');
    }

    for (var param in m.params) {
      final paramName = _cParamRename(param.name);
      args.add('${cType(param.type.name)} $paramName');
    }

    return args.join(", ");
  }

  bool _needsTemporaries(String binaryName) {
    // currently no type needs temporaries.
    return false;
  }

  // arguments at call site
  String _callArgs(Method m, String classVar, String methodVar) {
    final args = ['jniEnv'];
    if (hasSelfParam(m)) {
      args.add('self_');
    } else {
      args.add(classVar);
    }
    args.add(methodVar);
    for (var param in m.params) {
      final paramName = _cParamRename(param.name);
      if (_needsTemporaries(param.type.name)) {
        args.add('_$paramName');
      } else {
        args.add(paramName);
      }
    }
    return args.join(', ');
  }

  String _initParams(Method m) {
    // currently no type needs temporaries, but in future we may add
    // some options that require temporaries.
    return '';
  }

  String _destroyParams(Method m) {
    final s = StringBuffer();
    for (var param in m.params) {
      final paramName = _cParamRename(param.name);
      if (_needsTemporaries(param.type.name)) {
        s.write('$_indent(*jniEnv)->DeleteLocalRef(jniEnv, _$paramName);\n');
      }
    }
    return s.toString();
  }

  String _result(Method m) {
    final cReturnType = cType(m.returnType.name);
    if (cReturnType == 'jobject' || isCtor(m)) {
      return '${_indent}return to_global_ref(_result);\n';
    } else {
      return '${_indent}return _result;\n';
    }
  }

  String _fieldSignature(Field f) {
    final iname = _internalNameOf(f.type);
    if (iname.length == 1) {
      return iname;
    }
    return 'L$iname;';
  }

  String _internalName(String binaryName) {
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

  String _internalNameOf(TypeUsage usage) {
    switch (usage.kind) {
      case Kind.declared:
        return _internalName((usage.type as DeclaredType).binaryName);
      case Kind.primitive:
        return _internalName((usage.type as PrimitiveType).name);
      case Kind.typeVariable:
        // It should be possible to compute the erasure of a type
        // in parser itself.
        // TODO(#23): Use erasure of the type variable here.
        // This is just a (wrong) placeholder
        return "java/lang/Object";
      case Kind.array:
        final inner = _internalNameOf((usage.type as ArrayType).type);
        return "[$inner";
      case Kind.wildcard:
        final extendsBound = (usage.type as Wildcard).extendsBound;
        if (extendsBound != null) {
          return _internalNameOf(extendsBound);
        }
        return 'java/lang/Object';
    }
  }

  /// Returns the JNI signature of the method.
  String _signature(Method m) {
    final s = StringBuffer();
    s.write('(');
    for (var param in m.params) {
      final type = _internalNameOf(param.type);
      s.write(type.length == 1 ? type : 'L$type;');
    }
    s.write(')');
    final returnType = _internalNameOf(m.returnType);
    s.write(returnType.length == 1 ? returnType : 'L$returnType;');
    return s.toString();
  }

  // For call<type>Method or get<type>field calls in JNI.
  String _typeNameAtCallSite(TypeUsage t) {
    if (isPrimitive(t)) {
      return t.name.substring(0, 1).toUpperCase() + t.name.substring(1);
    }
    return "Object";
  }
}

class CPreludes {
  static const autoGeneratedNotice = '// Autogenerated by jni_gen. '
      'DO NOT EDIT!\n\n';
  static const includes = '#include <stdint.h>\n'
      '#include "jni.h"\n'
      '#include "dartjni.h"\n'
      '\n';
  static const defines = 'thread_local JNIEnv *jniEnv;\n'
      'struct jni_context jni;\n\n'
      'struct jni_context (*context_getter)(void);\n'
      'JNIEnv *(*env_getter)(void);\n'
      '\n';
  static const initializers =
      'void setJniGetters(struct jni_context (*cg)(void),\n'
      '        JNIEnv *(*eg)(void)) {\n'
      '    context_getter = cg;\n'
      '    env_getter = eg;\n'
      '}\n'
      '\n';
  static const prelude =
      autoGeneratedNotice + includes + defines + initializers;
}
